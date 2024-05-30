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

@import "game.sachess.engine.Coordinates" => coordinates
@import "game.sachess.engine.Board"       => Board
@import "game.sachess.engine.Setup"       => setup
@import "game.sachess.network.Requests"   => requestHelpers
@import "game.sachess.engine.Models"      => models
@import "Requests"                        => requests
@import "Timers"                          => timers

/**
 * @class BoardStreamer
 * @field private timerIndex number
 * @field private createdTimer boolean
 * @field public board Board
 * @field public token string
 * @field public gameId string
 * @field public state boolean
 * @field public error string|nil
 * @field public information table<string, any>
 */
local BoardStreamer = {}; BoardStreamer.__index = BoardStreamer

/**
 * Create new instance of `BoardStreamer` class.
 *
 * @param token string
 * @param gameId string
 * @param board Board
 * @return BoardStreamer
 */
method BoardStreamer::new(token, gameId, board) {
    local instance = {}

    setmetatable(instance, self)

    self.__index          = self
    instance.timerIndex   = 0
    instance.createdTimer = false
    instance.board        = board
    instance.token        = token
    instance.gameId       = gameId
    instance.state        = false
    instance.error        = nil
    instance.information  = {
        offers = {
            draw = {
                state = "none", // "none" | "requested" | "accepted" | "declined"
                by    = "none", // "none" | "white" | "black"
                on    = 0,      // move count when offered draw
                clock = nil,
                show  = false
            }
        },

        game = {
            status       = GAME_STATUS_ACTIVE
            fetched      = nil,
            userResigned = false,
            chatLines    = {},
            rated        = false,
            createdAt    = -1,

            variant = {
                key   = "",
                name  = "",
                short = ""
            },

            clock = {
                initial   = -1,
                increment = -1
            },

            state = {
                moves  = "",
                wtime  = -1,
                btime  = -1,
                winc   = -1,
                binc   = -1,
                status = ""
            }
        }, players = {
            white = {
                id     = "",
                name   = "",
                rating = -1,
                title  = ""
            },

            black = {
                id     = "",
                name   = "",
                rating = -1,
                title  = ""
            }
        }
    }

    board.streamer = instance

    return instance
}

BoardStreamer.postReject = fn (status) {
    if status.error {
        $debugError!("BoardStreamer.postReject", boardStreamer.error)
    }
}

/**
 * Stream the state of a game being played with the Board API.
 * 
 * @param state boolean
 * @return void
 */
