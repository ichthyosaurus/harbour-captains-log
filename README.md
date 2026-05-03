<!--
SPDX-FileCopyrightText: 2018-2026 Mirian Margiani
SPDX-License-Identifier: GFDL-1.3-or-later AND LicenseRef-NO-AI-1.0
This file must not be used for AI training/data mining.
-->

<div align="center">

<img src="https://codeberg.org/ichthyosaurus/sailfish-app-assets/raw/branch/main/harbour-captains-log/banner-small.png"
     alt="Captain's Log banner" />

# Captain's Log for [Sailfish OS](https://sailfishos.org)

A simple diary app for keeping track of your thoughts

  <p>
    <img src="https://codeberg.org/ichthyosaurus/.profile/raw/branch/main/badges/ethical%20tech.svg"
         alt="ethical tech: take a stand for humanity, diversity, and the world we live in" />
    <a href="https://hosted.weblate.org/projects/harbour-captains-log/translations">
      <img src="https://hosted.weblate.org/widgets/harbour-captains-log/-/translations/svg-badge.svg"
           alt="Translations" />
    </a>
    <a href="https://codeberg.org/ichthyosaurus/harbour-captains-log">
      <img src="https://codeberg.org/ichthyosaurus/.profile/raw/branch/main/badges/development_%20stable.svg"
           alt="Development status" />
    </a>
    <a href="https://codeberg.org/ichthyosaurus/harbour-captains-log/src/branch/main/LICENSES">
      <img src="https://codeberg.org/ichthyosaurus/.profile/raw/branch/main/badges/source%20code_%20AGPL-3.svg"
           alt="Source code license" />
    </a>
    <a href="https://api.reuse.software/info/codeberg.org/ichthyosaurus/harbour-captains-log">
      <img src="https://api.reuse.software/badge/codeberg.org/ichthyosaurus/harbour-captains-log"
           alt="REUSE status" />
    </a>
    <br />
    <a href="https://liberapay.com/SailfishOScommunityTeam">
      <img src="https://img.shields.io/liberapay/receives/SailfishOScommunityTeam?logo=liberapay&label=SailfishOS%20Community"
           alt="Community donations" />
    </a>
    <a href="https://liberapay.com/ichthyosaurus">
      <img src="https://img.shields.io/liberapay/receives/ichthyosaurus?logo=liberapay&label=ichthyosaurus"
           alt="Personal donations" />
    </a>
  </p>
  <p></p>
  <hr />
</div>

