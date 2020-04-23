import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    anchors.fill: parent

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        PageHeader {
            id: header
            title: qsTr("About")
        }

        Column {
            id: content
            width: parent.width - 2*Theme.horizontalPageMargin
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingMedium

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "/usr/share/icons/hicolor/172x172/apps/harbour-captains-log.png"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Captain's Log"
                font.pixelSize: Theme.fontSizeLarge
            }

            Item { width: parent.width; height: Theme.paddingLarge }

            Label {
                text: qsTr("Author:")
                color: Theme.highlightColor
            }
            Label {
                x: Theme.paddingLarge
                text: "Gabriel Berkigt"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { width: parent.width; height: Theme.paddingLarge }

            Label {
                text: qsTr("License:")
                color: Theme.highlightColor
            }
            Label {
                x: Theme.paddingLarge
                text: "GNU General Public Licence 3.0"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { width: parent.width; height: Theme.paddingLarge }

            Label {
                text: qsTr("Version:")
                color: Theme.highlightColor
            }
            Label {
                x: Theme.paddingLarge
                text: appVersionNumber
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { width: parent.width; height: Theme.paddingLarge }

            Label {
                text: qsTr("Contact:")
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Send Feedback")
                color: Theme.primaryColor
                onClicked: {
                    Qt.openUrlExternally("mailto: m.gabrielboehme@googlemail.com" +
                                          "?subject=[Captain's Log] %1".arg(qsTr("Feedback", "feedback email subject line")))
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sources")
                onClicked: Qt.openUrlExternally("http://www.github.com/AlphaX2/Captains-Log")
            }
        }
    }
}
