# coding: utf-8
#
# This file is part of harbour-captains-log.
# SPDX-FileCopyrightText: 2020 Gabriel Berkigt
# SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#

import os
import csv
import sqlite3
import re
from pathlib import Path
from datetime import datetime

import pyotherside


#
# BEGIN Database
#

DIARY = None
INITIALIZED = False  # TODO actually check this value everywhere


class Diary:
    def __init__(self, data_path, db_data_file, db_version_file):
        self.ready = False
        self._data_path = data_path

        try:
            print(f"preparing local data path in {self._data_path}")
            Path(self._data_path).mkdir(parents=True, exist_ok=True)
        except FileExistsError:
            pyotherside.send('fatal.local-data.inaccessible')
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
            self.conn.create_function("REWRITE_DATE", 1, self._reformat_date_pre_db4)

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
    def _format_date(date_string, tz_string):
        zone = " [{}]".format(tz_string) if tz_string else ""

        if not date_string:
            date_string = "never{tz}".format(tz=zone)

        return date_string

# END


#
# BEGIN Database Functions
#

def initialize(data_path, db_data_file, db_version_file):
    global DIARY
    global INITIALIZED

    DIARY = Diary(data_path, db_data_file, db_version_file)

    if DIARY.ready:
        INITIALIZED = True
        return True

    return False


def _clean_entry_row(row):
    # default values are only used if database is corrupted
    return {"create_date": row["create_date"] if row["create_date"] else "",
            "day": (row["create_date"] if row["create_date"] else "").split(' ')[0],
            "modify_date": row["modify_date"] if row["modify_date"] else "",
            "mood": row["mood"] if row["mood"] is not None else 2,  # default to 2=okay
            "title": (row["title"] if row["title"] else "").strip(),
            "preview": (row["preview"] if row["preview"] else "").strip(),
            "entry": (row["entry"] if row["entry"] else "").strip(),
            "bookmark": True if row["bookmark"] == 1 else False,
            "hashtags": (row["hashtags"] if row["hashtags"] else "").strip(),
            "create_tz": row["create_tz"] if row["create_tz"] else "",
            "modify_tz": row["modify_tz"] if row["modify_tz"] else "",
            "rowid": row["rowid"]  # rowid cannot be empty
            }


def get_entries():
    """ Load all entries and ship them to QML """

    DIARY.cursor.execute(""" SELECT *, rowid FROM diary ORDER BY rowid DESC; """)
    rows = DIARY.cursor.fetchall()

    batch = []

    for i, row in enumerate(rows, 1):
        batch.append(_clean_entry_row(row))

        if i % 20 == 0:
            pyotherside.send('entries', batch)
            batch = []

    pyotherside.send('entries', batch)


def add_entry(create_date, mood, title, preview, entry, hashs, timezone):
    """ Add new entry to the database. By default last modification is set to NULL and bookmark option to FALSE. """
    DIARY.cursor.execute("""INSERT INTO diary
                            (create_date, modify_date, mood, title, preview, entry, bookmark, hashtags, create_tz)
                            VALUES (?, "", ?, ?, ?, ?, 0, ?, ?);""",
                         (create_date, mood, title.strip(), preview.strip(), entry.strip(), hashs.strip(), timezone))
    DIARY.conn.commit()

    entry = {"create_date": create_date,
             "day": create_date.split(' ')[0],
             "modify_date": "",
             "mood": mood,
             "title": title.strip(),
             "preview": preview.strip(),
             "entry": entry.strip(),
             "bookmark": False,
             "hashtags": hashs.strip(),
             "create_tz": timezone,
             "modify_tz": "",
             "rowid": DIARY.cursor.lastrowid}
    return entry


def update_entry(create_date, create_tz, modify_date, mood, title, preview, entry, hashs, timezone, rowid):
    """ Updates an entry in the database. """
    DIARY.cursor.execute("""UPDATE diary
                            SET create_date = ?,
                                create_tz = ?,
                                modify_date = ?,
                                mood = ?,
                                title = ?,
                                preview = ?,
                                entry = ?,
                                hashtags = ?,
                                modify_tz = ?
                            WHERE
                                rowid = ?;""",
                         (create_date, create_tz, modify_date, mood, title.strip(), preview.strip(), entry.strip(), hashs.strip(), timezone, rowid))
    DIARY.conn.commit()


def update_bookmark(id, mark):
    """ Just updates the status of the bookmark option """
    DIARY.cursor.execute("""UPDATE diary
                            SET bookmark = ?
                            WHERE rowid = ?; """, (1 if mark else 0, id))
    DIARY.conn.commit()


def delete_entry(id):
    """ Deletes an entry from the diary table """
    DIARY.cursor.execute("""DELETE FROM diary
                            WHERE rowid = ?; """, (id, ))
    DIARY.conn.commit()

# END


#
# BEGIN Export Functions
#

