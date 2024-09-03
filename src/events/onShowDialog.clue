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

@import "game.User"      => user
@import "game.Admins"    => admins
@import "game.Spectator" => spectator
@import "game.GReport"   => greport

@import "Config" => config
@import "Common" => common

static checkedAdminList = false

user::addOnAloginCallback("resetCheckedAdminListVar", fn (state) {
    if !state {
        checkedAdminList = false
    }
})

method sampev.onShowDialog(id, style, title, firstButton, secondButton, text) {
    title, firstButton, secondButton, text = u8($1), u8($2), u8($3), u8($4)

    greport.dialog.state = false

    if config.root.additions.hideIpAddresses.use {
        text = string.gsub($, "%d+%.%d+%.%d+%.%d+", "XXX.XXX.XXX.XXX")
    }

    if title == "Выбор персонажа" {
        user::setAloginStatus(false)
    }

    if user::getOOCNickname() != "Администратор"
       && user::getOOCNickname() != "Technical Admin"
       && string.find(text, "Авторизация.*Введите логин:")
    {
        sampSendDialogResponse(id, 1, -1, user::getOOCNickname())
        return false
    }
    
    if config.root.additions.autoLogin.use && #config.root.additions.autoLogin.accountPassword >= 3
       && style == DIALOG_STYLE_PASSWORD && string.find(text, "Для продолжения игры, Вам необходимо авторизоваться")
    {
        if string.find(text, "Попытка входа:") {
            config.root.additions.autoLogin.accountPassword = ""
            common::sendScriptMessage("Вы ввели неверный пароль в настройках для авто-ввода. Пароль был сброшен.")
        } else {
            sampSendDialogResponse(id, 1, -1, config.root.additions.autoLogin.accountPassword)
            return false
        }
    }

    if style == DIALOG_STYLE_PASSWORD && firstButton == "Далее" && secondButton == "Отмена"
       && string.find(text, "{4a86b6}Авторизация.*{FFFFFF}Введите пароль:")
       && #config.root.additions.autoLogin.aloginPassword >= 3
       && config.root.additions.autoLogin.use
    {
        sampSendDialogResponse(id, 1, -1, config.root.additions.autoLogin.aloginPassword)
        return false
    }

    if !checkedAdminList && !user::getAloginStatus() {
        if string.find(text, "Администрация в игре.*Лог отключений") {
            sampSendDialogResponse(id, 1, 0, nil)
            return false
        } elseif string.find(text, "Администраторы в сети:") {
            for line with string.gmatch(text, "[^\n]+") {
                if string.find(line, "^.*%[%d+%] %- [1-5] уровень") {
                    local oocNickname, adminId, adminLvl = string.match(line, "^{FFFFFF}(.*)%[(%d+)%] %- ([1-5]) уровень")

                    if tonumber(adminId) == user::getId() {
                        user::setOOCNickname(oocNickname)
                        user::setAdminLvl(tonumber(adminLvl))    
                    }

                    admins::insert({
                        id  = tonumber(adminId),
                        lvl = tonumber(adminLvl),

                        nickname = {
                            ooc = oocNickname,
                            ic  = icNickname
                        }
                    })

                    if user::getOOCNickname() == "Администратор" && user::getAdminLvl() == -1 {
                        user::setOOCNickname("Technical Admin")
                        user::setAdminLvl(6)
                    }
                }
            }

            user::setAloginStatus(true)
            checkedAdminList = true
            
            return false
        }
    }

    if string.find(text, "Информация о игроке") && spectator.stats.checking {
        text                = string.gsub($, "{......}", "")
        local money, bank   = string.match(text, "Деньги: ([%$%-0-9]-)\nБанк%: ([%$%-0-9]-)\n")
       
        spectator.nickname = string.match(text, "Информация о игроке (.+)%[%d+]%.")

        spectator::setInformation({
            statsId     = string.match(text, "Информация о игроке .+%[(%d+)%]")
            accountId   = string.match(text, "ID Аккаунта: (%d+)")
            money       = money
            bank        = bank
            fraction    = string.match(text, "Фракция: (.-)\n")
            rang        = string.match(text, "Должность: (.-)\n")
            vehicle     = string.match(text, "Транспорт: (.-)\n")
            house       = string.match(text, "Дом: (.-)\n")
            vip         = string.match(text, "Премиум аккаунт: (.-)\n")
            regDate     = string.match(text, "Дата регистрации: (.-)\n")
            warnings    = (string.find(text, "Предупреждения:.*%d+")) ? string.match(text, "Предупреждения:.*(%d+)") : "0"
            stage       = "0"
        })
        
        spectator.stats.checking = false

        sampSendDialogResponse(id, 0, -1, "")
        
        return false
    }

    if config.root.windows.greport.use && title == "Обработка репорта" {
        text                  = string.gsub($, "{......}", "")
        greport.player.active = true
        greport.dialog.state  = true

        if style == DIALOG_STYLE_INPUT {
            if greport.dialog.awaiting.input[1] {
                sampSendDialogResponse(id, 1, -1, greport.dialog.awaiting.input[2])
                greport.dialog.awaiting.inputs  = { false, nil }
                greport.dialog.state            = false
                
                greport.player::reset()

                // return false
            }
        }

        if string.find(text, "Дата и время репорта") {
            local nickname, id = string.match(text, "Игрок %(ID%)%: (.+) %((%d+)%)") 

            greport.player.nickname = nickname
            greport.player.id       = tonumber(id)
            greport.player.context  = string.match(text, "Описание репорта:\n(.*)\n")
            greport.window::open(false)
        } elseif string.find(text, "Перейти в режим наблюдения за игроком") {
            if greport.dialog.awaiting.options[1] {
                sampSendDialogResponse(id, 1, greport.dialog.awaiting.options[2], "")

                if greport.dialog.awaiting.options[2] == GREPORT_OPTION_TO_ADMINISTRATION {
                    greport.dialog.state            = false
                    greport.dialog.awaiting.options = { false, nil }

                    greport.player::reset()

                    return false 
                }

                greport.dialog.awaiting.options = { false, nil }
            }
        } elseif string.find(text, "Заблокировать на %d+ минут") {
            if greport.dialog.awaiting.special[1] {
                sampSendDialogResponse(id, 1, greport.dialog.awaiting.special[2], "")
               
                greport.dialog.state            = false
                greport.dialog.awaiting.special = { false, nil }
              
                greport.player::reset()

                return false
            }
        }

        greport.player.time ??= os.date("*t")

        return false
    }

    return { id, style, u8::decode(title), u8::decode(firstButton), u8::decode(secondButton), u8::decode(text) }
}
