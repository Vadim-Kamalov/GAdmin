/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
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

method sampev.onTextDrawSetString(id, text) {
    if string.find(text, "~y~%(%d+%)") {
        spectator.textDrawId = id
        spectator::setTo(tonumber(string.match(text, "%((%d+)%)")))
    } elseif string.find(text, "HP") && string.find(text, "ID") {
        spectator::setInformation({ health = string.match(text, "HP: (%d+)") })
    
        local result, handle = spectator::getHandle()
        if result && isCharInAnyCar(handle) {
            spectator::setInformation({ moveSpeedCurrent = string.match(text, "(%d+) / [%-]?%d+") })
        }

        spectator::setInformation({ world = string.match(text, "~n~Android: .+~n~Mo.+: (%d+)$") })
    }

    if string.find(text, "~n~Android: .+~n~") {
        spectator.platform = (string.match(text, "~n~Android: (.+)~n~") == "He\166") ? PLATFORM_PC : PLATFORM_ANDROID
    }
}
