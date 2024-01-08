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

local algorithm = {}

/**
 * Swap indexA from tab to indexB
 * 
 * @param tab table
 * @param indexA number
 * @param indexB number
 * @return void
 */
method algorithm::swap(tab, indexA, indexB) {
    local temp  = tab[indexA]
    tab[indexA] = tab[indexB]
    tab[indexB] = temp
}

/**
 * Sort table by `key` using bubble sort.
 *
 * @param key any
 * @param tab table
 * @return void
 */
method algorithm::bubbleSortByKey(tab, key) {
    local n         = #tab
    local sorted    = false
    
    while !sorted {
        sorted = true
        for i = 1, n - 1 {
            if tab[i][key] > tab[i + 1][key] {
                self::swap(tab, i, i + 1)
                sorted = false
            }
        }
        n = n - 1
    }
}

return algorithm
