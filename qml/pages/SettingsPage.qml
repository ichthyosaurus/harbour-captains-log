/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020 Gabriel Berkigt
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    property var moodStats: ([])

    function updateStatistics() {
        appWindow.calculateStatistics(dateMin.selectedDateString,
                                      dateMax.selectedDateString,
                                      function(stats){
            console.log("got new statistics:", stats)

            if (!!stats) {
                console.log("updating statistics")
                moodStats = stats
                statsGrid.values = stats
            } else {
                console.log("clearing statistics")
                moodStats = []
                statsGrid.values = []
            }
        })
    }

    Component.onCompleted: {
        updateStatistics()
    }

    onStatusChanged: {
        if(status === PageStatus.Deactivating) {
            if (protectionSwitch.checked && config.protectionCode !== "-1") {
                // if protection is switched on AND a protection code is set - save!
                config.useCodeProtection = true

                // if the code was just set, make sure the app knows it's unlocked
                appWindow.unlocked = true
            } else {
                // if not checked or code not set rollback all details
                config.useCodeProtection = false
                config.protectionCode = "-1"
            }
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flick }

        Column {
            id: column
            spacing: Theme.paddingMedium
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            GroupedDrawer {
                title: qsTr("Security")
                spacing: Theme.paddingLarge
                isOpen: false

                TextSwitch {
                    id: protectionSwitch
                    text: qsTr("Activate code protection")
                    description: qsTr("Please note that this code only prevents " +
                                      "access to the app. The database is not " +
                                      "encrypted, and the code is not stored securely.")
                    checked: config.useCodeProtection

                    onCheckedChanged: {
                        if (checked && config.protectionCode === "-1") {
                            passcodeButton.clicked(null)
                        } else if (!checked) {
                            config.useCodeProtection = false
                            config.protectionCode = "-1"
                        }
                    }
                }

                Button {
                    id: passcodeButton
                    width: Theme.buttonWidthLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: config.protectionCode === "-1" ? qsTr("Set Code") : qsTr("Change Code")
                    visible: protectionSwitch.checked
                    onClicked: pageStack.push(Qt.resolvedUrl("ChangePinPage.qml"), {
                                                  expectedCode: config.protectionCode === "-1" ? "" : config.protectionCode,
                                                  settingsPage: root
                                              })
                }
            }

            GroupedDrawer {
                title: qsTr("Appearance")
                spacing: Theme.paddingLarge
                isOpen: false

                TextSwitch {
                    id: moodSwitch
                    text: qsTr("Enable mood tracking")
                    description: qsTr("Disable this setting to disable all " +
                                      "mood related features completely.") + " " +
                                 qsTr("Note that entries will save your mood as " +
                                      "“okay” if this setting is disabled.")
                    checked: config.useMoodTracking
                    onCheckedChanged: config.useMoodTracking = checked
                }

                TextSwitch {
                    text: qsTr("Always ask for mood")
                    description: qsTr("This enables asking for your mood " +
                                      "immediately when creating a new entry.")
                    onClicked: config.askForMood = checked
                    enabled: moodSwitch.checked

                    Binding on checked {
                        when: !moodSwitch.checked
                        value: false
                    }

                    Binding on checked {
                        when: moodSwitch.checked
                        value: config.askForMood
                    }
                }
            }

            GroupedDrawer {
                title: qsTr("Export and backup")
                spacing: Theme.paddingLarge
                isOpen: false

                ButtonLayout {
                    preferredWidth: Theme.buttonWidthLarge

                    Button {
                        text: qsTr("Export data")
                        onClicked: pageStack.push(Qt.resolvedUrl("ExportPage.qml"))
                    }

                    Button {
                        text: qsTr("Database backup")
                        onClicked: py.call("diary.backup_database")
                    }
                }
            }

            GroupedDrawer {
                id: insights
                title: qsTr("Insights")
                spacing: Theme.paddingMedium
                isOpen: true
                visible: config.useMoodTracking

                MoodStatisticsGrid {
                    id: statsGrid
                    values: insights.moodStats
                }

                Row {
                    width: parent.width

                    DatePickerCombo {
                        id: dateMin
                        width: parent.width / 2
                        label: qsTr("From")
                        emptyText: qsTr("anytime", "search option, as in: " +
                                        "“match all entries regardless of their date”")
                        onSelectedDateStringChanged: updateStatistics()
                    }

                    DatePickerCombo {
                        id: dateMax
                        width: parent.width / 2
                        label: qsTr("Until")
                        emptyText: qsTr("anytime", "search option, as in: " +
                                        "“match all entries regardless of their date”")
                        onSelectedDateStringChanged: updateStatistics()
                    }
                }

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2*x
                    text: qsTr("Press and hold to reset the date.")
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.Wrap
                    color: Theme.secondaryHighlightColor
                }
            }
        }
    }
}
