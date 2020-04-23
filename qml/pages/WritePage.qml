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

    property string creationDate: ""
    property string changeDate: dbCurrentDate
    property alias title: titleField.text
    property alias entry: entryArea.text
    property alias hashtags: hashtagField.text
    property alias mood: feelCombo.currentIndex
    property int rowid: -1
    property int index: -1

    acceptDestination: Qt.resolvedUrl("FirstPage.qml")
    onAccepted: {
        var creationDate = dbCurrentDate
        var mood = feelCombo.currentIndex
        var title_text = titleField.text.trim()
        // regular expression to kick out all newline chars in preview
        var preview = entryArea.text.substring(0, 150).replace(/\r?\n|\r/g, " ").trim()
        var entry = entryArea.text.trim()
        var hashs = hashtagField.text.trim()

        if (editing) {
            updateEntry(index, changeDate, mood, title_text, preview, entry, hashs, rowid);
        } else {
            addEntry(creationDate, mood, title_text, preview, entry, hashs);
        }
    }

    SilicaFlickable {
        id: content
        anchors.fill: parent
        VerticalScrollDecorator { flickable: content }

        Column {
            anchors.fill: parent
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
                    Label { color: Theme.primaryColor; text: parseDate(creationDate).toLocaleString(Qt.locale(), fullDateTimeFormat) }
                }
                Row {
                    spacing: Theme.paddingSmall
                    Label { color: Theme.secondaryHighlightColor; text: qsTr("Changed:") }
                    Label { color: Theme.secondaryColor; text: currentDate }
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

                currentIndex: 2
                width: parent.width
                description: editing ? qsTr("How did you feel?") : qsTr("How do you feel?")
                label: qsTr("Your mood:")

                menu: ContextMenu {
                    MenuItem { text: moodTexts[0] }
                    MenuItem { text: moodTexts[1] }
                    MenuItem { text: moodTexts[2] }
                    MenuItem { text: moodTexts[3] }
                    MenuItem { text: moodTexts[4] }
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
