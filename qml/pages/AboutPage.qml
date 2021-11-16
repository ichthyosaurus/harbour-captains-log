/*
 * This file is part of Captain's Log.
 *
 * SPDX-FileCopyrightText: 2021 Mirian Margiani
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
import Sailfish.Silica 1.0
import Opal.About 1.0

AboutPageBase {
    id: page
    appName: appWindow.appName
    appIcon: Qt.resolvedUrl("../images/harbour-captains-log.png")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("A simple diary application for keeping track of your thoughts.")
    mainAttributions: ["2020-2021 Mirian Margiani", "2020 Gabriel Berkigt"]
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
            name: "Opal.About"
            entries: "2018-2021 Mirian Margiani"
            licenses: License { spdxId: "GPL-3.0-or-later"}
            sources: "https://github.com/Pretty-SFOS/opal-about"
            homepage: "https://github.com/Pretty-SFOS/opal"
        }
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

                // ContributionGroup { title: qsTr("English"); entries: ["Gabriel Berkigt", "Mirian Margiani"]}
            ]
        }
    ]
}
