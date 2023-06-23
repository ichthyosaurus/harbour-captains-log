#
# This file is part of harbour-captains-log.
# SPDX-FileCopyrightText: 2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#

# import os
# import sqlite3
# import re
# import unicodedata
# from pathlib import Path
# from datetime import datetime
# from datetime import timedelta

try:
    import pyotherside
    HAVE_SIDE = True
except ImportError:
    HAVE_SIDE = False

    class pyotherside:
        def send(*args, **kwargs):
            print(f"pyotherside.send: {args} {kwargs}")


def select_all(selected, model, count):
#    print(model)
#    print(model.count)
#    print(model.getNow(1))
#    print(model.roleForName("rowid"))
#    print(model.get)
#    print(model.get(0, "rowid"))
#    print(model.get(0).rowid)

    for i in range(0, model.count):
        rowid = model.getNow(i)

        if rowid in selected and selected[rowid] is True:
            continue

        selected[rowid] = True
        count += 1

    return {
        'selected': selected, 'count': count
    }
