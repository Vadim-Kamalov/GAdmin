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

/**
 * Helpers to determine special, space, lowercase and uppercase characters.
 */
@macro IS_SPECIAL(str)  { (string.find(". \n", $str)) }
@macro IS_SPACE(str)    { ($str == ' ' || $str == '\n' || $str == '\t') }
@macro IS_LOWER(str)    { (string.lower($str) == $str && !$IS_SPECIAL!($str)) }
@macro IS_UPPER(str)    { (string.upper($str) == $str && !$IS_SPECIAL!($str)) }

/**
 * Our board is represented as a 120 character string. The padding allows for
 * fast detection of moves that don't stay within the board.
 *
 * Initial position for board will be represented as:
 *
 * ```clue
 * local initial = 
 *      "         \n" .. //   0 - 9
 *      "         \n" .. //  10 - 19
 *      " rnbqkbnr\n" .. //  20 - 29
 *      " pppppppp\n" .. //  30 - 39
 *      " ........\n" .. //  40 - 49
 *      " ........\n" .. //  50 - 59
 *      " ........\n" .. //  60 - 69
 *      " ........\n" .. //  70 - 79
 *      " PPPPPPPP\n" .. //  80 - 89
 *      " RNBQKBNR\n" .. //  90 - 99
 *      "         \n" .. // 100 - 109
 *      "         \n"    // 110 - 119
 * ```
 *
 * @alias ChessBoard string
 */
static enum /** @enum TABLE_CORNER */ {
    TABLE_CORNER_A1 = 91,
    TABLE_CORNER_H1 = 98,
    TABLE_CORNER_A8 = 21,
    TABLE_CORNER_H8 = 28
}

/**
 * Tables of possible moves for each piece type.
 */
local N, E, S, W = -10, 1, 10, -1
local directions = {
    P = { N, N + N, N + W, N + E },
    N = {
        N + N + E,
        E + N + E,
        E + S + E,
        S + S + E,
        S + S + W,
        W + S + W,
        W + N + W,
        N + N + W
    },
    B = { N + E, S + E, S + W, N + W },
    R = { N, E, S, W },
    Q = { N, E, S, W, N + E, S + E, S + W, N + W },
    K = { N, E, S, W, N + E, S + E, S + W, N + W }
}

local __1 = 1 //! 1-index correction.

/**
 * @class Position
 *
 * @field public board ChessBoard
 * @field private check boolean
 * @field private wc boolean[]
 * @field private bc boolean[]
 * @field private ep number
 * @field private kp number
 */
local Position = {}; Position.__index = Position

/**
 * Create new instance of `Position` class.
 *
 * @param board ChessBoard      120 char representation of the board.
 * @param wc boolean[]          The castling rights.
 * @param bc boolean[]          The oponnent castling rights.
 * @param ep number             The En-Passant square.
 * @param kp number             The King-Passant square.
 * @return Position
 */
method Position::new(board, wc, bc, ep, kp) {
    local instance = {}

    setmetatable(instance, self)
    self.__index = self

    instance.board    = board
    instance.check    = false
    instance.wc       = wc
    instance.bc       = bc
    instance.ep       = ep
    instance.kp       = kp

    return instance
}

/**
 * Generate moves or each of our pieces by iteration through each possible `ray` of moves,
 * as defined in the `directions` map. The rays are broken e.g. by captures or immediately
 * in case of pieces such as knights.
 *
 * @param check boolean
 * @return number[][] First number is piece, second is generated move.
 */
method Position::generateMoves(check = false) {
    local moves = {}

    for i = 1 - __1, #self.board - __1 {
        local piece = string.sub(self.board, i + __1, i + __1)
        if $IS_UPPER!(piece) && directions[piece] {
            for _, direction in directions[piece] {
                local limit = (i + direction + 0x2710) * direction
                for j = i + direction, limit, direction {
                    local q = string.sub(self.board, j + __1, j + __1)

                    if $IS_SPACE!(q) { break } //! Stay inside the board.

                    if !check {
                        /**
                        * Castling.
                        */
                        if i == TABLE_CORNER_A1 && q == 'K' && self.wc[0 + __1] && !self::isKingLossMove({ j, j - 1 }) {
                            table.insert(moves, { j, j - 2 })
                        }

                        if i == TABLE_CORNER_H1 && q == 'K' && self.wc[1 + __1] && !self::isKingLossMove({ j, j + 1 }) {
                            table.insert(moves, { j, j + 2 })
                        }
                    }

                    if $IS_UPPER!(q) { break } //! No friendly captures.

                    /**
                     * Special pawn stuff like en-passant and double push.
                     */
                    if piece == 'P' && (direction == N + W || direction == N + E) && q == '.' && j != self.ep && j != self.kp {
                        break
                    }

                    if piece == 'P' && (direction == N || direction == (N + N)) && q != '.' {
                        break
                    }

                    if piece == 'P' && direction == (N + N) && (i < (TABLE_CORNER_A1 + N) || string.sub(self.board, i + N + __1, i + N + __1) != '.') {
                        break
                    }

                    //! Move allowed, so insert it.
                    table.insert(moves, { i, j })

                    if piece == 'P' || piece == 'N' || piece == 'K' { break }   //! Stop crawlers from sliding.
                    if $IS_LOWER!(q) { break }                                  //! No sliding after captures.
                }
            }
        }
    }

    return moves
}

