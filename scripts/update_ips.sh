#!/bin/bash
#
# GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2026 The Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0-only
#
# =========================================
# usage: ./update_ips.sh [git_commit_flags]
# =========================================

set -euo pipefail

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
NEW_IPS=$(dig "sa.gambit-rp.ru" "ru.gambit-rp.ru" +short | sort)

if [ -z "$NEW_IPS" ]; then
    echo "dig command returned an empty string"
    exit 1
fi

ALLOWED_IPS_FILE="$SCRIPT_PATH/../embed/allowed_ips.txt"
OLD_IPS=$(cat "$ALLOWED_IPS_FILE")

if [[ "$NEW_IPS" == "$OLD_IPS" ]]; then
    exit 0
fi

printf "%s" "$NEW_IPS" > "$ALLOWED_IPS_FILE"

git add "$ALLOWED_IPS_FILE"
git commit -m "misc: update embed/allowed_ips.txt (./scripts/update_ips.sh)" "$@"
git push
