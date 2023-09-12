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

@import "game.User"         => user
@import "game.Admins"       => admins
@import "game.Spectator"    => spectator
@import "Config"            => config

local checkedAdminList = false

sampev.onShowDialog = fn(id, style, title, firstButton, secondButton, text) {
    title, firstButton, secondButton, text = u8($1), u8($2), u8($3), u8($4)

    if !checkedAdminList && !user::getAloginStatus() {
        if string.find(text, "Администрация в игре.*Лог отключений") {
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        } elseif string.find(text, "Администраторы в сети:") {
            for line with string.gmatch(text, "[^\n]+") {
                if string.find(line, "^.*%[%d+%] %- [1-5] уровень") {
                    local oocNickname, adminId, adminLvl = string.match(line, "^{FFFFFF}(.*)%[(%d+)%] %- ([1-5]) уровень")
                    if tonumber(adminId) == user::getId() && user::getOOCNickname() != oocNickname {
                        config.root.user.oocNickname = oocNickname
                        config::save()
                    } else {
                        admins::insert({
                            id  = tonumber(adminId),
                            lvl = tonumber(adminLvl),

                            nickname = {
                                ooc = oocNickname,
                                ic  = icNickname
                            }
                        })
                    }
                }
            }

            checkedAdminList = true
            
            return false
        }
    }

    if string.find(text, "Информация о игроке") && spectator.stats.checking {
        text = string.gsub($, "{......}", "")
        spectator::setInformation({
            statsId     = string.match(text, "Информация о игроке .+%[(%d+)%]")
            accountId   = string.match(text, "ID Аккаунта: (%d+)")
            money, bank = string.match(text, "Деньги: (%$[%-]?%d+)\nБанк%: (%$[%-]?%d+)\n")
            fraction    = string.match(text, "Фракция: (.-)\n")
            vehicle     = string.match(text, "Транспорт: (.-)\n")
            house       = string.match(text, "Дом: (.-)\n")
            vip         = string.match(text, "Премиум аккаунт: (.-)\n")
            regDate     = string.match(text, "Дата регистрации: (.-)\n")
            warnings    = (string.find(text, "Предупреждения:.*%d+")) ? string.match(text, "Предупреждения:.*(%d+)") : "0"
            stage       = "0"
        })

        sampSendDialogResponse(id, 0, 0, "")
        spectator.stats.checking = false
        return false
    }
}
