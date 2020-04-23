import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

PinPage {
    ConfigurationValue {
        id: protectionCode
        key: "/protectionCode"
    }

    property var settingsPage // settings page instance
    expectedCode: "" // has to be set by settings page

    title: expectedCode !== "" ? qsTr("Enter your old security code") : qsTr("Enter a new security code")
    onAccepted: {
        if (expectedCode === "") {
            // set new pin
            protectionCode.value = enteredCode
            pageStack.pop(settingsPage) // pop back to settings page
            showMessage(qsTr("Saved your protection code."))
        } else {
            // ask for new pin
            pageStack.push(Qt.resolvedUrl("ChangePinPage.qml"), { settingsPage: settingsPage })
        }
    }
}
