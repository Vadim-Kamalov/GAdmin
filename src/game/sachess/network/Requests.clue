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

@import "Requests" => requests

local requestHelpers = {}

/**
 * Send POST request to the Lichess API.
 *
 * @param directive string
 * @param token string
 * @param reject (fun(table<string, string>): void)|nil
 * @param arguments table<string, string|table>|nil
 * @return void
 */
method requestHelpers::postLichess(directive, token, reject = fn {}, arguments = {}) {
    arguments.headers             ??= {}
    arguments.headers.Authorization = "Bearer " .. token

    local status = {}

    lua_thread.create(fn {
        requests::asyncHttpRequest("POST", "https://lichess.org" .. directive, arguments, fn (response) {
            status.error = match response.status_code {
                400 || 404  => response.text,
                429         => "429 status code. Wait full minute before usaging API.",
                default     => nil
            }

            if status.error {
                return reject(status)
            }
        }, fn {
            return requests::postLichess(directive, token, reject, arguments)
        })
    })
}

return requestHelpers
