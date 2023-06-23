# coding: utf-8
#
# This file is part of harbour-captains-log.
# SPDX-FileCopyrightText: 2020 Gabriel Berkigt
# SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#

import os
import sqlite3
import re
import unicodedata
import shutil
import glob
import traceback
import tempfile
from typing import Dict
from typing import Callable
from dataclasses import dataclass
from pathlib import Path
from datetime import datetime
from datetime import timedelta

try:
    import pyotherside
    HAVE_SIDE = True
except ImportError:
    HAVE_SIDE = False

    class pyotherside:
        def send(*args, **kwargs):
            print(f"pyotherside.send: {args} {kwargs}")

    @dataclass
    class StandardPaths:
        home: Path = Path('./db/home').resolve()
        data: Path = Path('./db/data').resolve()


#
# BEGIN Database
#

DIARY: 'Diary' = None
INITIALIZED: bool = False  # TODO actually check this value everywhere


class Diary:
    DB_DATA_FILE_PRE_SAILJAIL: str = 'logbuch.db'
    DB_VERSION_FILE_PRE_SAILJAIL: str = 'schema_version'

    DB_DATA_FILE_PRE_V8: str = 'logbook.db'
    DB_VERSION_FILE_PRE_V8: str = 'schema_version'

    DB_DATA_FILE_V8_GLOB: str = r'diary-v[0-9][0-9][0-9].db'
    DB_DATA_FILE_V8_FORMAT: str = r'diary-v{version:03d}.db'
    DB_DATA_FILE_V8_RE: re.Pattern = re.compile(r'(?P<path>.*)/(?P<dbfile>diary-v(?P<version>[0-9]{3}).db)$')

    DB_BACKUP_DIR: str = 'backups'

    def __init__(self, standard_paths):
        self.ready = False
        self._standard_paths = standard_paths

        self.home_path: str = ''
        self.data_path: str = ''

        for i in ['home', 'data']:
            path = getattr(standard_paths, i, None)

            if path:
                setattr(self, f'{i}_path', Path(path))
            else:
                pyotherside.send('error', 'path-unavailable',
                                 {'kind': i, 'obj': standard_paths})
                self.ready = False
                return

        try:
            print(f"using local data at {self.data_path}")
            Path(self.data_path).mkdir(parents=True, exist_ok=True)
        except FileExistsError:
            pyotherside.send('error', 'local-data-inaccessible')
            self.ready = False
            return

        latest_db = self._get_active_db_path()

        if latest_db is None:
            pyotherside.send('error', 'database-unavailable')
            self.ready = False
            return

        try:
            latest_db = self._update_schema(latest_db)
        except Exception as ex:
            trace = '\n'.join([
                ''.join(traceback.format_exception_only(None, ex)).strip(),
                ''.join(traceback.format_exception(None, ex, ex.__traceback__)).strip()
            ])

            pyotherside.send('error', 'database-update-failed',
                             {'database': latest_db, 'exception': trace})

        if not latest_db:
            # notification has been sent in _update_schema
            self.ready = False
            return

        print(f"using database at {latest_db}")
        self.db_path = latest_db
        self.conn = sqlite3.connect(self.db_path)
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()
        self.ready = True

    def _get_active_db_path(self) -> [str, None]:
        back = Path('.').resolve()
        os.chdir(self.data_path)
        candidates = sorted(glob.glob(self.DB_DATA_FILE_V8_GLOB), reverse=True)
        os.chdir(str(back))

        if candidates:
            return str(Path(self.data_path / candidates[0]).absolute())
        elif Path(self.data_path / self.DB_DATA_FILE_PRE_V8).is_file():
            if ok := self._migrate_files_single_file():
                return self._get_active_db_path()
            elif ok is False:
                return None
            else:
                return ''
        elif ok := self._migrate_files_sailjail():
            return self._get_active_db_path()
        elif ok is False:
            return None

        return ''

    def _migrate_files_sailjail(self) -> [bool, None]:
        # return True on success, False on failure, and None if there was nothing to migrate
        old_dir: Path = self.home_path / '.local/share/harbour-captains-log'
        new_dir: Path = self.data_path

        old_db = old_dir / self.DB_DATA_FILE_PRE_SAILJAIL
        new_db = new_dir / self.DB_DATA_FILE_PRE_V8

        old_version = old_dir / self.DB_VERSION_FILE_PRE_SAILJAIL
        new_version = new_dir / self.DB_VERSION_FILE_PRE_V8

        if (old_db.exists() and not new_db.exists()) and \
                (old_version.exists() and not new_version.exists()):
            try:
                print(f"migrating {old_db} to {new_db}...")
                shutil.copy(str(old_db.absolute()), str(new_db.absolute()))
                print(f"migrating {old_version} to {new_version}...")
                shutil.copy(str(old_version.absolute()), str(new_version.absolute()))

                self.move_aside(old_db)
                self.move_aside(old_version)
                return True
            except Exception:
                pyotherside.send('error', 'sailjail-migration-failed',
                                 {'source': str(old_dir), 'dest': str(new_dir)})
                return False

        return None

    def _migrate_files_single_file(self) -> [bool, None]:
        # return True on success, False on failure, and None if there was nothing to migrate

        # don't resolve symlinks here
        old_version_file: Path = Path(self.data_path / self.DB_VERSION_FILE_PRE_V8).absolute()
        old_db_file: Path = Path(self.data_path / self.DB_DATA_FILE_PRE_V8).absolute()

        if not old_db_file.exists() and old_version_file.exists():
            self.move_aside(old_version_file)

        if old_version_file.is_file():
            with open(str(old_version_file), 'r') as f:
                old_schema_version = f.readline().strip()
        else:
            old_schema_version = "none"

        if old_db_file.is_file():
            if old_schema_version == "none":
                pyotherside.send('error', 'schema-file-missing', {'path': str(old_version_file)})
                return False
            else:
                new_db_file: Path = Path(
                    self.data_path / self.DB_DATA_FILE_V8_FORMAT.format(
                        version=int(old_schema_version)))

                if new_db_file.exists():
                    self.move_aside(new_db_file)

                print(f"migrating {old_db_file} with {old_version_file} to {new_db_file}")
                shutil.move(str(old_db_file), str(new_db_file))
                old_version_file.unlink()
                return True

        return None

    def _get_update_db(self, from_version: int, source_db: str):
        updating = sqlite3.connect(':memory:')
        updating.row_factory = sqlite3.Row

        if from_version < 0:
            return updating
        elif not source_db or not Path(source_db).is_file():
            raise RuntimeError(f'bug: source_db parameter must be an existing file, got {source_db}')
        else:
            source = sqlite3.connect(source_db)

            with updating:
                source.backup(updating)

            source.close()

        return updating

    def _db_update_to_0(self, conn: sqlite3.Connection):
        conn.execute("""CREATE TABLE IF NOT EXISTS diary(
            creation_date TEXT NOT NULL,
            modify_date TEXT NOT NULL,
            mood INT,
            title TEXT,
            preview TEXT,
            entry TEXT,
            favorite BOOL,
            hashtags TEXT
        );""")

    def _db_update_to_1(self, conn: sqlite3.Connection):
        # add new mood 'not okay' with index 3, moving 3 to 4, and 4 to 5
        conn.execute("""UPDATE diary SET mood=5 WHERE mood=4""")
        conn.execute("""UPDATE diary SET mood=4 WHERE mood=3""")

    def _db_update_to_2(self, conn: sqlite3.Connection):
        # add columns to store time zone info
        conn.execute("""ALTER TABLE diary ADD COLUMN creation_tz TEXT DEFAULT '';""")
        conn.execute("""ALTER TABLE diary ADD COLUMN modify_tz TEXT DEFAULT '';""")

        # add column to store an audio file path (not yet used)
        conn.execute("""ALTER TABLE diary ADD COLUMN audio_path TEXT DEFAULT '';""")

    def _db_update_to_3(self, conn: sqlite3.Connection):
        # rename and reorder columns: creation_date -> create_date and creation_tz -> create_tz
        conn.execute("""CREATE TABLE IF NOT EXISTS diary_temp(
            create_date TEXT NOT NULL,
            create_tz TEXT,
            modify_date TEXT NOT NULL,
            modify_tz TEXT,
            mood INT,
            title TEXT,
            preview TEXT,
            entry TEXT,
            favorite BOOL,
            hashtags TEXT,
            audio_path TEXT
        );""")
        conn.execute("""INSERT INTO diary_temp(
                create_date, create_tz, modify_date, modify_tz,
                mood, title, preview, entry, favorite, hashtags, audio_path)
            SELECT creation_date, creation_tz, modify_date, modify_tz, mood,
                title, preview, entry, favorite, hashtags, audio_path
            FROM diary;""")
        conn.execute("""DROP TABLE diary;""")
        conn.execute("""ALTER TABLE diary_temp RENAME TO diary;""")

    def _db_update_to_4(self, conn: sqlite3.Connection):
        conn.create_function(
            "REWRITE_DATE", 1, self._reformat_date_pre_db4, deterministic=True)

        # rewrite all dates to use a standard format
        conn.execute("""UPDATE diary SET create_date=REWRITE_DATE(create_date);""")
        conn.execute("""UPDATE diary SET modify_date=REWRITE_DATE(modify_date);""")

    def _db_update_to_5(self, conn: sqlite3.Connection):
        # rename column 'favorite' to 'bookmark'
        conn.execute("""CREATE TABLE IF NOT EXISTS diary_temp(
            create_date TEXT NOT NULL, create_tz TEXT, modify_date TEXT NOT NULL, modify_tz TEXT,
            mood INT, title TEXT, preview TEXT, entry TEXT,
            bookmark BOOL,
            hashtags TEXT, audio_path TEXT);""")
        conn.execute("""INSERT INTO diary_temp(
                create_date, create_tz, modify_date, modify_tz,
                mood, title, preview, entry, bookmark, hashtags, audio_path)
            SELECT create_date, create_tz, modify_date, modify_tz, mood, title,
                preview, entry, favorite, hashtags, audio_path
            FROM diary;""")
        conn.execute("""DROP TABLE diary;""")
        conn.execute("""ALTER TABLE diary_temp RENAME TO diary;""")

    def _db_update_to_6(self, conn: sqlite3.Connection):
        # 1. rename columns:
        # - hashtags    -> tags
        # - audio_path  -> attachments_id
        #
        # 2. add columns:
        # - create_order
        # - entry_order
        # - entry_addenda_day
        # - entry_addenda_seq
        # - entry_date
        # - entry_tz
        # - entry_normalized
        #
        # 3. rewrite columns:
        # - preview
        #
        # 4. reorder columns
        # 5. add default values

        conn.create_function(
            "REWRITE_PREVIEW", 1, self._format_preview, deterministic=True)
        conn.create_function(
            "REWRITE_NORMALIZED", -1, self.normalize_text, deterministic=True)
        conn.create_function(
            "REWRITE_NORMALIZED_TAGS", 1,
            lambda x: self.normalize_text(x, keep=[',']),
            deterministic=True)
        conn.execute("""DROP TABLE IF EXISTS diary_temp;""")
        conn.execute("""CREATE TABLE IF NOT EXISTS diary_temp(
            create_order INTEGER NOT NULL,
            entry_order INTEGER NOT NULL,
            entry_addenda_day INTEGER NOT NULL,
            entry_addenda_seq INTEGER NOT NULL,
            create_date TEXT NOT NULL, create_tz TEXT DEFAULT '',
            entry_date TEXT NOT NULL, entry_tz TEXT DEFAULT '',
            modify_date TEXT NOT NULL, modify_tz TEXT DEFAULT '',
            title TEXT DEFAULT '', entry TEXT DEFAULT '',
            entry_normalized TEXT DEFAULT '', preview TEXT DEFAULT '',
            tags TEXT DEFAULT '', tags_normalized TEXT DEFAULT '',
            mood INTEGER, bookmark BOOLEAN,
            attachments_id TEXT DEFAULT ''
        );""")
        conn.execute("""INSERT INTO diary_temp(
                create_order, entry_order,
                entry_addenda_day, entry_addenda_seq,
                create_date, create_tz,
                entry_date, entry_tz,
                modify_date, modify_tz,
                title, entry,
                entry_normalized, preview,
                tags, tags_normalized,
                mood, bookmark,
                attachments_id
            ) SELECT rowid, rowid,
                0, 0,
                create_date, create_tz,
                create_date, create_tz,
                modify_date, IFNULL(modify_tz, ''),
                title, entry,
                REWRITE_NORMALIZED(title, entry), REWRITE_PREVIEW(entry),
                hashtags, REWRITE_NORMALIZED_TAGS(hashtags),
                mood, bookmark,
                IFNULL(audio_path, '')
            FROM diary;
        """)
        conn.execute("""DROP TABLE diary;""")
        conn.execute("""ALTER TABLE diary_temp RENAME TO diary;""")

    def _db_update_to_7(self, conn: sqlite3.Connection):
        conn.create_function(
            "REWRITE_SECONDS", 1, self._reformat_date_seconds, deterministic=True)

        # fix timestamps with an invalid seconds field
        conn.execute("""UPDATE diary SET
            create_date=REWRITE_SECONDS(create_date),
            modify_date=REWRITE_SECONDS(modify_date),
            entry_date=REWRITE_SECONDS(entry_date)
        ;""")

    def _db_update_to_8(self, conn: sqlite3.Connection):
        # 1. make sure no content field is NULL
        # 2. make sure bookmarks are explicitly set to 0 or 1
        # 3. update normalized texts because they could contain the string
        #    "none" if a field was NULL before

        for i in ["title", "entry", "tags"]:
            conn.execute(f"UPDATE diary SET {i}='' WHERE {i} IS NULL;")

        conn.execute("UPDATE diary SET bookmark=0 WHERE bookmark IS NULL;")

        conn.create_function(
            "REWRITE_NORMALIZED", -1, self.normalize_text, deterministic=True)
        conn.create_function(
            "REWRITE_NORMALIZED_TAGS", 1,
            lambda x: self.normalize_text(x, keep=[',']),
            deterministic=True)
        conn.execute("""UPDATE diary SET entry_normalized=REWRITE_NORMALIZED(entry);""")
        conn.execute("""UPDATE diary SET tags_normalized=REWRITE_NORMALIZED_TAGS(tags);""")

    def _db_final(self, conn: sqlite3.Connection):
        pass  # this is a no-op method to mark the end of the update chain

    def _update_schema(self, source_db: str):
        UPDATE_FUNCTIONS: Dict[int, Callable[[sqlite3.Connection], None]] = {
            -1: self._db_update_to_0,
            0: self._db_update_to_1,
            1: self._db_update_to_2,
            2: self._db_update_to_3,
            3: self._db_update_to_4,
            4: self._db_update_to_5,
            5: self._db_update_to_6,
            6: self._db_update_to_7,
            7: self._db_update_to_8,
            8: self._db_final,
        }

        if not source_db:
            print(f"creating new database in {self.data_path}")
            from_version = -1
        else:
            print(f"updating database {source_db}")
            from_version = int(self.DB_DATA_FILE_V8_RE.match(source_db).group('version'))

        updating = self._get_update_db(from_version, source_db)

        if from_version not in UPDATE_FUNCTIONS:
            pyotherside.send('error', 'unknown-database-version',
                             {'got': from_version, 'latest': list(UPDATE_FUNCTIONS.keys())[-1]})
            print(f"error: cannot use database with unknown schema version '{from_version}'")
            return ''
        else:
            update_path = {k: v for k, v in UPDATE_FUNCTIONS.items() if k >= from_version}

        for key, updater in update_path.items():
            print(f"updating database from version {key}...")
            current_version = key

            if updater == self._db_final:
                break  # reached the end of the update chain

            with updating:
                updater(updating)

        if current_version != from_version:
            print(f"database has been updated to version {current_version}")

            with updating:
                updating.execute('VACUUM')

            fd, tempfile_path = tempfile.mkstemp(prefix=f'update_{current_version:03d}_', suffix='.db', dir=self.data_path)
            os.close(fd)
            temp_db = sqlite3.connect(tempfile_path)

            with temp_db:
                updating.backup(temp_db)

            # save updated db as current db
            temp_db.close()
            updating.close()
            final_db = self.data_path / self.DB_DATA_FILE_V8_FORMAT.format(version=current_version)
            self.move_aside(final_db)
            shutil.move(str(tempfile_path), str(final_db))

            # move source db to backups folder
            today = datetime.now().strftime("%Y-%m-%d")
            backup_path = Path(self.data_path / self.DB_BACKUP_DIR / Path(source_db).name)
            backup_path = backup_path.with_stem(f'{today} - {backup_path.stem}')
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            self.move_aside(backup_path)
            shutil.move(str(source_db), str(backup_path))
        else:
            print(f"database schema is up-to-date (version: {current_version})")
            final_db = source_db

        updating.close()
        return final_db

    @staticmethod
    def _reformat_date_pre_db4(old_date_string):
        """Reformat old date strings (prior db version 4) to the new format.

        New date format: 'yyyy-MM-dd hh:mm:ss'.
        Old date format: 'd.M.yyyy | h:m:s' (with ':s' being optional).
        - Each field was padded with 0 to be two characters long (not enforced).
        """

        if not old_date_string:
            return ""

        reg = re.compile(r"^(\d{1,2}\.){2}\d{4} \| \d{1,2}:\d{1,2}(:\d{1,2})?$")
        if reg.search(old_date_string) is None:
            print("warning: could not convert invalid date '{}'".format(old_date_string))
            return ""

        date_time = old_date_string.split(' | ')  # "10.12.2009 | 10:00:01" -> ("1.10.2010", "10:0:01")
        date = date_time[0].split('.')  # "1.10.2010" -> ("1", "10", "2010")
        time = date_time[1].split(':')  # "10:0:01" -> ("10", "0", "01")
        sec = time[2] if len(time) >= 3 else "0"

        new_string = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}".format(
            int(date[2]), int(date[1]), int(date[0]), int(time[0]), int(time[1]), int(sec))

        print("{} -> {}".format(old_date_string, new_string))
        return new_string

    @staticmethod
    def _reformat_date_seconds(date_string):
        if date_string[16:] == ':60':
            date_format = '%Y-%m-%d %H:%M:%S'
            old_date = datetime.strptime(f'{date_string[:16]}:59', date_format)
            new_date = old_date + timedelta(seconds=1)

            if old_date.day != new_date.day:
                # It is probably safer to change the seconds than to change the day.
                return old_date.strftime(date_format)

            return new_date.strftime(date_format)

        return date_string

    @staticmethod
    def _format_date(date_string, tz_string):
        zone = " [{}]".format(tz_string) if tz_string else ""

        if not date_string:
            date_string = "never{tz}".format(tz=zone)

        return date_string

    @staticmethod
    def _format_preview(entry):
        return re.sub(r'[ \t]+', ' ', re.sub(r'[\n]+', '\n', (entry or '').strip()))[:300]

    @staticmethod
    def _normalize_text(*args, keep=[]):
        return Diary.normalize_text(*args, keep)

    @staticmethod
    def normalize_text(*args, keep=[]):
        punctutation_cats = set(['Pc', 'Pd', 'Ps', 'Pe', 'Pi', 'Pf', 'Po'])
        joined = ' '.join((re.sub(r'\s+', ' ', str(x).strip()) for x in args)).strip()

        return ''.join(x for x in unicodedata.normalize('NFKD', joined)
                       if not unicodedata.combining(x)
                       and (unicodedata.category(x) not in punctutation_cats
                            or x in keep)).lower()

    @staticmethod
    def move_aside(path):
        turn = 0

        if not Path(path).exists():
            return

        while True:
            bak = str(path) + '.bak' + (f'~{turn}~' if turn > 0 else '')

            if Path(bak).exists():
                turn += 1
            else:
                shutil.move(str(path), bak)
                break

