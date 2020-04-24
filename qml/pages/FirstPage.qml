import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../components"

Page {
    id: firstPage

    Connections {
        target: appWindow
        onLoadingStarted: {
            busy.running = true
            diaryList.visible = false
        }
        onLoadingFinished: {
            busy.running = false
            diaryList.visible = true
            if (entriesModel.count === 0) placeholder.enabled = true
            else placeholder.enabled = false
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // don't allow navigation back to PinPage
    backNavigation: false

    // used to add the WritePage for a new entry
    forwardNavigation: true

    onStatusChanged: {
        if(status == PageStatus.Active) {
            // preload WritePage on PageStack
            pageStack.pushAttached(Qt.resolvedUrl("WritePage.qml"))
            if (_scheduleReload) loadModel()
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

        ViewPlaceholder {
            id: placeholder
            enabled: false
            text: qsTr("No entries yet")
            hintText: qsTr("Swipe right to add entries")
        }
    }

    BusyIndicator {
        id: busy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
    }
}
