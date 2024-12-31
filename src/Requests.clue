/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

local requests = {}

/**
 * Send asynchronous HTTP request with specific method (`type`). 
 * Use this function only in the thread! (`lua_thread.create(fn { ... })`).
 *
 * @param type string
 * @param url string
 * @param args table<string, string|table>|nil
 * @param resolve (fun(table): void)|nil
 * @param reject (fun(string): void)|nil
 * @return void
 */
method requests::asyncHttpRequest(type, url, args = {}, resolve = fn {}, reject = fn {}) {
    local thread = effil.thread(fn (type, url, args) {
        local requests = require("requests")
        local result, response = pcall(requests.request, type, url, args)
        if result {
            response.json, response.xml = nil, nil
            return true, response
        } else {
            return false, response
        }
    })(type, url, args)
    
    loop {
        wait(0)
        local status, err = thread::status()

        if !err {
            if status == "completed" {
                local result, response = thread::get()

                if result {
                    local must = match response.status_code {
                        301 || 302 || 303 || 307 || 308 => true
                        default => false
                    }

                    if must && response.headers.location {
                        return self::asyncHttpRequest(type, response.headers.location, args, resolve, reject)
                    }

                    return resolve(response)
                }

                return reject(response)
            }
        } elseif status == "canceled" {
            return reject(status)
        } else {
            return reject(err)
        }
    }
}

/**
 * Convert `str` to `application/x-www-form-urlencoded` schema string.
 *
 * @param str string
 * @return string
 */
method requests::encodeURLString(str) {
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", fn (c) { return string.format("%%%02X", string.byte(c)) })
    str = string.gsub(str, " ", "+")
    return str
}

/**
 * Fetch colors of the nicknames that listed in `$NICKNAME_COLORS_URL`. Lines are represented
 * as `nickname = [ FIRST-COLOR, SECOND-COLOR, ..., N-COLOR ]`. Colors are hexadecimal numbers
 * in `0xRRGGBB` format. The information will be in:
 *
 * ```clue
 * static nicknameColors = {} //! { nickname: string, colors: number[] }...
 * ```
 *
 * @return void
 */
method requests::fetchNicknameColors() {
    lua_thread.create(fn {
        self::asyncHttpRequest("GET", $NICKNAME_COLORS_URL, {}, fn (response) {
            if response.status_code == 200 {
                for line with string.gmatch(response.text, "[^\n]+") {
                    if local nickname, colors = string.match(line, "^(%S+)%s*=%s*%[([%s,0xX%x]+)]") {
                        local fetchedColors = {}
                        
                        for color with string.gmatch(colors, "0x%x+") {
                            table.insert(fetchedColors, tonumber(color))
                        }

                        table.insert(nicknameColors, { nickname = nickname, colors = fetchedColors })
                    }
                }
            } else {
                $debugWarning!("system", "failed to fetch $NICKNAME_COLORS_URL")
            }
        }, fn (error) {
            $debugWarning!("system", "failed to fetch $NICKNAME_COLORS_URL, error:")
            $debugWarning!("system", error)
        })
    })
}

/**
 * Fetch and parse themes. The information will be written in `userThemes`.
 * @return void
 */
method requests::fetchUserThemes() {
    lua_thread.create(fn {
        self::asyncHttpRequest("GET", $THEMES_URL, {}, fn (response) {
            if response.status_code == 200 {
                userThemes = {}
                for attributes with string.gmatch(response.text, "<%s*theme%s+(.-)/>") {
                    table.insert(userThemes, {
                        author      = string.match(attributes, "author%s*=%s*\"(.-)\""),
                        version     = string.match(attributes, "version%s*=%s*\"(.-)\""),
                        title       = string.match(attributes, "title%s*=%s*\"(.-)\""),
                        link        = string.match(attributes, "link%s*=%s*\"(.-)\""),
                        description = string.match(attributes, "description%s*=%s*\"(.-)\"")
                    })
                }
            } else {
                $debugWarning!("system", "failed to fetch $THEMES_URL")
            }
        }, fn (error) {
            $debugWarning!("system", "failed to fetch $THEMES_URL, error:")
            $debugWarning!("system", error)
        })
    })
}

return requests
