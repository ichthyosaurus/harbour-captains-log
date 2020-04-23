import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page

    function getDateString(selection) {
        var date = selection
        var year = date.getFullYear()
        var month = add_leading_zero(date.getMonth()+1) // JS Date starts index with 0
        var day = add_leading_zero(date.getDate())

        return day+"."+month+"."+year
    }

    function add_leading_zero(s) {
        return String("0"+s).slice(-2)
    }

    function loadModel() {
        console.log("loadModel() function @ SearchPage was called")
        py.call("diary.get_filtered_entry_list", [], function(result) {
            entriesModel.clear()
            for(var i=0; i<result.length; i++) {
                entriesModel.append(result[i])
            }
            resultList.model = entriesModel
        }
        )
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: content
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Search")
        }

        ComboBox {
            id: filterCombo
            anchors.top: header.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            description: qsTr("Filter your results")
            label: qsTr("Search by:")
            currentIndex: 0

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Title & Entry")
                    onClicked: {
                        entriesModel.clear()
                    }
                }
                MenuItem {
                    text: qsTr("Creation date")
                    onClicked: {
                        entriesModel.clear()
                        var selectedDate = pageStack.push(datePicker)
                        selectedDate.accepted.connect(function() {
                            var dateStr = add_leading_zero(selectedDate.day)+"."+add_leading_zero(selectedDate.month)+"."+selectedDate.year
                            py.call("diary.search_date", [dateStr], function() {loadModel()})
                            pageStack.navigateBack()
                        }
                        )
                    }
                }
                MenuItem {
                    text: qsTr("Favorites")
                    onClicked: {
                        entriesModel.clear()
                        py.call("diary.search_favorites", [])
                        loadModel()
                    }
                }
                MenuItem {
                    text: qsTr("Hashtag")
                    onClicked: {
                        entriesModel.clear()
                    }
                }
                MenuItem {
                    text: qsTr("Mood")
                    onClicked: {
                        entriesModel.clear()
                    }
                }
            }
        }

        ComboBox {
            id: moodCombo

            anchors.top: filterCombo.bottom
            anchors.right: parent.right
            anchors.left: parent.left

            // not visible until mood is selected as filter
            visible: filterCombo.currentIndex === 4 ? true : false

            label: qsTr("Filter:", "the mood filter to apply")
            description: qsTr("Filter results by mood")
            currentIndex: -1

            menu: ContextMenu {
                Repeater {
                    model: moodTexts
                    delegate: MenuItem {
                        text: moodTexts[index]
                        onClicked: py.call("diary.search_mood", [index], function() {loadModel()})
                    }
                }
            }
        }

        Component {
            id: datePicker
            DatePickerDialog {}
        }

        SilicaListView {
            id: resultList

            anchors.top: moodCombo.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            header: SearchField {
                id: searchField

                // just active in case of text search (title & entry or hashtags)
                active: filterCombo.currentIndex === 0 || filterCombo.currentIndex === 3 ? true : false

                width: parent.width
                placeholderText: qsTr("Search your entries...")

                // Show 'next' icon to indicate pressing Enter will move the
                // keyboard focus to the next text field in the page
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    switch(filterCombo.currentIndex) {
                    case 0:
                        py.call("diary.search_entries", [searchField.text], function() {
                            loadModel()
                        });
                        break;
                    case 3:
                        py.call("diary.search_hashtags", [searchField.text], function() {
                            loadModel()
                        });
                        break;
                    }
                }
            }

            clip: true
            model: entriesModel
            delegate: EntryElement {}
        }

        ListModel {
            id: entriesModel
        }
    }
}
