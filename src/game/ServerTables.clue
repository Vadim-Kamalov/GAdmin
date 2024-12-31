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

return {
    weaponDamage = {
        { "Оружие", "Калибр", "Ноги", "Руки", "Пах", "Торс", "Голова", "Эффект" },
        { "Colt 1911", "9mm", "15", "15", "30", "35", "60", "Кровотечение 30%" },
        { "SD Pistol", "9mm", "20", "20", "35", "40", "60", "Кровотечение 40%" },
        { "Desert Eagle", ".50 ACTION", "20", "20", "40", "60", "60", "Кровотечение 30%" },
        { "Shotgun", "12mm", "20", "20", "40", "60", "100", "Кровотечение 60%" },
        { "Sawnoff Shotgun", "12mm", "15", "15", "30", "35", "100", "Кровотечение 60%" },
        { "UZI", "9.19mm", "15", "15", "30", "35", "100", "Кровотечение 10%" },
        { "MP5", "9.19mm", "15", "15", "30", "35", "100", "Кровотечение 10%" },
        { "AK-47", "7.62mm", "20", "20", "50", "50", "80", "Кровотечение 10%" },
        { "M4", "5.56mm ", "20", "20", "50", "50", "80", "Кровотечение 10%" },
        { "TEC-9", "9.19mm", "15", "15", "30", "35", "100", "Кровотечение 10%" },
        { "Country Rifle", "7.62mm", "50", "50", "50", "70", "90", "Кровотечение 30%" },
        { "Sniper Rifle", "7.62mm", "60", "60", "60", "70", "100", "Кровотечение 30%" },
        { "Spraycan", "", "0", "0", "0", "0", "0", "Нокаут 2%" },
        { "Fire Ext.", "", "0", "0", "0", "0", "0", "Нокаут 2%" },
        { "Кулак", "", "5", "5", "8", "10", "15", "Нокаут 1%" },
        { "Кастет", "", "10", "10", "12", "15", "20", "Нокаут 2% + Кровотечение 10%" },
        { "Клюшка", "", "10", "10", "12", "30", "35", "Нокаут 5%" },
        { "Полиц. дубинка", "", "10", "10", "12", "30", "35", "Нокаут 4%" },
        { "Нож", "", "15", "15", "20", "35", "40", "Кровотечение 50%" },
        { "Бита", "", "15", "15", "20", "35", "40", "Нокаут 10%" },
        { "Лопата", "", "15", "15", "20", "35", "40", "Нокаут 10% + Кровотечение 30%" },
        { "Кий", "", "15", "15", "20", "35", "40", "Нокаут 10%" },
        { "Катана", "", "20", "20", "30", "40", "50", "Кровотечение 60%" },
        { "Бензопила", "", "20", "20", "30", "40", "50", "Кровотечение 90%" },
        { "Розовый дилдо", "", "5", "5", "8", "10", "15", "Нокаут 1%" },
        { "Мал. дилдо", "", "5", "5", "8", "10", "15", "Нокаут 1%" },
        { "Вибратор", "", "5", "5", "8", "10", "15", "Нокаут 1%" },
        { "Сильвер Вибратор", "", "5", "5", "8", "10", "15", "Нокаут 1%" },
        { "Цветы", "", "0", "0", "0", "0", "0", "" },
        { "Трость", "", "0", "0", "0", "0", "0", "" },
        { "Граната", "", "0", "0", "0", "0", "0", "" }
    },

    prices = {
        { "Автомобили", {
            "Sadler", "2500$",
            "Perenniel", "4000$",
            "Tampa", "4000$",
            "Walton", "4000$",
            "Regina", "4500$",
            "Nebula", "4950$",
            "Hustler", "5000$",
            "Manana", "5000$",
            "Picador", "5500$",
            "Virgo", "5950$",
            "Previon", "6000$",
            "Majestic", "6438$",
            "Rumpo", "6500$",
            "Solair", "6500$",
            "Topfunvan", "6500$",
            "Bravura", "6750$",
            "Esperanto", "7000$",
            "Clover", "7000$",
            "Moonbeam", "7500$",
            "Voodoo", "7500$",
            "Broadway", "7500$",
            "Hermes", "7500$",
            "Camper", "8000$",
            "Buccaneer", "8000$",
            "Primo", "8300$",
            "Glendale", "8400$",
            "Pony", "8500$",
            "Remington", "8500$",
            "Sabre", "8500$",
            "Blade", "8500$",
            "Oceanic", "9500$",
            "Tornado", "9500$",
            "Greenwood", "9800$",
            "Fortune", "10000$",
            "Slamwan", "10000$",
            "Sunrise", "11500$",
            "Stallion", "12500$",
            "Savanna", "14500$",
            "Tahoma", "17500$",
            "Intruder", "6500$",
            "Emperor", "7000$",
            "Sentinel", "7500$",
            "Benson", "8000$"
            "Willard", "8000$",
            "Cadrona", "8500$",
            "Vincent", "9000$",
            "Merit", "10000$",
            "Admiral", "10000$",
            "Windsor", "10500$",
            "Boxvile", "11000$"
            "Bobcat", "11500$",
            "Blistacompact", "11500$",
            "Burrito", "12500$",
            "Premier", "13000$",
            "Elegant", "13500$",
            "Phoenix", "13500$",
            "Club", "14000$",
            "Alpha", "14500$",
            "Feltzer", "14500$",
            "Stafford", "15000$",
            "Mesa", "16000$",
            "Washington", "17500$",
            "Yosemite", "17500$",
            "Uranus", "17500$",
            "Rancher", "18000$",
            "Mule", "18500$"
            "Euros", "19000$",
            "Landstalker", "20000$",
            "Jester", "20000$",
            "Flash", "20000$",
            "Stratum", "23000$",
            "Utility Van", "25000$"
            "Sultan", "25000$",
            "Elegy", "27500$",
            "Huntley", "27500$",
            "Comet", "28000$",
            "Hotknife", "27500$",
            "DFT-30", "35000$",
            "Yankee", "35000$",
            "ZR-350", "40000$",
            "Flatbed", "55000$"
            "Linerunner", "75000$"
            "Buffalo", "75000$",
            "Tanker", "85000$",
            "Roadtrain", "100000$"
            "Banshee", "215000$",
            "SuperGT", "250000$",
            "Cheetah", "575000$",
            "Turismo", "625000$",
            "Infernus", "725000$",
            "Bullet", "745000$"
        }},

        { "Мотоциклы/велосипеды", {
            "BMX", "250$",
            "Bike", "300$",
            "Faggio", "1000$",
            "Mountainbike", "1750$",
            "Sanchez", "4500$",
            "PCJ-600", "5000$",
            "Quad", "6000$",
            "BF-400", "7500$",
            "FCR-900", "7500$",
            "Freeway", "10000$", 
            "Wayfarer", "10000$",
            "NRG-500", "31500$"
        }},

        { "Воздушный транспорт", {
            "Maverick", "$725.000",
            "Sparrow", "$470.000",
            "Nevada", "$2.100.000",
            "Shamal", "$1.300.000",
            "Stuntplane", "$710.000",
            "Cropduster", "$690.000",
            "Skimmer", "$500.000",
            "Rustler", "$420.000",
            "Beagle", "$200.000"
        }},

        { "Водный транспорт", {
            "Jetmax", "$900.000",
            "Squallo", "$830.000",
            "Speeder", "$260.000",
            "Reefer", "$100.000",
            "Dinghy", "$50.000",
            "Marquis", "$1.600.000",
            "Tropic", "$700.000"
        }}
    }
}
