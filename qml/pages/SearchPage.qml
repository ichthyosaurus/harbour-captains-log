/*
 * This file is part of harbour-captains-log.
 * Copyright (C) 2020  Gabriel Berkigt, Mirian Margiani
 *
 * harbour-captains-log is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-captains-log is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-captains-log.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    function loadFilteredModel() {
        console.log("loading filtered model...")
        py.call("diary.get_filtered_entry_list", [], function(result) {
            resetFilteredModel()
            placeholder.enabled = (result.length === 0);
            for(var i=0; i<result.length; i++) filteredModel.append(result[i])
        })
    }

    function resetFilteredModel() {
        filteredModel.clear()
        placeholder.enabled = false
    }

    DiaryListView {
        id: listView
        anchors.fill: parent
        model: ListModel { id: filteredModel }
        editable: true

        header: Column {
            width: parent.width
            PageHeader {
                id: header
                title: qsTr("Search")
            }

            ComboBox {
                id: filterCombo
                width: parent.width

                description: qsTr("Filter your results")
                label: qsTr("Search by:")
                currentIndex: 0

                menu: ContextMenu {
                    MenuItem {
                        property string type: "entry"
                        text: qsTr("Title and Entry")
                        onClicked: resetFilteredModel()
                    }

                    MenuItem {
                        property string type: "creation"
                        text: qsTr("Creation date")
                        onClicked: resetFilteredModel()
                    }

                    MenuItem {
                        property string type: "favorites"
                        text: qsTr("Favorites")
                        onClicked: {
                            resetFilteredModel()
                            py.call("diary.search_favorites", [])
                            loadFilteredModel()
                        }
                    }

                    MenuItem {
                        property string type: "hashtags"
                        text: qsTr("Hashtag")
                        onClicked: resetFilteredModel()
                    }

                    MenuItem {
                        property string type: "mood"
                        text: qsTr("Mood")
                        onClicked: resetFilteredModel()
                    }
                }
            }

            ComboBox {
                id: moodCombo
                width: parent.width
                label: qsTr("Filter:", "the mood filter to apply")
                description: qsTr("Filter results by mood")
                currentIndex: -1

                // not visible until mood is selected as filter
                visible: filterCombo.currentItem.type === "mood" ? true : false
                onVisibleChanged: if (visible) refresh(currentIndex)

                function refresh(index) {
                    if (index < 0) return
                    py.call("diary.search_mood", [index], function() { loadFilteredModel() })
                }

                menu: ContextMenu {
                    Repeater {
                        model: moodTexts
                        delegate: MenuItem {
                            text: moodTexts[index]
                            onClicked: moodCombo.refresh(index)
                        }
                    }
                }
            }

            SearchField {
                id: searchField
                width: parent.width
                property string type: filterCombo.currentItem.type
                placeholderText: qsTr("Search your entries...")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: { focus = false; refresh() }
                EnterKey.enabled: searchField.text.length > 0

                // only visible for text search
                visible: filterCombo.currentItem.type === "entry" || filterCombo.currentItem.type === "hashtags" ? true : false
                onVisibleChanged: if (visible) refresh()
                onTypeChanged: if (visible) refresh()

                function refresh() {
                    if (searchField.text === "") return
                    var type = filterCombo.currentItem.type
                    if (type === "entry") {
                        py.call("diary.search_entries", [searchField.text], function() { loadFilteredModel() });
                    } else if (type === "hashtags") {
                        py.call("diary.search_hashtags", [searchField.text], function() { loadFilteredModel() });
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            Row {
                id: dateRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingMedium
                height: childrenRect.height + Theme.paddingLarge

                // not visible until creation date is selected as filter
                visible: filterCombo.currentItem.type === "creation" ? true : false
                onVisibleChanged: if (visible) refresh()

                function refresh(selectedDate, otherButton) {
                    if (selectedDate && !otherButton.haveDate) {
                        otherButton._selectedDate = selectedDate
                        return
                    }

                    resetFilteredModel()
                    var from = fromDate.selectedDateString
                    var till = tillDate.selectedDateString

                    if (fromDate._selectedDate.getTime() > tillDate._selectedDate.getTime()) {
                        from = tillDate.selectedDateString
                        till = fromDate.selectedDateString
                    }

                    if (from === "" || till === "") return
                    py.call("diary.search_date", [from, till], function() { loadFilteredModel() })
                }

                DateButton {
                    id: fromDate
                    text: qsTr("from", "search entries between 'from' and 'till'")
                    on_SelectedDateChanged: dateRow.refresh(_selectedDate, tillDate)
                }
                DateButton {
                    id: tillDate
                    text: qsTr("till", "search entries between 'from' and 'till'")
                    on_SelectedDateChanged: dateRow.refresh(_selectedDate, fromDate)
                }
            }
        }

        ViewPlaceholder {
            id: placeholder
            enabled: false
            text: qsTr("No entries found")
            hintText: qsTr("No entries matched these criteria.")
            verticalOffset: listView.headerItem.height
        }
    }
}
