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

@import "Config" => config
@import "Common" => common

@import "imgui.Assets"  => imguiAssets
@import "imgui.HotKey"  => HotKey

@import "game.sa.Ped"       => ped
@import "game.sa.Vehicle"   => vehicle
@import "game.GReport"      => greport
@import "game.User"         => user
@import "game.Spectator"    => spectator

@define MOUSE_WHEEL_VERTICAL_SIDE_UP    0x780000
@define MOUSE_WHEEL_VERTICAL_SIDE_DOWN  0xFF880000

static receivedKillFocusEvent = false

local justPressed = {
    mButtonDown = false
}

global fn onWindowMessage(msg, wparam, lparam) {
    $SETUP_EVENT_MV!(msg, wparam)

    HotKey::setupWatcher(msg, wparam, lparam)

    if msg == wm.WM_KILLFOCUS {
        receivedKillFocusEvent = true
    } elseif msg == wm.WM_SETFOCUS {
        receivedKillFocusEvent = false
    }

    if config.root.cheats.clickwarp.use && user::getAloginStatus() {
        if msg == wm.WM_MBUTTONDOWN && !justPressed.mButtonDown {
            clickWarp.enabled           = !$
            justPressed.mButtonDown     = true

            sampSetCursorMode((clickWarp.enabled) ? 3 : 0)
            imguiAssets::setCursorStatus(!clickWarp.enabled)
            
            consumeWindowMessage(true, true)
        } elseif msg == wm.WM_MBUTTONUP {
            justPressed.mButtonDown = false
        } elseif msg == wm.WM_LBUTTONDOWN && clickWarp.enabled && clickWarp.teleportation.pos {
            local pos = clickWarp.teleportation.pos
            
            if local handle = clickWarp.teleportation.tpIntoCar {
                if !vehicle::jumpInto(handle) {
                    ped::teleport(handle, pos.x, pos.y, pos.z)
                }
            } else {
                ped::teleport(pos.x, pos.y, pos.z)
            }

            sampSetCursorMode(0)
            imguiAssets::setCursorStatus(true)

            clickWarp.enabled       = false
            clickWarp.teleportation = {
                tpIntoCar   = nil,
                pos         = nil
            }

            // Yes, this won't consume attack.
            consumeWindowMessage(true, true)
        }
    }

    if msg == wm.WM_SYSKEYDOWN || msg == wm.WM_KEYDOWN && !sampIsChatInputActive() && !isSampfuncsConsoleActive() && !sampIsDialogActive() {
        if greport.window.state && !isGamePaused() && config.root.windows.greport.use && wparam == 13 /* VK_ESCAPE */ {
            if #ffi.string(greport.window.answerInput) == 0 {
                greport.window.noInputClock = os.clock()
            } else {
                greport.player::answer(ffi.string(greport.window.answerInput))
                consumeWindowMessage(true, true)
            }
        }
    }

    if msg == wm.WM_MOUSEWHEEL && !greport.window.state && !mainWindow.state[0] {
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
