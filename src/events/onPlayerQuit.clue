/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

@import "game.Admins"    => admins
@import "game.GReport"   => greport
@import "game.User"      => user
@import "game.Spectator" => spectator
@import "Notifications"  => notify
@import "Icons"          => icons
@import "Config"         => config
@import "Assets"         => assets

method sampev.onPlayerQuit(id) {
    local nickname = sampGetPlayerNickname(id)
    
    if config.root.windows.playerChecker.use {
        for _, player in config.root.windows.playerChecker.players {
            if player.nickname == nickname && user::getAloginStatus() {
                if local notificationType = config.root.windows.playerChecker.notificationType {
                    if notificationType != NOTIFICATION_TYPE_NONE {
                        notify::send({
                            title       = string.gsub(nickname, "_", " ") .. " вышел из игры.",
                            text        = (config.root.windows.playerChecker.displayOfflinePlayers)
                                ? "Теперь он отображается отключенным в чекере."
                                : "Больше он не отображается в чекере.",
                            icon        = icons.ICON_PERSON,
                            duration    = 5
                        }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? (string.gsub(nickname, "_", " ") .. " вышел из игры.") : nil)
                    }
                }

                break
            }
        }
    }
    
    table.insert(allowedLogs[LOG_INDEX_CONNECTION][2], {
        time = assets::getLocalTime(),
        text = string.format("%s[%d] вышел из игры.", nickname, id)
    })

    match id {
        greport.player.id   => { greport.player::reset() }
        spectator.id        => { spectator::exit() }
    }
}
