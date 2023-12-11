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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger

@import "game.User" => user

@import "Config" => config
@import "Assets" => assets

window::new("imgui.windows.UserInformation", {
    description = "Информация о Вас"
    type        = MV_DEFAULT
    size        = { x = 200, y = 0 }
    condition   = fn { return config.root.windows.userInformation.use && isSampAvailable() },
    initialize  = {
        style = StyleChanger::new({
            WindowBorderSize    = 0
            WindowPadding       = imgui.ImVec2(0, 0)
            WindowBg            = imgui.ImVec4(0, 0, 0, 0)
        })
    }
}, fn(self) {
    local strokeSize = config.root.windows.userInformation.strokeSize

    self.sortArray = fn(originalArray, targetArray) {
        local sortedArray = {}

        for i = 1, #targetArray {
            for j = i, #originalArray {
                if originalArray[j].name == targetArray[i][1] || type(originalArray[j]) == "string" {
                    table.insert(sortedArray, originalArray[j])
                    break
                }
            }
        }

        return sortedArray
    }

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
        local time          = assets::getLocalTime()
        local online        = user::getTime()
        local answers       = user::getAnswersCount()

        {
            local text = string.format(
                "%d-%d-%d %02d:%02d:%02d",
                time.wYear, time.wMonth, time.wDay,
                time.wHour, time.wMinute, time.wSecond
            )

            self.setNextItemAligned(text)
            imguiAssets::addStrokedText(text, strokeSize)
        }

        for _, item in self.sortArray({
            { name = "ID", value = user::getId() }
            { name = "IC никнейм", value = user::getNickname() },
            { name = "OOC никнейм", value = user::getOOCNickname() },
            { name = "Админ уровень", value = user::getAdminLvl() },
            { name = "Пинг", value = user::getPing() },
            
            "NewLine",

            { name = "Общий онлайн", value = fn {
                local this = online.total
                return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
            }},

            { name = "Онлайн за неделю", value = fn {
                local this = online.weekTotal
                return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
            }},

            { name = "Онлайн за сессию", value = fn {
                local this = online.session
                return string.format("%02d:%02d:%02d", this.hour, this.min, this.sec)
            }},

            "NewLine",

            { name = "Ответов всего", value = answers.total },
            { name = "Ответов за неделю", value = answers.weekTotal },
            { name = "Ответов за сесcию", value = answers.session }
        }, config.root.windows.userInformation.display) {
            if item == "NewLine" {
                imgui.NewLine()
            } else {
                for _, display in config.root.windows.userInformation.display {
                    // display[1] = string, must equals to item.name.
                    // display[2] = boolean, display status.
                    if display[1] == item.name && display[2] {
                        local name, value = item.name, tostring((type(item.value) == "function") ? item.value() : item.value)

                        self.setNextItemAligned(name .. ": " .. value)
                        imguiAssets::addStrokedText("%s: %s", strokeSize, nil, name, value)
                        imguiAssets::setPreviousItemAbleToCopy(value)

                        if self.size && self.pos {
                            local rectMinX = imgui.GetItemRectMin().x - self.pos.x
                            if rectMinX < 0 {
                                self.size.x += math.abs(rectMinX)
                            }

                            if imgui.GetItemRectSize().x > self.size.x {
                                self.size.x = imgui.GetItemRectSize().x
                            }
                        }
                    }
                }
            }
        }
    })
    self.var.style::reset()
})