def _read_all_entries():
    """ Read all entries to export them """
    DIARY.cursor.execute(""" SELECT *, rowid FROM diary ORDER BY rowid DESC; """)
    rows = DIARY.cursor.fetchall()

    cleaned_rows = []

    for row in rows:
        # default values are only used if database is corrupted
        entry = _clean_entry_row(row)
        cleaned_rows.append(entry)

    return cleaned_rows


def export(filename, type, translations):
    """ Export all entries to 'filename' as 'type'.

    'translations' is a JS object containing translations for exported strings.
    The field 'moodTexts' must contain a list of translated string for all moods.
    Cf. ExportPage.qml for the main definition.
    """

    entries = _read_all_entries()  # get latest state of the database

    if not entries:
        return  # nothing to export

    def tr(string):
        # return the translation for 'string' or 'string' if none is available
        return translations.get(string, string)

    def trMood(index):
        # cf. tr()
        moodTexts = translations.get('moodTexts', [])
        return moodTexts[index] if len(moodTexts) > index else str(index)

    if type == "txt":
        # Export as plain text file
        with open(filename, "w+", encoding='utf-8') as f:
            for e in entries:
                lines = [
                    tr('Created: {}').format(DIARY._format_date(e["create_date"], e["create_tz"])),
                    tr('Changed: {}').format(tr(DIARY._format_date(e["modify_date"], e["modify_tz"]))), '',
                    tr('Title: {}').format(e['title']), '',
                    tr('Entry:\n{}').format(e['entry']), '',
                    tr('Hashtags: {}').format(e['hashtags']),
                    tr('Bookmark: {}').format(tr("yes") if e["bookmark"] else tr("no")),
                    tr('Mood: {}').format(trMood(e["mood"])),
                    "-".rjust(80, "-"), '',
                ]
                f.write('\n'.join(lines))
    elif type == "csv":
        # Export as CSV file
        with open(filename, "w+", newline='', encoding='utf-8') as f:
            fieldnames = ["rowid", "create_date", "create_tz", "modify_date", "modify_tz", "mood", "preview", "title", "entry", "hashtags", "bookmark"]
            csv_writer = csv.DictWriter(f, fieldnames=fieldnames)
            csv_writer.writeheader()

            for e in entries:
                del e["day"]  # generated field
                csv_writer.writerow(e)
    elif type == "md":
        # Export as plain Markdown file
        with open(filename, "w+", encoding='utf-8') as f:
            with open(filename, "w+", encoding='utf-8') as f:
                from_date = DIARY._format_date(entries[-1]["create_date"], entries[-1]["create_tz"])
                till_date = DIARY._format_date(entries[0]["create_date"], entries[0]["create_tz"])
                f.write('# ' + tr('Diary from {} until {}').format(from_date, till_date) + '\n\n')

                for e in entries:
                    bookmark = " *" if e["bookmark"] else ""
                    title = "** {} **\n".format(e["title"]) if e["title"] else ""
                    mood = trMood(e["mood"])
                    hashtags = "\\# *" + e["hashtags"] + "*" if e["hashtags"] else ""

                    lines = [
                        '## ' + DIARY._format_date(e["create_date"], e["create_tz"]) + bookmark, '',
                        title + e['entry'], '',
                        tr('Mood: {}').format(mood),
                        tr('Changed: {}').format(tr(DIARY._format_date(e["modify_date"], e["modify_tz"]))),
                        '', hashtags, '',
                    ]
                    f.write('\n'.join(lines))
    elif type == "tex.md":
        # Export as Markdown file to be converted using Pandoc
        with open(filename, "w+", encoding='utf-8') as f:
            from_date = DIARY._format_date(entries[-1]["create_date"], entries[-1]["create_tz"])
            till_date = DIARY._format_date(entries[0]["create_date"], entries[0]["create_tz"])
            head = [
                '---'
                'title: "{}"'.format(tr("Diary from {} until {}").format(from_date, till_date)),
                'author: ""',
                f'date: {datetime.now().strftime("%Y-%m-%d")}',
                '---',
                '',
            ]
            f.write('\n'.join(head) + '\n')

            for e in entries:
                bookmark = " $\\ast$" if e["bookmark"] else ""
                title = "** {} **\n".format(e["title"]) if e["title"] else ""
                mood = trMood(e["mood"])
                hashtags = "\\# \\emph{" + e["hashtags"] + "}" if e["hashtags"] else ""

                lines = [
                    '# ' + DIARY._format_date(e["create_date"], e["create_tz"]) + bookmark, '',
                    title + e['entry'], '',
                    '\\begin{small}',
                    '{}\\hfill {}'.format(tr('Mood: {}').format(mood), tr('changed: {}').format(tr(DIARY._format_date(e["modify_date"], e["modify_tz"])))),
                    hashtags,
                    '\\end{small}\n', '',
                ]
                f.write('\n'.join(lines))
