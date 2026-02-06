/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020-2026 Mirian Margiani
 * SPDX-FileCopyrightText: 2025 Smooth-E
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page

    property string expectedCode: ""
    property alias enteredCode: pinField.text
    property string title: qsTr("Please enter your security code")

    signal accepted

    allowedOrientations: Orientation.All
    state: isLandscape ? "landscape" : "portrait"

    states: [
        State {
            name: "landscape"

            AnchorChanges {
                target: infoContainer

                anchors {
                    verticalCenter: page.verticalCenter
                    bottom: undefined
                }
            }

            AnchorChanges {
                target: keypadContainer
                anchors.left: infoContainer.right
            }
        },
        State {
            name: "portrait"

            AnchorChanges {
                target: infoContainer

                anchors {
                    verticalCenter: undefined
                    bottom: keypadContainer.top
                }
            }

            AnchorChanges {
                target: keypadContainer
                anchors.left: page.left
            }
        }
    ]

    Column {
        id: infoContainer

        anchors {
            left: parent.left
            rightMargin: Theme.paddingLarge
            leftMargin: Theme.paddingLarge
        }

        width: (isLandscape ? parent.width / 2 : parent.width) - Theme.paddingLarge * 2
        height: childrenRect.height
        spacing: Theme.paddingMedium

        Label {
            id: infoLabel

            width: parent.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade

            text: title
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
        }

        Label {
            id: errorLabel

            property bool haveError: false

            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryColor
            text: qsTr("please try again")
            opacity: haveError ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        TextField {
            id: pinField

            width: keypad.width
            readOnly: true
            font.pixelSize: 1.5 * Theme.fontSizeHuge
            echoMode: TextInput.Password
            passwordCharacter: "\u2022"
            horizontalAlignment: Text.AlignHCenter
            labelVisible: false
            textTopMargin: 0
            textMargin: 0
            color: Theme.highlightColor

            validator: IntValidator {
                bottom: 0
                top: 9
            }

            onTextChanged: {
                // reset color and error label after incorrect input
                color = Theme.highlightColor
                errorLabel.haveError = false
            }
        }
    }

    Item {
        id: keypadContainer

        anchors.bottom: parent.bottom
        width: isLandscape ? parent.width / 2 : parent.width
        height: isLandscape ? parent.height : parent.height / 2

        Keypad {
            id: keypad

            anchors.centerIn: parent
            vanityDialNumbersVisible: false
            symbolsVisible: false

            onClicked: {
                if (errorLabel.haveError) {
                    // delete wrong pin and try again
                    pinField.text = number
                } else {
                    pinField.text = pinField.text + number
                }
            }
        }

        KeypadButton {
            id: enterButton

            width: keypad._buttonWidth
            height: keypad._buttonHeight

            anchors {
                right: keypad.right
                bottom: keypad.bottom
                rightMargin: keypad._horizontalPadding
            }

            icon.source: "image://theme/icon-m-accept"

            onClicked: {
                if (expectedCode === "" || pinField.text === expectedCode) {
                    appWindow.unlocked = true
                    accepted()
                } else {
                    pinField.color = Theme.secondaryColor
                    errorLabel.haveError = true
                }
            }
        }

        KeypadButton {
            id: deleteButton

            width: keypad._buttonWidth
            height: keypad._buttonHeight

            anchors {
                left: keypad.left
                bottom: keypad.bottom
                leftMargin: keypad._horizontalPadding
            }

            icon.source: "image://theme/icon-m-backspace-keypad"
            opacity: pinField.text.length > 0 ? 1 : 0
            enabled: opacity === 1
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            onClicked: pinField.text = pinField.text.substring(0, pinField.text.length - 1)
        }
    }
}
