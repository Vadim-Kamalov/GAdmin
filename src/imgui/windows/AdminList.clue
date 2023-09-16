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

@import "imgui.Windows"         => windows
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Admins" => admins

@import "Config"        => config
@import "Icons"         => icons
@import "Common"        => common
@import "Notifications" => notify 

windows::new("imgui.windows.AdminList", {
    description = "Список администраторов в сети",
    type        = MV_DEFAULT,
    size        = { x = 200, y = 0 }
    condition   = fn {
        return config.root.windows.adminList.use
    },

    initialize  = {
        windowStyle = StyleChanger::new({
            WindowBorderSize    = 0,
            WindowPadding       = imgui.ImVec2(0, 0),
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    self.var.windowStyle::apply()
    self::begin(self.id, fn {
        for _, admin in admins {
            local pos   = imgui.GetCursorPos()
            local text  = (config.root.windows.showAdminLvl)
                ? string.format("[LVL: %d] %s[%d]", admin.lvl, admin.nickname.ooc, admin.id)
                : string.format("%s[%d]", admin.nickname.ooc, admin.id)

            pos.x = match config.root.windows.adminList.textAlignMode {
                ALIGN_CENTER    => self.size.x / 2 - imgui.CalcTextSize(text).x / 2,
                ALIGN_RIGHT     => self.size.x - imgui.CalcTextSize(text).x - 5,
                default         => pos.x
            }

            imgui.SetCursorPos(pos)
            local isClicked, isHovered = imguiAssets::addStrokedText(
                text,
                config.root.windows.adminList.strokeSize,
                (config.root.windows.adminList.textColorBasedOnClist) ?
                    common::convertHex2ImVec4(string.format("%06X", sampGetPlayerColor(admin.id) & 0xFFFFFF)) : nil
            )

            if isHovered {
                imgui.GetWindowDrawList()::AddLine(
                    imgui.ImVec2(self.pos.x + pos.x, self.pos.y + pos.y + imgui.CalcTextSize(text).y),
                    imgui.ImVec2(imgui.GetItemRectMax().x - 2, self.pos.y + pos.y + imgui.CalcTextSize(text).y),
                    -1,
                    2
                )
            } 

            if isClicked && setClipboardText(admin.nickname.ooc) {
                notify::send({
                    icon        = icons.ICON_KEYBOARD
                    title       = "Никнейм скопирован"
                    text        = "Успешно скопирован OOC никнейм у администратора " .. admin.nickname.ooc .. "!"
                    duration    = 3
                    buttons     = {
                        first   = {
                            name = "Закрыть"
                            call = fn(close) { close() }
                        }

                        second = {
                            name = "Упомянуть"
                            call = fn {
                                sampSetChatInputEnabled(true)
                                sampSetChatInputText("/a @" .. admin.nickname.ooc .. " ")
                            }
                        }
                    }
                })
            }
        }
    })
    self.var.windowStyle::reset()
})
