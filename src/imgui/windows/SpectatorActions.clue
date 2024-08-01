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

@import "imgui.Windows"         => windows
@import "imgui.Assets"          => imguiAssets
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Spectator"    => spectator
@import "game.User"         => user
@import "game.Binder"       => binder

@import "Config"            => config
@import "Notifications"     => notify
@import "Icons"             => icons

@macro SPECTATOR_ACTIONS_CUSTOM_WIDGET() { (fn {
    local id         = "spectatorActionsCustomWidget"
    local childSizeX = math.max(imgui.GetWindowWidth() - 12, 350)

    local getActionType = fn (index) {
        return (type(config.root.windows.spectatorActions.buttons[index][2]) == "string") ? 1 : 2
    }

    local getValue = fn (index) {
        return (type(config.root.windows.spectatorActions.buttons[index][2]) == "number")
            ? imgui.new.int(config.root.windows.spectatorActions.buttons[index][2])
            : imgui.new.char[512](config.root.windows.spectatorActions.buttons[index][2])
    }

    if !SPECTATOR_ACTIONS_CUSTOM_WIDGET {
        global SPECTATOR_ACTIONS_CUSTOM_WIDGET = {
            selected = 1,
            title    = imgui.new.char[144](config.root.windows.spectatorActions.buttons[1][1])
            action   = imgui.new.int(getActionType(1)),
            value    = getValue(1),
            state    = imgui.new.bool(config.root.windows.spectatorActions.buttons[1][3])
        }
    }

    local this = SPECTATOR_ACTIONS_CUSTOM_WIDGET

    imgui.BeginGroup()
        imguiAssets::textWithFont("Настройки кнопки", regular10)
        imgui.SameLine()
        imguiAssets::textWithFont(config.root.windows.spectatorActions.buttons[this.selected][1])
    imgui.EndGroup()
    imgui.BeginChild(id .. ".buttonSettings", imgui.ImVec2(childSizeX, 167), true)
        imgui.SetCursorPos(imgui.ImVec2(6, 6))
        imgui.BeginGroup()
            imgui.PushItemWidth(imgui.GetWindowWidth() - 12)
                imguiAssets::textWithFont("Название кнопки", bold10)

                if imgui.InputTextWithHint("##" .. id .. ".title", "Название", this.title, ffi.sizeof(this.title)) {
                    config.root.windows.spectatorActions.buttons[this.selected][1] = ffi.string(this.title)
                }

                imguiAssets::textWithFont("Действие кнопки", bold10)

                if imgui.SliderInt(
                    string.format("##%s.action", id),
                    this.action,
                    1, 
                    2,
                    ({ "Выполнить бинд", "Выполнить действие" })[this.action[0]]
                ) {
                    local value = config.root.windows.spectatorActions.buttons[this.action[0]]
                    this.value  = match this.action[0] {
                        1 => imgui.new.char[512]((type(value) == "string") ? value : ""),
                        2 => imgui.new.int((type(value) == "number") ? value : 0)
                    }
                }
            
                if this.action[0] == 1 {
                    if imgui.InputText("##" .. id .. ".actionInput", this.value, ffi.sizeof(this.value)) {
                        config.root.windows.spectatorActions.buttons[this.selected][2] = ffi.string(this.value)
                    }
                } elseif this.action[0] == 2 {
                    if imgui.SliderInt("##" .. id .. ".actionSlider", this.value, 0, 6, ({
                        "Следующий игрок",
                        "Переключить режим наблюдения",
                        "Предыдущий игрок",
                        "Открыть статистику игрока",
                        "Открыть сессии игрока",
                        "Открыть инвентарь игрока",
                        "Выйти из режима наблюдения"
                    })[this.value[0] + 1]) {
                        config.root.windows.spectatorActions.buttons[this.selected][2] = this.value[0]
                    }
                }

                imgui.PushFont(bold10)
                    if animations::toggleButton("Отображать в окне##" .. id .. ".stateButton", this.state) {
                        config.root.windows.spectatorActions.buttons[this.selected][3] = this.state[0]
                    }
                imgui.PopFont()
            imgui.PopItemWidth()
        imgui.EndGroup()
    imgui.EndChild()

    imguiAssets::textWithFont("Список кнопок", regular10)
    imgui.BeginChild(id .. ".buttonList", imgui.ImVec2(childSizeX, 250), true)
        local drawList = imgui.GetWindowDrawList()
        
        imgui.SetCursorPos(imgui.ImVec2(6, 6))
        imgui.BeginGroup()
            for index, item in config.root.windows.spectatorActions.buttons {
                imgui.BeginGroup()
                    local itemWidth  = imgui.GetWindowWidth() - 22
                    local selectItem = fn (index) {
                        if index != this.selected {
                            this.selected  = index
                            this.action[0] = getActionType(index)
                            this.value     = getValue(index)
                            this.state[0]  = config.root.windows.spectatorActions.buttons[index][3]
                        
                            imgui.StrCopy(this.title, config.root.windows.spectatorActions.buttons[index][1])
                        }
                    }

                    drawList::AddRectFilled(
                        imgui.GetCursorScreenPos(),
                        imgui.GetCursorScreenPos() + imgui.ImVec2(itemWidth, 25),
                        imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg]),
                        imgui.GetStyle().FrameRounding
                    )
                        
                    imgui.BeginGroup()
                        local baseCursorPos = imgui.GetCursorPos()
                        local id            = "##" .. id .. ".itemIndex-" .. index
                        local moveItem      = fn (new) {
                            if index == this.selected {
                                selectItem(new)
                            }

                            table.insert(
                                config.root.windows.spectatorActions.buttons,
                                new,
                                table.remove(config.root.windows.spectatorActions.buttons, index)
                            ) 
                        }
                            
                        imgui.SetCursorPos(baseCursorPos + imgui.GetStyle().FramePadding)
                        imguiAssets::textWithFont(item[1], bold10)
                        imgui.PushFont(regular12)
                            imgui.SetCursorPos(imgui.ImVec2(itemWidth - 160, baseCursorPos.y))
                            imgui.BeginGroup()
                                if animations::button("Вверх" .. id, imgui.ImVec2(40, 25), nil, nil, buttonColors) {
                                    moveItem(math.max(1, index - 1))
                                }
                                imgui.SameLine(nil, 2)                
                                if animations::button("Вниз" .. id, imgui.ImVec2(40, 25), nil, nil, buttonColors) {
                                    moveItem(math.min(index + 1, #config.root.windows.spectatorActions.buttons))
                                }
                            imgui.EndGroup()
                            imgui.SetCursorPos(imgui.ImVec2(itemWidth - 75, baseCursorPos.y))
                            if animations::button("Настроить" .. id, imgui.ImVec2(80, 25), nil, nil, buttonColors) {
                                selectItem(index)
                            }
                        imgui.PopFont()
                    imgui.EndGroup()
                    imgui.SameLine()
                    imgui.Dummy(imgui.ImVec2(itemWidth, 25))
                imgui.EndGroup()
            }
        imgui.EndGroup()
    imgui.EndChild()
})}

