/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

@import "game.Spectator" => spectator

method sampev.onShowTextDraw(id, data) {
    if data.text == "Adadadad_Dfghsadersasd(111)" ||
       data.text == "2282282~n~$400000~n~90 MP/H~n~100/20~n~M4A1/Pustinniy Orel~n~999 ms~n~127.23.42.123"
    {
        return false
    }

    if string.find(data.text, "~y~%(%d+%)") {
        spectator.textDrawId = id
        spectator::setTo(tonumber(string.match(data.text, "~y~%(%d+%)")))
        return false
    } 

    if string.find(data.text, "ID Akkay") {
        return false
    }
}
