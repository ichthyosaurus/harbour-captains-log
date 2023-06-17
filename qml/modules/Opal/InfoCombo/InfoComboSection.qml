//@ This file is part of opal-infocombo.
//@ https://github.com/Pretty-SFOS/opal-infocombo
//@ SPDX-FileCopyrightText: 2023 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.0
QtObject{property string title
property string text
property bool placeAtTop:true
property var linkHandler:function(link){Qt.openUrlExternally(link)
}
readonly property int __is_info_combo_section:0
}