dnl/// SPDX-FileCopyrightText: 2022-2023 Mirian Margiani
dnl/// SPDX-License-Identifier: GFDL-1.3-or-later

ifdef(${__X_summary}, ${
__name is a simple diary application for keeping track of your thoughts.
})dnl

ifdef(${__X_readme}, ${This repository contains the development of version 2.0.0 and upwards of
Captain's Log. Previous versions were developed by the original author
[AlphaX2](https://github.com/AlphaX2/Captains-Log-Sailfish).
})dnl

## Features

- lockscreen to restrict access
- bookmark entries
- add tags
- browse your entries by different filters
- export your data to different file formats

**Note:** Captain's Log can hide your entries behind a protection code but it's
nothing special. Your data is neither encrypted nor otherwise protected against
a bad guy with physical (or SSH) access to your device.

ifdef(${__X_readme}, ${### Planned features

- attach images to your entries
- include voice notes
- improved translations})

## Permissions

Captain's Log requires the following permissions:

- Documents: required to export the database to different file formats
