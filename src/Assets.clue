/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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

local assets = {}

assets.randomICNicknames = {
    "Matvei_Romanov",
    "Manato_Imai",
    "Alberto_Barcia",
    "Antonella_Rosado",
    "Manon_Villard",
    "Max_Lindstrom",
    "Melanie_Fansler",
    "Nikolaj_Conradsen",
    "Iuliana_Zaituc",
    "Tyler_Dzone",
    "Eva_Levina"
}

assets.randomOOCNicknames = {
    "covboy",
    "defaultzone",
    "montreal",
    "ivanrampage",
    "Toshik",
    "Furofushi",
    "dontkillme",
    "GoblinJr",
    "krutenka",
    "refraction",
    "GMengland"
}

/**
 * Download a list of files. The `files` argument is represented by a table, device:
 *
 * ```clue
 * files = { { url = String, destination = String}... }
 * ```
 * 
 * Note that each file is downloaded every second to prevent undefined behavior.
 * If no files are downloaded after 120 seconds, the function will return false.
 * After files are successfully downloaded, the `afterDownloadCallback` ...
 * ... argument is called (this is a function that accepts the list of `files` that was passed to the main function).
 *
 * @param files table
 * @param afterDownloadCallback
 * @return boolean
 */
method assets::downloadFileList(files, afterDownloadCallback) {
    local downloadStatus    = require("moonloader").download_status
    local total             = {}
    local time              = os.clock()

    for _, data in files {
        lua_thread.create(fn {
            wait(1000) // We need to add delay to avoid the "device or resource busy: device or resource busy" error.
            downloadUrlToFile(data.url, data.destination, fn(_, status, p1, p2) {
                if status == downloadStatus.STATUS_ENDDOWNLOADDATA {
                    table.insert(total, 0)
                    @ifdef __GADMIN_DEBUG__ { $debugSuccessful!("assets::downloadFileList", "loaded " .. data.destination .. " from " .. data.url) }
                } else {
                    @ifdef __GADMIN_DEBUG__ {
                        $debugInformation!("assts::downloadFileList", "loading " .. data.destination .. ". Remaining " .. string.format("%d of %d.", p1, p2))
                    }
                }
            })
        })   

        lua_thread.create(fn {
            while true {
                wait(0)
                if #total == #files {
                    if afterDownloadCallback { afterDownloadCallback(files) }
                    @ifdef __GADMIN_DEBUG__ {
                        $debugSuccessful!("assets::downloadFileList", "`files` loaded. afterDownloadCallback called (if present).") 
                    }
                    return true
                } else {
                    if os.clock() - time >= 120 {
                        @ifdef __GADMIN_DEBUG__ {
                            $debugError!("assets::downloadFileList", "`files` not downloaded after 120 seconds. `entryPoint` returned false")
                        }
                        return false
                    }
                }
            }
        })
    }
}

/**
 * Convert Unicode character to UTF8 string.
 *
 * @param code number   Unicode character.
 * @return string       UTF8 string.
 */
method assets::convertUnicode2Utf8(code) {
    local t, h = {}, 128
    while code >= h {
        table.insert(t, 128 + code % 64)
        code = math.floor(code / 64)
        h = (h > 32) ? 32 : h / 2
    }
    table.insert(t, 256 - 2 * h + code)
    return string.reverse(string.char(table.unpack(t)))
}

/**
 * Expode ARGB number to variables.
 * 
 * @param argb number
 * @return number, number, number, number
 */
method assets::explodeARGB(argb) {
    local a = (argb >> 24) & 255
    local r = (argb >> 16) & 255
    local g = (argb >> 8) & 255
    local b = argb & 255
    return a, r, g, b
}

return assets
