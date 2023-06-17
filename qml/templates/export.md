#!
#! SPDX-FileCopyrightText: 2023 Mirian Margiani
#! SPDX-License-Identifier: GPL-3.0-or-later
#!
<!--(set_escape)-->#!
    html
<!--(end)-->#!

# @!tr('''Diary from {0} to {1}''', from_date, to_date)!@

// *@!tr('''This file has been exported from Captain's Log on {0}.''', today)!@*

<!--(for i in entries)-->

    <!--(if i['title'])-->#!
## @!('(*) ' if i['bookmark'] else '')!@@!date(i['entry_date'], i['entry_tz'])!@: @!i['title']!@
    <!--(else)-->#!
## @!('(*) ' if i['bookmark'] else '')!@@!date(i['entry_date'], i['entry_tz'])!@
    <!--(end)-->#!

    <!--(if i['is_addendum'])-->#!
*@!tr('''Addendum from {0}''', date(i['create_date'], i['create_tz']))!@*

    <!--(end)-->#!
    <!--(if i['entry'])-->#!
@!paragraphs(i['entry'])!@

    <!--(end)-->#!
// *@!tr('''Mood: {0}''', mood(i['mood']))!@*

    <!--(if i['tags'])-->#!
// *@!tr('''Tags: {0}''', i['tags'])!@*

    <!--(end)-->#!
    <!--(if i['modify_date'])-->#!
// *@!tr('''last changed on {0}''', date(i['modify_date'], i['modify_tz']))!@*
    <!--(end)-->#!

<!--(end)-->#!