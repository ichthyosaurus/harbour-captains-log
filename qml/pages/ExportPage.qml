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
                MenuItem { text: qsTr("Plain text"); property string extension: "txt" }
                MenuItem { text: qsTr("Comma-separated values (CSV)"); property string extension: "csv" }
            }
            onCurrentIndexChanged: {
                extension = fileTypeCombo.currentItem.extension
            }
        }
    }
    onAccepted: {
        var time = new Date().getTime()
        var filenameFormat = "%1/%2.%3"
        var filename = filenameFormat.arg(homePath).arg("logbook_export_"+String(time)).arg(extension)

        if(filenameField.text.length > 0) {
            filename = filenameFormat.arg(homePath).arg(filenameField.text).arg(extension)
        }

        showMessage(qsTr("Data exported to: %1").arg(filename)) // defined in harbour-captains-log.qml
        py.call("diary.export", [filename, extension])
    }
}
