#>
#> SPDX-FileCopyrightText: 2023 Mirian Margiani
#> SPDX-License-Identifier: GPL-3.0-or-later
#>
<!--(set_escape)-->#>
    latex
<!--(end)-->#>
---
title: "@!tr('''Diary from {0} to {1}''', from_date, to_date)!@"
author: ""
date: "@!today!@"
header-includes:
- |
  ```{=latex}
    \hypersetup{colorlinks=true}
    \usepackage{csquotes}
    \makeatletter
    \renewcommand\maketitle{
    \begin{center}
        {\LARGE\bfseries\@title\par\vspace{0.3em}}
        {\@date}
    \end{center}
    }
    \makeatother
  ```
---

<!--

# @!tr('''This file has been exported from Captain's Log on {0}.''', today)!@

@!tr('''You can convert this file to PDF using the following command:''')!@

    pandoc --defaults='@!output_name!@.yaml' '@!output_name!@.tex.md' -o '@!output_name!@.pdf'

@!tr('''Note: this requires “pandoc” and “lualatex”.''')!@

-->

<!--(macro changed)-->#> args: item
    <!--(if i['modify_date'])-->#>
\hfill{}@!tr('''last changed on {0}''', date(i['modify_date'], i['modify_tz']))!@#>
    <!--(end)-->#>
<!--(end)-->#>

<!--(macro tags)-->#> args: item
    <!--(if i['tags'])-->


// @!tr('''Tags: {0}''', i['tags'])!@
    <!--(end)-->#>
<!--(end)-->#>

<!--(for i in entries)-->

# <!--(if i['bookmark'])-->$\ast$ <!--(end)-->@!date(i['entry_date'], i['entry_tz'])!@<!--(if i['title'])-->: @!i['title']!@<!--(end)-->#>

    <!--(if i['is_addendum'])-->#>

*@!tr('''Addendum from {0}''', date(i['create_date'], i['create_tz']))!@*
    <!--(end)-->#>

    <!--(if i['entry'])-->#>
@!paragraphs(i['entry'])!@
    <!--(end)-->#>

\begin{small}
// @!tr('''Mood: {0}''', mood(i['mood']))!@@!changed(i=i)!@@!tags(i=i)!@
\end{small}

<!--(end)-->
