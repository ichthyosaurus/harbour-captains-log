/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Opal.SortFilterProxyModel 1.0
import Opal.MenuSwitch 1.0
import Opal.InfoCombo 1.0 as I
import Opal.ComboData 1.0 as C
import Opal.LinkHandler 1.0 as L
import "../components"

Dialog {
    id: root
    allowedOrientations: Orientation.All

    property bool enableFilterSelected: false
    readonly property var activeQueries: _activeQueriesProxy

    property var _activeQueriesProxy: SearchQueriesData {}
    readonly property SearchQueriesData _queries: SearchQueriesData {
        matchAllMode: true
        text: textField.text
        textMatchSyntax: textSyntax.currentItem.mode
        textMatchMode: textMode.currentItem.mode
        dateMin: !dateMin.selectedDate || isNaN(dateMin.selectedDate.valueOf()) ?
                     _queries.dateMinUnset : dateMin.selectedDate
        dateMax: !dateMax.selectedDate || isNaN(dateMax.selectedDate.valueOf()) ?
                     _queries.dateMaxUnset : dateMax.selectedDate
        bookmark: bookmarks.currentItem.mode
        selected: enableFilterSelected ? onlySelected.currentItem.mode : Qt.PartiallyChecked
        tags: ([])
        tagsNormalized: ([])
        moodMin: Math.min(moodMin.moodIndex, moodMax.moodIndex)
        moodMax: Math.max(moodMin.moodIndex, moodMax.moodIndex)
    }

    function resetQueries(newQueries) {
        _queries.matchAllMode = newQueries.matchAllMode
        textField.text = newQueries.text
        textSyntax.currentIndex = textSyntax.indexOfData(newQueries.textMatchSyntax)
        textMode.currentIndex = textMode.indexOfData(newQueries.textMatchMode)
        dateMin.selectedDate = (newQueries.dateMin.valueOf() ===
            _queries.dateMinUnset.valueOf()) ? new Date(NaN) : newQueries.dateMin
        dateMax.selectedDate = (newQueries.dateMax.valueOf() ===
            _queries.dateMaxUnset.valueOf()) ? new Date(NaN) : newQueries.dateMax
        bookmarks.currentIndex = bookmarks.indexOfData(newQueries.bookmark)
        onlySelected.currentIndex = onlySelected.indexOfData(newQueries.selected)
        _queries.tags = newQueries.tags
        _queries.tagsNormalized = newQueries.tagsNormalized
        moodMin.menu.selectedIndex = newQueries.moodMin
        moodMax.menu.selectedIndex = newQueries.moodMax
    }

    function copyQueries(source, dest) {
        // Copy the full query to a separate object so
        // that changing any field on the query page does
        // not automatically restart the search. Searching
        // after every key press is slow in large databases.
        dest.matchAllMode = source.matchAllMode
        dest.text = source.text
        dest.textMatchSyntax = source.textMatchSyntax
        dest.textMatchMode = source.textMatchMode
        dest.dateMin = source.dateMin
        dest.dateMax = source.dateMax
        dest.bookmark = source.bookmark
        dest.selected = source.selected
        dest.tags = source.tags
        dest.tagsNormalized = source.tagsNormalized
        dest.moodMin = source.moodMin
        dest.moodMax = source.moodMax
    }

    onAcceptPendingChanged: {
        if (acceptPending) {
            copyQueries(_queries, activeQueries)
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        PullDownMenu {
            flickable: listView

            MenuSwitch {
                automaticCheck: false
                checked: !_queries.matchAllMode
                onClicked: _queries.matchAllMode = false
                text: qsTr("Any may match")
            }

            MenuSwitch {
                automaticCheck: false
                checked: _queries.matchAllMode
                onClicked: _queries.matchAllMode = true
                text: qsTr("All must match")
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

            SelectedTagsView {
                width: parent.width
                tagsList: _queries.tags

                onRemoveRequested: {
                    tagsField.text = tag
                    var index = _queries.tags.indexOf(tag)

                    if (index >= 0) {
                        _queries.tags.splice(index, 1)
                        _queries.tagsNormalized.splice(index, 1)
                        _queries.tags = _queries.tags
                        _queries.tagsNormalized = _queries.tagsNormalized
                    }
                }
            }

            SearchField {
                id: tagsField
                width: parent.width
                placeholderText: qsTr("Search tags")
                canHide: false
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }

            TagSuggestionsView {
                width: parent.width
                searchTerm: tagsField.text !== '' ?
                    tagsField.text : (tagsField.focus ? ' ' : '')

                onTagSelected: {
                    if (_queries.tags.indexOf(tag.text) < 0) {
                        _queries.tags = _queries.tags.concat([tag.text])
                        _queries.tagsNormalized = _queries.tagsNormalized.concat([tag.normalized])
                    }
                }
            }

            I.InfoCombo {
                id: textSyntax
                width: parent.width
                currentIndex: 0
                label: qsTr("Search syntax")
                linkHandler: L.LinkHandler.openOrCopyUrl

                property int currentData
                property var indexOfData
                C.ComboData { dataRole: "mode" }

                I.InfoComboSection {
                    text: qsTr("Use simplified plain text searching if you are unsure " +
                               "how you spelled something in the past: select “plain text” " +
                               "as search syntax here, and “simplified” as search mode in " +
                               "the separate setting.")
                    placeAtTop: true
                }

                menu: ContextMenu {
                    I.InfoMenuItem {
                        text: qsTr("plain text")
                        property int mode: RegExpFilter.FixedString
                        info: qsTr(
                            "Search for the string as you entered it. Note: some " +
                            "simplifications will be applied to the search term " +
                            "if the “Search mode” is set to “simplified”.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("wildcard")
                        property int mode: RegExpFilter.WildcardUnix
                        info: qsTr(
                            "This option allows to search for extended patterns. " +
                            "Use “?” to match any single character, and “*” to " +
                            "match zero or more characters. Groups of characters " +
                            "can be defined in square brackets. Use a backslash " +
                            "to search for literal “?” or “*”, e.g. “%1”.").arg("\\?")
                    }
                    I.InfoMenuItem {
                        text: qsTr("regular expression")
                        property int mode: RegExpFilter.RegExp
                        info: qsTr(
                            "Search using complex regular expressions. Use the " +
                            "vertical bar “|” to search for multiple terms. " +
                            "Search the Internet if you want to learn more about " +
                            "regular expressions.")
                    }
                }

                I.InfoComboSection {
                    placeAtTop: false
                    title: qsTr("Note")
                    text: "The search mode “simplified” is only " +
                          "available when the “plain text” search syntax is selected."
                }
            }

            I.InfoCombo {
                id: textMode
                width: parent.width
                currentIndex: 0
                enabled: textSyntax.currentItem.mode === RegExpFilter.FixedString
                label: qsTr("Search mode")
                linkHandler: L.LinkHandler.openOrCopyUrl

                Binding on currentIndex {
                    when: !textMode.enabled
                    value: 1
                }

                property int currentData
                property var indexOfData
                C.ComboData { dataRole: "mode" }

                menu: ContextMenu {
                    I.InfoMenuItem {
                        text: qsTr("simplified")
                        property int mode: _queries.matchSimplified
                        info: qsTr(
                            "Ignore diacritics on characters, matching e.g. “ö”, “ó”, and " +
                            "“õ” when searching for “o”. Ignore any punctuation marks. " +
                            "Use this mode when you are unsure how you spelled something " +
                            "in the past.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("strict")
                        property int mode: _queries.matchStrict
                        info: qsTr(
                            "Match the query string exactly. Use this mode when you know exactly " +
                            "what you are searching for, or when you want to search for a string " +
                            "containing punctuation marks like “-”, “!”, or “#”."
                        )
                    }
                }

                I.InfoComboSection {
                    placeAtTop: false
                    title: qsTr("Note")
                    text: "The search mode “simplified” is only " +
                          "available when the “plain text” search syntax is selected."
                }
            }

            I.InfoCombo {
                id: bookmarks
                width: parent.width
                currentIndex: 0
                label: qsTr("Bookmarks")
                linkHandler: L.LinkHandler.openOrCopyUrl

                property int currentData
                property var indexOfData
                C.ComboData { dataRole: "mode" }

                menu: ContextMenu {
                    I.InfoMenuItem {
                        text: qsTr("all entries", "search option, as in: " +
                                   "“find all entries, whether they are " +
                                   "bookmarked or not”")
                        property int mode: Qt.PartiallyChecked
                        info: qsTr(
                            "Find entries regardless of whether they are bookmarked " +
                            "or not.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("marked", "search option, as in: " +
                                   "“find only bookmarked entries”")
                        property int mode: Qt.Checked
                        info: qsTr("Find only bookmarked entries.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("unmarked", "search option, as in: " +
                                   "“find only entries that are not bookmarked”")
                        property int mode: Qt.Unchecked
                        info: qsTr("Find only entries that are not bookmarked.")
                    }
                }
            }

            I.InfoCombo {
                id: onlySelected
                width: parent.width
                visible: enableFilterSelected
                currentIndex: 0
                label: qsTr("Selection")
                linkHandler: L.LinkHandler.openOrCopyUrl

                property int currentData
                property var indexOfData
                C.ComboData { dataRole: "mode" }

                menu: ContextMenu {
                    I.InfoMenuItem {
                        text: qsTr("all entries", "search option, as in: " +
                                   "“find all entries, whether they are " +
                                   "currently selected or not”")
                        property int mode: Qt.PartiallyChecked
                        info: qsTr(
                            "Find entries regardless of whether they are selected " +
                            "or not.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("selected", "search option, as in: " +
                                   "“find only selected entries”")
                        property int mode: Qt.Checked
                        info: qsTr("Find only currently selected entries.")
                    }
                    I.InfoMenuItem {
                        text: qsTr("unselected", "search option, as in: " +
                                   "“find only entries that are not selected")
                        property int mode: Qt.Unchecked
                        info: qsTr("Find only entries that are currently not selected.")
                    }
                }
            }

            SectionHeader {
                text: qsTr("Mood")
                visible: config.useMoodTracking
            }

            Row {
                width: parent.width
                visible: config.useMoodTracking

                ComboBox {
                    id: moodMin
                    width: parent.width / 2
                    label: qsTr("From")
                    value: appWindow.moodTexts[menu.selectedIndex]
                    property int moodIndex: menu.selectedIndex
                    menu: MoodMenu { selectedIndex: appWindow.moodTexts.length-1 }
                    onPressAndHold: _controller.openMenu()
                }

                ComboBox {
                    id: moodMax
                    width: parent.width / 2
                    label: qsTr("To")
                    value: appWindow.moodTexts[menu.selectedIndex]
                    property int moodIndex: menu.selectedIndex
                    menu: MoodMenu { selectedIndex: 0 }
                    onPressAndHold: _controller.openMenu()
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
                    label: qsTr("Until")
                    emptyText: qsTr("anytime", "search option, as in: " +
                                    "“match all entries regardless of their date”")
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: qsTr("Press and hold to reset the date.")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                color: Theme.secondaryHighlightColor
            }
        }
    }
}
