import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page

    ConfigurationValue {
        id: protectionCode
        key: "/protectionCode"
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: content
        anchors.fill: parent

        Column {

            width: parent.width - (2*Theme.horizontalPageMargin)

            PageHeader {
                title: protectionCode.value === "-1" ? qsTr("Set your code") : qsTr("Change your code")
            }

            TextField {
                id: oldField

                width: parent.width
                placeholderText: qsTr("Your old code")
                validator: IntValidator {bottom: 0; top: 9999}
                inputMethodHints: Qt.ImhDigitsOnly
                // this field is visible only in case of a code change and need to be filled with the correct code to allow a change
                visible: protectionCode.value === "-1" ? false : true
            }
            TextField {
                id: newField

                width: parent.width
                placeholderText: qsTr("Your new code")
                echoMode: TextInput.Password
                validator: IntValidator {bottom: 0; top: 9999}
                inputMethodHints: Qt.ImhDigitsOnly
                // if no code was set or the old pin was entered correctly (in case of change) - show this field
                visible: protectionCode.value === "-1"  || protectionCode.value === oldField.text ? true : false
            }
            Button {
                id: saveButton

                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Save")
                visible: newField.text !== ""
                onClicked: {
                    protectionCode.value = newField.text
                    pageStack.pop()
                    showMessage(qsTr("Saved your protection code."))
                }
            }
        }
    }
}
