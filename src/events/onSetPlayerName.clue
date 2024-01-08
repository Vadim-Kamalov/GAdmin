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

@import "Notifications" => notify
@import "Icons"         => icons
@import "Config"        => config

sampev.onSetPlayerName = fn(id, nickname, success) {
    /**
     * Yes, code for check player join here is same as code in `events.onPlayerJoin`.
     */
    if config.root.windows.playerChecker.use && !success {
        for _, player in config.root.windows.playerChecker.players {
            if player.nickname == nickname {
                if local notificationType = config.root.windows.playerChecker.notificationType {
                    if notificationType != NOTIFICATION_TYPE_NONE {
                        notify::send({
                            title       = string.gsub(nickname, "_", " ") .. " зашел в игру.",
                            text        = (config.root.windows.playerChecker.displayOfflinePlayers)
                                ? "Теперь он отображается подключенным в чекере."
                                : "Теперь он отображается в чекере.",
                            icon        = icons.ICON_PERSON,
                            duration    = 5
                        }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? (string.gsub(nickname, "_", " ") .. " зашел в игру.") : nil)
                    }
                }

                break
            }
        }
    }
}