# END


#
# BEGIN Database Functions
#

def initialize(standard_paths):
    if is_initialized(False):
        pyotherside.send('warning', 'database-already-initialized')
        return True

    global DIARY
    global INITIALIZED

    DIARY = Diary(standard_paths)

    if DIARY.ready:
        INITIALIZED = True
        return True

    return False


def is_initialized(notify: bool = True) -> bool:
    global DIARY
    global INITIALIZED

    if not DIARY or not INITIALIZED:
        if notify:
            pyotherside.send('error', 'database-not-ready')

        return False

    return True


def backup_database():
    if not is_initialized():
        return

    def progress(status, remaining, total):
        pyotherside.send('backup-progress', {
            'status': 'working', 'done': total - remaining,
            'remaining': remaining, 'total': total
        })

    try:
        today = datetime.now().strftime("%Y-%m-%d")
        backup_path = Path(DIARY.data_path / DIARY.DB_BACKUP_DIR / Path(DIARY.db_path).name)
        backup_path = backup_path.with_stem(f'{today} - {backup_path.stem}')
        backup_path.parent.mkdir(parents=True, exist_ok=True)

        fd, tempfile_path = tempfile.mkstemp(prefix=f'backup_{today}_', suffix='.db', dir=backup_path.parent)
        os.close(fd)
        temp_db = sqlite3.connect(tempfile_path)

        with temp_db:
            DIARY.conn.backup(temp_db, pages=25, progress=progress)

        temp_db.close()
        Diary.move_aside(backup_path)
        shutil.move(str(tempfile_path), str(backup_path))

        print(f'backed up {DIARY.db_path} to {backup_path}')
    except Exception as e:
        trace = '\n'.join([
            ''.join(traceback.format_exception_only(None, e)).strip(),
            ''.join(traceback.format_exception(None, e, e.__traceback__)).strip()
        ])

        pyotherside.send('backup-progress', {
            'status': 'failed', 'database': DIARY.db_path,
            'backup': backup_path, 'exception': trace})


