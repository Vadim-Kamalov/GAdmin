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

@import "game.Spectator"    => spectator
@import "Config"            => config

sampev.onBulletSync = fn(id, data) {
    if id == spectator.id {
        local information   = spectator::getInformation()
        local shotHit       = (data.targetType == 0 || data.targetType == 3) ? 0 : 1 
        spectator::setInformation({
            shotTotal   = information.shot.total + 1
            shotHit     = information.shot.hit + shotHit
        })
    }

    if config.root.additions.tracers.use {
        if data.target.x == -1 || data.target.y == -1 || data.target.z == -1 {
            return true
        }

        bulletData.lastId += 1

        if bulletData.lastId < 1 || bulletData.lastId > config.root.additions.tracers.maxLines {
            bulletData.lastId = 1
        }

        if local id = bulletData.lastId {
            bulletData[id].enable   = true
            bulletData[id].type     = data.targetType
            bulletData[id].time     = os.time() + 15
            bulletData[id].o.x, bulletData[id].o.y, bulletData[id].o.z = 
                data.origin.x, data.origin.y, data.origin.z
            bulletData[id].t.x, bulletData[id].t.y, bulletData[id].t.z = 
                data.target.x, data.target.y, data.target.z
        }
    }
}
