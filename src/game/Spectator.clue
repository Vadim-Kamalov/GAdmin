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
@import "game.sa.Vehicle"   => vehicle
@import "game.User"         => user

@import "Assets" => assets
@import "Common" => common

global enum /** @enum SPECTATOR_MENU */ {
    SPECTATOR_MENU_NEXT = 0,
    SPECTATOR_MENU_SWITCH,
    SPECTATOR_MENU_BACK,
    SPECTATOR_MENU_STATS,
    SPECTATOR_MENU_SESSIONS,
    SPECTATOR_MENU_FRISK,
    SPECTATOR_MENU_EXIT
}

static enum /** @enum PLATFORM */ {
    PLATFORM_AWAITING_OR_NONE = 0,
    PLATFORM_PC,
    PLATFORM_ANDROID,
}

static enum /** @enum CAMERA_SWITCH_STATE */ {
    CAMERA_SWITCH_STATE_NONE,
    CAMERA_SWITCH_STATE_PLAYER,
    CAMERA_SWITCH_STATE_VEHICLE
}

static enum /** @enum SYNC_KEYS */ {
    SYNC_KEYS_PLAYER,
    SYNC_KEYS_VEHICLE,

    //! Used only when `self.platform == PLATFORM_ANDROID`, contains joy stick position
    //! by x and y.
    SYNC_KEYS_JOY_STICK
}

static __spectator__ = {
    id          = -1
    nickname    = ""
    time        = nil

    afk = {
        thread  = nil
        time    = 0
        clock   = -1 
        awaiting = {
            message = false
        }
    }

    keys = {
        [PLATFORM_PC] = {
            [SYNC_KEYS_PLAYER]      = {}
            [SYNC_KEYS_VEHICLE]     = {}
        },
        
        [PLATFORM_ANDROID] = {
            [SYNC_KEYS_PLAYER]      = {}
            [SYNC_KEYS_VEHICLE]     = {}
            [SYNC_KEYS_JOY_STICK]   = {
                new     = { x = 0, y = 0 }
                old     = { x = 0, y = 0 }
                clock   = os.clock()
            }
        }
    }

    cameraSwitchState = CAMERA_SWITCH_STATE_NONE
    platform          = PLATFORM_AWAITING_OR_NONE
    status            = false

    stats = {
        lastChecked = os.clock()
        checking    = false
    }

    textDrawId  = nil
    information = {}
}

/**
 * Callback to handle all errors due using methods in this module
 * when user is recently called /alogout.
 */
user::addOnAloginCallback("game.Spectator", fn(state) {
    if !state {
        __spectator__::exit()
    }
})

/**
 * @return table User information in spectator.
 */
method __spectator__::getInformation() {
    local result, _ = self::getHandle()
    return {
        platform    = self.platform || "N/A"
        armor       = (result) ? sampGetPlayerArmor(self.id) : 0
        ping        = (result) ? sampGetPlayerPing(self.id) : 0
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

method __spectator__::setupJoyStickWatcher(x, y) {
    if local this = self.keys[PLATFORM_ANDROID][SYNC_KEYS_JOY_STICK] { 
        if os.clock() - this.clock > 0.1 {
            this.clock = os.clock()
            this.old.x = this.new.x
            this.old.y = this.new.y
            this.new.x = (!x) ? 0 : ((x > 128) ? x - 0xFFFF : x)
            this.new.y = (!y) ? 0 : ((y > 128) ? y - 0xFFFF : y)
        }
    }
}

method __spectator__::setKeyStatus(syncType, key, status) {
    self.keys[self.platform][syncType][key] = status
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
 * Setup main loop for this module. Only for use in while-true loop!
 * @return void
 */
method __spectator__::loop() {
    if self.status {
        if sampIsPlayerPaused(self.id) {
            if os.clock() - self.afk.clock >= 1 {
                self.afk.time += 1
                self.afk.clock = os.clock()
            }
        } else {
            self.afk.time = 0
        }

        local result, handle = self::getHandle()

        if result {
            local speed = { current = 0, max = 0 }

            if isCharInAnyCar(handle) {
                if local car = storeCarCharIsInNoSave(handle) {
                    speed.current = getCarSpeed(car)
                    speed.max     = vehicle::getMaxSpeed(getCarModel(car))
                }
            } else {
                speed.current = getCharSpeed(handle)
                speed.max     = ped::getMaxSpeed(handle)
            }

            self.information.moveSpeedCurrent = math.floor(speed.current)
            self.information.moveSpeedMax     = math.floor(speed.max)
        } else {
            while !result && !common::isInputsActive() {
                sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH)
                wait(1000)

                result, handle = self::getHandle()
            }
        }
    }
}

/**
 * Get platform of spectator as string.
 * @return string
 */
method __spectator__::platformToString() {
    return match self.platform {
        PLATFORM_PC         => "PC",
        PLATFORM_ANDROID    => "MOBILE",
        default             => "N/A"
    }
}

/**
 * Get active time from time where self.active was set to true.
 * @return string Time as MM:SS.
 */
method __spectator__::getActiveTime() {
    if self.time {
        local time    = os.date("*t")
        local diff    = os.difftime(os.time(time), os.time(self.time))
        local minutes = math.floor(diff / 60)
        local seconds = diff % 60
        return string.format("%02d:%02d", minutes, seconds)
    } else {
        return "00:00"
    }
}

/**
 * Get handle of spectating player.
 * @return boolean, number|nil
 */
method __spectator__::getHandle() {
    if self.id != -1 && sampIsPlayerConnected(self.id) && self.status {
        return sampGetCharHandleBySampPlayerId(self.id)
    }

    return false, nil
}

/**
 * Go in to spectator to a specific player.
 *
 * @param playerId number|nil The player id that user should spectate to.
 * @param useDelay boolean    Use delay after sending message. By default it's false, delay taken from $COMMAND_DELAY const variable.
 * @return void
 */
method __spectator__::setTo(playerId) {
    if playerId {
        self.status = true

        if self.id != playerId || !self.time {
            self.time = os.date("*t")
        }
        
        self.id = playerId

        if tonumber(self.information.statsId) != self.id
           && os.clock() - self.stats.lastChecked > 1
           && !sampIsDialogActive() && !self.stats.checking
        {
            sampSendMenuSelectRow(3)
            self.stats.checking         = true
            self.stats.lastChecked      = os.clock()
            self.afk.time               = 0

            self.information.shotTotal  = "0"
            self.information.shotHit    = "0"

            self.cameraSwitchState = CAMERA_SWITCH_STATE_NONE
            
            self.keys = {
                [PLATFORM_PC] = {
                    [SYNC_KEYS_PLAYER]      = {}
                    [SYNC_KEYS_VEHICLE]     = {}
                },
        
                [PLATFORM_ANDROID] = {
                    [SYNC_KEYS_PLAYER]      = {}
                    [SYNC_KEYS_VEHICLE]     = {}
                    [SYNC_KEYS_JOY_STICK]   = {
                        new     = { x = 0, y = 0 }
                        old     = { x = 0, y = 0 }
                        clock   = os.clock()
                    }
                }
            }
            
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
