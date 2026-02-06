/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.SortFilterProxyModel 1.0

SilicaListView {
    id: root
    height: Math.min(limitResults + 1, count) * Theme.itemSizeSmall

    signal tagSelected(var tag)

    property string searchTerm
    readonly property int defaultLimit: 3
    property int limitResults: defaultLimit

    property var _highlightRegex: new RegExp(
        searchTerm.replace(/([-.[\](){}\\*?*^$|])/g, "\\$1"), 'i')

    SortFilterProxyModel {
        id: tagSuggestionsModel
        sourceModel: searchTerm !== "" ? appWindow.tagsModel : null

        sorters: StringSorter {
            roleName: "text"
        }

        filters: AnyOf {
            RegExpFilter {
                roleName: "text"
                pattern: searchTerm
                caseSensitivity: Qt.CaseInsensitive
                syntax: RegExpFilter.WildcardUnix
            }
            RegExpFilter {
                roleName: "normalized"
                pattern: appWindow.normalizeText(searchTerm)
                caseSensitivity: Qt.CaseInsensitive
                syntax: RegExpFilter.FixedString
            }
        }
    }

    onCountChanged: {
        if (count != limitResults) {
            limitResults = defaultLimit
        }
    }

    clip: true
    quickScroll: false
    interactive: false  // prevent scrolling

    model: tagSuggestionsModel

    delegate: Item {
        x: Theme.horizontalPageMargin
        width: root.width - 2*x
        height: Theme.itemSizeSmall
        visible: index < root.limitResults

        Label {
            id: tagLabel
            anchors {
                fill: parent
                margins: Theme.paddingMedium
            }
            text: Theme.highlightText(model.text, _highlightRegex, Theme.highlightColor)
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            anchors.fill: tagBackground
            radius: tagBackground.contentItem.radius
            color: appWindow.stringToColor(model.text)
            opacity: Theme.opacityFaint
        }

        BackgroundItem {
            id: tagBackground
            width: tagLabel.implicitWidth + 2*Theme.paddingMedium
            height: Theme.itemSizeSmall - 2*Theme.paddingSmall
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            contentItem.radius: 15
            onClicked: tagSelected(model)
        }
    }

    footerPositioning: ListView.OverlayFooter
    footer: BackgroundItem {
        width: parent.width
        height: Theme.itemSizeSmall

        property int remaining: Math.max(0, root.count - root.limitResults)
        visible: remaining > 0

        onClicked: root.limitResults = root.count

        Label {
            anchors {
                fill: parent
                margins: Theme.horizontalPageMargin
            }

            text: qsTr("... and %n more", "", remaining)
            truncationMode: TruncationMode.Fade
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }
    }
}
