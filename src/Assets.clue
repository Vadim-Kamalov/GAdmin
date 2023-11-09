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

ffi.cdef("
    typedef unsigned short WORD;
    typedef struct {
        WORD wYear;
        WORD wMonth;
        WORD wDayOfWeek;
        WORD wDay;
        WORD wHour;
        WORD wMinute;
        WORD wSecond;
        WORD wMilliseconds;
    } SYSTEMTIME, *PSYSTEMTIME;

    void GetLocalTime(PSYSTEMTIME lpSystemTime);
")

local assets = {}

assets.randomICNicknames = {
    "Marcus_Tullius_Cicero",
    "Francois_Marie_Arouet",
    "Thales_of_Miletus",
    "Friedrich_Nietzsche",
    "Leonardo_da_Vinci",
    "Immanuel_Kant",
    "John_Locke",
    "Augustine_of_Hippo",
    "Arthur_Schopenhauer",
    "Gottfried_Wilhelm_von_Leibniz",
    "Diogenes_of_Sinope"
}

assets.randomStrings = {
    "Недостаточно овладеть премудростью, нужно также уметь пользоваться ею.",
    "Тем, кто хочет учиться, часто вредит авторитет тех, кто учит.",
    "Подумай, как трудно изменить себя самого, и ты поймешь, сколь ничтожны твои возможности изменить других.",
    "Невежество — ночь ума, ночь безлунная и беззвездная.",
    "Есть только одно благо — знание, и только одно зло — невежество.",
    "Блаженство тела состоит в здоровье, блаженство ума — в знании.",
    "Познавший самого себя — собственный палач.",
    "Речь истины проста.",
    "Единственным критерием истины является опыт.",
    "Весёлое выражение лица постепенно отражается и на внутреннем мире.",
    "Образование создаёт разницу между людьми.",
    "Что легко? — Давать советы другим.",
    "Кто ненавидит мир? Те, кто растерзал истину.",
    "Многие философы так же тягостны, как ночные гуляки, нарушающие сон мирных жителей",
    "Всякое учение истинно в том, что оно утверждает, и ложно в том, что оно отрицает или исключает.",
    "Философия и медицина сделали человека самым разумным из животных, гадание и астрология — самым безумным, суеверие и деспотизм — самым несчастным.",
    "С большой властью приходит большая ответственность."
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
 * files = { { url = String, destination = String }... }
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
    local total             = 0
    local time              = os.clock()
    local result            = false

    lua_thread.create(fn {
        while true {
            wait(0)
            if total == #files {
                result = true
                afterDownloadCallback(files)
                break
            } else {
                if os.clock() - time >= 120 {
@ifdef __GADMIN_DEBUG__
{
                    $debugError!("assets::downloadFileList", "`files` not downloaded after 120 seconds. `entryPoint` returned false")
}
                    break
                }
            }
        }
    })

    for _, data in files {
        lua_thread.create(fn {
            wait(1000) // We need to add delay to avoid the "device or resource busy: device or resource busy" error.
            downloadUrlToFile(data.url, data.destination, fn(_, status, p1, p2) {
                if status == downloadStatus.STATUS_ENDDOWNLOADDATA {
                    total += 1
@ifdef __GADMIN_DEBUG__
                    {
                    $debugSuccessful!("assets::downloadFileList", "loaded " .. data.destination .. " from " .. data.url)
}
                } else {
@ifdef __GADMIN_DEBUG__
{
                    $debugInformation!("assets::downloadFileList", "loading " .. data.destination .. ". Downloaded " .. string.format("%d of %d.", p1, p2))
}
                }
            })
        })   
    }
}

/**
 * Merge two tables into one.
 *
 * @param first table
 * @param second table
 * @return table
 */
method assets::mergeTables(first, second) {
    for key, value of second {
        if type(value) == "table" && type(first[key] || false) == "table" {
            self::mergeTables(first[key], second[key])
        } else {
            first[key] = value
        }
    }
    return first
}

/**
 * Explode timestamp to date-table.
 * 
 * @param timestamp number
 * @return table
 */
method assets::explodeDate(timestamp) {
    local seconds   = timestamp % 60
    timestamp       = (timestamp - seconds) / 60
    local minutes   = timestamp % 60
    timestamp       = (timestamp - minutes) / 60
    local hours     = timestamp % 24
    timestamp       = (timestamp - hours) / 24
    local days      = timestamp % 31 + 1
    timestamp       = (timestamp - days + 1) / 31
    local months    = timestamp % 12 + 1
    local years     = (timestamp - months + 1) / 12 + 1970

    return {
        sec     = seconds,
        min     = minutes,
        hour    = hours,
        day     = days,
        month   = months,
        year    = years
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
 * Get system time.
 * @return table
 */
method assets::getLocalTime() {
    local time = ffi.new("SYSTEMTIME")
    ffi.C.GetLocalTime(time)
    return time
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
