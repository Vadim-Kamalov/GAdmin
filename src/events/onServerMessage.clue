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

@import "game.Admins"      => admins
@import "game.User"        => user
@import "game.Spectator"   => spectator
@import "game.samp.Player" => player
@import "game.GReport"     => greport

@import "Common"           => common
@import "Assets"           => assets
@import "CommandRequester" => commandRequester
@import "Config"           => config
@import "Notifications"    => notify
@import "Icons"            => icons

local logs = {
    { "IC чат/действия", {
        "^%w+.*говорит:",
        "^%w+.*кричит:",                        // /s
        "^%w+.*шепчет:",                        // /w
        { "^%w+", -413892353 },                 // /me
        { "%- сказал.+%w+.*, ", -413892353 },   // /todo
        " %%(%( .* %)%)$"                       // /do
    }},

    { "OOC чат", {
        "^%(%( %w+.*%[%d+]: .* %)%)$",                          // /b
        { "^%(%( PM [отк] %w+.*%[%d+]: .* %)%)$", -3342081 },   // /pm (to/from)
        "^%(%( %w+.*%[%d+]: .*%.%.%.$",                         // long /b start
        "^%.%.%. .*%)%)$", -1                                   // long /b end
    }},

    { "Действия/чаты администраторов", {
        { "^%[A] .*%[%d+] ответил .+%[%d+]:", -6732374 },                                       // /ans
        { "^%[A] .*%[%d+] вылечил .+%[%d+]%.$", -1347440726 },                                  // /heal
        { "^%[A] .*%[%d+] подкинул .+%[%d+]%.$", -1347440726 },                                 // /slap
        { "^%[A] .*%[%d+]:? ", 866792362 },                                                     // /a | actions in /a
        { "^%[A] .*%[%d+] взялся за обработку репорта от игрока .+%[%d+]%.$", -1347440726 },    // /grep(ort) was taked by administrator
        { "^%[A] .+%[%d+] перевёл деньги через банк .+%[%d+] %- %$%d+$", -1347440726 },         // money bank-transaction
        { "^%[A] .+%[%d+] передал деньги .+%[%d+] %- %$%d+$", -1347440726 },                    // /pay
        { "^%[A] .*%[%d+] удалил репорт от игрока .+%[%d+]%.$", -1347440726 },                  // /grep(ort) was removed by administrator
        { "^%[A] .+%[%d+] нарисовал граффити%. MysqlID: %d+$", -65366 },                        // /graffiti
        { "^%[A] .*%[%d+] починил машину с ID: %d+%.$", -1347440726 },                          // /vr(epair)
        { "^%[A] .+%[%d+] установил описание: ", -1697828182 },                                 // /pame (ped description)
        { "^%[A] .+%[%d+] установил описание авто: ", -1697828182 },                            // /pame (car description)
        { "^%[A] .+%[%d+] установил слухи: ", -1697828182 },                                    // /pame (gossip)
        { "^%[GBUY] .+%[%d+] создал объявление %[%d+]: ", -1697828182 },                        // GBUY advertisement creation
        { "^%[A] .+%[%d+] установил действие: ", -1697828182 },                                 // /action
        { "^Администратор .+%.Причина: ", -10270806 },                                          // /ban | /mute | /kick | /bmute | /warn
        { "^Администратор .+ установил <Player Kill> персонажу .+%.$", -10270806 },             // /pk
        { "^Администратор .+ установил <Character Kill> персонажу .+%.$", -10270806 },          // /ck
        "^%[A] Жалоба от .+%[%d+]:",                                                            // /rep
        "^%[A] Репорт от .+%[%d+]:"                                                             // /rep
    }}
}

local skipNextMessage     = false
local adminListCheckClock = os.clock() - $COMMAND_DELAY

local unwrapStarted  = false
local unwrapFinished = false
local unwrappedText  = ""

local messageContinuation = {
    awaiting = false,
    color    = nil,
    new      = nil
}

