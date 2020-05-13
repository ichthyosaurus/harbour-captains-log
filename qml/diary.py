# coding: utf-8
#
# This file is part of harbour-captains-log.
# Copyright (C) 2020  Gabriel Berkigt, Mirian Margiani
#
# harbour-captains-log is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-captains-log is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-captains-log.  If not, see <http://www.gnu.org/licenses/>.
#

import os
import csv
import sqlite3
import re


# - - - helper functions - - - #
def _reformat_date_pre_db4(old_date_string):
    """Reformat old date strings (prior db version 4) to the new format.

    New date format: 'yyyy-MM-dd hh:mm:ss'.
    Old date format: 'd.M.yyyy | h:m:s' (with ':s' being optional).
    - Each field was padded with 0 to be two characters long (not enforced).
    """

    if not old_date_string:
        return ""

    reg = re.compile("^(\d{1,2}\.){2}\d{4} \| \d{1,2}:\d{1,2}(:\d{1,2})?$")
    if reg.search(old_date_string) is None:
        print("warning: could not convert invalid date '{}'".format(date_string))
        return ""

    date_time = old_date_string.split(' | ')  # "10.12.2009 | 10:00:01" -> ("1.10.2010", "10:0:01")
    date = date_time[0].split('.')  # "1.10.2010" -> ("1", "10", "2010")
    time = date_time[1].split(':')  # "10:0:01" -> ("10", "0", "01")
    sec = time[2] if len(time) >= 3 else "0"

    new_string = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}".format(
        int(date[2]), int(date[1]), int(date[0]), int(time[0]), int(time[1]), int(sec))

    print("{} -> {}".format(old_date_string, new_string))
    return new_string
# - - - basic settings - - - #

home = os.getenv("HOME")
db_path = home+"/.local/share/harbour-captains-log"

if os.path.isdir(db_path) == False:
    print("Create app path in .local/share")
    os.mkdir(db_path)

database = db_path + "/logbuch.db"
schema = db_path + "/schema_version"
filtered_entry_list = []
schema_version = "none"

conn = sqlite3.connect(database)
conn.row_factory = sqlite3.Row
cursor = conn.cursor()

def upgrade_schema(from_version):
    to_version = ""

    if from_version == "none":
        to_version = "0"
        cursor.execute("""CREATE TABLE IF NOT EXISTS diary
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
        cursor.execute("""UPDATE diary SET mood=5 WHERE mood=4""")
        cursor.execute("""UPDATE diary SET mood=4 WHERE mood=3""")
    elif from_version == "1":
        to_version = "2"

        # add columns to store time zone info
        cursor.execute("""ALTER TABLE diary ADD COLUMN creation_tz TEXT DEFAULT '';""")
        cursor.execute("""ALTER TABLE diary ADD COLUMN modify_tz TEXT DEFAULT '';""")

        # add column to store an audio file path (not yet used)
        cursor.execute("""ALTER TABLE diary ADD COLUMN audio_path TEXT DEFAULT '';""")
    elif from_version == "2":
        to_version = "3"

        # rename and reorder columns: creation_date -> create_date and creation_tz -> create_tz
        cursor.execute("""CREATE TABLE IF NOT EXISTS diary_temp
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
        cursor.execute("""INSERT INTO diary_temp(create_date, create_tz, modify_date, modify_tz, mood, title, preview, entry, favorite, hashtags, audio_path)
                            SELECT creation_date, creation_tz, modify_date, modify_tz, mood, title, preview, entry, favorite, hashtags, audio_path
                            FROM diary;""")
        cursor.execute("""DROP TABLE diary;""")
        cursor.execute("""ALTER TABLE diary_temp RENAME TO diary;""")
    elif from_version == "3":
        to_version = "4"
        conn.create_function("REWRITE_DATE", 1, _reformat_date_pre_db4)

        # rewrite all dates to use a standard format
        cursor.execute("""UPDATE diary SET create_date=REWRITE_DATE(create_date);""")
        cursor.execute("""UPDATE diary SET modify_date=REWRITE_DATE(modify_date);""")
    elif from_version == "4":
        # we arrived at the latest version; save it and return
        if schema_version != from_version:
            conn.commit()
            conn.execute("""VACUUM;""")
            with open(schema, "w") as f:
                f.write(from_version)
        print("database schema is up-to-date (version: {})".format(from_version))
        return
    else:
        print("Invalid schema version!", from_version)
        return

    print("upgrading schema from {} to {}...".format(from_version, to_version))
    upgrade_schema(to_version)


if os.path.isfile(schema) == False:
    schema_version = "none"
else:
    with open(schema) as f:
        schema_version = f.readline().strip()

# make sure database is up-to-date
upgrade_schema(schema_version)


# - - - add support for regex matching - - - #

def regexp(expr, item):
    if item is None:
        return False

    reg = re.compile(expr)
    return reg.search(item) is not None


conn.create_function("REGEXP", 2, regexp)


# - - - helper functions - - - #

def _parse_date(date_string):
    if not date_string:
        return ()

    date_time = date_string.split(' | ')
    date = date_time[0].split('.')
    time = date_time[1].split(':')
    sec = time[2] if len(time) >= 3 else "0"

    return (int(date[2]), int(date[1]), int(date[0]), int(time[0]), int(time[1]), int(sec))


def _format_date(date_string, tz_string):
    date = _parse_date(date_string)
    zone = " [{}]".format(tz_string) if tz_string else ""

    if date_string:
        date_string = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}{tz}".format(
            date[0], date[1], date[2], date[3], date[4], date[5], tz=zone)
    else:
        date_string = "never{tz}".format(tz=zone)

    return date_string


