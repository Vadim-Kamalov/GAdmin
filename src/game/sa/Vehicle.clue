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

local vehicle = {}

/**
 * Get vehicle name by id as string.
 *
 * @param id number Vehicle-ID
 * @return string
 */
method vehicle::getName(id) {
    return match tonumber(id) {
        525 => "Towtruck",
        552 => "Utility Van",
        437 => "Coach",
        582 => "Newsvan",
        431 => "Bus",
        510 => "Mountain Bike",
        490 => "FBI Rancher",
        488 => "SAN News Maverick",
        497 => "Police Maverick",
        420 => "Taxi",
        416 => "Ambulance",
        472 => "Coastguard",
        528 => "FBI Truck",
        406 => "Dumper",
        407 => "Firetruck",
        408 => "Trashmaster",
        428 => "Securicar",
        438 => "Cabbie",
        443 => "Packer",
        471 => "Quad",
        485 => "Baggage",
        486 => "Dozer",
        524 => "Cement Truck",
        530 => "Forklift",
        531 => "Tractor",
        532 => "Combine Harvester",
        544 => "Firetruck LA",
        571 => "Kart",
        572 => "Mower",
        574 => "Sweeper",
        596 => "Police Car (LSPD)",
        597 => "Police Car (SFPD)",
        598 => "Police Car (LVPD)",
        509 => "Bike",
        default => getGxtText(getNameOfVehicleModel(tonumber(id)))
    }
}

/**
 * Get free vehicle seat index.
 * 
 * @author FYP
 * @author we_sux team
 * @author https://www.blast.hk/threads/15459/
 *
 * @param car number
 * @return number|nil
 */
method vehicle::getFreeSeat(car) {
    if doesCharExist(getDriverOfCar(car)) {
        local maxPassengers = getMaximumNumberOfPassengers(car)
        for i = 0, maxPassengers {
            if isCarPassengerSeatFree(car, i) {
                return i + 1
            }
        }
        return nil
    } else {
        return 0
    }
}

/**
 * Jump into car.
 * 
 * @author FYP
 * @author we_sux team
 * @author https://www.blast.hk/threads/15459/
 *
 * @param car number
 * @return boolean
 */
method vehicle::jumpInto(car) {
    local seat = self::getFreeSeat(car)
    
    if !seat { return false }
    
    if seat == 0 {
        warpCharIntoCar(PLAYER_PED, car)
    } else {
        warpCharIntoCarAsPassenger(PLAYER_PED, car, seat - 1)
    }

    restoreCameraJumpcut()
    
    return true
}

return vehicle
