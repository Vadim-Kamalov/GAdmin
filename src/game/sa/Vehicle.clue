local vehicle = {}

method vehicle::getName(id) {
    return ({
        [525] = "Towtruck",
        [552] = "Utility Van",
        [437] = "Coach",
        [582] = "Newsvan",
        [431] = "Bus",
        [510] = "Mountain Bike",
        [490] = "FBI Rancher",
        [488] = "SAN News Maverick",
        [497] = "Police Maverick",
        [420] = "Taxi",
        [416] = "Ambulance",
        [472] = "Coastguard",
        [528] = "FBI Truck",
        [406] = "Dumper",
        [407] = "Firetruck",
        [408] = "Trashmaster",
        [428] = "Securicar",
        [438] = "Cabbie",
        [443] = "Packer",
        [471] = "Quad",
        [485] = "Baggage",
        [486] = "Dozer",
        [524] = "Cement Truck",
        [530] = "Forklift",
        [531] = "Tractor",
        [532] = "Combine Harvester",
        [544] = "Firetruck LA",
        [571] = "Kart",
        [572] = "Mower",
        [574] = "Sweeper",
        [596] = "Police Car (LSPD)",
        [597] = "Police Car (SFPD)",
        [598] = "Police Car (LVPD)",
        [509] = "Bike"
    })[tonumber(id)] || getGxtText(getNameOfVehicleModel(tonumber(id)))
}

return vehicle
