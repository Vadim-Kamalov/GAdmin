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

@import "game.sa.Ped"       => ped
@import "game.Spectator"    => spectator
@import "game.GReport"      => greport
@import "game.User"         => user

@macro NEW_VARIABLE(name, description, callback) {
    table.insert(variables.order, $name)
    variables.description[$name]    = $description
    variables[$name]                = $callback
}

@macro SPECTATOR_INFORMATION_HELPER(keyUpper, key, name) {
    $NEW_VARIABLE!("SPECTATOR_" .. $keyUpper, $name .. " игрока за которым вы следите", (fn {
        if spectator.status {
            return tostring(spectator::getInformation().$key)
        }
    }))
}

@macro GREPORT_HELPER(keyUpper, key, name) {
    $NEW_VARIABLE!("GREPORT_" .. $keyUpper, $name .. " игрока за которым закреплен GReport", (fn {
        if greport.player.active {
            return tostring(greport.player.$key)
        }
    }))
}

@macro USER_HELPER(keyUpper, key, description) {
    $NEW_VARIABLE!("USER_" .. $keyUpper, $description, (fn {
        if local it = user::$key() {
            return match type(it) {
                "boolean" => ((it) ? "+" : "-")
                default => tostring(it)
            }
        }
    }))
}

local variables = { description = {}, order = {} }

$NEW_VARIABLE!("CLOSEST_PLAYER_ID", "ID ближайшего игрока к вам/игроку за которым вы следите", (fn {
    if local handle = ped::getClosestHandle((spectator.status) ? spectator.id : PLAYER_PED) {
        return select(2, sampGetPlayerIdByCharHandle(handle))
    }
}))

$NEW_VARIABLE!("CLOSEST_PLAYER_NICKNAME", "Никнейм ближайшего игрока к вам/игроку за которым вы следите", (fn {
    if local handle = ped::getClosestHandle((spectator.status) ? spectator.id : PLAYER_PED) {
        local _, id = sampGetPlayerIdByCharHandle(handle)
        return sampGetPlayerNickname(id)
    }
}))

$NEW_VARIABLE!("SPECTATOR_ID", "ID игрока за которым вы следите", (fn {
    if spectator.status {
        return spectator.id
    }
}))

$NEW_VARIABLE!("SPECTATOR_NICKNAME", "Никнейм игрока за которым вы следите", (fn {
    if spectator.status {
        return spectator.nickname
    }
}))

$NEW_VARIABLE!("GREPORT_ACTIVE_TIME", "Активное время (МИН:CЕК) полученного GReport'а", (fn {
    return greport.player::getActiveTime()
}))

$NEW_VARIABLE!("SPECTATOR_VEHICLE_ID", "ID машины (из /dl) игрока за которым вы следите", (fn {
    if spectator.status {
        local result, handle = spectator::getHandle()
        if isCharInAnyCar(handle) && result {
            if local car = storeCarCharIsInNoSave(handle) {
                local result, vehId = sampGetVehicleIdByCarHandle(car)
                return (result) ? vehId : nil
            }
        }
    }
}))

$SPECTATOR_INFORMATION_HELPER!("PLATFORM", platform, "Платформа")
$SPECTATOR_INFORMATION_HELPER!("ARMOR", armor, "Броня")
$SPECTATOR_INFORMATION_HELPER!("PING", ping, "Пинг")
$SPECTATOR_INFORMATION_HELPER!("WEAPON", weapon, "Оружие")
$SPECTATOR_INFORMATION_HELPER!("ACCOUNT_ID", accountId, "ID аккаунта")
$SPECTATOR_INFORMATION_HELPER!("HEALTH", health, "Пинг")
$SPECTATOR_INFORMATION_HELPER!("MONEY", money, "Деньги на руках")
$SPECTATOR_INFORMATION_HELPER!("BANK", bank, "Деньги в банке")
$SPECTATOR_INFORMATION_HELPER!("FRACTION", fraction, "Фракция")
$SPECTATOR_INFORMATION_HELPER!("RANG", rang, "Должность")
$SPECTATOR_INFORMATION_HELPER!("ALL_VEHICLES", vehicle, "Машина(-ы)")
$SPECTATOR_INFORMATION_HELPER!("ALL_HOUSES", house, "Дом(а)")
$SPECTATOR_INFORMATION_HELPER!("VIP", vip, "VIP cтатус")
$SPECTATOR_INFORMATION_HELPER!("REGISTRATION_DATE", regDate, "Дата регистрации")
$SPECTATOR_INFORMATION_HELPER!("WARNINGS", warnings, "Количество предупреждений")
$SPECTATOR_INFORMATION_HELPER!("STAGE", stage, "Стадия")
$SPECTATOR_INFORMATION_HELPER!("AFK_TIME", afkTime, "Время в AFK")
$SPECTATOR_INFORMATION_HELPER!("CURRENT_MOVE_SPEED", moveSpeed.current, "Текущая скорость")
$SPECTATOR_INFORMATION_HELPER!("MAX_MOVE_SPEED", moveSpeed.max, "Максимальная скорость")
$SPECTATOR_INFORMATION_HELPER!("TOTAL_SHOTS", shot.total, "Количество выстрелов")
$SPECTATOR_INFORMATION_HELPER!("HITS", shot.hit, "Количество попаданий")

$GREPORT_HELPER!("SENDER_ID", id, "ID")
$GREPORT_HELPER!("SENDER_NICKNAME", nickname, "Никнейм")
$GREPORT_HELPER!("QUESTION", context, "Вопрос")

$USER_HELPER!("ALOGIN_STATE", getAloginStatus, "Статус /alogin (+ ИЛИ -)")
$USER_HELPER!("ID", getId, "Ваш ID")
$USER_HELPER!("NICKNAME", getNickname, "Ваш IC никнейм")
$USER_HELPER!("PING", getPing, "Ваш пинг")
$USER_HELPER!("OOC_NICKNAME", getOOCNickname, "Ваш OOC никнейм (если еще не получен, вернет \"Администратор\")")
$USER_HELPER!("ADMIN_LVL", getAdminLvl, "Ваш уровень администрирования (если еще не получен, вернет \"-1\")")

return variables
