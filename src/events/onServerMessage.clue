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
@import "game.Spectator"    => spectator
@import "Config"            => config
@import "game.samp.Player"  => player

sampev.onServerMessage = fn(color, text) {
    local text = u8($)

    local fn compare(pattern, clr) {
        return (pattern && color) ? string.find(text, pattern) && color == clr :
               (pattern) ? string.find(text, pattern) :
               (color) ? color == clr :
               false
    }

    local fn rgb2color(rgb) {
        return rgb && bit.tobit(tonumber(string.format("%s%02X", rgb, color & 0xFF)), 16))
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
    if string.find(text, "^(%w+.*) говорит:(.*)") && config.root.additions.displayIdInIc.use {
        local nickname, message = string.match(text, "^(%w+.*) говорит:(.*)")
        
        nickname = string.gsub(nickname, " ", "_")
        text = nickname .. "[" .. player::getIdByNickname(nickname) .. "]" .. " говорит:" .. message
    }
    if string.find(text, "^%[A%] .*%[%d+%] авторизовался как администратор %d+ уровня%.$") {
        @ifdef __GADMIN_DEBUG__ { $debugInformation!("onServerMessage", "found connected administrator") }

        local oocNickname, adminId, adminLvl = string.match(text, "^%[A%] (.*)%[(%d+)%] авторизовался как администратор (%d+) уровня%.$")
        local connectionPassed = true

        for _, data in admins {
            if data.nickname.ooc == oocNickname {
                connectionPassed = false
                break
            }
        }
       
        @ifdef __GADMIN_DEBUG__ { $debugInformation!("onServerMessage", "connectionPassed: " .. tostring(connectionPassed)) }
        
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
        for index, data in admins {
            if data.id == adminId {
                @ifdef __GADMIN_DEBUG__ { $debugSuccessful!("onServerMessage", "removed disconnected administrator from `admins` table") }
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

    return { color, u8::decode(text) }
}
