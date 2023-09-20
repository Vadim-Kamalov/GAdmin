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

@import "game.sa.Ped" => ped

global enum /* SPECTATOR_MENU */ {
    SPECTATOR_MENU_NEXT     = 0,
    SPECTATOR_MENU_SWITCH   = 1,
    SPECTATOR_MENU_BACK     = 2,
    SPECTATOR_MENU_STATS    = 3,
    SPECTATOR_MENU_SESSIONS = 4,
    SPECTATOR_MENU_FRISK    = 5,
    SPECTATOR_MENU_EXIT     = 6
}

global enum /* PLATFORM */ {
    PLATFORM_AWAITING_OR_NONE,
    PLATFORM_PC,
    PLATFORM_ANDROID,
}

static __spectator__ = {
    id          = -1
    nickname    = ""
    handle      = -1
    time        = nil

    afk = {
        thread  = nil
        time    = 0
        clock   = -1 
        awaiting = {
            message = false
        }
    }

    platform    = PLATFORM_AWAITING_OR_NONE
    status      = false

    stats = {
        lastChecked = os.clock()
        checking = false
    }

    textDrawId  = nil
    information = {}
}

/**
 * @return table User information in spectator.
 */
method __spectator__::getInformation() {
    return {
        platform    = self.platform || "N/A"
        armor       = (self.id != -1) ? sampGetPlayerArmor(self.id) : 0
        ping        = (self.id != -1) ? sampGetPlayerPing(self.id) : 0
        weapon      = ped::getPlayerWeaponNameById(self.id) || "N/A"
        accountId   = self.information.accountId || "N/A"
        health      = self.information.health || "N/A"
        statsId     = self.information.statsId || "N/A"
        money       = self.information.money || "N/A"
        bank        = self.information.bank || "N/A"
        fraction    = self.information.fraction || "N/A"
        rang        = self.information.rang || "N/A"
        vehicle     = self.information.vehicle || "N/A"
        house       = self.information.house || "N/A"
        vip         = self.information.vip || "N/A"
        regDate     = self.information.regDate || "N/A"
        warnings    = self.information.warnings || "N/A"
        stage       = self.information.stage || "N/A"
        afkTime     = self.afk.time || "N/A"

        moveSpeed = {
            current = self.information.moveSpeedCurrent || "N/A"
            max     = self.information.moveSpeedMax || "N/A"
        }

        shot = {
            total   = self.information.shotTotal || "0"
            hit     = self.information.shotHit || "0"
        }
    }
}

/**
 * @param information table Set user information in spectator.
 * @return void
 */
method __spectator__::setInformation(information = {}) {
    for key, value of information {
        self.information[key] = value
    }
}

/**
 * Get platform of spectator as string.
 * @return string
 */
method __spectator__::platformToString() {
    return match self.platform {
        PLATFORM_PC     => "PC",
        PLATFORM_MOBILE => "MOBILE",
        default         => "N/A"
    }
}

/**
 * Get active time from time where self.active was set to true.
 * @return string Time as MM:SS.
 */
method __spectator__::getActiveTime() {
    if self.time {
        local time      = os.date("*t")
        local minutes   = math.floor((time.min - self.time.min + 60) % 60)
        local seconds   = math.floor((time.sec - self.time.sec) % 60)
        return string.format("%02d:%02d", minutes, seconds)
    } else {
        return "00:00"
    }
}

/**
 * Get handle of spectating player.
 * @return boolean, number
 */
method __spectator__::getHandle() {
    return sampGetCharHandleBySampPlayerId(self.id)
}

/**
 * Go in to spectator to a specific player.
 *
 * @param playerId number   The player id that user should spectate to.
 * @param useDelay boolean  Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method __spectator__::setTo(playerId) {
    if playerId {
        self.status     = true
        if self.id != playerId || !self.time { self.time = os.date("*t") }
        self.id         = playerId
        self.nickname   = sampGetPlayerNickname(playerId)

        if tonumber(self.information.statsId) != self.id
           && os.clock() - self.stats.lastChecked > 1
           && !sampIsDialogActive() && !self.stats.checking
        {
            sampSendMenuSelectRow(3)
            self.stats.checking         = true
            self.stats.lastChecked      = os.clock()
            self.afk.time               = 0

            if !self.afk.awaiting.message {
                lua_thread.create(fn {
                    wait($COMMAND_DELAY)
                    self.afk.awaiting.message = true
                    sampSendChat(string.format("/afk %d", self.id))
                })
            }
        }
    }
}

/**
 * Get out of spectating a player. spectator.nickname will not changed.
 * 
 * @param useDefault boolean Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method __spectator__::exit() {
    self.status         = false
    self.time           = nil
    self.id             = -1
    self.platform       = PLATFORM_AWAITING_OR_NONE
    self.information    = {}
}

return __spectator__
