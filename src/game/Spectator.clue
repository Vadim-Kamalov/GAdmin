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

global enum {
    PLATFORM_AWAITING_OR_NONE,
    PLATFORM_PC,
    PLATFORM_ANDROID,
}

static __spectator__ = {
    id          = -1
    nickname    = ""
    
    platform    = PLATFORM_AWAITING_OR_NONE
    status      = true

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
        platform    = self.platform
        ping        = sampGetPlayerPing(self.id)
        weapon      = ped::getPlayerWeaponNameById(self.id)
        accountId   = self.information.accountId
        health      = self.information.health
        statsId     = self.information.statsId
        money       = self.information.money
        bank        = self.information.bank
        fraction    = self.information.fraction
        vehicle     = self.information.vehicle
        house       = self.information.house
        vip         = self.information.vip
        regDate     = self.information.regDate
        warnings    = self.information.warnings
        stage       = self.information.stage
        moveSpeed   = {
            current = self.information.moveSpeedCurrent
            max     = self.information.moveSpeedMax
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
 * Go in to spectator to a specific player.
 *
 * @param playerId number   The player id that user should spectate to.
 * @param useDelay boolean  Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method __spectator__::setTo(playerId) {
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
