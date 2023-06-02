/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

// A combo box that can show detailed descriptions of all menu items.
//
// Usage:
// Define the combo box like any other ComboBox, then add a "info"
// property on the menu items that should have descriptions.
//
// Use InfoComboSection items to add further sections that do not
// belong to a specific menu item.
//
// Example:
/*

InfoCombo {
    width: parent.width
    label: "Food preference"

    InfoComboSection {
        placeAtTop: true
        title: "Food types"
        text: "We provide different kinds of food."
    }

    menu: ContextMenu {
        MenuItem {
            text: "Vegetarian"
            property string info: "Vegetarian food does not have any meat."
        }
        MenuItem {
            text: "Vegan"
            property string info: "Vegan food is completely plant-based."
        }
    }

    InfoComboSection {
        placeAtTop: false
        title: "What about meat?"
        text: "We don't provide any meat."
    }
}

*/

ComboBox {
    id: root
    rightMargin: Theme.horizontalPageMargin + Theme.iconSizeMedium

    readonly property IconButton infoButton: button

    IconButton {
        id: button
        enabled: root.enabled
        anchors.right: parent.right
        Binding on highlighted { when: root.highlighted; value: true }
        icon.source: "image://theme/icon-m-about"

        onClicked: {
            var top = []
            var bottom = []
            var items = []

            for (var i in root.children) {
                var sec = root.children[i]

                if (sec.hasOwnProperty('__is_info_combo_section')) {
                    if (sec.placeAtTop) {
                        top.push(sec)
                    } else {
                        bottom.push(sec)
                    }
                }
            }

            if (root.menu) {
                for (var j in menu._contentColumn.children) {
                    var item = menu._contentColumn.children[j]

                    if (item && item.visible &&
                            item.hasOwnProperty("__silica_menuitem") &&
                            item.hasOwnProperty("info")) {
                        items.push({title: item.text, text: item.info,
                                    isOption: true})
                    }
                }
            }

            var sections = top.concat(items, bottom)

            pageStack.push(Qt.resolvedUrl("InfoComboPage.qml"), {
                title: root.label, sections: sections,
                hasExtraSections: top.length > 0 || bottom.length > 0
            })
        }
    }
}