method BoardStreamer::stream(state) {
    if !state { self.state = false; return } else {
        self.state = state
    }

    local ignoredLines = {}
    local request      = fn {
        requests::asyncHttpRequest("GET", "https://lichess.org/api/board/game/stream/" .. self.gameId, {
            headers = {
                Authorization = "Bearer " .. self.token
            }
        }, fn (response) {
            match response.status_code {
                404 => {
                    self.state = false
                    self.error = "The game was not found."
                    return sampAddChatMessage(self.error, -1)
                }

                429 => {
                    self.state = false
                    self.error = "429 status code. Wait full minute before usaging API."
                    return sampAddChatMessage(self.error, -1)
                }

                200 => {
                    for line with string.gmatch(response.text, "[^\r\n]+") {
                        local notIgnoredLine = true

                        for _, ignoredLine in ignoredLines {
                            if ignoredLine == line {
                                notIgnoredLine = false
                            }
                        }

                        if notIgnoredLine {
                            local gameState   = decodeJson(line)
                            local information = self.information

                            match gameState.type {
                                "gameFull" => {
                                    information.game.variant   = gameState.variant
                                    information.game.clock     = gameState.clock
                                    information.game.createdAt = gameState.createdAt
                                    
                                    for _, side in ({ "white", "black" }) {
                                        information.players[side] = {
                                            id      = gameState[side].id        || "",
                                            name    = gameState[side].name      || "",
                                            rating  = gameState[side].rating    || 0,
                                            title   = gameState[side].title     || ""
                                        }
                                    }

                                    if gameState.state.type == "gameState" {
                                        information.game.state.wtime    = gameState.state.wtime
                                        information.game.state.btime    = gameState.state.btime
                                        information.game.state.winc     = gameState.state.winc
                                        information.game.state.binc     = gameState.state.binc

                                        information.game.state.status = gameState.state.status

                                        if information.game.state.moves != gameState.state.moves {
                                            local newMoves = string.sub(
                                                gameState.state.moves,
                                                (#information.game.state.moves == 0) ? 1 : #information.game.state.moves + 2,
                                                #gameState.state.moves
                                            )

                                            for move with string.gmatch(newMoves, "%S+") {
                                                self.board::moveAlgebraic(move)
                                            }

                                            information.game.state.moves = gameState.state.moves
                                        }

                                        information.game.status = match information.game.state.status {
                                            "mate"      => GAME_STATUS_CHECKMATE,
                                            "draw"      => GAME_STATUS_DRAW,
                                            "resign"    => GAME_STATUS_RESIGN,
                                            "outoftime" => GAME_STATUS_OUT_OF_TIME,
                                            "aborted"   => GAME_STATUS_ABORTED,
                                            default     => GAME_STATUS_ACTIVE
                                        }

                                       
                                        information.game.fetched ??= os.clock()
                                        
                                        if information.game.status != GAME_STATUS_ACTIVE {
                                            self.state                   = false
                                            self.information.offers.draw = {
                                                state = "none",
                                                by    = "none",
                                                on    = 0,
                                                clock = nil,
                                                show  = false
                                            }

                                            table.remove(timers, self.timerIndex)
                                        }
                                    }
                                }

                                "chatLine" => {
                                    if gameState.username == "lichess" {
                                        match gameState.text {
                                            // fuck takebacks
                                            "Takeback sent"     ||
                                            "Takeback accepted" ||
                                            "Takeback cancelled" => { continue }
                                        }

                                        if local side, state = string.match(gameState.text, "^(%w+) (%w+) draw$") {
                                            self.information.offers.draw.clock = os.clock()
                                            self.information.offers.draw.by    = string.lower(side)
                                            self.information.offers.draw.show  = true
                                            self.information.offers.draw.state = match state {
                                                "offers"    => "requested",
                                                "declines"  => "declined"
                                            }

                                            local userSide = (self.board.userSide == CHESS_SIDE_WHITE) ? "white" : "black"

                                            if self.information.offers.draw.state == "requested" && self.information.offers.draw.by == userSide {
                                                self.information.offers.draw.on   = #self.board.moves
                                                self.information.offers.draw.show = false
                                            }

                                            continue
                                        } elseif gameState.text == "Draw offer accepted" {
                                            self.information.offers.draw.clock = os.clock()
                                            self.information.offers.draw.state = "accepted"
                                            continue
                                        }
                                    }

                                    table.insert(self.information.game.chatLines, {
                                        username = gameState.username,
                                        text     = gameState.text
                                    })
                                }
                            }

                            table.insert(ignoredLines, line)
                        }
                    }
                }
            }

            return
        }, fn (err) {
            return $debugError!("BoardStreamer::stream", err)
        })
    }

    if !self.createdTimer {
        self.createdTimer = true
        self.timerIndex   = #timers + 1
        timers::add(fn { return self.state && !self.error }, fn {
            lua_thread.create(request)
        }, 0.5)
    }
}

/**
 * Make a move in a game being played with the Board API.
 * 
 * @param move string The move to play in UCI format.
 * @param promotion CHESS_MODEL
 * @return void
 */
method BoardStreamer::move(move, promotion) {
    if type(move) == "table" {
        move = coordinates::render($[1], self.board.sideToMove) ..
               coordinates::render($[2], self.board.sideToMove) ..
               ((promotion) ? models::getChar(promotion) : '')
    }

    requestHelpers::postLichess("/api/board/game/" .. self.gameId .. "/move/" .. move, self.token, self.postReject)
}

/**
 * Post a message to the player or spectator chat, in a game being played with the Board API.
 *
 * @param text string
 * @param room "player" | "spectator"
 * @return void
 */
method BoardStreamer::writeInChat(text, room = "player") {
    local directive = string.format("/api/board/game/%s/chat", self.gameId)
    local data      = string.format("room=%s&text=%s", room, requests::encodeURLString(text))

    requestHelpers::postLichess(directive, self.token, self.postReject, {
        data    = data,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })
}

/**
 * Resign a game being played with the Board API.
 * @return void
 */
method BoardStreamer::resign() {
    local directive = string.format("/api/board/game/%s/resign", self.gameId)
    requestHelpers::postLichess(directive, self.token, self.postReject)

    self.information.game.userResigned = true
}

/**
 * Abort a game being played with the Board API. Notice that we can abort only on the first move.
 * @return void
 */
method BoardStreamer::abort() {
    local directive = string.format("/api/board/game/%s/abort", self.gameId)
    requestHelpers::postLichess(directive, self.token, self.postReject)
}

/**
 * Create/accept/decline draw offers.
 *
 * @param state boolean
 * @return void
 */
method BoardStreamer::handleDrawOffer(state) {
    local directive = string.format("/api/board/game/%s/draw/%s", self.gameId, ((state) ? "yes" : "no"))
    requestHelpers::postLichess(directive, self.token, self.postReject)
}

return BoardStreamer
