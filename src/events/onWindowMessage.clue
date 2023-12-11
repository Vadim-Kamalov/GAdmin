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

@import "Config" => config

@import "imgui.HotKey" => HotKey

@import "game.Spectator" => spectator

@define MOUSE_WHEEL_VERTICAL_SIDE_UP    0x780000
@define MOUSE_WHEEL_VERTICAL_SIDE_DOWN  0xFF880000

global fn onWindowMessage(msg, wparam, lparam) {
    $SETUP_EVENT_MV!(msg, wparam)

    
    if msg == wm.WM_CHAR || msg == wm.WM_KEYDOWN || msg == wm.WM_SYSKEYDOWN {
        HotKey::setupWatcher(wparam)
        if #HotKey::getDownKeys() > 0 && changingHotKey {
            consumeWindowMessage(true, false)
        } 
    } elseif msg == wm.WM_MOUSEWHEEL {
        if spectator.status && config.root.additions.zoomSpectatorCamera.use {
            local step = config.root.additions.zoomSpectatorCamera.step

            if wparam == $MOUSE_WHEEL_VERTICAL_SIDE_UP {
                spectatorCameraFov = math.min(getCameraFov() + step, 130)
            } elseif wparam == $MOUSE_WHEEL_VERTICAL_SIDE_DOWN {
                spectatorCameraFov = math.max(getCameraFov() - step, 50)
            }

            consumeWindowMessage(true, true)
        } else {
            spectatorCameraFov = -1
        }
    }
}