sampev.onServerMessage = fn(color, text) {
    local text     = u8($)
    local pureText = string.gsub(text, "{%x%x%x%x%x%x}", "")
    
    local fn rgb2color(rgb) {
        return rgb && bit.tobit(tonumber(string.format("%s%02X", rgb, color & 0xFF), 16))
    }

    if string.find(text, "^%.%.%. ") && messageContinuation.awaiting && messageContinuation.color == color {
        color                        = rgb2color(messageContinuation.new)
        messageContinuation.awaiting = false
        messageContinuation.color    = nil
    }

    if local otherA = string.match(pureText, "^%.%.%. (.+)") {
        if local otherB, dots = string.match(pureText, "^%.%.%. (.+ )(%.+)$") {
            if #dots == 2 || #dots == 3 {
                unwrappedText ..= otherB
            }
        } else {
            unwrapStarted   = false
            unwrapFinished  = true
            unwrappedText ..= otherA
        }
    } elseif unwrapStarted {
        unwrapStarted  = false
        unwrapFinished = false
        unwrappedText  = ""
    }

    if local dots = string.match(pureText, "(%.+)$") {
        if #dots == 2 || #dots == 3 && !unwrapStarted {
            unwrappedText = string.sub(pureText, 1, #pureText - #dots)
            unwrapStarted = true
        }
    }

    // If previous string(s) was(were) wrapped then this variable will store
    // unwrapped string. Otherwise it will store `text` argument. In both cases
    // tags `{RRGGBB}` in string will be removed. 
    //
    //! Don't return anything after using this variable (string.find, string.match)!
    local safeText = pureText

    if unwrapFinished && !unwrapStarted {
        safeText       = unwrappedText
        unwrapStarted  = false
        unwrapFinished = false
        unwrappedText  = ""
    } elseif unwrapStarted {
        safeText = ""
    }

    if messageContinuation.awaiting && messageContinuation.color == color
       && unwrapFinished && !unwrapStarted
    {
        color                        = rgb2color(messageContinuation.new)
        messageContinuation.awaiting = false
        messageContinuation.color    = nil
    }

    for sectionIndex, section in logs {
        local log = {
            time = assets::getLocalTime()
            text = safeText
        }

        for _, item in section[2] {
            if type(item) == "table" {
                if string.find(safeText, item[1]) && color == item[2] {
                    table.insert(allowedLogs[sectionIndex][2], log)
                    break
                }
            } else {
                if string.find(safeText, item) {
                    table.insert(allowedLogs[sectionIndex][2], log)
                    break
                }
            }
        }
    }

    commandRequester::setupChatWatcher(safeText, color)
    greport::setupChatWatcher(safeText)

    local fn compare(pattern, clr) {
        return (pattern && color) ? string.find(text, pattern) && color == clr :
               (pattern) ? string.find(text, pattern) :
               (color) ? color == clr :
               false
    }

    if ((string.find(text, "^%w+.* ") && color == -413892353) || string.find(text, "^%w+.* говорит:"))
       && config.root.additions.displayIdInIc.use
    {
        if local nickname, other = string.match(text, "^([%w ]+) (.*)") {
            if local id = player::getIdByNickname(string.gsub(nickname, " ", "_")) {
                text = string.format("%s[%d] %s", nickname, id, other)
            }
        }
    }

    if config.root.additions.reportOneColor.use {
        if string.find(text, "^%[A] Жалоба от .+%[%d+]:") || string.find(text, "^%[A] Репорт от .+%[%d+]:") {
            if local dots = string.match(text, "(%.+)$") {
                if #dots == 2 || #dots == 3 {
                    messageContinuation.awaiting = true
                    messageContinuation.color    = color
                    messageContinuation.new      = config.root.additions.reportOneColor.color
                }
            }
            color = rgb2color(config.root.additions.reportOneColor.color)
        }
    }

    if text == "Вы были отсоединены от сервера за неправильный пароль администрирования." &&
       config.root.additions.autoLogin.use && #config.root.additions.autoLogin.aloginPassword >= 3
    {
        config.root.additions.autoLogin.aloginPassword = ""
        common::sendScriptMessage("Вы ввели неверный пароль в настройках для авто-ввода. Пароль был сброшен.")
    }

    if string.find(text, "^%[A%] %S+%[%d+%]: %S+") && color == 866792362 && config.root.additions.mention.use {
        local mentionStarter, possibleMention   = string.match(text, "^%[A%] (%S+)%[%d+]: (%S+)")
        local replacedColor                     = false

        for index, pattern in ({
            "^(%d+),",
            "^@(%d+)",
            "^(%d+)$",
            "^@(%d+)$"
            "^(.+),",
            "^@(.+)",
            "^(.+)$",
            "^@(.+)$"
        }) {
            if index <= 4 {
                if tonumber(string.match(possibleMention, pattern)) == user::getId() {
                    color           = rgb2color(config.root.additions.mention.color)
                    replacedColor   = true
                }
            } else {
                if local nickname = string.match(possibleMention, pattern) {
                    if string.lower(nickname) == string.lower(user::getOOCNickname()) {
                        color           = rgb2color(config.root.additions.mention.color)
                        replacedColor   = true
                    }
                } elseif possibleMention == "all" {
                    color = rgb2color(config.root.additions.mention.color)
                    if mentionStarter != user::getOOCNickname() {
                        replacedColor = true
                    }
                }
            }

            if replacedColor {
                if config.root.additions.mention.soundNotification {
                    addOneOffSound(0, 0, 0, 1137)
                }

                if local dots = string.match(text, "(%.+)$") {
                    if #dots == 2 || #dots == 3 {
                        messageContinuation.awaiting = true
                        messageContinuation.color    = color
                        messageContinuation.new      = config.root.additions.mention.color
                    }
                }

                if local notificationType = config.root.additions.mention.notificationType {
                    if notificationType != NOTIFICATION_TYPE_NONE {
                        notify::send({
                            title   = "Вас упомянули в /a чате",
                            text    = "Вас упомянул " .. mentionStarter .. ". Сообщение выделено в чате.",
                            icon    = icons.ICON_PEOPLE
                        }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? mentionStarter .. " вас упомянул в /a чате." : nil)
                    }
                }

                break
            }
        }
    }

    if config.root.additions.hideIpAddresses.use {
        text = string.gsub($, "%d+%.%d+%.%d+%.%d+", "XXX.XXX.XXX.XXX")
    }

    if string.find(safeText, "^%[A%] %S+%[%d+%] авторизовался как администратор %d+ уровня%.$") {
@ifdef __GADMIN_DEBUG__
{
        $debugInformation!("onServerMessage", "found connected administrator")
}

        local oocNickname, adminId, adminLvl = string.match(safeText, "^%[A%] (%S+)%[(%d+)%] авторизовался как администратор (%d+) уровня%.$")
        local connectionPassed = true

        for _, data in admins {
            if data.nickname.ooc == oocNickname {
                connectionPassed = false
                break
            }
        }
       
@ifdef __GADMIN_DEBUG__
{
        $debugInformation!("onServerMessage", "connectionPassed: " .. tostring(connectionPassed))
}
        
        if connectionPassed {
            admins::insert({
                id  = tonumber(adminId),
                lvl = tonumber(adminLvl),
                
                nickname = {
                    ooc = oocNickname,
                    ic  = sampGetPlayerNickname(tonumber(adminId))
                }
            })
        }
    } elseif string.find(safeText, "^%[A%] %S+%[%d+%] вышел как администратор%.$") {
        local adminId = tonumber(string.match(safeText, "^%[A%] %S+%[(%d+)%] вышел как администратор%.$"))
    
        if adminId == user::getId() {
            user::setAloginStatus(false)
            checkedAdminList = false
        }

        for index, data in admins {
            if data.id == adminId {
                admins::remove(index)
                break
            }
        }
    }

    if string.find(text, "^{FFFF00}%| {ffffff}За сессию администратирования вы заработали {4a86b6}%d+ {FFFFFF}GMoney%.$")
       && user::getAloginStatus()
    {
        user::setAloginStatus(false)
        checkedAdminList = false

        for index, data in admins {
            if data.id == user::getId() {
                admins::remove(index)
                break
            }
        }
    }

    if string.find(text, "Игрок не AFK!") && spectator.afk.awaiting.message {
        spectator.afk.awaiting.message = false
        return false
    }

    if spectator.afk.awaiting.message && string.find(text, "^.+%-%s+%d+$") {
        spectator.afk.time              = tonumber(string.match(text, "^.+%-%s+(%d+)$"))
        spectator.afk.clock             = os.clock()
        spectator.afk.awaiting.message  = false
        return false
    }

    if (string.find(text, "Вы успешно авторизовались как администратор")
        || string.find(text, "Вы уже авторизировались")
        || string.find(text, "Вы успешно авторизовались как ведущий администратор")
        || string.find(text, "Вы успешно авторизовались как разработчик")) && color == -1
    {
        if os.clock() - adminListCheckClock >= $COMMAND_DELAY {
            lua_thread.create(fn {
                wait($COMMAND_DELAY)
                sampSendChat("/adm")
            })
        
            if config.root.additions.autoAlogout.use {
                assets::workInBackground(true)
            }
        }
    }

    if string.match(safeText, "^%[A%] (%S+)%[%d+%] ответил %S+%[%d+%]: .*") == user::getOOCNickname() {
        user::incrementAnswersCount()
    }

    for _, data in config.root.chat.changeColor {
        if compare(data.pattern, rgb2color(data.colors.old)) {
            color = rgb2color(data.colors.new)
            break
        }
    }

    if config.root.additions.disableServerMessages.use {
        if skipNextMessage {
            if local dots = string.match(text, " (%.+)$") {
                if #dots == 2 || #dots == 3 {
                    return false
                }
            } else {
                skipNextMessage = false
                return false
            }
        }

        for key, value of ({
            anticheat       = { "^Античит", "^%[BOT DETECTOR]" },
            complaints      = { "^%[A] Жалоба от .+%[%d+]:" },
            questions       = { "^%[A] Репорт от .+%[%d+]:" },
            adminActions    = -1347440726,
            punishments     = {
                "^Администратор .+%. Причина:",
                "^Администратор .+ установил <Player Kill> персонажу .+%.$",
                "^Администратор .+ установил <Character Kill> персонажу .+%.$"
            },

            playerActions = {
                "^%[A] .+%[%d+] нарисовал граффити%. MysqlID: %d+$",
                "^%[A] .+%[%d+] установил описание: ",
                "^%[A] .+%[%d+] установил описание авто: ",
                "^%[GBUY] .*%[%d+] создал объявление %[%d+]: ",
                "^%[A] .+%[%d+] установил слухи: ",
                "^%[A] .+%[%d+] установил действие: ",
                "^%[A] .+%[%d+] перевёл деньги ",
                "^%[A] .+%[%d+] передал деньги"
            }
        }) {
            if config.root.additions.disableServerMessages[key] {
                if type(value) == "number" && color == value {
                    return false
                } elseif type(value) == "table" {
                    for _, patternOrColor in value {
                        if string.find(text, patternOrColor) {
                            if local dots = string.match(text, " (%.+)$") {
                                if #dots == 2 || #dots == 3 {
                                    skipNextMessage = true
                                }
                            }

                            return false
                        }
                    }
                }
            }
        }
    }

    if config.root.additions.changeNicknameColors.use {
        if string.find(text, "^%[A%] %S+%[%d+%]") && color == 866792362 {
            math.randomseed(os.clock())
            for _, player of nicknameColors {
                local color     = bit.tohex(player.colors[math.random(#player.colors)], 6)
                local find      = string.format("(%s)", player.nickname)
                local replace   = "{" .. color .. "}%1{33AA33}" 
                text            = string.gsub($, find, replace)
            }
        }
    }
    
    for _, data in config.root.chat.remove {
        if compare(data.pattern, rgb2color(data.color)) {
            return false
        }
    }

    return { color, u8::decode(text) }
}
