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
    assert(id >= 400 && id <= 611, "Vehicle-ID should be in 400..611 range!")

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
 * Get vehicle max speed by it's id.
 *
 * @param id number Vehicle-ID
 * @return string
 */
method vehicle::getMaxSpeed(id) {
    assert(id >= 400 && id <= 611, "Vehicle-ID should be in 400..611 range!")

    return ({
        43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61,
        46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
        54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43,
        39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0,
        53, 43, 16, 33, 43, 29, 26, 43, 37, 48, 43, 30, 29,
        14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69,
        51, 32, 38, 51, 20, 43, 34, 18, 27, 17, 47, 40, 38,
        43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58,
        59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
        43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16,
        19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41,
        40, 41, 39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43,
        49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22,
        30, 30, 43, 43, 75, 36, 43, 42, 42, 37, 23, 0, 42, 38,
        45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41,
        30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
    })[id - 399]
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