def normalize_text(string):
    return Diary.normalize_text(string)


_FIELD_DEFAULTS = {
    'rowid': (-1, lambda x: x if x is not None else -1),
    'create_order': (0, lambda x: x or 0),
    'entry_order': (0, lambda x: x or 0),
    'entry_addenda_day': (0, lambda x: x or 0),
    'entry_addenda_seq': (0, lambda x: x or 0),
    'create_date': ('', lambda x: x or ''),
    'create_tz': ('', lambda x: x or ''),
    'entry_date': ('', lambda x: x or ''),
    'entry_tz': ('', lambda x: x or ''),
    'modify_date': ('', lambda x: x or ''),
    'modify_tz': ('', lambda x: x or ''),
    'title': ('', lambda x: x.strip() if x else ''),
    'entry': ('', lambda x: x.strip() if x else ''),
    'entry_normalized': ('', lambda x: x.strip() if x else ''),
    'preview': ('', lambda x: x.strip() if x else ''),
    'tags': ('', lambda x: x.strip() if x else ''),
    'tags_normalized': ('', lambda x: x.strip() if x else ''),
    'mood': (2, lambda x: x if x is not None else 2),
    'bookmark': (False, lambda x: True if x == 1 else False),
    'attachments_id': (0, lambda x: x or ''),
}

