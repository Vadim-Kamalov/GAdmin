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

@import "imgui.Windows"         => windows
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Admins"   => admins
@import "game.User"     => user

@import "Assets"        => assets
@import "Config"        => config
@import "Icons"         => icons
@import "Common"        => common
@import "Notifications" => notify
@import "Algorithm"     => algorithm

local fn getAdmins() {
    if config.root.windows.adminList.sortByLvl {
        local adminList = assets::copyTable(admins)
        algorithm::bubbleSortByKey(adminList, "lvl")
        return adminList
    } else {
        return admins
    }
}

windows::new("imgui.windows.AdminList", {
    description = "Список администраторов в сети"
    type        = MV_DEFAULT
    size        = { x = 0, y = 0 }
    condition   = fn { return config.root.windows.adminList.use && user::getAloginStatus() }

    initialize  = {
        windowStyle = StyleChanger::new({
            WindowBorderSize    = 0
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
            ScrollbarSize       = 5
            ScrollbarBg         = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    self.flags = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar
        + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize

    self.size.y = config.root.windows.adminList.countForScrollbar * 20

    self.var.windowStyle::apply()
    self::begin(self.id, fn {
        for _, admin in getAdmins() {
            imgui.BeginGroup()
                local align = config.root.windows.adminList.textAlignMode
                local pos   = imgui.GetCursorPos()
                local text  = (config.root.windows.adminList.showAdminLvl)
                    ? string.format("[LVL: %d] %s[%d]", admin.lvl, admin.nickname.ooc, admin.id)
                    : string.format("%s[%d]", admin.nickname.ooc, admin.id)

                local color = (config.root.windows.adminList.textColorBasedOnClist)
                    ? common::convertHex2ImVec4($PLAYER_COLOR_TO_HEX!(admin.id)) : nil

                for _, player in nicknameColors {
                    if player.nickname == admin.nickname.ooc && player.colors[1] {
                        color = common::convertHex2ImVec4(bit.tohex(player.colors[1], 6))
                        break
                    }
                }

                imgui.PushFont(bold10)
                    pos.x = match align {
                        ALIGN_CENTER    => self.size.x / 2 - imgui.CalcTextSize(text).x / 2,
                        ALIGN_RIGHT     => self.size.x - imgui.CalcTextSize(text).x - 10,
                        default         => pos.x
                    }

                    imgui.SetCursorPos(pos)
                    local clicked, hovered = imguiAssets::addStrokedText(
                        text,
                        config.root.windows.adminList.strokeSize,
                        color
                    )
                    if self.size.x < (imgui.GetItemRectSize().x + ((align == ALIGN_RIGHT) ? 10 : 0)) {
                        self.size.x = imgui.GetItemRectSize().x + ((align == ALIGN_RIGHT) ? 10 : 0)
                    }
                imgui.PopFont()

                if hovered {
                    imgui.GetForegroundDrawList()::AddLine(
                        imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                        imgui.GetItemRectMax(),
                        -1,
                        2
                    )
                } 

                if clicked {
                    setClipboardText(admin.nickname.ooc)
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
            imgui.EndGroup()
        }
    }, self.flags)
    self.var.windowStyle::reset()
})
