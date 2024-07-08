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
 * SPDX-License-Identifier: GPL-3.0-only
 */

local vehicle = {}

vehicle.names = {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr. Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider",
    "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina",
    "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "SAN News Maverick", "Rancher", "FBI Rancher", "Virgo", "Greenwood",
    "Jetmax", "Hotring Racer", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer",
    "Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Towtruck", "Fortune", "Cadrona", "FBI Truck",
    "Willard", "Forklift", "Tractor", "Combine Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Brown Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", "Nevada",
    "Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna",
    "Bandito", "Freight", "Brown Streak", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "Newsvan", "Tug", "Petrol Truck", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam",
    "Launch", "Police Car (LSPD)", "Police Car (SFPD)", "Police Car (LVPD)", "Ranger", "Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale", "Sadler",
    "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller", "Utility Trailer"
}

/**
 * Get vehicle that nearest to the center of the screen.
 *
 * @param radius number
 * @return ({ handle: number, distance: number, pos: { number, number }})|nil
 */
method vehicle::getNearestToScreenCenter(radius) {
    local nearest       = { handle = nil, distance = radius, pos = { 0.0, 0.0 }}
    local sizeX, sizeY  = getScreenResolution()

    for _, handle in getAllVehicles() {
        if getDriverOfCar(handle) != PLAYER_PED && isCarOnScreen(handle) {
            local x, y     = convert3DCoordsToScreen(getCarCoordinates(handle))
            local distance = getDistanceBetweenCoords2d(sizeX / 2, sizeY / 2, x, y)

            if distance < nearest.distance && radius > distance {
                nearest = {
                    handle   = handle,
                    distance = distance,
                    pos      = { x, y }
                }
            }
        }
    }

    return (nearest.handle) ? nearest : nil
}

/**
 * Get vehicle name by id as string.
 *
 * @param id number Vehicle-ID
 * @return string
 */
method vehicle::getName(id) {
    assert(id >= 400 && id <= 611, "Vehicle-ID should be in 400..611 range!")
    return self.names[id - 399]
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
        88, 81, 103, 61, 74, 91, 61, 82, 55, 88, 72, 123,
        93, 61, 59, 107, 85, 61, 64, 83, 81, 85, 78, 55,
        75, 110, 96, 65, 65, 112, 104, 72, 52, 61, 93, 0,
        83, 88, 79, 93, 76, 0, 77, 70, 62, 91, 130, 71,
        62, 0, 0, 107, 102, 33, 74, 88, 59, 53, 87, 76,
        98, 89, 62, 80, 0, 0, 82, 78, 80, 70, 87, 61, 73,
        60, 83, 96, 140, 103, 65, 78, 102, 50, 87, 68, 37,
        55, 36, 96, 82, 77, 87, 83, 78, 99, 119, 98, 90, 98,
        60, 68, 78, 0, 119, 119, 96, 77, 99, 92, 60, 43, 55,
        81, 73, 91, 67, 79, 87, 87, 91, 150, 150, 89, 98, 84,
        72, 89, 87, 83, 98, 83, 34, 39, 61, 93, 93, 87, 96, 0,
        0, 55, 83, 113, 91, 84, 82, 81, 83, 79, 75, 85, 80, 87,
        67, 130, 80, 88, 61, 61, 87, 99, 94, 85, 99, 80, 0, 91,
        89, 96, 81, 0, 0, 52, 61, 61, 33, 87, 87, 150, 72, 87,
        85, 94, 76, 47, 0, 85, 80, 91, 60, 90, 0, 0, 150, 105,
        0, 65, 98, 98, 98, 89, 84, 61, 94, 95, 82, 84, 0, 0, 0,
        60, 0, 0
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