_GENERATED_FIELDS = {
    'day': lambda row, keys: row['entry_date'].split(' ')[0] if 'entry_date' in keys else '',
    'is_addendum': lambda row, keys: row['entry_addenda_seq'] > 0,
}


def _clean_entry_row(row):
    row_keys = row.keys()

    entry = {k: _FIELD_DEFAULTS[k][1](row[k]) if k in row_keys else _FIELD_DEFAULTS[k][0]
             for k, v in _FIELD_DEFAULTS.items()}

    for key, gen in _GENERATED_FIELDS.items():
        entry[key] = gen(row, row_keys)

    return entry


def get_tags():
    """ Load all tags and ship them to QML """
    if not is_initialized():
        return

    DIARY.cursor.execute("""
        SELECT TRIM(tags, " ") FROM diary
        WHERE tags IS NOT NULL AND TRIM(tags, " ") != "";
    """)
    rows = DIARY.cursor.fetchall()

    clean_tags = []

    for row in rows:
        tags = [{'text': x.strip(), 'normalized': Diary.normalize_text(x)}
                for x in row[0].split(',') if x.strip()]

        if tags:
            clean_tags += tags

    unique_tags = list({x['text']: x for x in clean_tags}.values())
    pyotherside.send('tags', unique_tags)


def get_entries():
    """ Load all entries and ship them to QML """
    if not is_initialized():
        return

    DIARY.cursor.execute("""
        SELECT *, rowid FROM diary
        ORDER BY entry_order DESC,
                 entry_addenda_day DESC,
                 entry_addenda_seq DESC;""")
    rows = DIARY.cursor.fetchall()

    batch = []

    for i, row in enumerate(rows, 1):
        batch.append(_clean_entry_row(row))

        if i % 20 == 0:
            pyotherside.send('entries', batch)
            batch = []

    pyotherside.send('entries', batch)

    get_tags()


