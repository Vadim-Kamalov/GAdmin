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

@import "imgui.Assets"          => imguiAssets
@import "imgui.Windows"         => window
@import "imgui.StyleChanger"    => StyleChanger

@import "game.Spectator"    => spectator
@import "game.sa.Vehicle"   => vehicle

@import "Common" => common
@import "Config" => config

static enum /* SPECTATOR_INFORMATION_TYPE */ {
    SPECTATOR_INFORMATION_TYPE_SINGLE,
    SPECTATOR_INFORMATION_TYPE_DOUBLE
}

local sizeX, sizeY = getScreenResolution()

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
        { name = "Пинг",                value = self.information.ping, color = self.pingColor },
        { name = "ID аккаунта",         value = self.information.accountId },
        { name = "Дата регистрации",    value = self.information.regDate },
        { name = "Наличные/банк",       value = self.information.money .. " / " .. self.information.bank },
        { name = "Здоровье/броня",      value = self.information.health .. " / " .. self.information.armor },
        { name = "Фракция",             value = self.information.fraction },
        { name = "Должность",           value = self.information.rang },
        { name = "Машина(-ы)",          value = self.information.vehicle },
        { name = "Стадия",              value = self.information.stage },
        { name = "VIP статус",          value = self.information.vip },
        { name = "Предупреждения",      value = self.information.warnings },
        { name = "Время в афк",         value = self.information.afkTime },
        { name = "Тек./макс. скорость", value = self.information.moveSpeed.current .. " / " .. self.information.moveSpeed.max, color = self.speedColor },
        { name = "Выстрелы/попадания",  value = self.information.shot.total .. " / " .. self.information.shot.hit, color = self.shotColor }
    }

    self.centerWrappedColumnText = fn(text) {
        for text with string.gmatch(text, "[^\n]+") {
            imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
            imgui.TextWrapped(text)
        }
    }

    self.addColumns = fn(columnsCount, columns, id) {
        columnsCount *= 2

        imgui.Columns(columnsCount, id, true)
        for index, item in columns {
            item.color  = item.color || imgui.GetStyle().Colors[imgui.Col.Text]
            item.name   = string.gsub($, "##.*", "")
            item.value  = string.gsub($, "##.*", "")

            imgui.PushFont(bold10)
                self.centerWrappedColumnText(tostring(item.name))
            imgui.PopFont()
            imgui.NextColumn()
            imgui.PushFont(regular9)
                imgui.PushStyleColor(imgui.Col.Text, item.color)
                    self.centerWrappedColumnText(tostring(item.value))
                imgui.PopStyleColor()
            imgui.PopFont()
            imgui.NextColumn()
            
            if index % (columnsCount / 2) == 0 && index != #columns {
                imgui.Separator()
            }
        }
    }
    
    self.addMiddleTextAfterColumns = fn(text, color = imgui.GetStyle().Colors[imgui.Col.Text], ...) {
        text = string.format($, ...)

        imgui.Columns(1)
        imgui.Separator()
        imgui.SetCursorPosX(self.size.x / 2 - imgui.CalcTextSize(text).x / 2)
        imgui.TextColored(color, text)
    }

    self::begin(self.id, fn {
        imgui.BeginGroup(/* Title */)
            imguiAssets::textWithFont(spectator::getActiveTime(), bold10)
            
            imgui.SameLine()
            imgui.SetCursorPosX((self.size.x - imgui.CalcTextSize(string.format("%s[%d]", spectator.nickname, spectator.id)).x) / 2)
            imgui.BeginGroup()
                imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
                    imguiAssets::textWithFont(string.gsub(spectator.nickname, "_", " "), bold10)
                    imguiAssets::setPreviousItemAbleToCopy(spectator.nickname, "Никнейм скопирован.", string.format("Успешно скопирован никнейм: %s", spectator.nickname))

                    imgui.SameLine()

                    imguiAssets::textWithFont(string.format("[%d]", spectator.id), bold10)
                    imguiAssets::setPreviousItemAbleToCopy(spectator.id, "Айди скопирован.", string.format("Успешно скопирован айди: %d", spectator.id))
                imgui.PopStyleVar()
            imgui.EndGroup()

            imguiAssets::textWithFont(spectator::platformToString(), bold10, imgui.ImVec2(self.size.x - imgui.CalcTextSize(spectator::platformToString()).x - 10, 5))
        imgui.EndGroup()

        self.var.columnsPadding::apply()
            imgui.Separator()
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

                    imgui.Separator()
                
                    self.addColumns(config.root.windows.spectatorInformation.type, {
                        { name = "Двигатель", value = engineStatus, color = engineColor },
                        { name = "Двери", value = lockStatus, color = lockColor }
                    }, self.id .. "_COLUMNS.CAR")
                }
            }
        self.var.columnsPadding::reset()
    })
})
