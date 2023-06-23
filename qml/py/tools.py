#
# This file is part of harbour-captains-log.
# SPDX-FileCopyrightText: 2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#

try:
    import pyotherside
    HAVE_SIDE = True
except ImportError:
    HAVE_SIDE = False

    class pyotherside:
        def send(*args, **kwargs):
            print(f"pyotherside.send: {args} {kwargs}")
