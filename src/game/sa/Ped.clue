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

local ped = {
    getBodyPartCoordinatesCast = ffi.cast("int(__thiscall*)(void*, float*, int, bool)", $GET_BODY_PART_COORDINATES_ADDR)
}

/**
 * Get bone coordinates on ped-handle.
 *
 * @param id number     Bone part.
 * @param handle number Ped-handle.
 * @return number, number, number (X, Y, Z)
 */
method ped::getBodyPartCoordinates(id, handle) {
    local vector = ffi.new("float[3]")
    self.getBodyPartCoordinatesCast(ffi.cast("void*", getCharPointer(handle)), vector, id, true)
    return vector[0], vector[1], vector[2]
}

/**
 * Get player weapon by id as string.
 * 
 * @param id number Weapon-ID
 * @return string|nil
 */
method ped::getPlayerWeaponNameById(id) {
    local result, ped = sampGetCharHandleBySampPlayerId(id)
    if result {
        return require("game.weapons").names[getCurrentCharWeapon(ped)]
    }
    return nil
}

/**
 * Get closest handle.
 *
 * @param to number (default = PLAYER_PED)
 * @return number | nil
 */
method ped::getClosestHandleTo(to = PLAYER_PED) {
    local minDistance   = 9999
    local closestHandle = nil
    local x, y, z       = getCharCoordinates(PLAYER_PED)

    for _, handle in getAllChars() {
        local result, _ = sampGetPlayerIdByCharHandle(handle)
        if result {
            local xI, yI, zI    = getCharCoordinates(handle)
            local distance      = math.sqrt((xI - x) ^ 2 + (yI - y) ^ 2 + (zI - z) ^ 2)
            if distance < minDistance {
                minDistance = distance
                closestHandle = handle
            }
        }
    }

    return closestHandle
}

/**
 * Check that `ped` is behind a wall.
 *
 * @param ped number
 * @return boolean
 */
method ped::isBehindWall(ped) {
    local behindWall    = false
    local result, _     = sampGetPlayerIdByCharHandle(ped)

    if result && isCharOnScreen(ped) {
        if ped == PLAYER_PED { behindWall = true }
        
        local x, y, z       = self::getBodyPartCoordinates(8, ped)
        local x1, y1, z1    = getActiveCameraCoordinates()
        behindWall          = isLineOfSightClear(x, y, z, x1, y1, z1, true, false, false, true, false)
    }

    return !behindWall
}

return ped
