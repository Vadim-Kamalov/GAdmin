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

@import "Config"            => config
@import "game.Spectator"    => spectator

@import "Notifications"     => notify
@import "Icons"             => icons

local sizeX, sizeY = getScreenResolution()

windows::new("imgui.windows.SpectatorActions", {
    description = "Окно действий в режиме наблюдения"
    type        = MV_ONLY_IN_SPECTATOR
    condition   = fn { return config.root.additions.spectatorActions.use }
    size        = { x = 700, y = 100 }
    defaultPos  = { x = sizeX / 2 - 350, y = sizeY / 1.128 }
    initialize  = {
        middleButtons = StyleChanger::new({
            FrameRounding   = 0
            ItemSpacing     = imgui.ImVec2(1, 0)
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

    self.setPreviousItemAbleToCopy = fn(
        text,
        notifyTitle         = "Текст скопирован.",
        notifyDescription   = "Следующий текст успешно скопирован: " .. text
    ) {
        if imgui.IsItemHovered() {
            imgui.GetWindowDrawList()::AddLine(
                imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                imgui.GetItemRectMax(),
                -1,
                2
            )
        } if imgui.IsItemClicked() {
            setClipboardText(tostring(text))
            notify::send({
                icon    = icons.ICON_KEYBOARD
                title   = notifyTitle
                text    = notifyDescription
            })
        }
    }

    /// TODO
    self.buttons = {
        { title = "*Вы тут?*", callback = fn {}},
        { title = "ANS", callback = fn {}}, 
        { title = "AHEAL", callback = fn {}},
        { title = "STATS", callback = fn {}},
        { title = "AFRISK", callback = fn {}},
        { title = "PAME", callback = fn {}},
        { title = "GG", callback = fn {}},
        { title = "SLAP", callback = fn {}},
        { title = "SWITCH", callback = fn {}},
        { title = "BAN", callback = fn {}},
        { title = "KICK", callback = fn {}},
        { title = "MUTE", callback = fn {}},
        { title = "BMUTE", callback = fn {}},
        { title = "PK", callback = fn {}},
        { title = "JAIL", callback = fn {}},
        { title = "CK", callback = fn {}}
    }

    self::begin(self.id, fn {
        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
            imguiAssets::textWithFont(string.gsub(spectator.nickname, "_", " "), bold10)
            self.setPreviousItemAbleToCopy(spectator.nickname, "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname))

            imgui.SameLine()

            imguiAssets::textWithFont(string.format("[%d]", spectator.id), bold10)
            self.setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id))
        imgui.PopStyleVar()

        imguiAssets::textWithFont(self.centeredText, regular9, imgui.ImVec2(self.size.x / 2 - imgui.CalcTextSize(self.centeredText).x / 2.3, 6.5))
        imguiAssets::textWithFont(spectator::platformToString(), bold10, imgui.ImVec2(self.size.x - imgui.CalcTextSize(spectator::platformToString()).x - 10, 5))

        imgui.BeginGroup()
            imgui.BeginGroup() // GO_TO_PREVIOUS_PLAYER
                local pos, windowPos = imgui.GetCursorPos(), imgui.GetWindowPos()
                animations::button("##sp:GO_TO_PREVIOUS_PLAYER", imgui.ImVec2(33, 68.5), 5)
                imguiAssets::textWithFont(icons.ICON_CHEVRON_LEFT, nil, imgui.ImVec2(6, 58))
                imgui.GetWindowDrawList()::AddRectFilled(
                    imgui.ImVec2(windowPos.x + 34, windowPos.y + 27.5),
                    imgui.ImVec2(windowPos.x + 37, windowPos.y + 93.5),
                    imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                )
            imgui.EndGroup() // GO_TO_PREVIOUS_PLAYER

            imgui.SameLine(33)

            self.var.middleButtons::apply()
                imgui.PushFont(regular9)
                    imgui.BeginGroup() // MIDDLE_BUTTONS
                        for index, button in self.buttons {
                            if index == 9 { imgui.NewLine() }
                            imgui.SetCursorPosY((index > 8) ? 60 : 26)
                            if animations::button(button.title .. "##sp:MIDDLE_BUTTONS", imgui.ImVec2(78, 34.5)) {
                                button.callback()
                            }
                            imgui.SameLine()
                        }
                    imgui.EndGroup() // MIDDLE_BUTTONS
                imgui.PopFont()
            self.var.middleButtons::reset()

            imgui.SameLine(657)
            imgui.BeginGroup() // GO_TO_NEXT_PLAYER
                local pos, windowPos = imgui.GetCursorPos(), imgui.GetWindowPos()
                animations::button(" ##sp:GO_TO_NEXT_PLAYER", imgui.ImVec2(33, 68.5), 10)
                imguiAssets::textWithFont(icons.ICON_CHEVRON_RIGHT, nil, imgui.ImVec2(665, 58))
                imgui.GetWindowDrawList()::AddRectFilled(
                    imgui.ImVec2(windowPos.x + 663, windowPos.y + 27.5),
                    imgui.ImVec2(windowPos.x + 665, windowPos.y + 93.5),
                    imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Button])
                )
            imgui.EndGroup() // GO_TO_NEXT_PLAYER
        imgui.EndGroup()
    })
})