def _is_db_empty():
    # expects the db to be ready and initialized
    DIARY.cursor.execute("""SELECT create_order FROM diary LIMIT 1;""")
    return DIARY.cursor.fetchone() is None


def add_entry(create_date, create_tz, entry_date, entry_tz,
              mood, title, entry, tags):
    """ Add a new entry to the database. """
    if not is_initialized():
        return

    DIARY.cursor.execute("""SELECT IFNULL(MAX(create_order), 0) + 1 FROM diary;""")
    row = DIARY.cursor.fetchone()
    create_order = row[0]

    if not _is_db_empty() \
            and create_date != entry_date \
            and create_date.split(' ')[0] != entry_date.split(' ')[0]:
        # assumptions:
        # - both dates are valid and properly formatted (yyyy-mm-dd hh:mm:ss)
        # - create_date is today
        # - entry_date is in the past
        # -> add an addendum to the day of entry_date

        DIARY.cursor.execute("""
            SELECT entry_order,
                   entry_addenda_day + (ABS(strftime("%s", date(entry_date))
                                           - strftime("%s", date(?)))
                                        / 86400) as new_day,
                   entry_addenda_seq + 1 as new_seq
            FROM diary
            WHERE entry_date <= strftime("%Y-%m-%d 23:59:59", date(?))
            ORDER BY entry_date DESC,
                     entry_order DESC,
                     entry_addenda_day DESC,
                     entry_addenda_seq DESC
            LIMIT 1;
        """, (entry_date, entry_date))
        row = DIARY.cursor.fetchone()

        if row is None:
            # the new entry is earlier than the first entry in the database
            DIARY.cursor.execute("""
                SELECT entry_order,
                       entry_addenda_day - (ABS(strftime("%s", date(entry_date))
                                               - strftime("%s", date(?)))
                                            / 86400) as new_day,
                       entry_addenda_seq + 1 as new_seq
                FROM diary
                WHERE entry_date >= strftime("%Y-%m-%d 23:59:59", date(?))
                ORDER BY entry_date ASC,
                         entry_order ASC,
                         entry_addenda_day ASC,
                         entry_addenda_seq DESC
                LIMIT 1;
            """, (entry_date, entry_date))
            row = DIARY.cursor.fetchone()

        entry_order = row[0]
        entry_addenda_day = row[1]
        entry_addenda_seq = row[2]
    else:
        # -> add a regular new entry
        entry_order = create_order
        entry_addenda_day = 0
        entry_addenda_seq = 0

    DIARY.cursor.execute("""
        INSERT INTO diary(
            create_order, entry_order,
            entry_addenda_day, entry_addenda_seq,
            create_date, create_tz,
            entry_date, entry_tz,
            modify_date, modify_tz,
            title, preview, entry,
            tags, mood, bookmark,
            entry_normalized, tags_normalized
        ) VALUES (
            ?, ?,
            ?, ?,
            ?, ?,
            ?, ?,
            "", "",
            ?, ?, ?,
            ?, ?, ?,
            ?, ?
        );""", (create_order, entry_order,
                entry_addenda_day, entry_addenda_seq,
                create_date, create_tz,
                entry_date, entry_tz,
                title.strip(), DIARY._format_preview(entry), entry.strip(),
                tags.strip(), mood, 0,
                Diary.normalize_text(title, entry),
                Diary.normalize_text(tags, keep=[','])))
    DIARY.conn.commit()

    DIARY.cursor.execute("""
        SELECT *, rowid FROM diary WHERE rowid = ?""", (
        DIARY.cursor.lastrowid, ))
    row = DIARY.cursor.fetchone()

    get_tags()

    return _clean_entry_row(row)


