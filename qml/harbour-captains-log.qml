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
import Opal.About 1.0 as A
import Opal.SupportMe 1.0 as M

import "pages"

ApplicationWindow {
    id: appWindow
    allowedOrientations: defaultAllowedOrientations
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: null

    readonly property alias entriesModel: _sortedModel
    readonly property alias rawModel: _sourceModel
    readonly property ListModel tagsModel: ListModel {}
    readonly property alias pinPageComponent: _pinPage
    property bool loading: true  // only true during startup
    readonly property var _currentlyEditedEntry: ({})

    // constants
    // -- important: always use formatDate(...) to format date strings
    readonly property string appName: qsTr("Captain's Log", "the app's name")
    readonly property string timezone: new Date().toLocaleString(Qt.locale("C"), "t")
    readonly property string atTimeFormat: qsTr("'at' hh':'mm",
        "time format, as in “at 10:00 (o'clock)”")
    readonly property string dateTimeFormat: qsTr("d MMM yyyy, hh':'mm",
        "date and time format, as in “Dec. 1st 2023, 10:00 o'clock”")
    readonly property string fullDateTimeFormat: qsTr("ddd d MMM yyyy, hh':'mm",
        "full date and time format, as in “Fri., Dec. 1st 2023, 10:00 o'clock”")
    readonly property string fullDateFormat: qsTr("ddd d MMM yyyy",
        "full date format, as in “Fri., Dec. 1st 2023”")
    readonly property string dateFormat: qsTr("d MMM yyyy",
        "date format, as in “Dec. 1st 2023”")
    readonly property string dateNoYearFormat: qsTr("d MMM",
        "date format without year, as in “Dec. 1st”")
    readonly property string dbDateFormat: "yyyy-MM-dd hh:mm:ss"
    property var moodTexts: [
        qsTr("fantastic", "as in “my mood is...”"),
        qsTr("good", "as in “my mood is...”"),
        qsTr("okay", "as in “my mood is...”"),
        qsTr("not okay", "as in “my mood is...”"),
        qsTr("bad", "as in “my mood is...”"),
        qsTr("horrible", "as in “my mood is...”")
    ]
    // ---------

    ListModel {
        id: _sourceModel
    }

    SortFilterProxyModel {
        id: _sortedModel
        sourceModel: _sourceModel

        sorters: [
            RoleSorter {
                roleName: "entry_order"
                sortOrder: Qt.DescendingOrder
            },
            RoleSorter {
                roleName: "entry_addenda_day"
                sortOrder: Qt.DescendingOrder
            },
            RoleSorter {
                roleName: "entry_addenda_seq"
                sortOrder: Qt.DescendingOrder
            }
        ]
    }

    // global helper functions
    function parseDate(dbDateString) {
        // This function creates a Date object from a date string
        // that strictly follows dbDateFormat.
        // We use this function to make sure JS does not calculate
        // some time zone magic when converting. The resulting Date
        // object is interpreted as "local time" and contains exactly
        // the same numbers as were given in dbDateString.

        if (typeof dbDateString === 'undefined' || dbDateString === "") {
            return ""
        }

        var dateTime = dbDateString.split(' ')
        var date = dateTime[0].split('-')
        var time = ["0", "0", "0"] // set to zero if the string had no time part

        if (dateTime.length >= 2) {
            time = dateTime[1].split(':')
        }

        return new Date(
            parseInt(date[0]), parseInt(date[1])-1, parseInt(date[2]),
            parseInt(time[0]), parseInt(time[1]), parseInt(time[2])
        )
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

    function normalizeText(string) {
        if ((typeof string == "undefined") || string.length < 1) {
            return ""
        }

        if (!py || !py.ready) {
            console.error("normalizeText(string) was called while the backend was not ready")
            return string
        }

        return py.call_sync('diary.normalize_text', [string])
    }

    function stringToColor(str) {
        var hash = 0
        for (var i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash)
        }

        var color = '#'
        for (var j = 0; j < 3; j++) {
            var value = ((200 * hash) >> (j * 8)) & 0xFF
            color += ('00' + value.toString(16)).substr(-2)
        }

        return color
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
        entryUpdated(rowid, rawModel.get(_mappedIndex(model, index)))
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

    function updateEntry(model, index, entryDate, entryTz, mood,
                         title, entry, tags, rowid) {
        var changeDate = new Date().toLocaleString(Qt.locale(), dbDateFormat)
        var modifyTz = timezone
        var mapped = _mappedIndex(model, index)

        // Some fields are generated in the Python backend, so we
        // first set them to the new entry text and update it later.
        rawModel.set(mapped, {
            "modify_date": changeDate, "modify_tz": modifyTz, "mood": mood, "title": title,
            "preview": entry, "entry": entry, "tags": tags, "rowid": rowid,
            "entry_date": entryDate, "entry_tz": entryTz,
            "entry_normalized": entry, "tags_normalized": tags
        })

        py.call("diary.update_entry", [entryDate, entryTz, changeDate, mood,
                                       title, entry, tags, modifyTz, rowid], function(entry) {
            console.log("Updated entry in database")
            entryUpdated(rowid, entry)

            if (rawModel.get(mapped)["rowid"] === rowid) {
                // Only update values if the mapped index is still correct.
                // It might be possible that an index changes while the Python
                // backend is still working (async).
                rawModel.set(mapped, {
                    "preview": entry["preview"],
                    "entry_normalized": entry["entry_normalized"],
                    "tags_normalized": entry["tags_normalized"]
                })
            }
        })
    }

    function addEntry(createDate, entryDate, entryTz, mood,
                      title, entry, tags) {
        py.call("diary.add_entry", [createDate, timezone, entryDate, entryTz,
                                    mood, title, entry, tags], function(entry) {
            console.log("Added entry to database")
            rawModel.insert(0, entry);
        })
    }

    function deleteEntry(model, index, rowid) {
        py.call("diary.delete_entry", [rowid])
        rawModel.remove(_mappedIndex(model, index))
    }

    function calculateStatistics(from, until, callback) {
        py.call("diary.calculate_statistics", [from, until], function(stats) {
            console.log("Calculated statistics:", from, until, JSON.stringify(stats))
            callback(stats)
        })
    }

    signal entryUpdated(var rowid, var newEntry)
    // -----------------------

    property bool unlocked: config.useCodeProtection ? false : true

    property ConfigurationGroup config: ConfigurationGroup {
        path: "/apps/harbour-captains-log"
        property int configMigrated: 0
        property bool useCodeProtection: false
        property string protectionCode: "-1"
        property string lastBackupDate: ""
        property string lastExportKind: "txt"
        property bool useMoodTracking: true
        property bool askForMood: true

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

    A.ChangelogNews {
        changelogList: Qt.resolvedUrl("Changelog.qml")
    }

    M.AskForSupport {
        contents: Component {
            MySupportDialog {}
        }
    }

    Notification {
        id: notification
        expireTimeout: 4000
    }

    Notification {
        id: backupNotification

        function start() {
            summary = qsTr("Database backup")
            body = ''
            progress = Notification.ProgressIndeterminate
            publish()
        }

        function update(backupProgress, backupFile) {
            notification.timestamp = new Date()

            if (backupProgress >= 1.0) {
                summary = qsTr("Backup finished")
                body = qsTr("A database backup has been created in “%1”.").
                    arg(backupFile)
                progress = undefined
                publish()
            } else {
                summary = qsTr("Database backup")
                body = ''
                progress = backupProgress
                publish()
            }
        }
    }

    function showMessage(msg, details) {
        if (!!details) {
            notification.expireTimeout = 0
            notification.summary = msg
            notification.body = details
            notification.previewSummary = msg
            notification.previewBody = details
        } else {
            notification.expireTimeout = 4000
            notification.summary = ''
            notification.body = ''
            notification.previewSummary = ''
            notification.previewBody = msg
        }

        notification.replacesId = -1
        notification.publish()
    }

    Python {
        id: py
        property string unexpectedErrorMessage: qsTr(
            "An unexpected error occurred. Please restart the app and " +
            "check the logs.")

        onReceived: {
            console.log(data)
        }

        onError: {
            loading = false
            console.error("an error occurred in the Python backend, traceback:")
            console.error(traceback)

            showMessage(qsTr("Error"), unexpectedErrorMessage)
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('py'))

            setHandler('error', function(ident, data){
                loading = false
                console.error("an error occurred in the Python backend: %1".arg(ident))
                console.error("error details:")
                console.error(JSON.stringify(data))

                var message = ''

                if (ident === 'path-unavailable') {
                    message = unexpectedErrorMessage
                } else if (ident === 'local-data-inaccessible') {
                    message = qsTr("The local data folder at “%1” " +
                                   "is not writable.").arg(data.path)
                } else if (ident === 'database-unavailable') {
                    message = qsTr("Failed to load the database due to an " +
                                   "unknown error.")
                } else if (ident === 'database-update-failed') {
                    message = qsTr("Failed to update the database at “%1” " +
                                   "to the latest version. Details: %2").
                        arg(data.database).arg(data.exception)
                } else if (ident === 'sailjail-migration-failed') {
                    message = qsTr("Failed to move files for Sailjail " +
                                   "support from “%1” to “%2”.").
                        arg(data.source).arg(data.dest)
                } else if (ident === 'schema-file-missing') {
                    message = qsTr("Failed to update the database to its " +
                                   "latest version because the version file " +
                                   "is missing at “%1”.").arg(data.path)
                } else if (ident === 'unknown-database-version') {
                    message = qsTr("The database version “%1” is incompatible " +
                                   "with this version of the app. The latest " +
                                   "supported database version is “%2”.").
                        arg(data.got).arg(data.latest)
                } else if (ident === 'database-not-ready') {
                    message = unexpectedErrorMessage
                } else if (ident === 'unknown-export-type') {
                    message = qsTr("Cannot export unknown file type “%1”. " +
                                   "Please report this bug.").arg(data.kind)
                } else {
                    message = unexpectedErrorMessage
                }

                showMessage(qsTr("Error"), message)
            })

            setHandler('backup-progress', function(result) {
                if (result.status === 'working') {
                    backupNotification.update(result.progress, result.backup)
                } else if (result.status === 'failed') {
                    backupNotification.close()
                    showMessage(qsTr("Backup failed"), unexpectedErrorMessage)
                    console.error('backup failed with an exception:', result.exception)
                } else {
                    console.error('bug: unknown backup progress status', result.status)
                }
            })

            setHandler('entries', function(result) {
                if (result.length > 0) loading = false

                for (var i = 0; i < result.length; i++) {
                    _sourceModel.append(result[i]);
                }

                console.log("adding", result.length, "item(s) to the list")
            })

            setHandler('tags', function(result){
                tagsModel.clear()

                for (var i in result) {
                    tagsModel.append(result[i])
                }
            })

            importModule('diary', function() {
                console.log("python backend loaded")

                py.call("diary.initialize", [StandardPaths], function(success) {
                    if (!success) {
                        console.error('failed to initialize backend')
                        showMessage(qsTr("Error"), qsTr("The database could not be loaded."))
                        return
                    }

                    console.log("loading entries...")
                    py.call('diary.get_entries', [], function(result) {
                        loading = false

                        if (config.lastBackupDate === "" ||
                                new Date() - parseDate(config.lastBackupDate) >
                                (1000 * 60 * 60 * 24 * 7)) {
                            console.log("creating database backup...")
                            backupNotification.start()
                            py.call('diary.backup_database')
                            config.lastBackupDate = new Date().toISOString().split('T')[0]
                        }
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
        // pageStack.replaceAbove(null, [firstPage, Qt.resolvedUrl("pages/SettingsPage.qml")])
    }
}
