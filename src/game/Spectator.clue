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
        ping        = (self.id != -1) ? sampGetPlayerPing(self.id) : 0
        weapon      = ped::getPlayerWeaponNameById(self.id) || "N/A"
        accountId   = self.information.accountId || "N/A"
        health      = self.information.health || "N/A"
        statsId     = self.information.statsId || "N/A"
        money       = self.information.money || "N/A"
        bank        = self.information.bank || "N/A"
        fraction    = self.information.fraction || "N/A"
        vehicle     = self.information.vehicle || "N/A"
        house       = self.information.house || "N/A"
        vip         = self.information.vip || "N/A"
        regDate     = self.information.regDate || "N/A"
        warnings    = self.information.warnings || "N/A"
        stage       = self.information.stage || "N/A"
        moveSpeed   = {
            current = self.information.moveSpeedCurrent || "N/A"
            max     = self.information.moveSpeedMax || "N/A"
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
 * Go in to spectator to a specific player.
 *
 * @param playerId number   The player id that user should spectate to.
 * @param useDelay boolean  Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method __spectator__::setTo(playerId) {
    if playerId {
        self.status     = true
        self.id         = playerId
        self.nickname   = sampGetPlayerNickname(playerId)

        if tonumber(self.information.statsId) != self.id
           && os.clock() - self.stats.lastChecked > 1
           && !sampIsDialogActive() && !self.stats.checking
        {
            sampSendMenuSelectRow(3)
            self.stats.checking     = true
            self.stats.lastChecked  = os.clock()
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
    self.id             = -1
    self.platform       = PLATFORM_AWAITING_OR_NONE
    self.information    = {}
}

return __spectator__
