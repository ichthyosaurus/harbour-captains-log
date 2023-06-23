//@ This file is part of opal-about.
//@ https://github.com/Pretty-SFOS/opal-about
//@ SPDX-FileCopyrightText: 2023 Mirian Margiani
//@ SPDX-License-Identifier: GPL-3.0-or-later

WorkerScript.onMessage = function(message) {
    var dict = message.dict
    var model = message.model
    var count = message.count

    for (var i = 0; i < model.count; ++i) {
        var rowid = model.get(i).rowid

        if (dict[rowid] === true) {
            continue
        } else {
            dict[rowid] = true
            count += 1
        }
    }

    WorkerScript.sendMessage({
        'dict': dict, 'count': count
    })
}