/**
 * Just rotate the board.
 * @return void
 */
method Position::rotate() {
    self.wc, self.bc    = $2, $1
    self.ep             = 119 - $
    self.kp             = 119 - $
    self.board          = string.reverse(string.gsub($, "%a", fn (c) {
        return ($IS_LOWER!(c)) ? string.upper(c) : string.lower(c)
    }))
}

/**
 * Move piece to new square.
 *
 * @param move number[]
 * @param conversion string|nil Piece that will change pawn after after it's promotion. (default = 'Q')
 * @return void
 */
method Position::move(move, conversion = 'Q') {
    local i, j = move[0 + __1], move[1 + __1]
    local p, q = string.sub(self.board, i + __1, i + __1), string.sub(self.board, j + __1, j + __1)

    local fn put(board, i, p) {
        return string.sub(board, 1, i - 1) .. p .. string.sub(board, i + 1)
    }

    /**
     * Copy variables and reset `ep` and `kp`.
     */
    local board          = self.board
    local wc, bc, ep, kp = self.wc, self.bc, 0, 0

    /**
     * Actual move.
     */
    board = put($, j + __1, string.sub($, i + __1, i + __1))
    board = put($, i + __1, '.')

    /**
     * Castling rights.
     */
    if i == TABLE_CORNER_A1 { wc = { false, wc[0 + __1] } }
    if i == TABLE_CORNER_H1 { wc = { wc[0 + __1], false } }
    if j == TABLE_CORNER_A8 { bc = { bc[0 + __1], false } }
    if j == TABLE_CORNER_H8 { bc = { false, bc[1 + __1] } }

    /**
     * Castling.
     */
    if p == 'K' {
        wc = { false, false }
        if math.abs(j - i) == 2 {
            kp      = math.floor((i + j) / 2)
            board   = put($, (j < i) ? TABLE_CORNER_A1 + __1 : TABLE_CORNER_H1 + __1, '.')
            board   = put($, kp + __1, 'R')
        }
    }

    /**
     * Special pawn stuff like En-Passant and double push.
     */
    if p == 'P' {
        if TABLE_CORNER_A8 <= j && j <= TABLE_CORNER_H8 {
            board = put($, j + __1, conversion)
        }

        if (j - i) == (N + N) {
            ep = i + N
        }

        if ((j - i) == N + W || (j - i) == N + E) && q == '.' {
            board = put($, j + S + __1, '.')
        }
    }

    self.board = board
    self.wc    = wc
    self.bc    = bc
    self.ep    = ep
    self.kp    = kp
}

/**
 * Check that player's king is in check. Call after enemy move to determine check.
 * If king is in check then you can use `Position::getKingSafeMoves` to generate not pseudo-legal move.
 *
 * @return boolean
 */
method Position::isKingInCheck() {
    self::rotate()
    
    for _, move in self::generateMoves(true) {
        if string.sub(self.board, move[2] + 1, move[2] + 1) == 'k' {
            self::rotate()
            return true
        }
    }

    self::rotate()

    return false
}

/**
 * Check that `move` is king loss.
 *
 * @param move number[]
 * @return boolean
 */
method Position::isKingLossMove(move) {
    local board          = self.board
    local wc, bc, ep, kp = self.wc, self.bc, self.ep, self.kp

    self::move(move)

    local result = self::isKingInCheck()
    self.board   = board
    self.wc      = wc
    self.bc      = bc
    self.ep      = ep
    self.kp      = kp
    
    return result
}

/**
 * Get moves that safe to king. If there is no safe moves
 * then there is a checkmate for a player.
 *
 * @return number[]
 */
method Position::getKingSafeMoves() {
    local moves = {}

    for _, move in self::generateMoves(true) {
        if !self::isKingLossMove(move) {
            table.insert(moves, move)
        }
    }

    return moves
}

return Position
