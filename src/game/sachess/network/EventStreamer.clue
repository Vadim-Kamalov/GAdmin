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

@import "game.sachess.network.Requests" => requestHelpers
@import "Requests"                      => requests
@import "Timers"                        => timers

/**
 * @class EventStreamer 
 * @field private createdTimer boolean
 * @field public token string
 * @field public active boolean
 * @field public err string
 * @field private callbacks (fun(table): void)[]
 */
local EventStreamer = {}; EventStreamer.__index = EventStreamer

/**
 * Create new instance of `EventStreamer` class.
 *
 * @param token string
 * @return EventStreamer
 */
method EventStreamer::new(token) {
    local instance = {}

    setmetatable(instance, self)

    self.__index          = self
    instance.createdTimer = false
    instance.token        = token
    instance.active       = false
    instance.err          = nil
    instance.callbacks    = {}

    return instance
}

/**
 * Create a public seek, to start a game with a random player.
 *
 * `options` table device:
 * ```clue
 * {
 *     rated        = boolean,
 *     time         = number,
 *     increment    = number,
 *     days         = number,
 *     variant      = string,
 *     color        = string
 *     rattingRange = string
 * }
 * ```
 *
 * Keep the connection open to keep the seek active (with `EventStreamer::start`).
 * If the client closes the connection, the seek is canceled. This way, if the client
 * terminates, the user won't be paired in a game they wouldn't play. 
 * When the seek is accepted, or expires, the server closes the connection.
 *
 * @param options table
 * @return void
 */
method EventStreamer::createSeek(options) {
    local directive = "/api/board/seek"
    local data      = ""

    for option, value of options {
        data ..= string.format("&%s=%s", option, value)
    }

    requestHelpers::postLichess(directive, self.token, fn (status) {
        if status.error {
            self.active = false
            self.err    = status.error
            return sampAddChatMessage(u8::decode(self.err), -1)
        } elseif status.warning {
            sampAddChatMessage(u8::decode(status.warning), -1)
        }
    }, {
        data    = string.sub(data, 2),
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })
}

/**
 * Add `callback` function to be called when received any event.
 *
 * @param callback fun(table): void
 * @return void
 */
method EventStreamer::onReceiveEvent(callback) {
    table.insert(self.callbacks, callback)
}

/**
 * Stream the events reaching a lichess user in real time.
 * @return void
 */
method EventStreamer::start() {
    local ignoredLines = {}

    self.active = true

    local fn request() {
        requests::asyncHttpRequest("GET", "https://lichess.org/api/stream/event", {
            headers = {
                Authorization = "Bearer " .. self.token
            }
        }, fn (response) {
            match response.status_code {
                429 => {
                    self.active = false
                    self.err    = "429 status code. Wait full minute before usaging API."
                    return $debugError!("EventStreamer::start", self.err)
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
                            for _, callback in self.callbacks {
                                callback(decodeJson(line))
                            }
                            table.insert(ignoredLines, line)
                        }
                    }
                }
            }
        }, fn (err) {
            return $debugError!("EventStreamer::start", err)
        })
    }

    if !self.createdTimer {
        self.createdTimer = true
        timers::add(fn { return self.active && !self.err }, fn {
            lua_thread.create(request)
        }, 3)
    }
}

/**
 * Stop streaming events.
 * @return void
 */
method EventStreamer::stop() {
    self.active = false
}

return EventStreamer
