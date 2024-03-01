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

@import "game.Spectator" => spectator

sampev.onPlayerSync = fn(id, data) {
    if id == spectator.id {
        if spectator.platform == PLATFORM_PC {
            for _, arguments in ({
                { "w",      data.upDownKeys == 0xFF80 },
                { "a",      data.leftRightKeys == 0xFF80 },
                { "s",      data.upDownKeys == 0x80 },
                { "d",      data.leftRightKeys == 0x80 },
                { "alt",    (data.keysData & 0x400) == 0x400 },
                { "shift",  (data.keysData & 0x8) == 0x8 },
                { "space",  (data.keysData & 0x20) == 0x20 },
                { "f",      (data.keysData & 0x10) == 0x10 },
                { "c",      (data.keysData & 0x2) == 0x2 },
                { "rmb",    (data.keysData & 0x4) == 0x4 },
                { "lmb",    (data.keysData & 0x80) == 0x80 }
            }) {
                spectator::setKeyStatus(SYNC_KEYS_PLAYER, table.unpack(arguments))
            }
        } elseif spectator.platform == PLATFORM_ANDROID {
            for _, arguments in ({
                { "hit",        (data.keysData & 0x4) == 0x4 },
                { "alt",        (data.keysData & 0x400) == 0x400 },
                { "f",          (data.keysData & 0x10) == 0x10 },
                { "jump / run", (data.keysData & 0x8) == 0x8 },
                { "aim",        (data.keysData & 0x80) == 0x80 }
            }) {
                spectator::setKeyStatus(SYNC_KEYS_PLAYER, table.unpack(arguments))
            }

            spectator::setupJoyStickWatcher(data.leftRightKeys, data.upDownKeys)
        }

        if spectator.cameraSwitchState == CAMERA_SWITCH_STATE_VEHICLE {
            sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH)
        }
        
        print("before", spectator.cameraSwitchState)
        spectator.cameraSwitchState = CAMERA_SWITCH_STATE_PLAYER
        print("after", spectator.cameraSwitchState)
    }
}
