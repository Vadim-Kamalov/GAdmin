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

@import "game.Admins"       => admins
@import "game.User"         => user
@import "game.Spectator"    => spectator
@import "game.samp.Player"  => player
@import "game.GReport"      => greport

@import "Assets"            => assets
@import "CommandRequester"  => commandRequester
@import "Config"            => config

static loggedServerMessages = {
    { "IC чат/действия", {} },
    { "OOC чат", {} },
    { "Действия/чат администраторов", {} }
}

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
        { "^%(%( PM [отк] %w+.*%[%d+]: .* %)%)$", -3342081 }    // /pm (to/from)
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
        { "^%[GBUY] [A-Za-z0-9]%[%d+] создал объвление %[%d+]: ", -1697828182 },                // GBUY advertisement creation
        { "^%.%.%. ", -1697828182 },                                                            // /pame (ped description/car description/gossip/GBUY ad) continuation
        { "^Администратор .+ .+%.Причина: ", -10270806 },                                       // /ban | /mute | /kick | /bmute | /warn
        { "^Администратор .+ установил <Player Kill> персонажу .+%.$", -10270806 },             // /pk
        { "^Администратор .+ установил <Character Kill> персонажу .+%.$", -10270806 },          // /ck
    }}
}

sampev.onServerMessage = fn(color, text) {
    local text = u8($)

    for sectionIndex, section in logs {
        local log = {
            time = assets::getLocalTime()
            text = text
        }

        for _, item in section[2] {
            if type(item) == "table" {
                if string.find(text, item[1]) && color == item[2] {
                    table.insert(loggedServerMessages[sectionIndex][2], log)
                    break
                }
            } else {
                if string.find(text, item) {
                    table.insert(loggedServerMessages[sectionIndex][2], log)
                    break
                }
            }
        }
    }

    commandRequester::setupChatWatcher(text, color)
    greport::setupChatWatcher(text)

    local fn compare(pattern, clr) {
        return (pattern && color) ? string.find(text, pattern) && color == clr :
               (pattern) ? string.find(text, pattern) :
               (color) ? color == clr :
               false
    }

    local fn rgb2color(rgb) {
        return rgb && bit.tobit(tonumber(string.format("%s%02X", rgb, color & 0xFF), 16))
    }

    if string.find(text, "^(%w+.*) говорит:(.*)") && config.root.additions.displayIdInIc.use {
        local nickname, message = string.match(text, "^(%w+.*) говорит:(.*)")
        
        nickname = string.gsub(nickname, " ", "_")
        text = nickname .. "[" .. player::getIdByNickname(nickname) .. "]" .. " говорит:" .. message
    }

    if string.find(text, "^%[A%] .*%[%d+%]: %S+") && color == 866792362 && config.root.additions.mention.use {
        local possibleMention = string.match(text, "^%[A%] .*%[%d+]: (%S+)")

        for _, pattern in ({
            "^(%d+),",
            "^@(%d+)",
            "^(%d+)$",
            "^@(%d+)$"
        }) {
            if tonumber(string.match(possibleMention, pattern)) == user::getId() {
                color = rgb2color(config.root.additions.mention.color)
            }
        }
    }

    if config.root.additions.hideIpAddresses.use {
        text = string.gsub($, "%[%d+%.%d+%.%d+%.%d+%]", "[XXX.XXX.XXX.XXX]")
    }

    if string.find(text, "^%[A%] .*%[%d+%] авторизовался как администратор %d+ уровня%.$") {
@ifdef __GADMIN_DEBUG__
{
        $debugInformation!("onServerMessage", "found connected administrator")
}

        local oocNickname, adminId, adminLvl = string.match(text, "^%[A%] (.*)%[(%d+)%] авторизовался как администратор (%d+) уровня%.$")
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
    } elseif string.find(text, "^%[A%] .*%[%d+%] вышел как администратор%.$") {
        local adminId = tonumber(string.match(text, "^%[A%] .*%[(%d+)%] вышел как администратор%.$"))
    
        if adminId == user::getId() {
            user::setAloginStatus(false)
            checkedAdminList = false
        }

        for index, data in admins {
            if data.id == adminId {
@ifdef __GADMIN_DEBUG__
{
                $debugSuccessful!("onServerMessage", "removed disconnected administrator from `admins` table") 
}
                admins::remove(index)
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

    if string.find(text, "Вы успешно авторизовались как администратор") || string.find(text, "%|.*Вы уже авторизировались") && color == -1 {
        lua_thread.create(fn {
            wait($COMMAND_DELAY)
            sampSendChat("/adm")
        })
    }

    if string.find(text, "^%[A%] " .. user::getOOCNickname() .. "%[%d+%] ответил .*%[%d+%]: .*") {
        user::incrementAnswersCount()
    }

    for _, data in config.root.chat.changeColor {
        if compare(data.pattern, rgb2color(data.colors.old)) {
            color = rgb2color(data.colors.new)
            break
        }
    }
    
    for _, data in config.root.chat.remove {
        if compare(data.pattern, rgb2color(data.color)) {
            return false
        }
    }

    return { color, u8::decode(text) }
}
