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

    property string change_date_p: getCurrentDate()+" | "+getCurrentTime()
    property string title_p
    property int mood_p
    property string entry_p
    property string hashtags_p
    property int rowid_p

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {

        anchors.fill: parent

        contentHeight: content.height

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Save")
                onClicked: {
                    var mood = feelCombo.currentIndex
                    var title_text = title.text
                    var entry = entryArea.text
                    var preview = entryArea.text.substring(0, 100).replace(/\r?\n|\r/g, " ") // regular expression to kick out all newline chars in preview
                    var hashs = hashtagField.text

                    py.call("diary.update_entry", [change_date_p, mood, title_text, preview, entry, hashs, rowid_p], function() {
                            console.log("Updated entry in database")
                        }
                    )
                    pageStack.navigateBack()
                    showMessage(qsTr("Saved your changes."))
                }
            }
        }

        Column {
            id: content

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - (2*Theme.horizontalPageMargin)
            spacing: Theme.paddingMedium

            PageHeader {
                id: header

                title: qsTr("Edit Entry")
            }

            Label {
                id: dateLabel
                width: parent.width
                text: qsTr("Changed at: ") + change_date_p
                color: Theme.highlightColor
            }

            ComboBox {
                id: feelCombo

                width: parent.width
                description: qsTr("How did you really felt?")
                label: qsTr("Your mood:")
                currentIndex: mood_p

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
                label: qsTr("Change your Title")
                placeholderText: qsTr("You might add a title?")
                text: title_p
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    entryArea.focus = true
                }
            }

            TextArea {
                id: entryArea

                width: parent.width
                label: qsTr("Change your entry")
                placeholderText: qsTr("Haven't you something to say?")
                wrapMode: TextEdit.WordWrap
                text: entry_p
            }
            TextField {
                id: hashtagField

                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                label: qsTr("Change your #hashtags")
                placeholderText: qsTr("Everything is better with Hashtags!")
                text: hashtags_p
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: {
                    hashtagField.focus = false
                }
            }
        }
    }
}

