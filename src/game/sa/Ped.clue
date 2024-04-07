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
 * Check that `handle` is male by his skin ID. Howewer,
 * there is `isCharMale` function already implemented in the MoonLoader API,
 * but, for some reasons this function will always return true.
 *
 * @param handle number
 * @return boolean
 */
method ped::isMale(handle) {
    for _, womanSkinId in ({
        9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56,
        63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92,
        93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150,
        151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194,
        195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215,
        216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238,
        243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307,
        308, 309
    }) {
        if getCharModel(handle) == womanSkinId {
            return false
        }
    }

    return true
}

/**
 * Get character max speed by his handle. If character is
 * in any car - then this function will always return `0`.
 *
 * @param handle number
 * @return number
 */
method ped::getMaxSpeed(handle) {
    if !isCharInAnyCar(handle) {
        return match getCharModel(handle) {
            0        => 11,
            92 || 99 => 8,
            default  => (self::isMale(handle)) ? 7 : 5
        }
    } else {
        return 0
    }
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
        if result && handle != to && handle != PLAYER_PED {
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

/**
 * Teleport ped to `x, y, z` coordinates.
 * 
 * @author FYP
 * @author we_sux team
 * @author https://www.blast.hk/threads/15459/
 *
 * @param x number
 * @param y number
 * @param z number
 * @return void
 */
method ped::teleport(x, y, z) {
    local fn setEntityCoordinates(entityPtr, x, y, z) {
        if entityPtr != 0 {
            local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
            if matrixPtr != 0 {
                local posPtr = matrixPtr + 0x30
                writeMemory(posPtr + 0, 4, representFloatAsInt(x), false)
                writeMemory(posPtr + 4, 4, representFloatAsInt(y), false)
                writeMemory(posPtr + 8, 4, representFloatAsInt(z), false)
            }
        }
    }

    if isCharInAnyCar(PLAYER_PED) {
        setCharCoordinates(PLAYER_PED, x, y, z)
    }

    if doesCharExist(PLAYER_PED) {
        local pointer = getCharPointer(PLAYER_PED)
        setEntityCoordinates(pointer, x, y, z)
    }
}

return ped
