/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
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
                return (result) ? resolve(response) : reject(response)
            }
        } elseif status == "canceled" {
            return reject(status)
        } else {
            return reject(err)
        }
    }
}

return requests