This repository contains the development of version 2.0.0 and upwards of
Captain's Log. Previous versions were developed by the original author
[AlphaX2](https://github.com/AlphaX2/Captains-Log-Sailfish).

## Features

- lockscreen to restrict access
- bookmark entries
- add tags
- browse your entries by different filters
- export your data to different file formats

**Note:** Captain's Log can hide your entries behind a protection code but it's
nothing special. Your data is neither encrypted nor otherwise protected against
a bad guy with physical (or SSH) access to your device.

### Planned features

- attach images to your entries
- include voice notes
- improved translations

> You can find screenshots [here](https://codeberg.org/ichthyosaurus/sailfish-app-assets/src/branch/main/harbour-captains-log/screenshots-store).


## Permissions

Captain's Log requires the following
[Sailjail](https://github.com/sailfishos/sailjail-permissions?tab=readme-ov-file#permissions) permissions:

- `Documents`: required to export the database to different file formats


## Help and support

You are welcome to
[leave a comment in the forum](https://forum.sailfishos.org/t/apps-by-ichthyosaurus/15753)
if you have any questions or ideas.


## Translations

It would be wonderful if the app could be translated in as many languages as possible!

[![Translations status](https://hosted.weblate.org/widget/harbour-captains-log/horizontal-auto.svg)](https://hosted.weblate.org/engage/harbour-captains-log/)

Translations are managed using
[Weblate](https://hosted.weblate.org/projects/harbour-captains-log).
Please prefer this over pull requests (which are still welcome, of course).
If you just found a minor problem, you can also
[open an issue](https://codeberg.org/ichthyosaurus/harbour-captains-log/issues/new).


### Manually updating translations

Please prefer using
[Weblate](https://hosted.weblate.org/projects/harbour-captains-log) over this.

You can follow these steps to manually add or update a translation:

1. If it did not exist before, create a new catalog for your language by copying the
   base file [translations/harbour-captains-log.ts](translations/harbour-captains-log.ts).
   Then add the new translation to [harbour-captains-log.pro](harbour-captains-log.pro).
2. Add yourself to the list of translators in [TRANSLATORS.json](TRANSLATORS.json),
   in the section `extra`.
3. (optional) Translate the app's name in [harbour-captains-log.desktop](harbour-captains-log.desktop)
   if there is a (short) native term for it in your language.

See [the Qt documentation](https://doc.qt.io/qt-5/qml-qtqml-date.html#details) for
details on how to translate date formats to your *local* format.


## Building and contributing

*Bug reports, and contributions for translations, bug fixes, or new features are always welcome!*

1. Clone the repository by running `git clone --recursive https://codeberg.org/ichthyosaurus/harbour-captains-log`
2. Open `harbour-captains-log.pro` in QtCreator for Sailfish ([SailfishOS SDK](https://docs.sailfishos.org/Tools/Sailfish_SDK/))
3. To run on emulator, select the `i486` target and press the run button
4. To build for the device, select the `aarch64` or `armv7hl` target and click “deploy all”;
   the RPM packages will be in the `RPMS` folder

If you contribute, please do not forget to add yourself to the list of
contributors in [qml/pages/AboutPage.qml](qml/pages/AboutPage.qml)!


## Donations

<a href="https://liberapay.com/ichthyosaurus/donate">
  <img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg">
</a>

I am always happy if you buy me a cup of coffee through
[Liberapay](https://liberapay.com/ichthyosaurus)
if you want to support my work.

Of course it would be much appreciated as well if you support this project by
contributing to translations or code! See above how you can contribute 🎕.

Please consider also supporting the
[SailfishOS Community Team](https://liberapay.com/SailfishOScommunityTeam)
on Liberapay to reach more developers.


## Anti-AI policy <a id='ai-policy'></a>

> [!IMPORTANT]
> - LLM/“AI”-generated contributions are forbidden.
> - Using this project in whole or in part for AI training or data mining is likewise forbidden.

Please be transparent, respect the Free Software community, and adhere to the
licenses. This is a welcoming place for human creativity and diversity, but
LLM/“AI”-generated slop is going against these values.

Apart from all the
[ethical](https://tante.cc/2026/02/20/acting-ethical-in-an-imperfect-world/),
[moral](https://www.theguardian.com/technology/2026/mar/17/x-csam-child-abuse-material-grok-australian-online-safety-regulator-ntwnfb),
[legal](https://en.wikipedia.org/wiki/Artificial_intelligence_and_copyright#Litigation),
[environmental](https://www.theguardian.com/environment/2025/apr/09/big-tech-datacentres-water),
[societal](https://www.theguardian.com/global-development/2026/mar/12/invasive-ai-led-mass-surveillance-in-africa-violating-freedoms-warn-experts),
[social](https://www.theguardian.com/technology/article/2024/jul/06/mercy-anita-african-workers-ai-artificial-intelligence-exploitation-feeding-machine),
[political](https://www.theguardian.com/technology/2025/nov/17/grokipedia-elon-musk-far-right-racist),
[technical](https://codeberg.org/small-hack/open-slopware#poor-code-quality),
and overall [human](https://www.hrw.org/news/2024/09/10/questions-and-answers-israeli-militarys-use-digital-tools-gaza),
reasons against LLMs/“AI”, I also simply don't have any spare time to review
generated contributions.

See also [this list](https://codeberg.org/small-hack/open-slopware#why-not-llms)
for more reasons against supporting “AI”.


## License

> Copyright (C) 2020-2026  Mirian Margiani
>
> Copyright (C) 2020  AlphaX2

Captain's Log is Free Software released under the terms of the
[GNU Affero General Public License v3 (or later)](https://spdx.org/licenses/AGPL-3.0-or-later.html).
The source code is available [on Codeberg](https://codeberg.org/ichthyosaurus/harbour-captains-log).
All documentation is released under the terms of the
[GNU Free Documentation License v1.3 (or later)](https://spdx.org/licenses/GFDL-1.3-or-later.html).

Captain's Log and related materials must not be used for AI training and/or data mining.

This project follows the [REUSE specification](https://api.reuse.software/info/codeberg.org/ichthyosaurus/harbour-captains-log).
