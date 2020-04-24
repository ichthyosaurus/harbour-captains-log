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

        // TODO implement signalling so that we can allow editing from here
        // Currently, only the main entriesModel is updated and all
        // update functions expect index values the same. Of course, they
        // are not the same as for our filteredModel.
        // We do NOT want Connections in every single EntryElement. That
        // is horrible for performance.
        editable: false

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
