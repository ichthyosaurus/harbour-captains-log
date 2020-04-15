# coding: utf-8

import os
import csv
import sqlite3

# - - - basic settings - - - #

home = os.getenv("HOME")
db_path = home+"/.local/share/harbour-captains-log"

if os.path.isdir(db_path) == False:
    print("Create app path in .local/share")
    os.mkdir(db_path)

database = db_path + "/logbuch.db"
conn = sqlite3.connect(database)
cursor = conn.cursor()

entry_list = []

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


# - - - database functions - - - #

def read_all_entries():
    """ Read all entries to show them on the main page """
    cursor.execute(""" SELECT creation_date,
                              modify_date,
                              mood,
                              title,
                              preview,
                              entry,
                              favorite,
                              hashtags,
                              rowid
                       FROM diary
                       ORDER BY rowid DESC; """)

    rows = cursor.fetchall()
    return create_entries_model(rows)


def add_entry(creation_date, mood, title, preview, entry, hashs):
    """ Add new entry to the database. By default last modification is set to NULL and favorite option to FALSE. """
    cursor.execute("""INSERT INTO diary
                      VALUES (?, "", ?, ?, ?, ?, 0, ?);""",
                      (creation_date, mood, title, preview, entry, hashs))
    conn.commit()


def update_entry(modify_date, mood, title, preview, entry, hashs, id):
    """ Updates an entry in the database. """
    cursor.execute("""UPDATE diary
                          SET modify_date = ?,
                              mood = ?,
                              title = ?,
                              preview = ?,
                              entry = ?,
                              hashtags = ?
                          WHERE
                              rowid = ?;""",
                              (modify_date, mood, title, preview, entry, hashs, id))
    conn.commit()


def update_favorite(id, fav):
    """ Just updates the status of the favorite option """
    cursor.execute(""" UPDATE diary
                       SET favorite = ?
                       WHERE rowid = ?; """, (fav, id))
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


def search_date(dateStr):
    """ Search for a date string """
    cursor.execute(""" SELECT *, rowid FROM diary WHERE creation_date LIKE ? ORDER BY rowid DESC; """, (dateStr+"%", ))
    rows = cursor.fetchall()
    create_entries_model(rows)

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

    entry_list.clear()

    for row in rows:
        entry = {"create_date": row[0],
                 "modify_date": row[1],
                 "mood": row[2],
                 "title": row[3],
                 "preview": row[4],
                 "entry": row[5],
                 "favorite": row[6],
                 "hashtags": row[7],
                 "rowid": row[8]}

        entry_list.append(entry)
    return entry_list


def get_entry_list():
    """ return the latest status of the entries list """
    return entry_list


# - - - export features - - - #


def export(filename, type):
    """ Export to ~/filename as txt or csv """

    # get latest state of the database
    read_all_entries()
    rows = get_entry_list()

    moods = ["Fantastic", "Good", "Okay", "Bad", "Horrible"]

    # Export as *.txt text file to filename
    if type == ".txt":
        with open(filename, "w") as f:
            for r in rows:
                date_str = r["create_date"]+" (changed: "+r["modify_date"]+")\n\n"
                title_str = "Title: "+r["title"]+"\n\n"
                entry_str = "Entry:\n"+r["entry"]+"\n\n"
                hash_str = "Hashtags: "+r["hashtags"]+"\n"
                if r["favorite"]:
                    fav_str = "Favorite: Yes!\n"
                else:
                    fav_str = "Favorite: - \n"
                mood_str = "Mood: "+moods[r["mood"]]+"\n\n"
                split_str = "-------------------------------------------------------------------------------\n\n"

                final_str = date_str + title_str + entry_str + hash_str + fav_str + mood_str + split_str
                f.write(final_str)
            f.close()

    # Export as *.csv file to filename
    if type == ".csv":
        with open(filename, "w", newline='') as f:
            fieldnames = ["rowid", "create_date", "modify_date", "mood", "preview", "title", "entry", "hashtags", "favorite"]
            csv_writer = csv.DictWriter(f, fieldnames=fieldnames)

            csv_writer.writeheader()

            for r in rows:
                csv_writer.writerow(r)

            f.close()
