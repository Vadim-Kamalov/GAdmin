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

@import "imgui.Windows"      => windows
@import "imgui.Assets"       => imguiAssets
@import "imgui.StyleChanger" => StyleChanger
@import "imgui.Animations"   => animations

@import "game.User" => user

@import "Config" => config

static killListWindow = {
    kills = {}
}

windows::new("imgui.windows.KillList", {
    description = "Улучшенный килл-лист"
    type        = MV_DEFAULT
    size        = { x = 0, y = 0 }
    condition   = fn { return config.root.windows.killList.use && user::getAloginStatus() }
    initialize  = {
        selected = {},
        popup    = StyleChanger::new({
            PopupBg         = "22222200"
            PopupBorderSize = 0
            FrameRounding   = 8
            FrameBorderSize = 0
            ItemSpacing     = imgui.ImVec2(0, 0)
            WindowPadding   = imgui.ImVec2(2, 2)
        }),

        style = StyleChanger::new({
            WindowBorderSize    = 0
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    self.strokeSize     = config.root.windows.killList.strokeSize
    self.allowOpenPopup = fn(player, color) {
        if imgui.IsItemHovered() {
            imgui.GetWindowDrawList()::AddLine(
                imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                imgui.GetItemRectMax(),
                imgui.ColorConvertFloat4ToU32(color),
                2
            )
        }; if imgui.IsItemClicked() && sampIsPlayerConnected(player.id) {
            self.var.selected = player
            imgui.OpenPopup(self.id .. ".popup")
        }
    }

    self.var.style::apply()
    self::begin(self.id, fn {
        for index = math.max(1, #killListWindow.kills - (config.root.windows.killList.maxItems - 1)), #killListWindow.kills {
            if local item = killListWindow.kills[index] {
                local text = {
                    left = {
                        nickname    = (item.nickname.killer) ? item.nickname.killer : item.nickname.killed,
                        id          = (item.nickname.killer) ? item.id.killer : item.id.killed,
                        color       = (item.nickname.killer) ? item.color.killer : item.color.killed
                    },

                    center = item.weapon,

                    right = {
                        nickname    = (item.nickname.killer) ? item.nickname.killed : "",
                        id          = (item.nickname.killer) ? item.id.killed : -1,
                        color       = (item.nickname.killer) ? item.color.killed : imgui.GetStyle().Colors[imgui.Col.Text]
                    }
                }

                local textWidth = 0
                {
                    if config.root.windows.killList.displayTime {
                        textWidth += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format(
                            "[%02d:%02d:%02d]",
                            item.time.wHour,
                            item.time.wMinute,
                            item.time.wSecond
                        )).x + self.strokeSize + 5
                    }

                    textWidth += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, text.left.nickname).x
                        + self.strokeSize + 5

                    if config.root.windows.killList.displayId && text.left.id != -1 {
                        textWidth += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format("[%d]", text.left.id)).x
                            + self.strokeSize
                    }

                    textWidth += regular9::CalcTextSizeA(regular9.FontSize, math.huge, 0.0, text.center).x
                        + self.strokeSize

                    if text.right.nickname != "" {
                        textWidth += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, text.right.nickname).x
                            + self.strokeSize + 5

                        if config.root.windows.killList.displayId && text.right.id != -1 {
                            textWidth += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, string.format("[%d]", text.right.id)).x
                                + self.strokeSize
                        }
                    }
                }

                imgui.SetCursorPosX(match config.root.windows.killList.textAlignMode {
                    ALIGN_CENTER    => self.size.x / 2 - textWidth / 2,
                    ALIGN_RIGHT     => self.size.x - textWidth - imgui.GetStyle().WindowPadding.x,
                    default         => imgui.GetCursorPos().x
                })

                imgui.BeginGroup()
                    local cursorPositionY = imgui.GetCursorPos().y

                    imgui.PushFont(bold10)
                        if config.root.windows.killList.displayTime {
                            imguiAssets::addStrokedText(
                                "[%02d:%02d:%02d]",
                                self.strokeSize,
                                nil,
                                item.time.wHour,
                                item.time.wMinute,
                                item.time.wSecond
                            )
                            imgui.SameLine(nil, 5)
                        }

                        imgui.BeginGroup()
                            imguiAssets::addStrokedText(text.left.nickname, self.strokeSize, text.left.color)
                            if config.root.windows.killList.displayId && text.left.id != -1 {
                                imgui.SameLine(nil, 0)
                                imguiAssets::addStrokedText("[%d]", self.strokeSize, text.left.color, text.left.id)
                            }
                        imgui.EndGroup()
                        self.allowOpenPopup(text.left, text.left.color)
                    imgui.PopFont()

                    imgui.SameLine(nil, 5)
                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)

                    imgui.PushFont(regular9)
                        imguiAssets::addStrokedText(text.center, self.strokeSize)
                        imguiAssets::setPreviousItemAbleToCopy(text.center)
                    imgui.PopFont()

                    if text.right.nickname != "" {
                        imgui.PushFont(bold10)
                            imgui.SameLine(nil, 5)
                            imgui.SetCursorPosY(cursorPositionY)

                            imgui.BeginGroup()
                                imguiAssets::addStrokedText(text.right.nickname, self.strokeSize, text.right.color)
                                if config.root.windows.killList.displayId && text.right.id != -1 {
                                    imgui.SameLine(nil, 0)
                                    imguiAssets::addStrokedText("[%d]", self.strokeSize, text.right.color, text.right.id)
                                }
                            imgui.EndGroup()
                            self.allowOpenPopup(text.right, text.right.color)
                        imgui.PopFont()
                    }
                imgui.EndGroup()

                if self.size.x < imgui.GetItemRectSize().x {
                    self.size.x = imgui.GetItemRectSize().x + 20
                }
            }
        }

        self.var.popup::apply()
        if imgui.BeginPopup(self.id .. ".popup", self.flags) {
            imgui.PushFont(regular9)
                for index, command in ({ "sp", "pame", "stats" }) {
                    print(command, (index == 1) ? 3 : ((index == 3) ? 12 : 0))
                    if animations::button(
                        string.format("/%s %d##%s", command, self.var.selected.id, self.id),
                        imgui.ImVec2(100, 25),
                        (index == 1) ? 3 : ((index == 3) ? 12 : 0)
                    ) {
                        sampSendChat(string.format("/%s %d", command, self.var.selected.id))
                    }
                }
            imgui.PopFont()
        }
        self.var.popup::reset()
    })
    self.var.style::reset()
})
