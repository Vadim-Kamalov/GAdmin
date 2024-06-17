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

static timers = {}

/**
 * Create timer that will execute `action` each `time`.
 *
 * @param condition fun(): boolean
 * @param action fun(): void
 * @param time number (in seconds)
 * @return void
 */
method timers::add(condition, action, time) {
    table.insert(self, {
        condition = condition,
        action    = action,
        clock     = os.clock() - time,
        time      = time
    })
}

/**
 * Initialize all timers. **Use only in while-true loop!**
 * @return void
 */
method timers::initialize() {
    for _, timer in self {
        if timer.condition() && os.clock() - timer.clock >= timer.time {
            timer.action()
            timer.clock = os.clock()
        }
    }
}

return timers
