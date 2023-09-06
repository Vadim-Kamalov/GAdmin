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

@import "Config" => config

static __user__ = { alogin = false }

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
    return sampGetPlayerIdByNickname(self::getId())
}

/**
 * @return string User in-game OOC nickname.
 */
method __user__::getOOCNickname() {
    return config.root.user.oocNickname
}

/**
 * Set OOC nickname and save it in to configuration file.
 * @return void
 */
method __user__::setOOCNickname(nickname) {
    config.root.user.oocNickname = nickname
}

return __user__
