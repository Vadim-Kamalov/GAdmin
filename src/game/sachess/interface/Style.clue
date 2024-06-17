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
 * SPDX-License-Identifier: GPL-3.0-only
 */

@import "Common" => common

local style = {}

/**
 * Theme for board. Colors were taked from Lichess Pretier extension:
 *    https://prettierlichess.github.io/
 */
style.board = {
    check = common::convertHex2ImVec4("AB4249"),
    arrow = common::convertHex2ImVec4("A0DAB4"),

    [CHESS_SIDE_WHITE] = {
        background  = common::convertHex2ImVec4("C7C7C7"),
        active      = common::convertHex2ImVec4("BDCABE"),
        moveTo      = common::convertHex2ImVec4("608977"),
        lastMove    = common::convertHex2ImVec4("B4CDB6")
    }, [CHESS_SIDE_BLACK] = {
        background  = common::convertHex2ImVec4("71828F"),
        active      = common::convertHex2ImVec4("799392"),
        moveTo      = common::convertHex2ImVec4("9CB99E"),
        lastMove    = common::convertHex2ImVec4("81A395")
    }
}

return style
