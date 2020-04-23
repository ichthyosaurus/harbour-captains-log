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

        Label {
            id: infoLabel
            anchors {
                top: parent.top; bottom: errorLabel.top
                left: parent.left; right: parent.right
                leftMargin: 3*Theme.paddingLarge; rightMargin: 3*Theme.paddingLarge
            }

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade

            text: qsTr("Please enter your security code")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
        }

        Label {
            id: errorLabel
            anchors.bottom: pinRow.top
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryColor
            text: qsTr("please try again")
            Behavior on opacity { NumberAnimation { duration: 200 } }
            opacity: 0
        }

        // input field with delete button
        Row {
            id: pinRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: keypad.top
            width: parent.width * 0.66

            TextField {
                id: pinField
                anchors.verticalCenter: deleteButton.verticalCenter
                width: parent.width - deleteButton.width
                readOnly: true
                font.pixelSize: 1.5*Theme.fontSizeHuge
                echoMode: TextInput.Password
                passwordCharacter: "\u2022"
                validator: IntValidator {bottom: 0; top: 9}
                horizontalAlignment: Text.AlignRight
                labelVisible: false
                textTopMargin: 0
                textMargin: 0
                color: Theme.highlightColor
                onTextChanged: {
                    // reset color and error label after incorrect input
                    color = Theme.highlightColor
                    errorLabel.opacity = 0.0
                }
            }

            IconButton {
                id: deleteButton
                icon.source: "image://theme/icon-m-backspace-keypad"
                visible: pinField.text.length === 0 ? false : true
                onClicked: {
                    var s = pinField.text
                    pinField.text = s.substring(0, s.length-1)
                }
            }
        }

        BackgroundItem {
            id: enterButton
            highlighted: down
            highlightedColor: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
            width: keypad._buttonWidth
            height: keypad._buttonHeight

            anchors {
                right: keypad.right; rightMargin: keypad._horizontalPadding
                bottom: keypad.bottom
                bottomMargin: 0
            }

            Icon {
                id: icon
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -Theme.fontSizeExtraSmall / 3
                }
                source: "image://theme/icon-m-accept"
                highlighted: parent.highlighted
                color: Theme.primaryColor
            }

            onClicked: {
                if (pinField.text === protectionCode.value) {
                    canNavigateForward = true
                    forwardNavigation = true
                    appWindow.unlocked = true
                    pageStack.navigateForward()
                } else {
                    pinField.color = Theme.secondaryColor
                    errorLabel.opacity = 1.0
                }
            }
        }

        Keypad {
            id: keypad
            anchors {
                bottom: parent.bottom; bottomMargin: Theme.paddingLarge
                left: parent.left; leftMargin: Theme.horizontalPageMargin
                right: parent.right; rightMargin: Theme.horizontalPageMargin
            }

            vanityDialNumbersVisible: false
            symbolsVisible: false
            onClicked: pinField.text = pinField.text + number
        }

        Item {
            id: spacer
            width: parent.width
            height: Theme.paddingLarge
        }
    }
}
