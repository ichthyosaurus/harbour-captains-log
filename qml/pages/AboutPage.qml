/*
 * This file is part of Captain's Log.
 * SPDX-FileCopyrightText: 2020-2023 Mirian Margiani
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
import Sailfish.Silica 1.0 as S
import Opal.About 1.0 as A

A.AboutPageBase {
    id: root
    allowedOrientations: S.Orientation.All

    appName: appWindow.appName
    appIcon: Qt.resolvedUrl("../images/harbour-captains-log.png")
    appVersion: APP_VERSION
    appRelease: APP_RELEASE
    description: qsTr("A simple diary application for keeping track of your thoughts.")
    allowDownloadingLicenses: false

    mainAttributions: ["2020-2023 Mirian Margiani", "2020 Gabriel Berkigt"]
    sourcesUrl: "https://github.com/ichthyosaurus/harbour-captains-log"
    homepageUrl: "https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753"
    translationsUrl: "https://hosted.weblate.org/projects/harbour-captains-log/translations"

    licenses: A.License { spdxId: "GPL-3.0-or-later" }

    attributions: [
        A.Attribution {
            name: "SortFilterProxyModel"
            entries: ["2016 Pierre-Yves Siret"]
            licenses: A.License { spdxId: "MIT" }
            sources: "https://github.com/oKcerG/SortFilterProxyModel"
        },
        A.Attribution {
            name: "PyOtherSide"
            entries: ["2011, 2013-2020 Thomas Perl"]
            licenses: A.License { spdxId: "ISC" }
            sources: "https://github.com/thp/pyotherside"
            homepage: "https://thp.io/2011/pyotherside/"
        },
        A.Attribution {
            name: "OSMScout Migration"
            entries: ["2021 Lukáš Karas"]
            licenses: A.License { spdxId: "GPL-2.0-or-later" }
            sources: "https://github.com/Karry/osmscout-sailfish/blob/" +
                     "35c12584e7016fc3651b36ef7c2b6a0898fd4ce1/src/Migration.cpp"
        },
        A.OpalInfoComboAttribution {},
        A.OpalAboutAttribution {}
    ]

    donations.text: donations.defaultTextCoffee
    donations.services: [
        A.DonationService {
            name: "Liberapay"
            url: "https://liberapay.com/ichthyosaurus"
        }
    ]

    contributionSections: [
        A.ContributionSection {
            title: qsTr("Development")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Programming")
                    entries: ["Mirian Margiani", "Gabriel Berkigt"]
                },
                A.ContributionGroup {
                    title: qsTr("Icon Design")
                    entries: ["Mirian Margiani", "JSEHV", "Gabriel Berkigt"]
                }
            ]
        },
        A.ContributionSection {
            title: qsTr("Translations")
            groups: [
                A.ContributionGroup {
                    title: qsTr("Swedish")
                    entries: ["Åke Engelbrektson, Allan Nordhøy"]
                },
                A.ContributionGroup {
                    title: qsTr("Chinese")
                    entries: ["dashinfantry"]
                },
                A.ContributionGroup {
                    title: qsTr("German")
                    entries: ["Gabriel Berkigt", "Mirian Margiani"]
                },
                A.ContributionGroup {
                    title: qsTr("Finnish")
                    entries: ["Matti Viljanen"]
                },
                A.ContributionGroup {
                    title: qsTr("Norwegian")
                    entries: ["Bokmål: Allan Nordhøy"]
                }
            ]
        }
    ]
}
