/**
 * This file is a part of the SAChess project: see `src/sachess/README.md` for more details.
 *
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

local coordinates = {}

/**
 * Parse algebraic coordinates and return cell index on the board.
 * @param c string
 * @return number
 */
method coordinates::parse(c) {
    local p, v          = string.sub(c, 1, 1), string.sub(c, 2, 2)
    local file, rank    = string.byte(p) - string.byte('a'), tonumber(v) - 1

    return TABLE_CORNER_A1 + file - 10 * rank 
}

/**
 * Get algebraic coordinates from cell index on the board.
 * @param i number
 * @param side CHESS_SIDE
 * @return string
 */
method coordinates::render(i, side = CHESS_SIDE_WHITE) {
    for coordinates, index of import("game.sachess.engine.Models").squares[side] {
        if i == index {
            return coordinates
        }
    }
}

return coordinates
