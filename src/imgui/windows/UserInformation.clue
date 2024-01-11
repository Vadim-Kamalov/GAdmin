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
@import "imgui.StyleChanger"    => StyleChanger

@import "game.User" => user

@import "Config" => config
@import "Assets" => assets

@macro USER_INFORMATION_CUSTOM_WIDGET() {
    (fn {
        if animations::button("Добавить новую линию##USER_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 25)) {
            table.insert(config.root.windows.userInformation.display, 1, "NewLine")
        }

        imgui.BeginChild("USER_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 300), true)
            local drawList  = imgui.GetWindowDrawList()
            local itemColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])

            imgui.SetCursorPos(imgui.ImVec2(6, 6))
            imgui.BeginGroup()
                for index, item in config.root.windows.userInformation.display {
                    local actionButtonPlaceholder = (type(item) == "table") ? ((item[2]) ? "Скрыть" : "Отобразить") : "Удалить"

                    imgui.BeginGroup()
                        local itemWidth = imgui.GetWindowWidth() - 22

                        drawList::AddRectFilled(
                            imgui.GetCursorScreenPos(),
                            imgui.GetCursorScreenPos() + imgui.ImVec2(itemWidth, 25),
                            itemColor,
                            imgui.GetStyle().FrameRounding
                        )
                        
                        imgui.BeginGroup()
                            local baseCursorPos = imgui.GetCursorPos()
                            local id            = "##USER_INFORMATION_CUSTOM_WIDGET.indexN" .. index
                            local moveItem      = fn(new) {
                                table.insert(
                                    config.root.windows.userInformation.display,
                                    new,
                                    table.remove(config.root.windows.userInformation.display, index)
                                ) 
                            }
                            
                            imgui.SetCursorPos(baseCursorPos + imgui.GetStyle().FramePadding)
                            imguiAssets::textWithFont(type(item) == "table" ? item[1] : "Новая линия", bold10)
                            imgui.PushFont(regular12)
                                imgui.SetCursorPos(imgui.ImVec2(itemWidth - 160, baseCursorPos.y))
                                imgui.BeginGroup()
                                    if animations::button("Вверх" .. id, imgui.ImVec2(40, 25)) {
                                        moveItem(math.max(1, index - 1))
                                    }
                                    imgui.SameLine(nil, 2)                
                                    if animations::button("Вниз" .. id, imgui.ImVec2(40, 25)) {
                                        moveItem(math.min(index + 1, #config.root.windows.userInformation.display))
                                    }
                                imgui.EndGroup()
                                imgui.SetCursorPos(imgui.ImVec2(itemWidth - 75, baseCursorPos.y))
                                if animations::button(actionButtonPlaceholder .. id, imgui.ImVec2(80, 25)) {
                                    if type(item) == "table" {
                                        item[2] = !$
                                    } else {
                                        table.remove(config.root.windows.userInformation.display, index)
                                    }
                                }
                            imgui.PopFont()
                        imgui.EndGroup()

                        imgui.SameLine()

                        imgui.Dummy(imgui.ImVec2(itemWidth, 25))
                    imgui.EndGroup()
                }
            imgui.EndGroup()
        imgui.EndChild()
    })
}

window::new("imgui.windows.UserInformation", {
    description = "Информация о Вас"
    type        = MV_DEFAULT
    size        = { x = 200, y = 0 }
    condition   = fn { return config.root.windows.userInformation.use && isSampAvailable() && user::getAloginStatus() },
    initialize  = {
        style = StyleChanger::new({
            WindowBorderSize    = 0
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    local strokeSize = config.root.windows.userInformation.strokeSize

    self.setNextItemAligned = fn(text) {
        local pos   = imgui.GetCursorPos()
        local align = match config.root.windows.userInformation.textAlignMode {
            ALIGN_CENTER    => self.size.x / 2 - imgui.CalcTextSize(text).x / 2,
            ALIGN_RIGHT     => self.size.x - imgui.CalcTextSize(text).x - strokeSize - imgui.GetStyle().WindowPadding.x,
            default         => pos.x
        }

        imgui.SetCursorPosX(align)
    }

    self.var.style::apply()
    self::begin(self.id, fn {
        imgui.BeginGroup()
            local time          = assets::getLocalTime()
            local online        = user::getTime()
            local answers       = user::getAnswersCount()
            
            if config.root.windows.userInformation.showTime {
                local text = string.format(
                    "%d-%d-%d %02d:%02d:%02d",
                    time.wYear, time.wMonth, time.wDay,
                    time.wHour, time.wMinute, time.wSecond
                )

                self.setNextItemAligned(text)
                imguiAssets::addStrokedText(text, strokeSize)
            }

            for _, item in config.root.windows.userInformation.display {
                local values = {
                    ["ID"]              = user::getId(),
                    ["IC никнейм"]      = user::getNickname(),
                    ["OOC никнейм"]     = user::getOOCNickname(),
                    ["Админ уровень"]   = user::getAdminLvl(),
                    ["Пинг"]            = user::getPing(),
                    
                    ["Общий онлайн"] = fn {
                        local this = online.total
                        return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
                    },

                    ["Онлайн за неделю"] = fn {
                        local this = online.weekTotal
                        return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
                    },

                    ["Онлайн за сессию"] = fn {
                        local this = online.session
                        return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
                    },

                    ["Ответов всего"]       = answers.total,
                    ["Ответов за неделю"]   = answers.weekTotal,
                    ["Ответов за сесcию"]   = answers.session
                }

                if item == "NewLine" {
                    imgui.NewLine()
                } else {
                    if item[2] && values[item[1]] {
                        local name, value = item[1], tostring((type(values[item[1]]) == "function") ? values[item[1]]() : values[item[1]])

                        self.setNextItemAligned(name .. ": " .. value)
                        imguiAssets::addStrokedText("%s: %s", strokeSize, nil, name, value)
                        imguiAssets::setPreviousItemAbleToCopy(value)
                    }
                }
            }
        imgui.EndGroup()
        
        if imgui.GetItemRectSize().x > self.size.x {
            self.size.x = imgui.GetItemRectSize().x + 20 
        }
    })
    self.var.style::reset()
})
