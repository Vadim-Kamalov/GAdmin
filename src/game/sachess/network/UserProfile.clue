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

/**
 * @class UserProfile
 * @field public token string
 * @field public username string
 * @field public games table<string, number>
 * @field public ratings table<string, number>
*/
local UserProfile = {}; UserProfile.__index = UserProfile

/**
 * Create new instance of `UserProfile` class.
 *
 * @param token string
 * @return UserProfile
 */
method UserProfile::new(token) {
    local instance = {}

    setmetatable(instance, self)
    
    self.__index      = self
    instance.token    = token
    instance.username = ""
    instance.games    = { all = 0, win = 0, loss = 0, draw = 0 }
    instance.ratings  = {
        classical = 0,
        rapid     = 0,
        blitz     = 0,
        bullet    = 0,
        puzzle    = 0
    }

    return instance
}

/**
 * Update `username`, `games` and `ratings` fields using `/api/account/` directive.
 *
 * @param onUpdate (fun(UserProfile): void)|nil
 * @param onError (fun(string): void)|nil
 * @return void
 */
method UserProfile::update(onUpdate, onError) {
    lua_thread.create(fn {
        requests::asyncHttpRequest("GET", "https://lichess.org/api/account", {
            headers = {
                Authorization = "Bearer " .. self.token
            }
        }, fn (response) {
            if response.status_code == 200 {
                local account = decodeJson(response.text)

                for perf, _ of self.ratings {
                    if account.perfs[perf]?.rating {
                        self.ratings[perf] = account.perfs[perf].rating
                    }
                }

                for type, _ of self.games {
                    self.games[type] = account.count[type]
                }

                self.username = account.username

                onUpdate?(self)
            } else {
                onError?(response.text)
            }
        }, fn (error) {
            onError?(error)
        })
    })
}

return UserProfile