def update_entry(entry_date, entry_tz, modify_date, mood,
                 title, entry, tags, timezone, rowid):
    """ Updates an entry in the database. """
    if not is_initialized():
        return

    DIARY.cursor.execute("""
        UPDATE diary
        SET entry_date = ?,
            entry_tz = ?,
            modify_date = ?,
            mood = ?,
            title = ?,
            preview = ?,
            entry = ?,
            entry_normalized = ?,
            tags = ?,
            tags_normalized = ?,
            modify_tz = ?
        WHERE
            rowid = ?;""", (
        entry_date, entry_tz,
        modify_date, mood,
        title.strip(),
        DIARY._format_preview(entry),
        entry.strip(),
        Diary.normalize_text(title, entry),
        tags.strip(),
        Diary.normalize_text(tags, keep=[',']),
        timezone, rowid
    ))
    DIARY.conn.commit()

    DIARY.cursor.execute("""
        SELECT *, rowid FROM diary WHERE rowid = ?""", (rowid, ))
    row = DIARY.cursor.fetchone()

    get_tags()

    return _clean_entry_row(row)


def update_bookmark(id, mark):
    """ Just updates the status of the bookmark option """
    if not is_initialized():
        return

    DIARY.cursor.execute("""UPDATE diary
                            SET bookmark = ?
                            WHERE rowid = ?; """, (1 if mark else 0, id))
    DIARY.conn.commit()


