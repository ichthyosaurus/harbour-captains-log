/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
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
import SortFilterProxyModel 0.2

import "pages"

ApplicationWindow
{
    id: appWindow
    allowedOrientations: defaultAllowedOrientations
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: null

    readonly property alias entriesModel: _sortedModel
    readonly property alias rawModel: _sourceModel
    readonly property alias pinPageComponent: _pinPage
    property bool loading: true  // only true during startup
    readonly property var _currentlyEditedEntry: ({})

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

    ListModel {
        id: _sourceModel
    }

    SortFilterProxyModel {
        id: _sortedModel
        sourceModel: _sourceModel
    }

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

    function formatDate(dbDateString, format, zone, alternativeIfEmpty) {
        if (dbDateString === "" && alternativeIfEmpty !== "" && !!alternativeIfEmpty) {
            return alternativeIfEmpty
        }

        var date = parseDate(dbDateString).toLocaleString(Qt.locale(), format)

        if (zone !== undefined && zone !== "" && zone !== timezone) {
            return qsTr("%1 (%2)", "1: date, 2: time zone info").arg(date).arg(zone)
        }

        return date
    }

    function _mappedIndex(model, index) {
        if (model.hasOwnProperty('mapToSource')) {
            if (model.sourceModel !== rawModel) {
                console.error('cannot handle nested SortFilterProxyModel models, ' +
                              'or models that are not based on rawModel')
                return -1
            }

            return model.mapToSource(index)
        } else if (model === rawModel) {
            return index
        } else {
            console.error('cannot handle', model, '- must use rawModel')
            return -1
        }
    }

    function setBookmark(model, index, rowid, setTrue) {
        py.call("diary.update_bookmark", [rowid, setTrue])
        rawModel.setProperty(_mappedIndex(model, index), 'bookmark', setTrue)
        entryBookmarkToggled(rowid, setTrue)
    }

    function _reopenEditDialog() {
        pageStack.push(Qt.resolvedUrl("pages/WritePage.qml"), _currentlyEditedEntry)
    }

    function remorseCancelWriting(parentPage, cancelMessage) {
        // This function requires valid data in _currentlyEditedEntry.
        // Populate the cache object before calling this function.

        var remorse = Remorse.popupAction(
                    parentPage, cancelMessage,
                    function(){}, 5000)

        var callback = function () {
            remorse.canceled.disconnect(callback)
            _reopenEditDialog()
        }

        remorse.canceled.connect(callback)
    }

    function updateEntry(model, index, createDate, createTz, mood, title, preview, entry, hashs, rowid) {
        var changeDate = new Date().toLocaleString(Qt.locale(), dbDateFormat)
        var modifyTz = timezone

        rawModel.set(_mappedIndex(model, index), {
            "modify_date": changeDate, "modify_tz": modifyTz, "mood": mood, "title": title,
            "preview": preview, "entry": entry, "hashtags": hashs, "rowid": rowid,
            "create_date": createDate, "create_tz": createTz
        })

        py.call("diary.update_entry", [createDate, createTz, changeDate, mood, title, preview, entry, hashs, modifyTz, rowid], function() {
            console.log("Updated entry in database")
            entryUpdated(createDate, createTz, changeDate, mood, title, preview, entry, hashs, modifyTz, rowid)
        })
    }

    function addEntry(createDate, mood, title, preview, entry, hashs) {
        py.call("diary.add_entry", [createDate, mood, title, preview, entry, hashs, timezone], function(entry) {
            console.log("Added entry to database")
            rawModel.insert(0, entry);
        })
    }

    function deleteEntry(model, index, rowid) {
        py.call("diary.delete_entry", [rowid])
        rawModel.remove(_mappedIndex(model, index))
    }

    signal entryUpdated(var createDate, var createTz, var changeDate, var mood, var title, var preview, var entry, var hashs, var modifyTz, var rowid)
    signal entryBookmarkToggled(var rowid, var isBookmark)
    // -----------------------

    property int _lastNotificationId: 0
    property bool unlocked: config.useCodeProtection ? false : true

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
        id: _pinPage
        PinPage {
            expectedCode: config.protectionCode
            onAccepted: pageStack.replaceAbove(null, Qt.resolvedUrl("pages/FirstPage.qml"))
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

        onReceived: {
            console.log(data)
        }

        onError: {
            loading = false
            console.error("an error occurred in the Python backend, traceback:")
            console.error(traceback)
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.'))

            setHandler('entries', function(result) {
                if (result.length > 0) loading = false

                for (var i = 0; i < result.length; i++) {
                    _sourceModel.append(result[i]);
                }

                console.log("adding", result.length, "item(s) to the list")
            })

            importModule('diary', function() {
                console.log("python backend loaded")

                py.call("diary.initialize", [StandardPaths.data,
                        DB_DATA_FILE, DB_VERSION_FILE], function(success) {
                    if (!success) {
                        console.error('failed to initialize backend')
                        showMessage(qsTr("Error: the database could not be loaded."))
                        return
                    }

                    console.log("loading entries...")
                    py.call('diary.get_entries', [], function(result) {
                        loading = false
                    })
                })
            })
        }
    }

    Component.onCompleted: {
        if (config.configMigrated < 1) {
            config.migrate()
        }
        pageStack.replaceAbove(null, config.useCodeProtection ? pinPageComponent : firstPage)
    }
}
