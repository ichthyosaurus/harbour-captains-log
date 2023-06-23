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


#
# BEGIN Database
#

DIARY: 'Diary' = None
INITIALIZED: bool = False  # TODO actually check this value everywhere


class Diary:
    def __init__(self, data_path, db_data_file, db_version_file):
        self.ready = False
        self._data_path = data_path

        try:
            print(f"preparing local data path in {self._data_path}")
            Path(self._data_path).mkdir(parents=True, exist_ok=True)
        except FileExistsError:
            pyotherside.send('error', 'local-data-inaccessible')
            self.ready = False
            return

        self.db_path = self._data_path + '/' + db_data_file
        self.schema = self._data_path + '/' + db_version_file
        self.schema_version = "none"

        if not os.path.isfile(self.db_path) and os.path.isfile(self.schema):
            turn = 0
            while True:
                try:
                    os.rename(self.schema, self.schema + '.bak' + (f'~{turn}' if turn > 0 else ''))
                    break
                except FileExistsError:
                    turn += 1

        self.conn = sqlite3.connect(self.db_path)
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()

        if os.path.isfile(self.schema):
            with open(self.schema) as f:
                self.schema_version = f.readline().strip()
        else:
            self.schema_version = "none"

        # make sure database is up-to-date
        self.upgrade_schema(self.schema_version)
        self.ready = True

    def upgrade_schema(self, from_version):
        to_version = ""

        if from_version == "none":
            to_version = "0"
            self.cursor.execute("""CREATE TABLE IF NOT EXISTS diary
                                   (creation_date TEXT NOT NULL,
                                   modify_date TEXT NOT NULL,
                                   mood INT,
                                   title TEXT,
                                   preview TEXT,
                                   entry TEXT,
                                   favorite BOOL,
                                   hashtags TEXT
                                   );""")
        elif from_version == "0":
            to_version = "1"

            # add new mood 'not okay' with index 3, moving 3 to 4, and 4 to 5
            self.cursor.execute("""UPDATE diary SET mood=5 WHERE mood=4""")
            self.cursor.execute("""UPDATE diary SET mood=4 WHERE mood=3""")
        elif from_version == "1":
            to_version = "2"

            # add columns to store time zone info
            self.cursor.execute("""ALTER TABLE diary ADD COLUMN creation_tz TEXT DEFAULT '';""")
            self.cursor.execute("""ALTER TABLE diary ADD COLUMN modify_tz TEXT DEFAULT '';""")

            # add column to store an audio file path (not yet used)
            self.cursor.execute("""ALTER TABLE diary ADD COLUMN audio_path TEXT DEFAULT '';""")
        elif from_version == "2":
            to_version = "3"

            # rename and reorder columns: creation_date -> create_date and creation_tz -> create_tz
            self.cursor.execute("""CREATE TABLE IF NOT EXISTS diary_temp
                                   (create_date TEXT NOT NULL,
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
            self.cursor.execute("""INSERT INTO diary_temp(create_date, create_tz, modify_date, modify_tz,
                                                          mood, title, preview, entry, favorite, hashtags, audio_path)
                                   SELECT creation_date, creation_tz, modify_date, modify_tz, mood, title, preview, entry, favorite, hashtags, audio_path
                                   FROM diary;""")
            self.cursor.execute("""DROP TABLE diary;""")
            self.cursor.execute("""ALTER TABLE diary_temp RENAME TO diary;""")
        elif from_version == "3":
            to_version = "4"
            self.conn.create_function("REWRITE_DATE", 1,
                                      self._reformat_date_pre_db4,
                                      deterministic=True)

            # rewrite all dates to use a standard format
            self.cursor.execute("""UPDATE diary SET create_date=REWRITE_DATE(create_date);""")
            self.cursor.execute("""UPDATE diary SET modify_date=REWRITE_DATE(modify_date);""")
        elif from_version == "4":
            to_version = "5"

            # rename column 'favorite' to 'bookmark'
            self.cursor.execute("""CREATE TABLE IF NOT EXISTS diary_temp
                                   (create_date TEXT NOT NULL, create_tz TEXT, modify_date TEXT NOT NULL, modify_tz TEXT,
                                   mood INT, title TEXT, preview TEXT, entry TEXT,
                                   bookmark BOOL,
                                   hashtags TEXT, audio_path TEXT);""")
            self.cursor.execute("""INSERT INTO diary_temp(create_date, create_tz, modify_date, modify_tz,
                                                          mood, title, preview, entry, bookmark, hashtags, audio_path)
                                   SELECT create_date, create_tz, modify_date, modify_tz, mood, title, preview, entry, favorite, hashtags, audio_path
                                   FROM diary;""")
            self.cursor.execute("""DROP TABLE diary;""")
            self.cursor.execute("""ALTER TABLE diary_temp RENAME TO diary;""")
        elif from_version == "5":
            to_version = "6"

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

            self.conn.create_function("REWRITE_PREVIEW", 1,
                                      self._format_preview, deterministic=True)
            self.conn.create_function("REWRITE_NORMALIZED", -1,
                                      self._normalize_text, deterministic=True)
            self.conn.create_function("REWRITE_NORMALIZED_TAGS", 1,
                                      lambda x: self._normalize_text(x, keep=[',']),
                                      deterministic=True)
            self.cursor.execute("""DROP TABLE IF EXISTS diary_temp;""")
            self.cursor.execute("""CREATE TABLE IF NOT EXISTS diary_temp(
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
            self.cursor.execute("""INSERT INTO diary_temp(
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
            self.cursor.execute("""DROP TABLE diary;""")
            self.cursor.execute("""ALTER TABLE diary_temp RENAME TO diary;""")
        elif from_version == "6":
            to_version = "7"

            self.conn.create_function("REWRITE_SECONDS", 1,
                                      self._reformat_date_seconds,
                                      deterministic=True)

            # fix timestamps with an invalid seconds field
            self.cursor.execute("""UPDATE diary SET
                create_date=REWRITE_SECONDS(create_date),
                modify_date=REWRITE_SECONDS(modify_date),
                entry_date=REWRITE_SECONDS(entry_date)
            ;""")
        elif from_version == "7":
            # we arrived at the latest version; save it and return
            if self.schema_version != from_version:
                self.conn.commit()
                self.conn.execute("""VACUUM;""")
                with open(self.schema, "w") as f:
                    f.write(from_version)
            print("database schema is up-to-date (version: {})".format(from_version))
            return
        else:
            print("error: cannot use database with invalid schema version '{}'".format(from_version))
            return

        print("upgrading schema from {} to {}...".format(from_version, to_version))
        self.upgrade_schema(to_version)

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
        punctutation_cats = set(['Pc', 'Pd', 'Ps', 'Pe', 'Pi', 'Pf', 'Po'])
        joined = ' '.join((re.sub(r'\s+', ' ', str(x).strip()) for x in args)).strip()

        return ''.join(x for x in unicodedata.normalize('NFKD', joined)
                       if not unicodedata.combining(x)
                       and (unicodedata.category(x) not in punctutation_cats
                            or x in keep)).lower()

# END


#
# BEGIN Database Functions
#

def initialize(data_path, db_data_file, db_version_file):
    if is_initialized(False):
        pyotherside.send('error', 'database-already-initialized')
        return

    global DIARY
    global INITIALIZED

    DIARY = Diary(data_path, db_data_file, db_version_file)

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


def normalize_text(string):
    return Diary._normalize_text(string)


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
        tags = [{'text': x.strip(), 'normalized': Diary._normalize_text(x)}
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
                Diary._normalize_text(title, entry),
                Diary._normalize_text(tags, keep=[','])))
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
        Diary._normalize_text(title, entry),
        tags.strip(),
        Diary._normalize_text(tags, keep=[',']),
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
        myzip.write(DIARY.schema, arcname=Path(DIARY.schema).name)
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

    for k, v in exported.items():
        with open(k, "w+", encoding='utf-8') as fd:
            fd.write(v)


if __name__ == '__main__':
    pass

    # initialize('temp', 'logbook.db', 'schema_version')

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