# - - - database functions - - - #

def read_all_entries():
    """ Read all entries to show them on the main page """
    cursor.execute(""" SELECT *, rowid FROM diary ORDER BY rowid DESC; """)
    rows = cursor.fetchall()
    return create_entries_model(rows)


def add_entry(create_date, mood, title, preview, entry, hashs, timezone):
    """ Add new entry to the database. By default last modification is set to NULL and favorite option to FALSE. """
    cursor.execute("""INSERT INTO diary
                      (create_date, modify_date, mood, title, preview, entry, favorite, hashtags, create_tz)
                      VALUES (?, "", ?, ?, ?, ?, 0, ?, ?);""",
                      (create_date, mood, title.strip(), preview.strip(), entry.strip(), hashs.strip(), timezone))
    conn.commit()

    entry = {"create_date": create_date,
             "day": create_date.split(' ')[0],
             "modify_date": "",
             "mood": mood,
             "title": title.strip(),
             "preview": preview.strip(),
             "entry": entry.strip(),
             "favorite": False,
             "hashtags": hashs.strip(),
             "create_tz": timezone,
             "modify_tz": "",
             "rowid": cursor.lastrowid}
    return entry


def update_entry(modify_date, mood, title, preview, entry, hashs, timezone, rowid):
    """ Updates an entry in the database. """
    cursor.execute("""UPDATE diary
                          SET modify_date = ?,
                              mood = ?,
                              title = ?,
                              preview = ?,
                              entry = ?,
                              hashtags = ?,
                              modify_tz = ?
                          WHERE
                              rowid = ?;""",
                              (modify_date, mood, title.strip(), preview.strip(), entry.strip(), hashs.strip(), timezone, rowid))
    conn.commit()


def update_favorite(id, fav):
    """ Just updates the status of the favorite option """
    cursor.execute(""" UPDATE diary
                       SET favorite = ?
                       WHERE rowid = ?; """, (1 if fav else 0, id))
    conn.commit()


def delete_entry(id):
    """ Deletes an entry from the diary table """
    cursor.execute(""" DELETE FROM diary
                       WHERE rowid = ?; """, (id, ))
    conn.commit()


# - - - search functions - - - #


