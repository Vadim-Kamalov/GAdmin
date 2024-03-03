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
 
@macro SPECTATOR_INFORMATION_CUSTOM_WIDGET() {
    (fn {
        imgui.BeginChild("SPECTATOR_INFORMATION_CUSTOM_WIDGET", imgui.ImVec2(350, 300), true)
            local drawList  = imgui.GetWindowDrawList()
            local itemColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])

            imgui.SetCursorPos(imgui.ImVec2(6, 6))
            imgui.BeginGroup()
                for index, item in config.root.windows.spectatorInformation.columns {
                    local actionButtonPlaceholder = (item[2]) ? "Скрыть" : "Отобразить"

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
                            local id            = "##SPECTATOR_INFORMATION_CUSTOM_WIDGET.indexN" .. index
                            local moveItem      = fn(new) {
                                table.insert(
                                    config.root.windows.spectatorInformation.columns,
                                    new,
                                    table.remove(config.root.windows.spectatorInformation.columns, index)
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
                                        moveItem(math.min(index + 1, #config.root.windows.spectatorInformation.columns))
                                    }
                                imgui.EndGroup()
                                imgui.SetCursorPos(imgui.ImVec2(itemWidth - 75, baseCursorPos.y))
                                if animations::button(actionButtonPlaceholder .. id, imgui.ImVec2(80, 25)) {
                                    if type(item) == "table" {
                                        item[2] = !$
                                    } else {
                                        table.remove(config.root.windows.spectatorInformation.columns, index)
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

@import "imgui.Assets"          => imguiAssets
@import "imgui.Windows"         => window
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Animations"      => animations

@import "game.Admins"     => admins
@import "game.Spectator"  => spectator
@import "game.sa.Vehicle" => vehicle

@import "Common" => common
@import "Config" => config

static enum /* SPECTATOR_INFORMATION_TYPE */ {
    SPECTATOR_INFORMATION_TYPE_SINGLE,
    SPECTATOR_INFORMATION_TYPE_DOUBLE
}

local sizeX, sizeY  = getScreenResolution()
local hintClock     = nil

window::new("imgui.windows.SpectatorInformation", {
    description = "Информация о игроке в спектаторе"
    type        = MV_ONLY_IN_SPECTATOR
    condition   = fn { return config.root.windows.spectatorInformation.use }
    size        = fn { return { x = 140 * (config.root.windows.spectatorInformation.type * 2), y = 0 } }
    defaultPos  = { x = 0, y = sizeY / 2.336 }
    initialize  = {
        columnsPadding = StyleChanger::new({
            ItemSpacing         = imgui.ImVec2(5, 5)
            WindowPadding       = imgui.ImVec2(0, 0)
            ItemInnerSpacing    = imgui.ImVec2(0, 0)
        })
    }
}, fn(self) {
    self.information = spectator::getInformation()

    hintClock ??= os.clock()
    
    local result, handle = spectator::getHandle()
    if result {
        if isCharInAnyCar(handle) {
            self.speedColor = (tonumber(self.information.moveSpeed.current) > tonumber(self.information.moveSpeed.max))
                && common::convertHex2ImVec4("FF8585")
        }
        
        if local ping = tonumber(self.information.ping) {
            self.pingColor = common::convertHex2ImVec4((ping <= 75) ? "8DFF85" : (
                                                       (ping >= 75 && ping <= 140) ? "F0E518" : "FF8585"))
        }
    }

    self.shotColor = (self.information.shot.total != "0" && (self.information.shot.total == self.information.shot.hit))
        && common::convertHex2ImVec4("FF8585")

    self.columns = {
        ["Пинг"]                = { value = self.information.ping, color = self.pingColor },
        ["ID аккаунта"]         = { value = self.information.accountId },
        ["Дата регистрации"]    = { value = self.information.regDate },
        ["Наличные/банк"]       = { value = self.information.money .. " / " .. self.information.bank },
        ["Здоровье/броня"]      = { value = self.information.health .. " / " .. self.information.armor },
        ["Фракция"]             = { value = self.information.fraction },
        ["Должность"]           = { value = self.information.rang },
        ["Машина(-ы)"]          = { value = self.information.vehicle },
        ["Стадия"]              = { value = self.information.stage },
        ["VIP статус"]          = { value = self.information.vip },
        ["Предупреждения"]      = { value = self.information.warnings },
        ["Время в афк"]         = { value = self.information.afkTime },
        ["Тек./макс. скорость"] = { value = self.information.moveSpeed.current .. " / " .. self.information.moveSpeed.max, color = self.speedColor },
        ["Выстрелы/попадания"]  = { value = self.information.shot.total .. " / " .. self.information.shot.hit, color = self.shotColor }
    }

    self.centerWrappedColumnText = fn(text, font) {
        local text         = string.match(text, "^%s*(.+)%s*$")
        local originalText = text
        local size         = font::CalcTextSizeA(font.FontSize, math.huge, 0.0, text)

        if size.x >= imgui.GetColumnWidth() {
            while size.x >= imgui.GetColumnWidth() {
                text = string.match($, "(.-)%S+%s*$")
                size = font::CalcTextSizeA(font.FontSize, math.huge, 0.0, text)
            }

            self.centerWrappedColumnText(text, font)
            self.centerWrappedColumnText(string.sub(originalText, #text), font)
        } else {
            imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - size.x / 2)
            imgui.PushFont(font)
                imgui.Text(text)
            imgui.PopFont()
        }
    }

    self.addColumns = fn(columnsCount, columns, id) {
        columnsCount *= 2

        imgui.Separator()
        imgui.Columns(columnsCount, id, true)

        for index, item in config.root.windows.spectatorInformation.columns {
            if item[2] {
                local name = string.gsub(item[1], "##.*", "")
                if local item = columns[item[1]] {
                    item.color  = item.color || imgui.GetStyle().Colors[imgui.Col.Text]
                    item.value  = string.gsub($, "##.*", "")

                    self.centerWrappedColumnText(tostring(name), bold10)
                    imgui.NextColumn()
                    imgui.PushFont(regular9)
                        imgui.PushStyleColor(imgui.Col.Text, item.color)
                            if name != "Машина(-ы)" {
                                self.centerWrappedColumnText(tostring(item.value), regular9)
                            } else {
                                local _, count  = string.gsub(item.value, "%d+", "")
                                local index     = 1
                                
                                imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(item.value).x / 2)
                                
                                if count == 0 { imgui.Text("Нет") } else {
                                    imgui.BeginGroup()
                                        for carId with string.gmatch(item.value, "%d+") {
                                            imgui.Text(carId)

                                            if imgui.IsItemHovered() {
                                                imgui.GetWindowDrawList()::AddLine(
                                                    imgui.ImVec2(imgui.GetItemRectMin().x, imgui.GetItemRectMax().y),
                                                    imgui.GetItemRectMax(),
                                                    -1,
                                                    2
                                                )
                                            }

                                            if imgui.IsItemClicked() {
                                                sampSendChat(string.format("/getbuycar %d", carId))
                                            }
                                        
                                            if count != index {
                                                imgui.SameLine(nil, 0)
                                                imgui.Text(",")
                                            }

                                            imgui.SameLine(nil, 0)

                                            index += 1
                                        }
                                    imgui.EndGroup()

                                    if !config.root.windows.spectatorInformation.showedHintFirstTime {
                                        if os.clock() - hintClock >= 7 || imgui.IsItemHovered() {
                                            config.root.windows.spectatorInformation.showedHintFirstTime = true
                                        }
                                    }

                                    animations::hint("Нажмите на любой из ID, для его телепортации", fn {
                                        return !config.root.windows.spectatorInformation.showedHintFirstTime 
                                    })
                                }
                            }
                        imgui.PopStyleColor()
                    imgui.PopFont()
                    imgui.NextColumn()
            
                    if imgui.GetColumnIndex() % (config.root.windows.spectatorInformation.type * 2) == 0 {
                        imgui.Separator()
                    }
                }
            }
        }
    }
    
    self.addMiddleTextAfterColumns = fn(text, color = imgui.GetStyle().Colors[imgui.Col.Text], ...) {
        text = string.format($, ...)

        imgui.Columns(1)
        imgui.SetCursorPosX(self.size.x / 2 - imgui.CalcTextSize(text).x / 2)
        imgui.TextColored(color, text)
    }

    self.nicknameColor = nil

    if admins::getAdminById(spectator.id) {
        self.nicknameColor = common::convertHex2ImVec4("FF8585")
    }

    self::begin(self.id, fn {
        imgui.BeginGroup(/* Title */)
            imguiAssets::textWithFont(spectator::getActiveTime(), bold10)
            
            imgui.SameLine()
            imgui.SetCursorPosX((self.size.x - imgui.CalcTextSize(string.format("%s[%d]", spectator.nickname, spectator.id)).x) / 2)
            imgui.BeginGroup()
                imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
                    imguiAssets::textWithFont(string.gsub(spectator.nickname || "", "_", " "), bold10, nil, self.nicknameColor)
                    imguiAssets::setPreviousItemAbleToCopy(spectator.nickname, "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname))

                    imgui.SameLine()

                    imguiAssets::textWithFont(string.format("[%d]", spectator.id), bold10, nil, self.nicknameColor)
                    imguiAssets::setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id))
                imgui.PopStyleVar()
            imgui.EndGroup()

            imguiAssets::textWithFont(spectator::platformToString(), bold10, imgui.ImVec2(self.size.x - imgui.CalcTextSize(spectator::platformToString()).x - 10, 5))
        imgui.EndGroup()

        self.var.columnsPadding::apply()
            self.addColumns(config.root.windows.spectatorInformation.type, self.columns, self.id .. "_COLUMNS")

            local result, handle = spectator::getHandle()
            if result {
                if isCharInAnyCar(handle) {
                    local carHandle = storeCarCharIsInNoSave(handle)
                    local carModel  = getCarModel(carHandle)
                    local carName   = vehicle::getName(carModel)
                    local _, carId  = sampGetVehicleIdByCarHandle(carHandle)

                    local engineStatus  = (isCarEngineOn(carHandle)) ? "Заведен" : "Заглушен"
                    local engineColor   = common::convertHex2ImVec4((engineStatus == "Заведен") ? "8DFF85" : "FF8585")

                    local lockStatus    = (getCarDoorLockStatus(carHandle) == 0) ? "Открыты" : "Закрыты"
                    local lockColor     = common::convertHex2ImVec4((lockStatus == "Открыты") ? "8DFF85" : "FF8585")

                    self.addMiddleTextAfterColumns("%s[%d]", nil, carName, carId)

                    self.addColumns(config.root.windows.spectatorInformation.type, {
                        ["Двигатель"]  = { value = engineStatus, color = engineColor },
                        ["Двери"]      = { value = lockStatus, color = lockColor }
                    }, self.id .. "_COLUMNS.CAR")
                }
            }
        self.var.columnsPadding::reset()
    })
})
