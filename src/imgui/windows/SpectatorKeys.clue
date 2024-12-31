/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Spectator" => spectator

@import "Config"    => config
@import "Icons"     => icons
@import "Common"    => common

local sizeX, sizeY = getScreenResolution()

window::new("imgui.windows.SpectatorKeys", {
    description = "Нажатые клавиши игрока"
    type        = MV_ONLY_IN_SPECTATOR
    condition   = fn { return config.root.windows.spectatorKeys.use }
    size        = { x = 0, y = 0 }
    defaultPos  = { x = sizeX / 2.346, y = sizeY / 1.242 }
    initialize  = {
        style = StyleChanger::new({
            WindowBg = "00000000"
            WindowBorderSize = 0
        })
    }
}, fn (self) {
    self.var.style::apply()
    self::begin(self.id, fn {
        local result, ped = spectator::getHandle()
        if self.isChangingWindowsPositions { result, ped = true, PLAYER_PED }

        if result {
            for platform, data of ({
                pc = {
                    [SYNC_KEYS_PLAYER] = {
                        "lmb",
                        "w",
                        "rmb",
                        { "shift",  imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        { "alt",    imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        "f",
                    
                        "NewLine",

                        "a",
                        "s",
                        "d",
                        { "space",  imgui.ImVec2(110, 35) },
                        "c"
                    },

                    [SYNC_KEYS_VEHICLE] = {
                        "q",
                        "w",
                        "e",
                        { "up",     imgui.ImVec2(50, 35) },
                        { "ctrl",   imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        { "alt",    imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        "f",

                        "NewLine",

                        "a",
                        "s",
                        "d",
                        { "down",   imgui.ImVec2(50, 35) },
                        { "space",  imgui.ImVec2(110, 35) },
                        "h"
                    }
                },

                mobile = {
                    [SYNC_KEYS_PLAYER] = {
                        { "hit",        imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        { "aim",        imgui.ImVec2(55 - imgui.GetStyle().ItemSpacing.x / 2, 35) },
                        "f",

                        "NewLine",

                        { "jump / run", imgui.ImVec2(110, 35) },
                        "alt"
                    },

                    [SYNC_KEYS_VEHICLE] = {
                        { "forward",    imgui.ImVec2(90, 35) },
                        { "signal",     imgui.ImVec2(65, 35) }
                        "2",

                        "NewLine",

                        { "backward",   imgui.ImVec2(90, 35) },
                        { "braking",    imgui.ImVec2(65, 35) }
                        "f"
                    }
                }
            }) {
                if platform == string.lower((self.isChangingWindowsPositions) ? "PC" : spectator::platformToString()) {
                    local currentSyncType   = (isCharInAnyCar(ped)) ? SYNC_KEYS_VEHICLE : SYNC_KEYS_PLAYER
                    local platform          = (self.isChangingWindowsPositions) ? PLATFORM_PC : spectator.platform
                    local id                = string.format("##%s.%d", self.id, platform)

                    if platform == PLATFORM_ANDROID {
                        imgui.Dummy(imgui.ImVec2(75, 75))
                        
                        local spacing   = imgui.GetStyle().ItemSpacing
                        local padding   = imgui.GetStyle().WindowPadding
                        local new       = spectator.keys[platform][SYNC_KEYS_JOY_STICK].new
                        local old       = spectator.keys[platform][SYNC_KEYS_JOY_STICK].old
                        local clock     = spectator.keys[platform][SYNC_KEYS_JOY_STICK].clock
                        local dl        = imgui.GetWindowDrawList()
                        local c         = imgui.ImVec2(self.pos.x + 37 + padding.x, self.pos.y + 42)

                        local color     = imgui.GetStyle().Colors[imgui.Col.Button]
                        local bgColor   = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, 0.3))
                        local itColor   = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color.x, color.y, color.z, color.w))
                
                        dl::AddCircleFilled(c, 37, bgColor, 48)
                        dl::AddCircle(c, 37, itColor, 48, 1)

                        local oX = imguiAssets::bringFloatTo((old.x / 100) * 13.5, (new.x / 100) * 13.5, clock, 0.1)
                        local oY = imguiAssets::bringFloatTo((old.y / 100) * 13.5, (new.y / 100) * 13.5, clock, 0.1)
                        dl::AddCircleFilled(imgui.ImVec2(c.x + oX, c.y + oY), 10, itColor, 0xF)

                        imgui.SameLine()
                    }

                    local newLinesCount = 1

                    imgui.BeginGroup()
                        imgui.PushFont(regular9)
                            for index, item in data[currentSyncType] {
                                if type(item) == "string" {
                                    if item == "NewLine" {
                                        local padding = imgui.GetStyle().WindowPadding
                                        local x       = (platform == PLATFORM_ANDROID) ? (75 + imgui.GetStyle().ItemSpacing.x + padding.x) : padding.x
                                        local y       = (imgui.GetItemRectSize().y + imgui.GetStyle().ItemSpacing.y) 
                                            * newLinesCount + padding.y

                                        imgui.SetCursorPos(imgui.ImVec2(x, y))
                                        
                                        newLinesCount += 1
                                    } else {
                                        animations::keyCap(string.upper(item) .. id, spectator.keys[platform][currentSyncType][item], imgui.ImVec2(35, 35))
                                        imgui.SameLine()
                                    }
                                } elseif type(item) == "table" {
                                    animations::keyCap(string.upper(item[1]) .. id, spectator.keys[platform][currentSyncType][item[1]], item[2])
                                    imgui.SameLine()
                                }
                            }
                        imgui.PopFont()
                    imgui.EndGroup()
                }
            } // for _, data in ({ ... })
        } // if result
    })
    self.var.style::reset()
})
