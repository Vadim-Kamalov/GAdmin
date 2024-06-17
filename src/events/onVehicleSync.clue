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
 * SPDX-License-Identifier: GPL-3.0-only
 */

@import "game.Spectator" => spectator

sampev.onVehicleSync = fn(id, _, data) {
    if id == spectator.id {
        if spectator.platform == PLATFORM_PC {
            for _, arguments in ({
                { "w",      (data.keysData & 0x8) == 0x8 },
                { "a",      data.leftRightKeys == 0xFF80 },
                { "s",      (data.keysData & 0x20) == 0x20 },
                { "d",      data.leftRightKeys == 0x80 },
                { "h",      (data.keysData & 0x2) == 0x2 },
                { "space",  (data.keysData & 0x80) == 0x80 },
                { "ctrl",   (data.keysData & 0x1) == 0x1 },
                { "alt",    (data.keysData & 0x4) == 0x4 },
                { "q",      (data.keysData & 0x100) == 0x100 },
                { "e",      (data.keysData & 0x40) == 0x40 },
                { "f",      (data.keysData & 0x10) == 0x10 },
                { "up",     data.upDownKeys == 0xFF80 },
                { "down",   data.upDownKeys == 0x80 }
            }) {
                spectator::setKeyStatus(SYNC_KEYS_VEHICLE, table.unpack(arguments))
            }
        } elseif spectator.platform == PLATFORM_ANDROID {
            for _, arguments in ({
                { "signal",     (data.keysData & 0x2) == 0x2 },
                { "forward",    (data.keysData & 0x8) == 0x8 },
                { "braking",    (data.keysData & 0x28) == 0x28 },
                { "backward",   (data.keysData & 0x20) == 0x20 },
                { "2",          (data.keysData & 0x200) == 0x200 },
                { "f",          (data.keysData & 0x10) == 0x10 },
            }) {
                spectator::setKeyStatus(SYNC_KEYS_VEHICLE, table.unpack(arguments))
            }

            spectator::setupJoyStickWatcher(data.leftRightKeys, data.upDownKeys)
        }
        
        if spectator.cameraSwitchState == CAMERA_SWITCH_STATE_PLAYER {
            sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH)
        }
        
        spectator.cameraSwitchState = CAMERA_SWITCH_STATE_VEHICLE
    }
}
