import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page

    property string homePath: StandardPaths.home
    property string extension: ".txt"

    ConfigurationValue {
        id: useCodeProtection
        key: "/useCodeProtection"
    }

    ConfigurationValue {
        id: protectionCode
        key: "/protectionCode"
        defaultValue: "-1"
    }

    onStatusChanged: {
        if(status == PageStatus.Deactivating) {
            if (protectionSwitch.checked && protectionCode.value !== "-1") {
                // if protection is switched on AND a protection code is set - save!
                useCodeProtection.value = 1

                // if the code was just set, make sure the app knows it's unlocked
                appWindow.unlocked = true
            } else {
                // if not checked or code not set rollback all details
                useCodeProtection.value = 0
                protectionCode.value = "-1"
            }
        }
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: listView
        anchors.fill: parent

        Column {
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Security")
            }

            TextSwitch {
                id: protectionSwitch
                text: qsTr("activate code protection")
                checked: useCodeProtection.value
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: protectionCode.value === "-1" ? qsTr("Set Code") : qsTr("Change Code")
                visible: protectionSwitch.checked
                onClicked: pageStack.push(Qt.resolvedUrl("ChangePinPage.qml"), {
                                              expectedCode: protectionCode.value === "-1" ? "" : protectionCode.value,
                                              settingsPage: page
                                          })
            }

            SectionHeader {
                text: qsTr("Export features")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Export data")
                onClicked: pageStack.push(exportDialog)
            }
        }
    }

    Dialog {
        id: exportDialog

        Column {
            width: parent.width
            spacing: Theme.paddingMedium

            DialogHeader {
                title: qsTr("Export your data")
            }
            TextField {
                id: filenameField
                width: parent.width
                placeholderText: qsTr("Define the file name...")
                label: qsTr("Filename")
            }
            ComboBox {
                id: fileTypeCombo

                width: parent.width
                description: qsTr("Export file type selection")
                label: qsTr("Select file type:")

                menu: ContextMenu {
                    MenuItem {
                        text: ".txt"
                    }
                    MenuItem {
                        text: ".csv"
                    }
                }
                onCurrentIndexChanged: {
                    extension = fileTypeCombo.value
                }
            }
        }
        onAccepted: {
            var time = new Date().getTime()
            var filename = homePath +"/"+ "logbook_export_"+String(time)+extension

            if(filenameField.text.length > 0) {
                filename = homePath +"/"+ filenameField.text+extension
            }
            // notifications are defined in harbour-captains-log.qml
            showMessage(qsTr("Data exported to: %1").arg(filename))
            py.call("diary.export", [filename, extension])
        }
    }
}
