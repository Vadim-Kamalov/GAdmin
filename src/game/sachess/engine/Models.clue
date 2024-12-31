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

static enum /** @enum CHESS_SIDE */ {
    CHESS_SIDE_BLACK,
    CHESS_SIDE_WHITE
}

static enum /** @enum CHESS_MODEL */ {
    CHESS_MODEL_NONE,
    CHESS_MODEL_KING,
    CHESS_MODEL_ROOK,
    CHESS_MODEL_BISHOP,
    CHESS_MODEL_QUEEN,
    CHESS_MODEL_KNIGHT,
    CHESS_MODEL_PAWN
}

local models = {
    squares = {}
}

/**
 * Get `CHESS_MODEL` from given `char`.
 *
 * @param char string (size == 1)
 * @return CHESS_MODEL
 */
method models::getFromChar(char) {
    return match string.lower(char) {
        '.' => CHESS_MODEL_NONE,
        'k' => CHESS_MODEL_KING,
        'q' => CHESS_MODEL_QUEEN,
        'b' => CHESS_MODEL_BISHOP,
        'n' => CHESS_MODEL_KNIGHT,
        'r' => CHESS_MODEL_ROOK,
        'p' => CHESS_MODEL_PAWN
    }
}

/**
 * Get `char` from given `CHESS_MODEL`.
 * 
 * @param model CHESS_MODEL
 * @param char string (size == 1)
 */
method models::getChar(model) {
    return match model {
        CHESS_MODEL_NONE    => '.',
        CHESS_MODEL_KING    => 'k',
        CHESS_MODEL_QUEEN   => 'q',
        CHESS_MODEL_BISHOP  => 'b',
        CHESS_MODEL_KNIGHT  => 'n',
        CHESS_MODEL_ROOK    => 'r',
        CHESS_MODEL_PAWN    => 'p'
    }
}

/**
 * All the squares on the 120-character board for white perspective.
 */
models.squares[CHESS_SIDE_WHITE] = {
    a1 = 91, b1 = 92, c1 = 93, d1 = 94, e1 = 95, f1 = 96, g1 = 97, h1 = 98,
    a2 = 81, b2 = 82, c2 = 83, d2 = 84, e2 = 85, f2 = 86, g2 = 87, h2 = 88,
    a3 = 71, b3 = 72, c3 = 73, d3 = 74, e3 = 75, f3 = 76, g3 = 77, h3 = 78,
    a4 = 61, b4 = 62, c4 = 63, d4 = 64, e4 = 65, f4 = 66, g4 = 67, h4 = 68,
    a5 = 51, b5 = 52, c5 = 53, d5 = 54, e5 = 55, f5 = 56, g5 = 57, h5 = 58,
    a6 = 41, b6 = 42, c6 = 43, d6 = 44, e6 = 45, f6 = 46, g6 = 47, h6 = 48,
    a7 = 31, b7 = 32, c7 = 33, d7 = 34, e7 = 35, f7 = 36, g7 = 37, h7 = 38,
    a8 = 21, b8 = 22, c8 = 23, d8 = 24, e8 = 25, f8 = 26, g8 = 27, h8 = 28
}

/**
 * All the squares on the 120-character board for black perspective.
 */
models.squares[CHESS_SIDE_BLACK] = {
    a1 = 28, b1 = 27, c1 = 26, d1 = 25, e1 = 24, f1 = 23, g1 = 22, h1 = 21,
    a2 = 38, b2 = 37, c2 = 36, d2 = 35, e2 = 34, f2 = 33, g2 = 32, h2 = 31,
    a3 = 48, b3 = 47, c3 = 46, d3 = 45, e3 = 44, f3 = 43, g3 = 42, h3 = 41,
    a4 = 58, b4 = 57, c4 = 56, d4 = 55, e4 = 54, f4 = 53, g4 = 52, h4 = 51,
    a5 = 68, b5 = 67, c5 = 66, d5 = 65, e5 = 64, f5 = 63, g5 = 62, h5 = 61,
    a6 = 78, b6 = 77, c6 = 76, d6 = 75, e6 = 74, f6 = 73, g6 = 72, h6 = 71,
    a7 = 88, b7 = 87, c7 = 86, d7 = 85, e7 = 84, f7 = 83, g7 = 82, h7 = 81,
    a8 = 98, b8 = 97, c8 = 96, d8 = 95, e8 = 94, f8 = 93, g8 = 92, h8 = 91
}

return models