def delete_entry(id):
    """ Deletes an entry from the diary table """
    if not is_initialized():
        return

    DIARY.cursor.execute("""DELETE FROM diary
                            WHERE rowid = ?; """, (id, ))
    DIARY.conn.commit()

    get_tags()

# END


#
# BEGIN Export Functions
#

def _read_all_entries():
    """ Read all entries to export them.
        Expects the database to be ready and initialized.
    """

    DIARY.cursor.execute("""
        SELECT *, rowid FROM diary
        ORDER BY entry_order DESC,
                 entry_addenda_day DESC,
                 entry_addenda_seq DESC;""")
    rows = DIARY.cursor.fetchall()

    cleaned_rows = []

    for row in rows:
        # default values are only used if database is corrupted
        entry = _clean_entry_row(row)
        cleaned_rows.append(entry)

    return cleaned_rows


def _export_template(template: str, env: dict):
    import pyratemp

    template_file = Path(__file__).resolve().parent / 'templates' / template
    renderer = pyratemp.Template(filename=str(template_file), data=env)

    return renderer()


def _export_txt(filename: str, env: dict):
    return {f'{filename}.txt': _export_template('export.txt', env)}


def _export_md(filename: str, env: dict):
    return {f'{filename}.md': _export_template('export.md', env)}


