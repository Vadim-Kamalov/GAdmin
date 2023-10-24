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
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Spectator"    => spectator
@import "game.User"         => user

@import "Config"            => config
@import "Notifications"     => notify
@import "Icons"             => icons

local sizeX, sizeY = getScreenResolution()

windows::new("imgui.windows.SpectatorActions", {
    description = "Окно действий в режиме наблюдения"
    type        = MV_ONLY_IN_SPECTATOR
    condition   = fn { return config.root.windows.spectatorActions.use }
    size        = { x = 718, y = 104 }
    defaultPos  = { x = sizeX / 2 - 350, y = sizeY / 1.128 }
    initialize  = {
        middleButtons = StyleChanger::new({
            FrameRounding   = 0
            ItemSpacing     = imgui.ImVec2(2, 0)
        })
    }
}, fn(self) {
    self.specInfo = spectator::getInformation()
    self.centeredText = string.format(
        "Скорость: %s / %s · Оружие: %s · Здоровье: %s · Пинг: %d",
        self.specInfo.moveSpeed.current, self.specInfo.moveSpeed.max,
        self.specInfo.weapon,
        self.specInfo.health,
        self.specInfo.ping
    )

    self.buttons = {
        { title = "*Вы тут?*", callback = fn {
            sampSendChat("/ans " .. tostring(spectator.id) .. " Вы тут? Ответ в /b или /pm " .. tostring(user::getId()))
        }},

        { title = "ANS", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText("/ans " .. tostring(spectator.id) .. " ")
        }},

        { title = "AHEAL", callback = fn {
            sampSendChat("/aheal " .. tostring(spectator.id))
        }},

        { title = "STATS", callback = fn {
            sampSendMenuSelectRow(SPECTATOR_MENU_STATS)
        }},

        { title = "AFRISK", callback = fn {
            sampSendMenuSelectRow(SPECTATOR_MENU_FRISK)
        }},

        { title = "PAME", callback = fn {
            sampSendChat("/pame " .. tostring(spectator.id))
        }},

        { title = "GG", callback = fn {
            sampSendChat(string.format("/ans %d %s" , spectator.id, config.root.binder.commands.gg.message))
        }},

        { title = "SLAP", callback = fn {
            sampSendChat("/slap " .. tostring(spectator.id))
        }},

        { title = "SWITCH", callback = fn {
            sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH)
        }},

        { title = "BAN", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/ban %d ", spectator.id))
        }},

        { title = "KICK", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/kick %d ", spectator.id))
        }},

        { title = "MUTE", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/mute %d ", spectator.id))
        }},

        { title = "BMUTE", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/bmute %d ", spectator.id))
        }},

        { title = "PK", callback = fn {
            sampSendChat("/pk " .. tostring(spectator.id))
        }},

        { title = "JAIL", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/jail %d ", spectator.id))
        }},
        
        { title = "CK", callback = fn {
            sampSetChatInputEnabled(true)
            sampSetChatInputText(string.format("/ck %d ", spectator.id))
        }}
    }

    self::begin(self.id, fn {
        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
            imguiAssets::textWithFont(string.gsub(spectator.nickname, "_", " "), bold10)
            imguiAssets::setPreviousItemAbleToCopy(spectator.nickname, "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname))

            imgui.SameLine()

            imguiAssets::textWithFont(string.format("[%d]", spectator.id), bold10)
            imguiAssets::setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id))
        imgui.PopStyleVar()

        imguiAssets::textWithFont(self.centeredText, regular9, imgui.ImVec2(self.size.x / 2 - imgui.CalcTextSize(self.centeredText).x / 2.3, 6.5))
        imguiAssets::textWithFont(spectator::platformToString(), bold10, imgui.ImVec2(self.size.x - imgui.CalcTextSize(spectator::platformToString()).x - 10, 5))

        imgui.BeginGroup()
            imgui.BeginGroup() // GO_TO_PREVIOUS_PLAYER
                local pos, windowPos = imgui.GetCursorPos(), imgui.GetWindowPos()
                if animations::button("##sp:GO_TO_PREVIOUS_PLAYER", imgui.ImVec2(33, 72), 5)
                   && !self.isChangingWindowsPositions
                {
                    sampSendMenuSelectRow(SPECTATOR_MENU_BACK)
                }
                
                imguiAssets::textWithFont(icons.ICON_CHEVRON_LEFT, nil, imgui.ImVec2(6, 58))
                imgui.GetWindowDrawList()::AddRectFilled(
                    imgui.ImVec2(windowPos.x + 33, windowPos.y + 26),
                    imgui.ImVec2(windowPos.x + 38, windowPos.y + 98),
                    imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                )
            imgui.EndGroup() // GO_TO_PREVIOUS_PLAYER

            imgui.SameLine(35)

            self.var.middleButtons::apply()
                imgui.PushFont(regular9)
                    imgui.BeginGroup() // MIDDLE_BUTTONS
                        for index, button in self.buttons {
                            if index == 9 { imgui.NewLine() }
                            imgui.SetCursorPosY((index > 8) ? 63 : 26)
                            if animations::button(button.title .. "##sp:MIDDLE_BUTTONS", imgui.ImVec2(78, 35))
                               && !self.isChangingWindowsPositions
                            {
                                button.callback()
                            }
                            imgui.SameLine()
                        }
                    imgui.EndGroup() // MIDDLE_BUTTONS
                imgui.PopFont()
            self.var.middleButtons::reset()
// 657
            imgui.SameLine(675)
            imgui.BeginGroup() // GO_TO_NEXT_PLAYER
                local pos, windowPos = imgui.GetCursorPos(), imgui.GetWindowPos()
                if animations::button(" ##sp:GO_TO_NEXT_PLAYER", imgui.ImVec2(33, 72), 10)
                   && !self.isChangingWindowsPositions
                {
                    sampSendMenuSelectRow(SPECTATOR_MENU_NEXT)
                }
                imguiAssets::textWithFont(icons.ICON_CHEVRON_RIGHT, nil, imgui.ImVec2(683, 58))
                imgui.GetWindowDrawList()::AddRectFilled(
                    imgui.ImVec2(windowPos.x + 680, windowPos.y + 26),
                    imgui.ImVec2(windowPos.x + 684, windowPos.y + 98),
                    imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                )
            imgui.EndGroup() // GO_TO_NEXT_PLAYER
        imgui.EndGroup()
    })
})
