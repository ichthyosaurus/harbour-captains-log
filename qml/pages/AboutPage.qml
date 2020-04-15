import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    anchors.fill: parent

    Column {
        anchors.top: header.bottom
        width: parent.width
        spacing: Theme.paddingMedium

        PageHeader {
            id: header
            title: qsTr("About")
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "/usr/share/icons/hicolor/172x172/apps/harbour-captains-log.png"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Captain's Log"
            font.pixelSize: Theme.fontSizeLarge
        }
        Item {
            height: Theme.paddingLarge
        }
        Label {
            x: Theme.paddingMedium
            text: qsTr("Author:")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            x: Theme.paddingLarge
            text: "Gabriel Berkigt"
            color: Theme.primaryColor

            font.pixelSize: Theme.fontSizeSmall
        }
        Label {
            x: Theme.paddingMedium
            text: qsTr("License:")
            color: Theme.highlightColor

            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            x: Theme.paddingLarge
            text: "GNU General Public Licence 3.0"
            color: Theme.primaryColor

            font.pixelSize: Theme.fontSizeSmall
        }
        Label {
            x: Theme.paddingMedium
            text: qsTr("Version:")
            color: Theme.highlightColor

            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            x: Theme.paddingLarge
            text: "1.0"
            color: Theme.primaryColor

            font.pixelSize: Theme.fontSizeSmall
        }
        Label {
            x: Theme.paddingMedium
            text: qsTr("Contact:")
            color: Theme.highlightColor

            font.pixelSize: Theme.fontSizeMedium
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Send Feedback")
            color: Theme.primaryColor
            onClicked: {
                Qt.openUrlExternally(qsTr("mailto: m.gabrielboehme@googlemail.com" +
                                      "?subject=Feedback zu Captain's Log"))
            }
        }
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Sources")
            onClicked: Qt.openUrlExternally("http://www.github.com/AlphaX2/Captains-Log")
        }
    }
}
