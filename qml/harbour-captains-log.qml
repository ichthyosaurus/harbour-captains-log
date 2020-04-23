import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import io.thp.pyotherside 1.5
import "pages"

ApplicationWindow
{
    id: appWindow
    allowedOrientations: defaultAllowedOrientations

    initialPage: useCodeProtection.value === 1 ? pinPage : firstPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    property ListModel entriesModel: ListModel { }

    // constants
    property string timeFormat: qsTr("hh':'mm")
    property string atTimeFormat: qsTr("'at' hh':'mm")
    property string dateTimeFormat: qsTr("d MMM yyyy, hh':'mm")
    property string fullDateTimeFormat: qsTr("ddd d MMM yyyy, hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")
    property string dateFormat: qsTr("d MMM yyyy")
    property string dbDateFormat: "dd.MM.yyyy | hh:mm"
    property var moodTexts: [
        qsTr("fantastic"),
        qsTr("good"),
        qsTr("okay"),
        qsTr("bad"),
        qsTr("horrible")
    ]
    // ---------

    // global helper functions
    function parseDate(dbDateString) {
        if (typeof dbDateString === 'undefined' || dbDateString === "") return "";
        var dateTime = dbDateString.split(' | ');
        var date = dateTime[0].split('.');
        var time = dateTime[1].split(':');
        return new Date(parseInt(date[2]), parseInt(date[1]), parseInt(date[0]), parseInt(time[0]), parseInt(time[1]), 0);
    }

    function setFavorite(index, rowid, setTrue) {
        py.call("diary.update_favorite", [rowid, setTrue])
        entriesModel.setProperty(index, 'favorite', setTrue)
        entryFavoriteToggled(index, setTrue)
    }

    function updateEntry(index, changeDate, mood, title, preview, entry, hashs, rowid) {
        entriesModel.set(index, { "modify_date": changeDate, "mood": mood, "title": title,
                             "preview": preview, "entry": entry, "hashtags": hashs, "rowid": rowid })
        py.call("diary.update_entry", [changeDate, mood, title, preview, entry, hashs, rowid], function() {
            console.log("Updated entry in database")
            entryUpdated(index, changeDate, mood, title, preview, entry, hashs, rowid)
        })
    }

    function addEntry(creationDate, mood, title, preview, entry, hashs) {
        py.call("diary.add_entry", [creationDate, mood, title, preview, entry, hashs], function(entry) {
            console.log("Added entry to database")
            entriesModel.insert(0, entry);
        })
    }

    function deleteEntry(index, rowid) {
        py.call("diary.delete_entry", [rowid])
        entriesModel.remove(index)
    }

    function loadModel() {
        loadingStarted()

        py.call("diary.read_all_entries", [], function(result) {
                entriesModel.clear()
                for(var i=0; i<result.length; i++) {
                    var item = result[i];
                    entriesModel.append(item)
                }

                loadingFinished()
            }
        )
    }

    signal loadingStarted()
    signal loadingFinished()
    signal entryUpdated(var index, var changeDate, var mood, var title, var preview, var entry, var hashs, var rowid)
    signal entryFavoriteToggled(var index, var isFavorite)
    // -----------------------

    property int _lastNotificationId: 0
    property bool unlocked: useCodeProtection.value === 1 ? false : true

    onUnlockedChanged: {
        if (!unlocked) entriesModel.clear()
        else if (py.ready) loadModel()
    }

    ConfigurationValue {
        id: useCodeProtection
        key: "/useCodeProtection"
    }

    Component {
        id: pinPage
        PinPage {
            expectedCode: protectionCode.value
            onAccepted: pageStack.push(Qt.resolvedUrl("pages/FirstPage.qml"))
            ConfigurationValue {
                id: protectionCode
                key: "/protectionCode"
            }
        }
    }

    Component  {
        id: firstPage
        FirstPage {}
    }

    Notification {
        id: notification
        expireTimeout: 4000
    }

    function showMessage(msg)
    {
        notification.replacesId = _lastNotificationId
        notification.previewBody = msg
        notification.publish()
        _lastNotificationId = notification.replacesId
    }

    Python {
        id: py
        property bool ready: false

        Component.onCompleted: {
            // Add the directory of this .qml file to the search path
            addImportPath(Qt.resolvedUrl('.'))
            importModule("diary", function() {console.log("diary.py loaded")})
            ready = true

            // Load the model for the first time.
            // If the app is locked and unlocked, the model will be reloaded
            // in onUnlockedChanged.
            loadModel()
        }
    }
}

