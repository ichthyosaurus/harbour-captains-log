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
            filteredModel.clear()
            placeholder.enabled = (result.length === 0);
            for(var i=0; i<result.length; i++) filteredModel.append(result[i])
        })
    }

    Component {
        id: datePicker
        DatePickerDialog {}
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
                        onClicked: filteredModel.clear()
                    }

                    MenuItem {
                        property string type: "creation"
                        text: qsTr("Creation date")
                        onClicked: {
                            filteredModel.clear()
                            var dialog = pageStack.push(datePicker)
                            dialog.accepted.connect(function() {
                                var dateString = dialog.date.toLocaleString(Qt.locale(), dbDateFormat)
                                py.call("diary.search_date", [dateString], function() { loadFilteredModel() })
                            })
                        }
                    }

                    MenuItem {
                        property string type: "favorites"
                        text: qsTr("Favorites")
                        onClicked: {
                            filteredModel.clear()
                            py.call("diary.search_favorites", [])
                            loadFilteredModel()
                        }
                    }

                    MenuItem {
                        property string type: "hashtags"
                        text: qsTr("Hashtag")
                        onClicked: filteredModel.clear()
                    }

                    MenuItem {
                        property string type: "mood"
                        text: qsTr("Mood")
                        onClicked: filteredModel.clear()
                    }
                }
            }

            ComboBox {
                id: moodCombo
                width: parent.width

                // not visible until mood is selected as filter
                visible: filterCombo.currentItem.type === "mood" ? true : false

                label: qsTr("Filter:", "the mood filter to apply")
                description: qsTr("Filter results by mood")
                currentIndex: -1

                menu: ContextMenu {
                    Repeater {
                        model: moodTexts
                        delegate: MenuItem {
                            text: moodTexts[index]
                            onClicked: py.call("diary.search_mood", [index], function() { loadFilteredModel() })
                        }
                    }
                }
            }

            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search your entries...")

                // only active for text search
                active: filterCombo.currentItem.type === "entry" || filterCombo.currentItem.type === "hashtags" ? true : false

                // Show 'next' icon to indicate pressing Enter will move the
                // keyboard focus to the next text field in the page
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    var type = filterCombo.currentItem.type
                    if (type === "entry") {
                        py.call("diary.search_entries", [searchField.text], function() { loadFilteredModel() });
                    } else if (type === "hashtags") {
                        py.call("diary.search_hashtags", [searchField.text], function() { loadFilteredModel() });
                    }
                }
            }
        }

        ViewPlaceholder {
            id: placeholder
            enabled: false
            text: qsTr("No entries found")
            hintText: qsTr("No entries matched these criteria.")
        }
    }
}
