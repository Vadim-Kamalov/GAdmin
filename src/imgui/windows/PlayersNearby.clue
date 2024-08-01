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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Animations"      => animations

@import "game.User"         => user
@import "game.Admins"       => admins
@import "game.Spectator"    => spectator

@import "Config"    => config
@import "Common"    => common
@import "Icons"     => icons
@import "Assets"    => assets
@import "Algorithm" => algorithm

local _, sizeY  = getScreenResolution()
local randomPlayers = {}

/**
 * Generate array with players nearby. Contains distance, nickname, id and admin-information.
 * Result can optionally (using config module) sorted with bubble sort by distance.
 *
 * @param isChangingWindowsPositions boolean If true, function will return random players.
 * @return table
 */
local fn getAllPlayersNearby(isChangingWindowsPositions) {
    local playersNearby = {}

    if !isSampAvailable() { return playersNearby }
    if isChangingWindowsPositions {
        if #randomPlayers != config.root.windows.playersNearby.maxPlayers {
            for _ = 1, config.root.windows.playersNearby.maxPlayers {
                table.insert(randomPlayers, {
                    distance    = math.random(1, 230)
                    nickname    = assets.randomICNicknames[math.random(#assets.randomICNicknames)]
                    id          = math.random(1, sampGetMaxPlayerId(false))
                    admin       = (math.random(0, 100) > 75) ? {
                        nickname = {
                            ooc = assets.randomOOCNicknames[math.random(#assets.randomOOCNicknames)]
                        }
                    } : nil
                })
            }
        }
        return randomPlayers
    }

    for _, player in getAllChars() {
        local result, playerId = sampGetPlayerIdByCharHandle(player)
        if result && playerId != user::getId() && playerId != spectator.id {
            local distance = 0.0
            {
                local fromResult, fromHandle = sampGetCharHandleBySampPlayerId(spectator.id)
                if fromResult || !spectator.status {
                    local aX, aY, aZ = getCharCoordinates(player)
                    local bX, bY, bZ = getCharCoordinates((spectator.status) ? fromHandle : PLAYER_PED)
                    distance = getDistanceBetweenCoords3d(aX, aY, aZ, bX, bY, bZ)
                }
            }
        
            table.insert(playersNearby, {
                distance    = distance
                nickname    = sampGetPlayerNickname(playerId)
                id          = playerId
                admin       = admins::getAdminById(playerId) 
            })
        }
    }

    if config.root.windows.playersNearby.sortByDistance {
        algorithm::bubbleSortByKey(playersNearby, "distance")
    }

    return playersNearby
}

window::new("imgui.windows.PlayersNearby", {
    description = "Список игроков рядом"
    type        = MV_DEFAULT
    condition   = fn { return config.root.windows.playersNearby.use && user::getAloginStatus() }
    size        = { x = 0, y = 0 }
    defaultPos  = { x = 0, y = sizeY / 2 }
    initialize  = {
        style = StyleChanger::new({
            WindowBorderSize    = 0
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })

        popup = StyleChanger::new({
            PopupBg             = "22222200"
            PopupBorderSize     = 0
            FrameRounding       = 0
            FrameBorderSize     = 0
            ItemSpacing         = imgui.ImVec2(0, 0)
            WindowPadding       = imgui.ImVec2(2, 2)
        }),
    }
}, fn (self) {
    self.var.style::apply()
    self::begin(self.id, fn {
        local players = getAllPlayersNearby(self.isChangingWindowsPositions)

        for i = 1, config.root.windows.playersNearby.maxPlayers {
            if local player = players[i] {
                imgui.PushFont(bold10)
                    local alignMode = config.root.windows.playersNearby.textAlignMode
                    local textSize  = nil
                    {
                        local text = string.format("%s[%d]", player.nickname, player.id)
                            text ..= (config.root.windows.playersNearby.showDistance) ? string.format("[X: %1.f]", player.distance) : ""
                            text ..= (config.root.windows.playersNearby.showAdmins && player.admin)
                                ? string.format("[%s]", player.admin.nickname.ooc)
                                : ""
                        textSize = imgui.CalcTextSize(text)
                    }

                    local alignX = match alignMode {
                        ALIGN_CENTER    => self.size.x / 2 - textSize.x / 2,
                        ALIGN_RIGHT     => self.size.x - textSize.x - 5
                        default         => imgui.GetCursorPos().x
                    }

                    imgui.SetCursorPosX(alignX)
                    imgui.BeginGroup()
                        local strokeSize    = config.root.windows.playersNearby.strokeSize
                        local color         = (config.root.windows.playersNearby.playerColorBasedOnClist) 
                            ? common::convertHex2ImVec4(string.format("%06X", sampGetPlayerColor(player.id) & 0xFFFFFF))
                            : nil

                        local isClicked, isHovered = 
                            imguiAssets::addStrokedText("%s[%d]", strokeSize, color, player.nickname, player.id)

                        if isHovered {
                            imgui.GetWindowDrawList()::AddLine(
                                imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                                imgui.GetItemRectMax(),
                                -1,
                                2
                            )
                        }
                    
                        if isClicked && !self.isChangingWindowsPositions {
                            imgui.OpenPopup("PlayersNearby.popup")
                            self.var.popupInformation = {
                                nickname    = player.nickname
                                id          = player.id
                            }
                        }

                        if config.root.windows.playersNearby.showDistance {
                            imgui.SameLine(nil, 0)
                            imguiAssets::addStrokedText("[X: %1.f]", strokeSize, color, player.distance)
                            imguiAssets::setPreviousItemAbleToCopy(
                                string.format("%1.f", player.distance),
                                "Скопировано расстояние",
                                "Успешно скопировано расстояние: " .. string.format("%1.f", player.distance)
                            )
                        }

                        if config.root.windows.playersNearby.showAdmins && player.admin {
                            imgui.SameLine(nil, 0)
                            imguiAssets::addStrokedText("[%s]", strokeSize, color, player.admin.nickname.ooc)
                            imguiAssets::setPreviousItemAbleToCopy(player.admin.nickname.ooc, nil, nil, {
                                icon        = icons.ICON_KEYBOARD
                                title       = "Никнейм скопирован"
                                text        = "Успешно скопирован OOC никнейм у администратора " .. player.admin.nickname.ooc .. "!"
                                duration    = 4
                                buttons     = {
                                    first   = {
                                        name = "Закрыть"
                                        call = fn (close) { close() }
                                    }

                                    second = {
                                        name = "Упомянуть"
                                        call = fn (close) {
                                            if !self.isChangingWindowsPositions {
                                                sampSetChatInputEnabled(true)
                                                sampSetChatInputText("/a @" .. player.admin.nickname.ooc .. " ")
                                                close()
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    imgui.EndGroup()
                imgui.PopFont()

                if imgui.GetItemRectSize().x + ((alignMode == ALIGN_RIGHT ? 5 : 0)) > self.size.x {
                    self.size.x = imgui.GetItemRectSize().x + ((alignMode == ALIGN_RIGHT) ? 5 : 0)
                }
            }
        }

        self.var.popup::apply()
        if imgui.BeginPopup("PlayersNearby.popup", self.flags) {
            imgui.PushFont(regular9)
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8)
                    if animations::button(
                        "/sp " .. tostring(self.var.popupInformation.id) .. "##PlayersNearby:popup",
                        imgui.ImVec2(70, 25),
                        3
                    ) {
                        sampSendChat("/sp " .. tostring(self.var.popupInformation.id))
                        imgui.CloseCurrentPopup()
                    }
                imgui.PopStyleVar() 
                
                if animations::button(
                    "/stats " .. tostring(self.var.popupInformation.id) .. "##PlayersNearby:popup",
                    imgui.ImVec2(70, 25),
                    0
                ) {
                    sampSendChat("/stats " .. tostring(self.var.popupInformation.id))
                    imgui.CloseCurrentPopup()
                }
                
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 8)
                    if animations::button(
                        "/pame " .. tostring(self.var.popupInformation.id) .. "##PlayersNearby:popup",
                        imgui.ImVec2(70, 25),
                        12
                    ) {
                        sampSendChat("/pame " .. tostring(self.var.popupInformation.id))
                        imgui.CloseCurrentPopup()
                    }
                imgui.PopStyleVar() 
            imgui.PopFont()
        }
        imgui.EndPopup()
        self.var.popup::reset()
    })
    self.var.style::reset()
})
