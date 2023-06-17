#!/bin/bash
#
# This file is part of harbour-captains-log.
# SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#

qmlfile="qml/components/ExportTranslations.qml"
comment="This string is used in export templates and uses Python formatting. See https://strftime.org for how to format dates and https://docs.python.org/3/library/stdtypes.html#str.format for more information."

# grep -Poe "\btr\('''.*?'''(, .*?)?\)" qml/diary.py qml/templates/* | \
#     grep -Poe "'''.*?'''" -o | \
#     sort -u | \
#     sed -Ee "s/'''(.*?)'''/\1/g" | \
#     sed -Ee 's/"/\"/g' | \
#     sed -Ee "s/'/\'/g" | \
#     sed -Ee "s|(.*)|QT_TRANSLATE_NOOP3_UTF8(\"Export\", \"\1\", \"$comment\")|g" \
#         > src/export_translations.h

cat <<EOF > "$qmlfile"
/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0

QtObject {
    property var translations: ({
EOF

grep -Poe "\btr\('''.*?'''(, .*?)?\)" \
        qml/diary.py \
        qml/templates/* \
    | \
    grep -Poe "'''.*?'''" -o | \
    sort -u | \
    sed -Ee "s/'''(.*?)'''/\1/g" | \
    sed -Ee 's/"/\"/g' | \
    sed -Ee "s/'/\'/g" | \
    sed -Ee "s|(.*)|        \"\1\": qsTr(\"\1\", \"$comment\"),|g" \
        >> "$qmlfile"

#     sed -Ee "s|(.*)|        \"\1\": qsTr(\"\1\", \"$comment\"),|g" | \
#     sed -Ee '$s/\),$/)/' \

cat <<EOF >> "$qmlfile"
        "moodTexts": appWindow.moodTexts
    })
}
EOF
