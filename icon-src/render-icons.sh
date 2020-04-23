#!/bin/bash
#
# This file is part of harbour-captains-log.
# Copyright (C) 2020  Mirian Margiani
#
# harbour-captains-log is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# harbour-captains-log is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with harbour-captains-log.  If not, see <http://www.gnu.org/licenses/>.
#

# echo "rendering app icon..."
#
# postfix=""
# root="../icons"
# appicons=(harbour-captains-log)
# for i in 86 108 128 172; do
#     mkdir -p "$root/${i}x$i"
#
#     for a in "${appicons[@]}"; do
#         if [[ ! "$a.svg" -nt "$root/${i}x$i/$a$postfix.png" ]]; then
#             echo "nothing to do for $a at ${i}x$i"
#             continue
#         fi
#
#         inkscape -z -e "$root/${i}x$i/$a$postfix.png" -w "$i" -h "$i" "$a.svg"
#     done
# done


echo "rendering icons..."

root="../qml/images"
files=(mood-0@112 mood-1@112 mood-2@112 mood-3@112 mood-4@112)
       # harbour-captains-log@256)
mkdir -p "$root"

for img in "${files[@]}"; do
    if [[ ! "${img%@*}.svg" -nt "$root/${img%@*}.png" ]]; then
        echo "nothing to do for '${img%@*}.svg'"
        continue
    fi

    inkscape -z -e "$root/${img%@*}.png" -w "${img#*@}" -h "${img#*@}" "${img%@*}.svg"
done

if [[ ! "cover-bg.svg" -nt "$root/cover-bg.png" ]]; then
    echo "nothing to do for 'cover-bg.svg'"
else
    inkscape -z -e "$root/cover-bg.png" -w "460" -h "736" "cover-bg.svg"
fi