local sizeX, sizeY = getScreenResolution()

windows::new("imgui.windows.SpectatorActions", {
    description = "Окно действий в режиме наблюдения"
    type        = MV_ONLY_IN_SPECTATOR
    condition   = fn { return config.root.windows.spectatorActions.use }
    size        = { x = 700, y = config.root.windows.spectatorActions.windowSizeY }
    defaultPos  = { x = sizeX / 2 - 350, y = sizeY / 1.128 }
    initialize  = {
        middleButtons = StyleChanger::new({
            FrameRounding   = 0
            ItemSpacing     = imgui.ImVec2(2, 0)
        })
    }
}, fn (self) {
    self.specInfo     = spectator::getInformation()
    self.size.y       = config.root.windows.spectatorActions.windowSizeY
    self.centeredText = string.format(
        "Скорость: %s / %s · Оружие: %s · Здоровье: %s · Пинг: %d",
        self.specInfo.moveSpeed.current, self.specInfo.moveSpeed.max,
        self.specInfo.weapon,
        self.specInfo.health,
        self.specInfo.ping
    )

    self::begin(self.id, fn {
        imgui.SetScrollY(0)

        imgui.BeginGroup()
            imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
                imguiAssets::textWithFont(string.gsub(spectator.nickname || "", "_", " "), bold10)
                imguiAssets::setPreviousItemAbleToCopy(spectator.nickname || "", "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname))

                imgui.SameLine()

                imguiAssets::textWithFont(string.format("[%d]", spectator.id), bold10)
                imguiAssets::setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id))
            imgui.PopStyleVar()

            imguiAssets::textWithFont(self.centeredText, regular9, imgui.ImVec2(
                (self.size.x - regular9::CalcTextSizeA(regular9.FontSize, math.huge, 0.0, self.centeredText).x) / 2,
                6.5
            ))

            imguiAssets::textWithFont(spectator::platformToString(), bold10, imgui.ImVec2(
                self.size.x - bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, spectator::platformToString()).x - 10,
                5
            ))
        imgui.EndGroup()

        imgui.BeginGroup()
            local maxItems = 2

            for _, item in config.root.windows.spectatorActions.buttons {
                if item[3] { maxItems += 1 }
            }

            local hasTallMiddleItem  = (maxItems - 2) % 2 != 0
            local maxItemsPerLine    = math.floor(maxItems / 2) + ((hasTallMiddleItem) ? 1 : 0)
            local itemWidth          = math.floor(self.size.x / maxItemsPerLine) - 1
            local itemHeight         = self.size.y - imgui.GetCursorPos().y - imgui.GetStyle().WindowPadding.y
            local cornerButtonSize   = imgui.ImVec2(math.floor((itemWidth - 12) / 2), itemHeight)
            local renderCornerButton = fn (text, id, action, rounding) {
                imgui.BeginGroup()
                    imgui.PushFont(icon)
                        local pos = imgui.GetCursorPos()
                        local id  = string.format("##%s.%s", self.id, id)

                        if animations::button(id, cornerButtonSize, rounding) && !self.isChangingWindowsPositions {
                            sampSendMenuSelectRow(action)
                        }

                        imgui.SetCursorPos(pos + imgui.ImVec2(0, 6) + (cornerButtonSize - imgui.CalcTextSize(text)) * 0.5)
                        imgui.Text(text)
                    imgui.PopFont()
                imgui.EndGroup()
            }

            renderCornerButton(icons.ICON_CHEVRON_LEFT, "buttonGoToPreviousPlayer", SPECTATOR_MENU_BACK, 5)
            imgui.SameLine(nil, 2)

            imgui.BeginGroup()
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
                imgui.PushFont(regular9)
                    for index, item in config.root.windows.spectatorActions.buttons {
                        if item[3] {
                            local label  = string.format("%s##%s.buttonIndex-%d", item[1], self.id, index)
                            local height = (hasTallMiddleItem && index == (maxItems - 2)) ? itemHeight : (itemHeight / 2 - 1)

                            if height == itemHeight {
                                imgui.SameLine(nil, 0)
                                imgui.SetCursorPosY(self.size.y - height - 5)
                            }

                            if animations::button(label, imgui.ImVec2(itemWidth, height)) && !self.isChangingWindowsPositions {
                                if type(item[2]) == "number" {
                                    sampSendMenuSelectRow(item[2])
                                } elseif type(item[2]) == "string" {
                                    binder::sendString(self.id, item[2], { spectator.id })
                                }
                            }

                            imgui.SameLine(nil, 2)
                           
                            if index % (maxItemsPerLine - ((hasTallMiddleItem) ? 2 : 1)) == 0 {
                                imgui.NewLine()
                                imgui.SetCursorPosY(imgui.GetCursorPos().y - 2)
                            }
                        }
                    }
                imgui.PopFont()
                imgui.PopStyleVar()
            imgui.EndGroup()

            imgui.SameLine(nil, (hasTallMiddleItem) ? 2 : 0)
            renderCornerButton(icons.ICON_CHEVRON_RIGHT, "buttonGoToNextPlayer", SPECTATOR_MENU_NEXT, 10)
        imgui.EndGroup()
    })
})
