import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        id: appImage
        anchors.centerIn: parent
        source: Qt.colorEqual(label.color, "#ffffff") ? Qt.resolvedUrl("/usr/share/harbour-captains-log/qml/imgs/feather_w.png") : Qt.resolvedUrl("/usr/share/harbour-captains-log/qml/imgs/feather_b.png")
        opacity: 0.8
    }
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Captain's Log")
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                if(appWindow.unlocked === true) {
                    pageStack.clear()
                    pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
                    pageStack.push(Qt.resolvedUrl("../pages/WritePage.qml"))

                    appWindow.activate()
                }
                else {
                    appWindow.activate()
                    pageStack.replace(Qt.resolvedUrl("../pages/PinPage.qml"))
                }
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: {
                if(appWindow.unlocked === true){
                    pageStack.clear()
                    pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
                    pageStack.push(Qt.resolvedUrl("../pages/SearchPage.qml"))

                    appWindow.activate()
                }
                else {
                    appWindow.activate()
                    pageStack.replace(Qt.resolvedUrl("../pages/PinPage.qml"))
                }
            }
        }
    }
}
