/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2022 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/*
 * Translators:
 * Please add yourself to the list of contributors below. If your language is already
 * in the list, add your name to the 'entries' field. If you added a new translation,
 * create a new section at the top of the list.
 *
 * Other contributors:
 * Please add yourself to the relevant list of contributors.
 *
 * <...>
 *  ContributionGroup {
 *      title: qsTr("Your language")
 *      entries: ["Existing contributor", "YOUR NAME HERE"]
 *  },
 * <...>
 *
 */

import QtQuick 2.0
//import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    id: page
    appName: appWindow.appName
    appIcon: Qt.resolvedUrl("../images/harbour-captains-log.png")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("A simple diary application for keeping track of your thoughts.")
    mainAttributions: ["2020-2022 Mirian Margiani", "2020 Gabriel Berkigt"]
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-captains-log"
    homepageUrl: "https://openrepos.net/content/ichthyosaurus/captains-log-updated"

    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: [
        Attribution {
            name: "PyOtherSide"
            entries: ["2011, 2013-2020 Thomas Perl"]
            licenses: License { spdxId: "ISC" }
            sources: "https://github.com/thp/pyotherside"
            homepage: "https://thp.io/2011/pyotherside/"
        },
        Attribution {
            name: "OSMScout Migration"
            entries: ["2021 Lukáš Karas"]
            licenses: License { spdxId: "GPL-2.0-or-later" }
            sources: "https://github.com/Karry/osmscout-sailfish/blob/35c12584e7016fc3651b36ef7c2b6a0898fd4ce1/src/Migration.cpp"
        },
        OpalAboutAttribution { }
    ]

    contributionSections: [
        ContributionSection {
            title: qsTr("Development")
            groups: [
                ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani", "Gabriel Berkigt"]
                }/*,
                ContributionGroup {
                    title: qsTr("Icon Design")
                    entries: ["Mirian Margiani", "Gabriel Berkigt"]
                }*/
            ]
        },
        ContributionSection {
            title: qsTr("Translations")
            groups: [
                ContributionGroup { title: qsTr("Swedish"); entries: ["Åke Engelbrektson"]},
                ContributionGroup { title: qsTr("Chinese"); entries: ["dashinfantry"]},
                ContributionGroup { title: qsTr("German"); entries: ["Gabriel Berkigt", "Mirian Margiani"]}
                ContributionGroup { title: qsTr("Finnish"); entries: ["Matti Viljanen"]}

                // ContributionGroup { title: qsTr("English"); entries: ["Gabriel Berkigt", "Mirian Margiani"]}
            ]
        }
    ]
}
