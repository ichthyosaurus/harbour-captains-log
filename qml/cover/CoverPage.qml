import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    HighlightImage {
        id: appImage
        color: Theme.primaryColor
        source: Qt.resolvedUrl("../images/cover-bg.png")
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        anchors.fill: parent
    }

    function open(pageUrl) {
        if(appWindow.unlocked === true) {
            pageStack.clear()
            pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
            pageStack.push(Qt.resolvedUrl(pageUrl))
            appWindow.activate()
        }
        else {
            appWindow.activate()
            pageStack.replace(Qt.resolvedUrl("../pages/PinPage.qml"))
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: open("../pages/WritePage.qml")
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            onTriggered: open("../pages/SearchPage.qml")
        }
    }
}
