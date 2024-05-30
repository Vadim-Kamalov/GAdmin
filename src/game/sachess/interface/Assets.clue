/**
 * This file is a part of the SAChess project: see `src/sachess/README.md` for more details.
 *
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
 *
 * SAChess - MoonLoader script that implements Lichess API.
 * Copyright (C) 2024 defaultzone.
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
 * SDPX-License-Identifier: GPL-3.0-only
 */

local assets = { token = {} }

/**
 * Get MM:SS from given milliseconds.
 * @param milliSeconds number
 * @return string
 */
method assets::getRenderedSeconds(milliSeconds) {
    local totalSeconds = milliSeconds / 1000
    local minutes      = math.floor(totalSeconds / 60)
    local seconds      = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
}

/**
 * Get previously saved (or not) token from `$PWD/SAChessToken.txt`.
 * @return string
 */
method assets.token::get() {
    if doesFileExist(getWorkingDirectory() .. "/SAChessToken.txt") {
        local handle = io.open(getWorkingDirectory() .. "/SAChessToken.txt", "r")
        local token  = handle::read("*all")
        handle::close()
        return token
    }
    return ""
}

/**
 * Save `token` in `$PWD/SAChessToken.txt`.
 * @param token string
 * @return void
 */
method assets.token::save(token) {
    local handle, error = io.open(getWorkingDirectory() .. "/SAChessToken.txt", "w")
    if !error { 
        handle::write(token)
        handle::close()
    }
}

return assets
