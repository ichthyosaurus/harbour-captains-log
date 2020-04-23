import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../components"

Page {
    id: firstPage

    Connections {
        target: appWindow
        onLoadingStarted: {
            hint.start()
            busy.running = true
            diaryList.visible = false
        }
        onLoadingFinished: {
            busy.running = false
            diaryList.visible = true
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        // preload WritePage on PageStack
        if(status == PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"))
        }
    }

    DiaryListView {
        id: diaryList
        anchors.fill: parent
        model: entriesModel

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings and Export")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Search")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Add new entry")
        }

        }
    }

    Label {
        id: addEntryLabel

        anchors.centerIn: firstPage

        font.pixelSize: Theme.fontSizeLarge
        text: qsTr("Swipe right to add new entry")
        visible: entriesModel.count === 0 && busy.running === false ? true : false
    }

    TouchInteractionHint {
        id: hint

        direction: TouchInteraction.Left
        interactionMode: TouchInteraction.Swipe
        loops: Animation.Infinite
        visible: addEntryLabel.visible

    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
    }
}
