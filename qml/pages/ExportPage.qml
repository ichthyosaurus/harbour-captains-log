import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: exportDialog
    property string homePath: StandardPaths.home
    property string extension: "txt"

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
