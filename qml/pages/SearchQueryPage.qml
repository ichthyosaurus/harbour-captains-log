/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property SearchQueriesData queries: SearchQueriesData {
        matchAllMode: true
        text: textField.text
        textMatchMode: textMode.currentItem.mode
        dateMin: !dateMin.selectedDate || isNaN(dateMin.selectedDate.valueOf()) ?
                     new Date('0000-01-01') : dateMin.selectedDate
        dateMax: !dateMax.selectedDate || isNaN(dateMax.selectedDate.valueOf()) ?
                     new Date('9999-01-01') : dateMax.selectedDate
        bookmark: bookmarks.currentItem.mode
        tags: tagsField.text
        moodMin: Math.min(moodMin.moodIndex, moodMax.moodIndex)
        moodMax: Math.max(moodMin.moodIndex, moodMax.moodIndex)
    }

    acceptDestination: Qt.resolvedUrl("SearchResultsPage.qml")
    acceptDestinationAction: PageStackAction.Push
    acceptDestinationProperties: ({queries: queries})

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            flickable: listView

            MenuItem {
                TextSwitch {
                    checked: !queries.matchAllMode
                    text: " "
                    highlighted: parent.highlighted
                    height: Theme.itemSizeSmall
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                }

                text: qsTr("Any may match")
                onClicked: queries.matchAllMode = false
            }

            MenuItem {
                TextSwitch {
                    checked: queries.matchAllMode
                    text: " "
                    highlighted: parent.highlighted
                    height: parent.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                }

                text: qsTr("All must match")
                onClicked: queries.matchAllMode = true
            }
        }

        Column {
            id: column
            width: parent.width

            DialogHeader {
                cancelText: qsTr("Back")
                acceptText: qsTr("Search")
            }

            SectionHeader {
                text: qsTr("Title and entry")
            }

            SearchField {
                id: textField
                width: parent.width
                placeholderText: qsTr("Search contents")
                canHide: false
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }

            SearchField {
                id: tagsField
                width: parent.width
                placeholderText: qsTr("Search tags")
                canHide: false
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }

            ComboBox {
                id: textMode
                width: parent.width
                currentIndex: 0
                label: qsTr("Search mode")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("plain text")
                        property int mode: RegExpFilter.FixedString
                    }
                    MenuItem {
                        text: qsTr("wildcard")
                        property int mode: RegExpFilter.Wildcard
                    }
                    MenuItem {
                        text: qsTr("regular expression")
                        property int mode: RegExpFilter.RegExp
                    }
                }
            }

            ComboBox {
                id: bookmarks
                width: parent.width
                currentIndex: 0
                label: qsTr("Bookmarks")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("all entries", "search option, as in: " +
                                   "“find all entries, whether they are " +
                                   "bookmarked or not”")
                        property int mode: Qt.PartiallyChecked
                    }
                    MenuItem {
                        text: qsTr("marked", "search option, as in: " +
                                   "“find only bookmarked entries”")
                        property int mode: Qt.Checked
                    }
                    MenuItem {
                        text: qsTr("unmarked", "search option, as in: " +
                                   "“find only entries that are not bookmarked”")
                        property int mode: Qt.Unchecked
                    }
                }
            }

            SectionHeader {
                text: qsTr("Mood")
            }

            Row {
                width: parent.width

                ComboBox {
                    id: moodMin
                    width: parent.width / 2
                    label: qsTr("From")
                    value: appWindow.moodTexts[menu.selectedIndex]
                    property int moodIndex: menu.selectedIndex
                    menu: MoodMenu { selectedIndex: appWindow.moodTexts.length-1 }
                }

                ComboBox {
                    id: moodMax
                    width: parent.width / 2
                    label: qsTr("To")
                    value: appWindow.moodTexts[menu.selectedIndex]
                    property int moodIndex: menu.selectedIndex
                    menu: MoodMenu { selectedIndex: 0 }
                }
            }

            SectionHeader {
                text: qsTr("Entry date")
            }

            Row {
                width: parent.width

                DatePickerCombo {
                    id: dateMin
                    width: parent.width / 2
                    label: qsTr("From")
                    emptyText: qsTr("anytime", "search option, as in: " +
                                    "“match all entries regardless of their date”")
                }

                DatePickerCombo {
                    id: dateMax
                    width: parent.width / 2
                    label: qsTr("Till")
                    emptyText: qsTr("anytime", "search option, as in: " +
                                    "“match all entries regardless of their date”")
                }
            }
        }
    }
}
