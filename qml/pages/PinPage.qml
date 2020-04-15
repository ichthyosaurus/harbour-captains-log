import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page

    ConfigurationValue {
        id: protectionCode
        key: "/protectionCode"
    }

    // attach main page, that can be opened, if pin is accepted
    onForwardNavigationChanged: pageStack.pushAttached(Qt.resolvedUrl("FirstPage.qml"))
    canNavigateForward: false

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: content

        anchors.fill: parent

        PageHeader {
            id: header

            title: qsTr("Enter your code")
        }

        Label {
            id: infoLabel

            anchors.bottom: pinRow.top
            anchors.horizontalCenter: parent.horizontalCenter

            //width: parent.width - (2*Theme.horizontalPageMargin)
            text: qsTr("Please type in your security code:")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }

        // input field with delete button
        Row {
            id: pinRow

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: keypad.top

            width: parent.width * 0.66

            TextField {
                id: pinField

                width: parent.width - deleteButton.width
                font.pixelSize: Theme.fontSizeLarge
                readOnly: true
                echoMode: TextInput.Password
                validator: IntValidator {bottom: 0; top: 9}
            }
            IconButton {
                id: deleteButton

                icon.source: "image://theme/icon-m-backspace-keypad"
                visible: pinField.text.length === 0 ? false : true
                onClicked: {
                    var s = pinField.text
                    pinField.text = s.substring(0, s.length -1)
                }
            }
        }

        // keypad for code input
        Keypad {
            id: keypad

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge

            width: parent.width - (2*Theme.horizontalPageMargin)
            vanityDialNumbersVisible: false
            symbolsVisible: false

            onPressed: {
                pinField.text = pinField.text + number
            }
            onReleased: {
                // fill variable code from python code
                if (pinField.text === protectionCode.value) {

                    infoLabel.visible = false
                    pinRow.visible = false
                    keypad.visible = false
                    imgCheck.visible = true

                    canNavigateForward = true
                    page.forwardNavigation = true
                    header.title = qsTr("Access granted")

                    // set app to unlocked state
                    appWindow.unlocked = true
                }
            }
        }

        // just adding some space
        Item {
            width: parent.width
            height: Theme.paddingLarge
        }

        // visual information that the code was okay
        Image {
            id: imgCheck

            anchors.centerIn: parent
            visible: false
            source: "image://theme/icon-l-acknowledge"
        }
    }
}


