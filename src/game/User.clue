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

@define WEEK_NUMBER tonumber(os.date("%W")) + tonumber(os.date("%y"))

@import "Config"        => config
@import "Assets"        => assets
@import "Notifications" => notify
@import "Icons"         => icons

static __user__ = {
    alogin          = false,
    weekNumber      = tostring(tonumber(os.date("%W")) + tonumber(os.date("%y"))),
    answersCount    = 0,

    online = {
        session = 0,
        clock   = os.clock()
    }
}

/**
 * @return boolean Wheather user is logged-in as administrator.
 */
method __user__::getAloginStatus() {
    return self.alogin
}

/**
 * @param status boolean Set alogin status. Doesn't logout/login as administrator!
 * @return void
 */
method __user__::setAloginStatus(status) {
    self.alogin = status
}

/**
 * Switch alogin status. Doesn't logout/login as administrator!
 * @return void
 */
method __user__::switchAloginStatus() {
    self.alogin = !$
}

/**
 * @return number User in-game ID.
 */
method __user__::getId() {
    return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
}

/**
 * @return string User in-game IC nickname.
 */
method __user__::getNickname() {
    return sampGetPlayerNickname(self::getId())
}

/**
 * @return number User in-game ping.
 */
method __user__::getPing() {
    return sampGetPlayerPing(self::getId())
}

/**
 * @return string User in-game OOC nickname.
 */
method __user__::getOOCNickname() {
    return config.root.user.oocNickname
}

/**
 * Set OOC nickname and save it in to configuration file.
 * @param nickname string
 * @return void
 */
method __user__::setOOCNickname(nickname) {
    config.root.user.oocNickname = nickname
}

/**
 * Get user administrator lvl.
 * @return number
 */
method __user__::getAdminLvl() {
    return config.root.user.adminLvl
}

/**
 * Set administator lvl and save it in to the configuration file.
 * @param lvl number
 * @return void
 */
method __user__::setAdminLvl(lvl) {
    config.root.user.adminLvl = lvl
}

/**
 * Update user time(session, total, week). Only for use in while-true loop!
 * @return void
 */
method __user__::updateTime() {
    if os.clock() - self.online.clock >= 1 {
        self.online.clock               = os.clock()
        self.online.session             += (self::getAloginStatus()) ? 1 : 0
        config.root.user.online.total   += 1
        
        if local this = config.root.user.online.weeks {
            if this[#this] && this[#this].weekPos == $WEEK_NUMBER {
                this[#this].days[tonumber(os.date("%w")) + 1] += 1
            } else {
                table.insert(this, {
                    weekPos = $WEEK_NUMBER,
                    days    = { 0, 0, 0, 0, 0, 0, 0 }
                })
            
                this[#this].days[tonumber(os.date("%w")) + 1] += 1
            }
        }
    }
}

/**
 * Get table with time information. Each value of returned table is another table,
 * that was created by os.date("*t", ...), except `week`.
 * 
 * @return table { session = table, total = table, week = table }
 */
method __user__::getTime() {
    return {
        session     = assets::explodeDate(self.online.session)
        total       = assets::explodeDate(config.root.user.online.total)
        week        = config.root.user.online.weeks[#config.root.user.online.weeks]
        weekTotal   = (fn {
            local total = 0
            if local this = config.root.user.online.weeks[#config.root.user.online.weeks] {
                if this.weekPos == tonumber(os.date("%W")) + tonumber(os.date("%y")) {
                    for _, time in this.days {
                        total += time
                    }
                }
            }
            return assets::explodeDate(total)
        })()
    }
}

/**
 * Increment answers count/
 * @return void
 */
method __user__::incrementAnswersCount() {
    self.answersCount               += 1
    config.root.user.answers.total  += 1
    
    if local this = config.root.user.answers.weeks {
        if this[#this] && this[#this].weekPos == $WEEK_NUMBER {
            this[#this].days[tonumber(os.date("%w")) + 1] += 1
        } else {
            table.insert(this, {
                weekPos = $WEEK_NUMBER,
                days    = { 0, 0, 0, 0, 0, 0, 0 }
            })

            this[#this].days[tonumber(os.date("%w")) + 1] += 1
        }
    }
}

/**
 * Just get answers count. Returns table where all values are number.
 * @return table
 */
method __user__::getAnswersCount() {
    return {
        session     = self.answersCount
        total       = config.root.user.answers.total
        week        = config.root.user.answers.weeks[#config.root.user.answers.weeks]
        weekTotal   = (fn {
            local total = 0
            if local this = config.root.user.answers.weeks[#config.root.user.answers.weeks] {
                for _, answers in this.days {
                    total += answers
                }
            }
            return total
        })()
    }
}

/**
 * Reconnect to the server.
 *
 * @param delay number (in milliseconds, default = 5000)
 * @return void
 */
method __user__::reconnect(delay = 5000) {
    notify::send({
        title   = "Переподключение через " .. math.floor(delay / 1000) .. " секунд",
        text    = "Переподключение на сервер произойдет через " .. math.floor(delay / 1000) .. " секунд!",
        icon    = icons.ICON_BELL
    })

    sampDisconnectWithReason(quit)
    lua_thread.create(fn {
        wait(delay)
        sampSetGameState(1)
    })
}

return __user__
