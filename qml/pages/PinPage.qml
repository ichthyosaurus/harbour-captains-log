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

Page {
    id: page
    allowedOrientations: Orientation.All

    property string expectedCode: ""
    property alias enteredCode: pinField.text
    property string title: qsTr("Please enter your security code")

    signal accepted

    SilicaFlickable {
        id: content
        anchors.fill: parent
        contentHeight: Screen.height
        VerticalScrollDecorator { flickable: content }

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

            text: title
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
        }

        Label {
            id: errorLabel
            property bool haveError: false
            onHaveErrorChanged: opacity = haveError ? 1.0 : 0.0

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
                    errorLabel.haveError = false
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
                if (expectedCode === "" || pinField.text === expectedCode) {
                    appWindow.unlocked = true
                    accepted()
                } else {
                    pinField.color = Theme.secondaryColor
                    errorLabel.haveError = true
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
            onClicked: {
                if (errorLabel.haveError) pinField.text = number // delete wrong pin and try again
                else pinField.text = pinField.text + number
            }
        }

        Item {
            id: spacer
            width: parent.width
            height: Theme.paddingLarge
        }
    }
}
