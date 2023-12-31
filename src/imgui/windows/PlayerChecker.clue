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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger

@import "Config" => config
@import "Assets" => assets
@import "Common" => common

@import "game.samp.Player" => sampPlayer

local randomPlayers = {}

local fn getPlayers(isMovingWindows) {
    if isMovingWindows {
        math.randomseed(os.clock())
        if #randomPlayers != 5 {
            table.insert(randomPlayers, {
                nickname    = assets.randomICNicknames[math.random(#assets.randomICNicknames)],
                commentary  = (math.random(1, 100) >= 80) ? assets.randomStrings[math.random(#assets.randomStrings)] : nil
            })
        }
        return randomPlayers
    } else {
        return config.root.windows.playerChecker.players
    }
}

window::new("imgui.windows.PlayerChecker", {
    description = "Чекер игроков"
    type        = MV_DEFAULT
    condition   = fn { return config.root.windows.playerChecker.use && isSampAvailable() }
    size        = { x = 0, y = 0 }
    defaultPos  = WIN_DEFAULT_POS_CENTER
    initialize  = {
        popupInformation    = {}
        windowStyle         = StyleChanger::new({
            WindowBorderSize    = 0,
            WindowBg            = imgui.ImVec4(0, 0, 0, 0),
            ItemSpacing         = imgui.ImVec2(0, 5)
        })

        popupStyle = StyleChanger::new({
            WindowPadding = imgui.ImVec2(5, 5)
            PopupBg = "222222"
            ItemSpacing = imgui.ImVec2(0, 1)
        })

        popupCommentaryStyle = StyleChanger::new({
            FrameBg = "222222"
            FrameBorderSize = 0
        })
    }
}, fn(self) {
    self.var.windowStyle::apply()
    self::begin(self.id, fn {
        for index, player in getPlayers(self.isChangingWindowsPositions) {
            local id                = sampPlayer::getIdByNickname(player.nickname)
            local playerConnected   = id != -1
            local strokeSize        = config.root.windows.playerChecker.strokeSize

            local textColor = imgui.GetStyle().Colors[imgui.Col.Text]
            if playerConnected { textColor = common::convertHex2ImVec4($PLAYER_COLOR_TO_HEX!(id)) }

            local align = imgui.GetCursorPos().x
            {
                if local it = config.root.windows.playerChecker {
                    local textSize = imgui.ImVec2(0, 0)

                    if it.displayOfflinePlayers {
                        textSize = imgui.CalcTextSize((playerConnected) ? "[ONLINE] " : "[OFFLINE] ")
                    }

                    textSize += imgui.CalcTextSize(player.nickname)

                    if playerConnected {
                        textSize += imgui.CalcTextSize("[" .. id .. "]")
                    }

                    align = match it.textAlignMode {
                        ALIGN_CENTER    => self.size.x / 2 - textSize.x / 2,
                        ALIGN_RIGHT     => self.size.x - textSize.x - (5 + strokeSize),
                        default         => align
                    }
                }
            }

            imgui.SetCursorPosX(align)
            imgui.BeginGroup()
                if config.root.windows.playerChecker.displayOfflinePlayers {
                    imguiAssets::addStrokedText(
                        (playerConnected) ? "[ONLINE] " : "[OFFLINE] ",
                        strokeSize,
                        common::convertHex2ImVec4((playerConnected) ? "8DFF85" : "FF8585")
                    )
                    imgui.SameLine()
                }

                if config.root.windows.playerChecker.displayOfflinePlayers || playerConnected {
                    imguiAssets::addStrokedText(player.nickname, strokeSize, textColor)
                    if playerConnected {
                        imgui.SameLine()
                        imguiAssets::addStrokedText("[" .. id .. "]", strokeSize, textColor)
                    }
                }
            imgui.EndGroup()

            if imgui.GetItemRectSize().x >= self.size.x {
                self.size.x += (imgui.GetItemRectSize().x - self.size.x) + (imgui.GetStyle().WindowPadding.x * 2)
            }

            if imgui.IsItemClicked() {
                imgui.OpenPopup("PlayerChecker.popup")
                self.var.popupInformation = {
                    nickname    = player.nickname
                    id          = id
                    commentary  = player.commentary
                    isConnected = playerConnected
                    index       = index
                }
            }

            if imgui.IsItemHovered() {
                imgui.GetWindowDrawList()::AddLine(
                    imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                    imgui.GetItemRectMax(),    
                    -1,
                    2
                )
            }
        }

        self.var.popupStyle::apply()
        if imgui.BeginPopup("PlayerChecker.popup", self.flags) {
            if local this = self.var.popupInformation {
                for index, item in ({
                    { name = "Никнейм:", value = this.nickname },
                    { 
                        name    = "Статус:",
                        value   = (this.isConnected) ? "В сети" : "Оффлайн",
                        color   = common::convertHex2ImVec4((this.isConnected) ? "8DFF85" : "FF8585") 
                    }
                }) {
                    if item.value {
                        imguiAssets::textWithFont(item.name, bold10)
                        imgui.SameLine(imgui.CalcTextSize(item.name).x + 7)
                        imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                        imguiAssets::textWithFont(item.value, regular9, nil, item.color)
                    }
                }

                if this.commentary {
                    if !this.imguiCommentary { this.imguiCommentary = imgui.new.char[65535](this.commentary) }

                    imguiAssets::textWithFont("Комментарий:", bold10)
                    imgui.SameLine()
                    imgui.SetCursorPosY(imgui.GetCursorPos().y - 3)

                    self.var.popupCommentaryStyle::apply()
                    imgui.PushFont(regular9)
                        if this.focusCommentary {
                            imgui.SetKeyboardFocusHere()
                            this.focusCommentary = false
                        }
                        
                        if imgui.InputText(
                            "##PlayerChecker.commentary",
                            this.imguiCommentary,
                            ffi.sizeof(this.imguiCommentary),
                            !this.changingCommentary && imgui.InputTextFlags.ReadOnly
                        ) {
                            config.root.windows.playerChecker.players[this.index].commentary = ffi.string(this.imguiCommentary)
                        }
                    imgui.PopFont()
                    self.var.popupCommentaryStyle::reset()
                }

                imgui.PushFont(regular9)
                    if animations::button(
                        "Удалить##PlayerChecker.popup.removeButton",
                        imgui.ImVec2(imgui.GetWindowWidth() - 10, 25),
                        (this.commentary || this.isConnected) ? 3 : nil
                    ) {
                        table.remove(config.root.windows.playerChecker.players, this.index)
                        imgui.CloseCurrentPopup()
                    }
                    
                    if this.commentary {
                        imgui.GetWindowDrawList()::AddRectFilled(
                            imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y - 4),
                            imgui.GetItemRectMax() + imgui.ImVec2(0, 6),
                            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                        )

                        if animations::button(
                            "Изменить комментарий##PlayerChecker.popup.changeCommentaryButton",
                            imgui.ImVec2(imgui.GetWindowWidth() - 10, 25),
                            (this.isConnected) ? 0 : 12
                        ) {
                            this.changingCommentary = true
                            this.focusCommentary = true
                        }
                    }

                    if this.isConnected {
                        imgui.GetWindowDrawList()::AddRectFilled(
                            imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y - 4),
                            imgui.GetItemRectMax() + imgui.ImVec2(0, 6),
                            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                        )
                        
                        if animations::button("Следить##PlayerChecker.popup.spectateButton", imgui.ImVec2(imgui.GetWindowWidth() - 10, 25), 12) {
                            sampSendChat("/sp " .. this.id)
                            imgui.CloseCurrentPopup()
                        }
                    }
                imgui.PopFont()
            }
        }
        imgui.EndPopup()
        self.var.popupStyle::reset()
    })
    self.var.windowStyle::reset()
})
