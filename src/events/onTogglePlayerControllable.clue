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

@import "game.User" => user
@import "Config"    => config

static onTogglePlayerControllableCount = 0

sampev.onTogglePlayerControllable = fn {
    onTogglePlayerControllableCount += 1
    if isSampAvailable() && sampGetPlayerScore(user::getId()) == 1
       && scriptLoadedWithGame
       && config.root.additions.autoAdminLogin.use
       && onTogglePlayerControllableCount == 2
    {
        sampSendChat("/alogin")
    }
}