def search_entries(keyword):
    """ Searches for the keyword in the database """
    cursor.execute(""" SELECT *, rowid FROM diary WHERE title LIKE ? OR entry LIKE ? OR hashtags LIKE ? ORDER BY rowid DESC; """, ("%"+keyword+"%", "%"+keyword+"%", "%"+keyword+"%"))
    rows = cursor.fetchall()
    create_entries_model(rows)


def search_date(dateString):
    """ Search for a date string """
    date = _parse_date(dateString)
    expression = "^0?{}\.0?{}\.{} \| ".format(date[2], date[1], date[0])
    cursor.execute(""" SELECT *, rowid FROM diary WHERE create_date REGEXP ? ORDER BY rowid DESC; """, (expression, ))
    rows = cursor.fetchall()
    create_entries_model(rows)
    print(rows)


def search_hashtags(hash):
    """ Search for a specific hashtag """
    cursor.execute(""" SELECT *, rowid FROM diary WHERE hashtags LIKE ? ORDER BY rowid DESC; """, ("%"+hash+"%", ))
    rows = cursor.fetchall()
    create_entries_model(rows)


def search_favorites():
    """ Returns list of all favorites """
    cursor.execute(""" SELECT *, rowid FROM diary WHERE favorite = 1 ORDER BY rowid DESC; """)
    rows = cursor.fetchall()
    create_entries_model(rows)


def search_mood(mood):
    """ Return list of all entries with specific mood """
    cursor.execute(""" SELECT *, rowid FROM diary WHERE mood = ? ORDER BY rowid DESC; """, (mood, ))
    rows = cursor.fetchall()
    create_entries_model(rows)


# - - - QML model creation functions - - - #

def create_entries_model(rows):
    """ Create the QML ListModel to be shown on main page """

    filtered_entry_list.clear()

    for row in rows:
        entry = {"create_date": row["create_date"],
                 "day": row["create_date"].split(' ')[0],
                 "modify_date": row["modify_date"],
                 "mood": row["mood"],
                 "title": row["title"].strip(),
                 "preview": row["preview"].strip(),
                 "entry": row["entry"].strip(),
                 "favorite": True if row["favorite"] == 1 else False,
                 "hashtags": row["hashtags"].strip(),
                 "create_tz": row["create_tz"],
                 "modify_tz": row["modify_tz"],
                 "rowid": row["rowid"]}
        filtered_entry_list.append(entry)
    return filtered_entry_list


def get_filtered_entry_list():
    """ return the latest status of the entries list """
    return filtered_entry_list


# - - - export features - - - #

def export(filename, type):
    """ Export to ~/filename as txt or csv """

    # get latest state of the database
    entries = read_all_entries()

    moods = ["Fantastic", "Good", "Okay", "Not okay", "Bad", "Horrible"]

    # Export as *.txt text file to filename
    if type == ".txt":
        with open(filename, "w") as f:
            for e in entries:
                created = _format_date(e["create_date"], e["create_tz"])
                modified = _format_date(e["modify_date"], e["modify_tz"])
                favorite = "Yes" if e["favorite"] else "No"
                mood = moods[e["mood"]]

                line = """
Created: {}
Changed: {}

Title: {}

Entry:
{}

Hashtags: {}
Favorite: {}
Mood: {}
{sep}""".format(created, modified, e["title"], e["entry"], e["hashtags"], favorite, mood, sep="-".rjust(80, "-"))

                f.write(line)

            f.close()

    # Export as *.csv file to filename
    if type == ".csv":
        with open(filename, "w", newline='') as f:
            fieldnames = ["rowid", "create_date", "create_tz", "modify_date", "modify_tz", "mood", "preview", "title", "entry", "hashtags", "favorite"]
            csv_writer = csv.DictWriter(f, fieldnames=fieldnames)

            csv_writer.writeheader()

            for e in entries:
                del e["day"]  # generated field
                csv_writer.writerow(e)

            f.close()
