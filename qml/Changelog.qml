/*
 * This file is part of harbour-captains-log.
 * SPDX-FileCopyrightText: Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import "modules/Opal/About"

ChangelogList {
    ChangelogItem {
        version: "4.1.1-1"
        date: "2024-08-10"
        paragraphs: [
            "- Updated translations: Spanish, Estonian, Swedish, Ukrainian, Norwegian Bokmål, and 11 more<br>" +
            "- Fixed two bugs that could cause database errors when the app is started for the first time<br>" +
            "- Added a rudimentary graph showing mood changes over time<br>" +
            "- Fixed mood statistics bar turning black if a value was above 50%<br>" +
            "- Fixed links in the new support dialog"
        ]
    }
    ChangelogItem {
        version: "4.1.0-1"
        date: "2024-07-26"
        paragraphs: [
            "- updated translations: Swedish, Ukrainian, German, Chinese, Turkish, Estonian, English, Russian, Spanish, Indonesian<br>" +
            "- added rudimentary statistics about tracked mood on the settings page (requires mood tracking to be enabled)<br>" +
            "- added periodic call for contributions and donations using Opal.SupportMe<br>" +
            "- added settings to disable mood tracking<br>" +
            "- added support for external links in texts<br>" +
            "- fixed disabling pin code protection<br>" +
            "- improved search settings descriptions<br>" +
            "- polished user interface here and there"
        ]
    }
    ChangelogItem {
        version: '4.0.0-1'
        date: "2023-06-23"
        paragraphs: [
            '- updated translations: Swedish, Italian, German<br>' +
            '- refreshed the app icon (based on a contribution by JSEHV)<br>' +
            '- refreshed the cover background<br>' +
            '- completely refactored exporting<br>' +
            '-   > the layout in all formats has been improved<br>' +
            '-   > a new database backup option has been added to export a zip archive<br>' +
            '-   > translations have been improved<br>' +
            '-   > new formats can be added easily<br>' +
            '-   > added descriptions for all export formats<br>' +
            '-   > no files will be overwritten when exporting (could happen before)<br>' +
            '- completely refactored database handling and migrations<br>' +
            '-   > the database is now stored in a single file<br>' +
            '-   > backups will be automatically created every week<br>' +
            '-   > manual backups can be created from the settings page<br>' +
            '-   > failed database updates should never lead to data loss and old databases (before any database update) are kept as backups<br>' +
            '- added support for exporting only selected entries<br>' +
            '-   > select entries from the export page<br>' +
            '-   > export search results directly<br>' +
            '- improved user experience when writing entries<br>' +
            '-   > automatically scroll the next field into view<br>' +
            '-   > make tag suggestions more visible<br>' +
            '-   > improve adding new tags<br>' +
            '- improved error feedback and notifications<br>' +
            '- improved database stability and error detection<br>' +
            '- fixed timestamps with invalid seconds fields<br>' +
            '- fixed a string that was causing issues with translations and had to be re-translated all the time (sorry for the hassle, translators)<br>' +
            '- added support for running the Python backend as a stand-alone script<br>' +
            '- added an in-app changelog<br>' +
            '- plus many small quality-of-life changes and many internal changes<br>' +
            '- note: this release changes the database in a non-backwards-compatible way, so that downgrading will not be possible<br>' +
        '' ]
    }
    ChangelogItem {
        version: '3.1.0-1'
        date: "2023-06-12"
        paragraphs: [
            '- new translation: Norwegian Bokmål<br>' +
            '- urgent: fixed initialising a new database<br>' +
            '- updated translations: Swedish, German, English<br>' +
            '- added option to view search results in full instead of only previews<br>' +
            '- added option to add new entries from search results page<br>' +
        '' ]
    }
    ChangelogItem {
        version: '3.0.0-1'
        date: "2023-06-03"
        paragraphs: [
            '- translations: moved to Weblate, updated German<br>' +
            '- added remorse timer when discarding a new / edited entry<br>' +
            '- added support for addenda, i.e. entries added at a later date<br>' +
            '- added improved scroll bar for scrolling to specific dates<br>' +
            '- added proper support for tags (including auto-completion)<br>' +
            '- added new, improved search page<br>' +
            '-   > search using multiple criteria at once<br>' +
            '-   > search for mood ranges and use wildcards for complex queries<br>' +
            '-   > search for tags<br>' +
            '-   > search for similar matches, e.g. match “ö” when searching for plain “o”<br>' +
            '-   > improved performance<br>' +
            '- added Weblate for translations (cf. About page)<br>' +
            '- added notifications in case of errors in the Python backend (should never happen)<br>' +
            '- fixed swipe direction hint in German translation<br>' +
            '- fixed cover actions while the app is locked<br>' +
            '- fixed editing an entry from the search results page<br>' +
            '- fixed exporting to CSV<br>' +
            '- plus many small quality-of-life changes and many internal changes<br>' +
            '- note: this release changes the database in a non-backwards-compatible way, so that downgrading will not be possible<br>' +
        '' ]
    }
    ChangelogItem {
        version: '2.1.0-1'
        date: "2022-03-24"
        paragraphs: [
            '- translations: added Chinese, updated Swedish<br>' +
            '- added support for My Backup<br>' +
            '- added a Sailjail profile (only permission is "Documents" for exporting)<br>' +
            '- fixed some highlight colors<br>' +
            '- fixed data being saved outside of the new sandbox<br>' +
            '- fixed settings being saved in the wrong location (automatically migrated)<br>' +
            '- changed export output directory from "/home/<user>" to "/home/<user>/Documents"<br>' +
            '- updated About page (now using Opal.About)<br>' +
            '- reduced overall package size<br>' +
        '' ]
    }
    ChangelogItem {
        version: '2.0.1-1'
        date: "2020-11-12"
        paragraphs: [
            '- fixed a serious bug where entries could not be opened or edited<br>' +
        '' ]
    }
    ChangelogItem {
        version: '2.0.0-2'
        date: "2020-06-18"
        paragraphs: [
            '- hotfix: fixed a typo in the German translation<br>' +
        '' ]
    }
    ChangelogItem {
        version: '2.0.0-1'
        date: "2020-06-18"
        paragraphs: [
            '- completely overhauled the user interface<br>' +
            '- added the GPL where necessary<br>' +
            '- added support for automated database schema upgrades<br>' +
            '- changed the database layout (database updates itself)<br>' +
            '-   > added support for time zones<br>' +
            '-   > added field for possible future feature: audio notes<br>' +
            '-   > changed internal date format from "dd.MM.yyyy | hh:mm" to (standard) "yyyy-MM-dd hh:mm:ss"<br>' +
            '-   > save seconds<br>' +
            '-   > renamed "favorites" to "bookmarks" (an important entry is not necessarily my "favorite")<br>' +
            '- added a new cover page<br>' +
            '- simplified reloading, improving performance (changes no longer require a full reload)<br>' +
            '- added new mood "not okay": "okay" is slightly positive, "not okay" is slightly negative; there is no "neutral" mood (database updates itself)<br>' +
            '- refactored export features<br>' +
            '-   > made exports translatable<br>' +
            '-   > added new export options: plain markdown and markdown for pandoc<br>' +
            '- updated the German translation to use polite "Sie"<br>' +
            '- replaced app icon by new, more "sailfishy" variant<br>' +
            '- implemented quickly changing the mood of an entry in the overview list<br>' +
            '- implemented searching for entries between two dates<br>' +
        '' ]
    }
    ChangelogItem {
        version: '1.0-2'
        date: "2020-04-19"
        paragraphs: [
            '- added Swedish translation<br>' +
        '' ]
    }
    ChangelogItem {
        version: '1.0-1'
        date: "2020-04-15"
        paragraphs: [
            '- initial release<br>' +
        '' ]
    }
}
