/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 * SPDX-FileCopyrightText: 2020 Mirian Margiani
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Captain's Log is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Captain's Log is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

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
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: null

    property ListModel entriesModel: ListModel { }

    // constants
    // -- important: always use formatDate(...) to format date strings
    readonly property string appName: qsTr("Captain's Log", "the app's name")
    readonly property string timezone: new Date().toLocaleString(Qt.locale("C"), "t")
    readonly property string timeFormat: qsTr("hh':'mm")
    readonly property string atTimeFormat: qsTr("'at' hh':'mm")
    readonly property string dateTimeFormat: qsTr("d MMM yyyy, hh':'mm")
    readonly property string fullDateTimeFormat: qsTr("ddd d MMM yyyy, hh':'mm")
    readonly property string fullDateFormat: qsTr("ddd d MMM yyyy")
    readonly property string dateFormat: qsTr("d MMM yyyy")
    readonly property string dbDateFormat: "yyyy-MM-dd hh:mm:ss"
    property var moodTexts: [
        qsTr("fantastic"),
        qsTr("good"),
        qsTr("okay"),
        qsTr("not okay"),
        qsTr("bad"),
        qsTr("horrible")
    ]
    // ---------

    // global helper functions
    function parseDate(dbDateString) {
        // This function creates a Date object from a date string that strictly follows dbDateFormat.
        // We use this function to make sure JS does not calculate some time zone magic when converting.
        // The resulting Date object is interpreted as "local time" and contains exactly the same
        // numbers as were given in dbDateString.
        if (typeof dbDateString === 'undefined' || dbDateString === "") return "";
        var dateTime = dbDateString.split(' ');
        var date = dateTime[0].split('-');
        var time = ["0", "0", "0"] // set to zero if the string had no time part
        if (dateTime.length >= 2) time = dateTime[1].split(':');
        return new Date(parseInt(date[0]), parseInt(date[1])-1, parseInt(date[2]), parseInt(time[0]), parseInt(time[1]), parseInt(time[2]));
    }

    function formatDate(dbDateString, format, zone) {
        var date = parseDate(dbDateString).toLocaleString(Qt.locale(), format)
        if (zone !== undefined && zone !== "" && zone !== timezone) {
            return qsTr("%1 (%2)", "1: date, 2: time zone info").arg(date).arg(zone)
        }

        return date
    }

    function setBookmark(model, index, rowid, setTrue) {
        py.call("diary.update_bookmark", [rowid, setTrue])
        model.setProperty(index, 'bookmark', setTrue)
        entryBookmarkToggled(rowid, setTrue)
        if (model !== entriesModel) _scheduleReload = true;
    }

    function updateEntry(model, index, mood, title, preview, entry, hashs, rowid) {
        var changeDate = new Date().toLocaleString(Qt.locale(), dbDateFormat)
        var modifyTz = timezone

        model.set(index, { "modify_date": changeDate, "modify_tz": modifyTz, "mood": mood, "title": title,
                             "preview": preview, "entry": entry, "hashtags": hashs, "rowid": rowid })

        py.call("diary.update_entry", [changeDate, mood, title, preview, entry, hashs, modifyTz, rowid], function() {
            console.log("Updated entry in database")
            entryUpdated(changeDate, mood, title, preview, entry, hashs, modifyTz, rowid)
            if (model !== entriesModel) _scheduleReload = true;
        })
    }

    function addEntry(createDate, mood, title, preview, entry, hashs) {
        py.call("diary.add_entry", [createDate, mood, title, preview, entry, hashs, timezone], function(entry) {
            console.log("Added entry to database")
            entriesModel.insert(0, entry);
        })
    }

    function deleteEntry(model, index, rowid) {
        py.call("diary.delete_entry", [rowid])
        model.remove(index)
        if (model !== entriesModel) _scheduleReload = true;
    }

    function loadModel() {
        _modelReady = false;
        _scheduleReload = false;
        loadingStarted()
        console.log("loading entries...")

        py.call("diary.read_all_entries", [], function(result) {
                entriesModel.clear()
                for(var i=0; i<result.length; i++) {
                    var item = result[i];
                    entriesModel.append(item)
                }

                loadingFinished()
                _modelReady = true;
                initialLoadingDone = true;
            }
        )
    }

    signal loadingStarted()
    signal loadingFinished()
    signal entryUpdated(var changeDate, var mood, var title, var preview, var entry, var hashs, var modifyTz, var rowid)
    signal entryBookmarkToggled(var rowid, var isBookmark)
    // -----------------------

    property bool initialLoadingDone: false
    property bool _modelReady: false
    property bool _scheduleReload: false // schedules the model to be reloaded when FirstPage ist activated

    property int _lastNotificationId: 0
    property bool unlocked: config.useCodeProtection ? false : true

    onUnlockedChanged: {
        if (!unlocked) {
            entriesModel.clear()
            _modelReady = false
        } else if (py.ready && !_modelReady) {
            loadModel()
        }
    }

    property ConfigurationGroup config: ConfigurationGroup {
        path: "/apps/harbour-captains-log"
        property int configMigrated: 0
        property bool useCodeProtection: false
        property string protectionCode: "-1"

        function migrate() {
            if (configMigrated === 0) {
                var _legacyConfig0 = Qt.createQmlObject(
                            "import Nemo.Configuration 1.0; ConfigurationGroup { path: '/' }",
                            appWindow, 'LegacyConfiguration0')
                useCodeProtection = (_legacyConfig0.value('/useCodeProtection', 0) === 0) ? false : true
                protectionCode = _legacyConfig0.value('/protectionCode', '-1')
                configMigrated = 1
                _legacyConfig0.setValue('/useCodeProtection', undefined)
                _legacyConfig0.setValue('/protectionCode', undefined)
                _legacyConfig0.destroy()
            }
        }
    }

    Component {
        id: pinPage
        PinPage {
            expectedCode: config.protectionCode
            onAccepted: pageStack.push(Qt.resolvedUrl("pages/FirstPage.qml"))
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
            importModule("diary", function() {
                console.log("diary.py loaded")

                py.call("diary.initialize",
                        [StandardPaths.data, DB_DATA_FILE, DB_VERSION_FILE],
                        function(success) {
                            if (success) {
                                // Load the model for the first time.
                                // If the app is locked and unlocked, the model will be reloaded
                                // in onUnlockedChanged.
                                loadModel()
                                ready = true
                            } else {
                                // TODO improve error reporting
                                console.log('[FATAL] failed to initialize backend')
                            }
                        })
            })
        }
    }

    Component.onCompleted: {
        if (config.configMigrated < 1) {
            config.migrate()
        }
        pageStack.replaceAbove(null, config.useCodeProtection ? pinPage : firstPage)
    }
}
