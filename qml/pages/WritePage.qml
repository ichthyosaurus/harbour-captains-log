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

Dialog {
    id: page
    allowedOrientations: Orientation.All // effective value restricted by ApplicationWindow.allowedOrientations

    onStatusChanged: {
        // make sure the date is always correct, even if the page has been
        // on the stack for a long time
        if (status !== PageStatus.Activating) return;
        currentDate = new Date().toLocaleString(Qt.locale(), fullDateTimeFormat);
        dbCurrentDate = new Date().toLocaleString(Qt.locale(), dbDateFormat);
    }

    property string currentDate: new Date().toLocaleString(Qt.locale(), fullDateTimeFormat);
    property string dbCurrentDate: new Date().toLocaleString(Qt.locale(), dbDateFormat);
    property bool editing: rowid > -1

    property string _currentChangeDate: dbCurrentDate
    property string createDate: ""
    property string modifyDate: ""
    property alias title: titleField.text
    property alias entry: entryArea.text
    property alias hashtags: hashtagField.text
    property alias mood: feelCombo.selectedIndex
    property string createTz: ""
    property string modifyTz: ""
    property int rowid: -1
    property int index: -1
    property var model: ""

    acceptDestination: Qt.resolvedUrl("FirstPage.qml")
    onAccepted: {
        var createDate = dbCurrentDate
        var mood = feelCombo.selectedIndex
        var title_text = titleField.text.trim()
        // regular expression to kick out all newline chars in preview
        var preview = entryArea.text.substring(0, 150).replace(/\r?\n|\r/g, " ").trim()
        var entry = entryArea.text.trim()
        var hashs = hashtagField.text.trim()

        if (editing) {
            updateEntry(model, index, _currentChangeDate, mood, title_text, preview, entry, hashs, timezone, rowid);
        } else {
            addEntry(createDate, mood, title_text, preview, entry, hashs);
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge
        VerticalScrollDecorator { flickable: flick }

        Column {
            id: content
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                title: editing ? qsTr("Edit Entry") : qsTr("New Entry")
                acceptText: qsTr("Save")
            }

            Column {
                id: datesColumn
                visible: editing
                opacity: Theme.opacityHigh
                anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin }

                Row {
                    spacing: Theme.paddingSmall
                    Label { color: Theme.highlightColor; text: qsTr("Created:") }
                    Label { color: Theme.primaryColor; text: formatDate(createDate, fullDateTimeFormat, createTz) }
                }
                Row {
                    spacing: Theme.paddingSmall
                    Label { color: Theme.secondaryHighlightColor; text: qsTr("Last changed:") }
                    Label { color: Theme.secondaryColor; text: modifyDate === "" ? qsTr("never") : formatDate(modifyDate, fullDateTimeFormat, modifyTz) }
                }
            }

            Label {
                anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin }
                visible: !datesColumn.visible
                color: Theme.highlightColor
                text: currentDate
            }

            ComboBox {
                id: feelCombo
                property int selectedIndex: 2
                value: moodTexts[selectedIndex]
                width: parent.width
                description: editing ? qsTr("How did you feel?") : qsTr("How do you feel?")
                label: qsTr("Your mood:")

                menu: ContextMenu {
                    id: menu
                    Flow {
                        anchors.horizontalCenter: parent.horizontalCenter
                        property int maxPerLine: Math.floor(parent.width / Theme.itemSizeMedium)
                        property int itemsPerLine: ((maxPerLine > 3) ? 3 : maxPerLine)

                        width: itemsPerLine*Theme.itemSizeMedium
                        height: Math.ceil(moodTexts.length/itemsPerLine)*Theme.itemSizeMedium

                        Repeater {
                            model: moodTexts
                            delegate: BackgroundItem {
                                property bool selected: index === feelCombo.selectedIndex
                                width: Theme.itemSizeMedium; height: width
                                highlighted: down || selected

                                HighlightImage {
                                    anchors.centerIn: parent
                                    source: "../images/mood-%1.png".arg(index)
                                    highlighted: parent.highlighted
                                    color: Theme.primaryColor
                                    highlightColor: Theme.highlightColor
                                }

                                onClicked: {
                                    feelCombo.selectedIndex = index
                                    menu.close()
                                }
                            }
                        }
                    }
                }
            }

            TextField {
                id: titleField
                width: parent.width
                placeholderText: qsTr("Add a title")
                label: qsTr("Title")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    entryArea.focus = true
                }
            }

            TextArea {
                id: entryArea

                width: parent.width
                placeholderText: editing ? qsTr("What do you want to say?") : qsTr("Entry...")
                label: qsTr("Entry")
                wrapMode: TextEdit.WordWrap
            }

            TextField {
                id: hashtagField

                width: parent.width
                placeholderText: qsTr("Hashtags")
                font.pixelSize: Theme.fontSizeExtraSmall
                label: qsTr("#Hashtags")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    hashtagField.focus = false
                }
            }
        }
    }
}
