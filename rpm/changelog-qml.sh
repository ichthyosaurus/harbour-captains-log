#!/bin/bash
# This file is part of Captain's Log.
# SPDX-FileCopyrightText: 2021-2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This script converts the RPM changelog into a ChangelogList QML component.
#

app="harbour-captains-log"
changelog="rpm/$app.changes"
changelog_copyright="Mirian Margiani"

# REUSE-IgnoreStart
changelog_license="GPL-3.0-or-later"
# REUSE-IgnoreEnd

opal_about_import='import "modules/Opal/About"'
opal_about_prefix=""
output_file="qml/Changelog.qml"

if [[ "$(basename "$(pwd)")" == "rpm" ]]; then
    cd ..  # run from base directory
fi

if [[ ! -d rpm || ! -d qml ]]; then
    echo "error: the script must be run from the project's base directory"
    exit 2
fi

if [[ ! -f "$changelog" ]]; then
    echo "error: RPM changelog not found"
    exit 2
fi

# REUSE-IgnoreStart
cat <<EOF > "$output_file"
/*
 * This file is part of $app.
 * SPDX-FileCopyrightText: $changelog_copyright
 * SPDX-License-Identifier: $changelog_license
 */

import QtQuick 2.0
import "modules/Opal/About"

ChangelogList {
EOF
# REUSE-IgnoreEnd

i1="    "
i2="        "
i3="            "

cat "$changelog" |\
    sed -Ee "s@\* ... (... .. ....) .*?> (.*)\$@${i2}'' ]\n${i1}}\n${i1}ChangelogItem {\n${i2}version: '\2'\n${i2}date: '\1'\n${i2}paragraphs: [@g;
             s/^- (.*)$/${i3}'- \1<br>' +/g;
             /^#/d;
             /^$/d;" |\
    sed -Ee "1d; 2d;" |\
    LC_ALL=C awk -v date_re="date: '(... .. ....)'" '{
        if ($0 ~ date_re) {
            # find dates
            match($0, date_re, m);

            # convert dates
            cmd="date -d \"" m[1] "\" \"+%F\" ";
            cmd | getline converted;
            close(cmd);

            # save dates
            sub(date_re, "date: \"" converted "\"");
            print;
        } else {
            print;
        }
    }' \
    >> "$output_file"

cat <<EOF >> "$output_file"
        '' ]
    }
}
EOF