def _export_tex_md(filename: str, env: dict):
    return {
        f'{filename}.tex.md': _export_template('export.tex.md', env),
        f'{filename}.yaml': _export_template('export.tex.yaml', env),
    }


def _export_csv(filename: str, env: dict):
    import io
    import csv

    output = io.StringIO()

    fieldnames = list(_FIELD_DEFAULTS.keys()) + list(_GENERATED_FIELDS.keys())
    csv_writer = csv.DictWriter(output, fieldnames=fieldnames)
    csv_writer.writeheader()

    for e in env['entries']:
        csv_writer.writerow(e)

    return {f'{filename}.csv': output.getvalue().strip()}


def _export_raw(filename: str, env: dict):
    import zipfile
    tr = env['tr']

    with zipfile.ZipFile(f'{filename}.zip', 'w',
                         compression=zipfile.ZIP_STORED,
                         allowZip64=True) as myzip:
        myzip.write(DIARY.db_path, arcname=Path(DIARY.db_path).name)
        myzip.writestr(tr('''README.txt'''), data=_export_template('export.zip.txt', env))

    # writing is handled here; the function returns no files because
    # the common writer writes text files
    return {}


def _get_translators(translations):
    # The tr() function returns the translation for 'string', or 'string' itself
    # if no translation is available.
    #
    # NOTE: 1. the string MUST be enclosed in triple single quotes, e.g. '''foobar'''
    #       2. after changing any translatable text, you MUST run update_export_translations.sh
    #          to make the text actually translatable
    def tr(string: str, *args, **kwargs):
        return translations.get(string, string).format(*args, **kwargs)

    def mood(index: int):
        moodTexts = translations.get('moodTexts', [])
        return moodTexts[index] if len(moodTexts) > index else str(index)

    return (tr, mood)


def export(filename: str, kind: str, translations):
    """ Export all entries to 'filename' as 'type'.

    'translations' is a JS object containing translations for exported strings.
    The field 'moodTexts' must contain a list of translated string for all moods.
    See the generated file "components/ExportTranslations.qml" for the
    main definition.
    """

    if not is_initialized():
        return

    entries = _read_all_entries()
    filename = filename.replace("'", "_").replace(":", "-").strip()

    if not entries or not filename:
        return  # nothing to export

    tr, mood = _get_translators(translations)

    def date(date_string: str, timezone: str = ''):
        dt = datetime.strptime(date_string, '%Y-%m-%d %H:%M:%S')

        if timezone:
            return dt.strftime(tr('''%A, %B %-d %Y (%-H:%M, {tz})''', tz=timezone))
        return dt.strftime(tr('''%A, %B %-d %Y (%-H:%M)'''))

    def paragraphs(string: str):
        lines = string.split('\n')
        lines = [x.strip() for x in lines]
        lines = [x if not x or x[0] == '-' else x + '\n' for x in lines]
        return '\n'.join(lines).strip()

    def underlined(string: str, line: str = '-'):
        return '\n'.join([string, line.rjust(len(string), line)])

    env = {
        'tr': tr,
        'mood': mood,
        'date': date,
        'paragraphs': paragraphs,
        'underlined': underlined,

        'entries': entries,
        'from_date': date(entries[-1]['entry_date'], entries[-1]['entry_tz']),
        'to_date': date(entries[0]['entry_date'], entries[0]['entry_tz']),
        'today': date(datetime.now().strftime('%Y-%m-%d %H:%M:%S')),
        'output_name': Path(filename).stem,
    }

    DIARY.conn.commit()

    if kind == 'txt':
        exported = _export_txt(filename, env)
    elif kind == 'md':
        exported = _export_md(filename, env)
    elif kind == 'tex.md':
        exported = _export_tex_md(filename, env)
    elif kind == 'csv':
        exported = _export_csv(filename, env)
    elif kind == 'raw':
        exported = _export_raw(filename, env)
    else:
        pyotherside.send('error', 'unknown-export-type', {'kind': kind})
        exported = {}

    for path, content in exported.items():
        Diary.move_aside(path)

        with open(path, "w+", encoding='utf-8') as fd:
            fd.write(content)


if __name__ == '__main__':
    pass

    initialize(standard_paths=StandardPaths)
    # backup_database()

    # print('txt')
    # export_new('output', 'txt', {})
    # print('md')
    # export('output', 'md', {})
    # print('tex.md')
    # export_new('output', 'tex.md', {})
    # print('csv')
    # export_new('output', 'csv', {})
    # print('zip')
    # export_new('output', 'raw', {})
