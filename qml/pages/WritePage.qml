import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    function getCurrentDate() {
        var date = new Date()
        var year = date.getFullYear()
        var month = add_leading_zero(date.getMonth()+1) // JS Date starts index with 0
        var day = add_leading_zero(date.getDate())

        return day+"."+month+"."+year
    }

    function getCurrentTime() {
        var date = new Date()
        var hour = add_leading_zero(date.getHours())
        var min = add_leading_zero(date.getMinutes())

        return hour+":"+min
    }

    function add_leading_zero(s) {
        return String("0"+s).slice(-2)
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: content

        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Save")
                onClicked: {
                    var creation_date = getCurrentDate() + " | "+getCurrentTime()
                    var mood = feelCombo.currentIndex
                    var title_text = title.text
                    var preview = entryArea.text.substring(0, 100).replace(/\r?\n|\r/g, " ") // regular expression to kick out all newline chars in preview
                    var entry = entryArea.text
                    var hashs = hashtagField.text

                    py.call("diary.add_entry", [creation_date, mood, title_text, preview, entry, hashs], function() {
                            console.log("Added entry to database")
                        }
                    )

                    pageStack.navigateBack()
                }
            }
        }

        Column {

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - (2*Theme.horizontalPageMargin)
            height: parent.height - (header.height+dateLabel.height)
            spacing: Theme.paddingMedium

            PageHeader {
                id: header

                title: qsTr("New Entry")
            }

            Label {
                id: dateLabel
                width: parent.width
                text: getCurrentDate()
                color: Theme.highlightColor
            }

            ComboBox {
                id: feelCombo

                width: parent.width
                description: qsTr("How do you feel today?")
                label: qsTr("Your mood:")

                menu: ContextMenu {
                         MenuItem { text: qsTr("fantastic") }
                         MenuItem { text: qsTr("good") }
                         MenuItem { text: qsTr("okay") }
                         MenuItem { text: qsTr("bad") }
                         MenuItem { text: qsTr("horrible") }
                }
            }

            TextField {
                id: title
                width: parent.width
                placeholderText: qsTr("Your Title")
                label: qsTr("Title")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    entryArea.focus = true
                }
            }

            TextArea {
                id: entryArea

                width: parent.width
                placeholderText: qsTr("New Entry")
                label: qsTr("Entry")
                wrapMode: TextEdit.WordWrap
            }
            TextField {
                id: hashtagField

                width: parent.width
                placeholderText: qsTr("Add some Hashtags")
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

