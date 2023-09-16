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

static __admins__ = {
    /**
     * {
     *     id  = Number,
     *     lvl = Number,

     *     nickname = {
     *         ooc = String,
     *         ic  = String
     *     } 
     * }...
     */
}

/**
 * Insert information about administrator to the `self`.
 *
 * @see __admins__
 *
 * @param data table
 * @return void
 */
method __admins__::insert(data) {
    table.insert(self, data)
}

/**
 * Remove information about administrator from the `self`.
 *
 * @see __admins__
 * 
 * @param data table
 * @return void
 */
method __admins__::remove(index) {
    table.remove(self, index)
}

/**
 * Get admin information by his id.
 * 
 * @param id number
 * @return table|nil
 */
method __admins__::getAdminById(id) {
    for _, admin in self {
        if admin.id == id {
            return admin
        }
    }
    return nil
}

return __admins__
