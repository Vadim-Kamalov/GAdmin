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

@import "game.sachess.engine.Position"     => Position
@import "game.sachess.engine.Coordinates"  => coordinates

local setup = {
    defaultFenNotation  = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    from                = {}
}

/**
 * Create new setup for `Board` from Forsyth-Edwards Notation (FEN).
 * 
 * Returned table device:
 * ```clue
 * {
 *     position     = Position,
 *     userSide     = CHESS_SIDE,
 *     sideToMove   = CHESS_SIDE,
 *     moveCount    = {
 *         noCaptures   = number,
 *         total        = number
 *     }
 * }
 *
 * @alias BoardSetup table<string, CHESS_SIDE|Position|table<string, number>>
 * @param userSide CHESS_SIDE
 * @param notation string FEN Notation. By default uses `setup.defaultFenNotation`.
 * @return BoardSetup
 */
method setup.from::forsythEdwardsNotation(userSide, notation = setup.defaultFenNotation) {
    local pieces, sideToMove, castlingRights, enPassantSquare, noCapturesMoveCount, moveCount
        = string.match(notation, "^([%w1-8/]+) ([wb]) ([KQkq%-]+) ([%-%w%d]+) (%d+) (%d+)$")

    local fn castlingContains(piece) {
        return (string.find(castlingRights, piece)) ? true : false
    }

    /**
     * We need padding here since our board is represented as 120-character length string.
     */
    local board = string.rep(string.rep(' ', 9) .. '\n', 2)

    for line with string.gmatch(pieces, "[^/]+") {
        board ..= ' '

        for index = 1, #line {
            local char = string.sub(line, index, index)

            if local times = tonumber(char) {
                board ..= string.rep('.', times)
            } else {
                board ..= char
            }
        }

        board ..= '\n'
    }

    board ..= string.rep(string.rep(' ', 9) .. '\n', 2)

    local whiteCastling = { castlingContains('Q'), castlingContains('K') }
    local blackCastling = { castlingContains('q'), castlingContains('k') }

    local userCastling     = (userSide == CHESS_SIDE_WHITE) ? whiteCastling : blackCastling
    local opponentCastling = (userSide == CHESS_SIDE_WHITE) ? blackCastling : whiteCastling

    local enPassant = (enPassantSquare == '-') ? 0 : coordinates::parse(enPassantSquare)

    local position   = Position::new(board, userCastling, opponentCastling, enPassant, 0)
    local sideToMove = ($ == 'w') ? CHESS_SIDE_WHITE : CHESS_SIDE_BLACK

    if sideToMove == CHESS_SIDE_BLACK && userSide == CHESS_SIDE_WHITE {
        position::rotate()
    }

    return {
        userSide    = userSide,
        position    = position,
        sideToMove  = sideToMove,
        moveCount   = {
            noCaptures  = tonumber(noCapturesMoveCount),
            total       = tonumber(moveCount)
        }
    }
}

return setup
