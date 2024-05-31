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

@import "imgui.Assets"          => imguiAssets
@import "imgui.drawList.Text"   => imguiText
@import "imgui.HotKey"          => HotKey

@import "game.sa.Vehicle"   => vehicle
@import "game.sa.Ped"       => ped
@import "game.Admins"       => admins
@import "game.User"         => user
@import "game.Spectator"    => spectator

@import "Assets"        => assets
@import "Icons"         => icons
@import "Notifications" => notify
@import "Common"        => common
@import "Config"        => config

static clickWarp = {
    enabled         = false,
    teleportation   = {
        tpIntoCar   = nil,
        pos         = nil
    }
}

local enum /** @enum ROUND_MENU_SELECTED_MODE */ {
    ROUND_MENU_SELECTED_MODE_PLAYER,
    ROUND_MENU_SELECTED_MODE_VEHICLE
}

local useWallhack = true
local useCarInfo  = true
local useTraccers = true

local roundMenuSelectedMode = ROUND_MENU_SELECTED_MODE_PLAYER

local roundMenuHotKey = HotKey::new("imgui.windows.DrawListRender->roundMenu", { VK_Z }, "Круговое меню поиска", HOTKEY_CONDITION_NEVER)
::registerCallback(fn {})

HotKey::new("imgui.windows.DrawListRender->wallhack", { VK_LCONTROL, VK_Z }, "Wallhack")
::registerCallback(fn {
    if user::getAloginStatus() && config.root.cheats.wallhack.use {
        useWallhack = !$

        if !config.root.cheats.wallhack.imguiStyle {
            assets::changeWallhackState(useWallhack)
        }

        if local notificationType = config.root.cheats.wallhack.notificationType {
            if notificationType != NOTIFICATION_TYPE_NONE {
                notify::send({
                    title       = "Wallhack " .. ((useWallhack) ? "включен." : "выключен."),
                    text        = "Теперь никнеймы игроков " .. ((useWallhack) ? "показаны." : "скрыты."),
                    icon        = icons.ICON_CHECKMARK,
                    duration    = 2
                }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? "Никнеймы игроков " .. ((useWallhack) ? "показаны." : "скрыты.") : nil)
            }
        }
    }
})

HotKey::new("imgui.windows.DrawListRender->tracersSwitch", { VK_LMENU, VK_C }, "Переключить трассера")
::registerCallback(fn {
    if config.root.additions.tracers.use && user::getAloginStatus() {
        useTraccers = !$
        if local notificationType = config.root.additions.tracers.notificationType {
            if notificationType != NOTIFICATION_TYPE_NONE {
                notify::send({
                    title       = "Трассеры " .. ((useTraccers) ? "включены." : "выключены."),
                    text        = "Теперь выстрелы от игроков " .. ((useTraccers) ? "показаны." : "скрыты."),
                    icon        = icons.ICON_CHECKMARK,
                    duration    = 2
                }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? "Трассера " .. ((useTraccers) ? "показаны." : "скрыты.") : nil)
            }
        }
    }
})

HotKey::new("imgui.windows.DrawListRender->traccersRemove", { VK_LMENU, VK_Z }, "Удалить трассера")
::registerCallback(fn {
    if config.root.additions.tracers.use {
        for i = 1, config.root.additions.tracers.maxLines {
            bulletData[i].enable = false
        }

        notify::send({
            title       = "Трассера удалены.",
            text        = "Трассера успешно удалены!",
            icon        = icons.ICON_CHECKMARK,
            duration    = 2
        })
    }
})

HotKey::new("imgui.windows.DrawListRender->switchCarInfoRender", { VK_LCONTROL, VK_C }, "Информация о машинах")
::registerCallback(fn {
    if config.root.additions.carInfo.use && user::getAloginStatus() {
        useCarInfo = !$
        if local notificationType = config.root.additions.carInfo.notificationType {
            if notificationType != NOTIFICATION_TYPE_NONE {
                notify::send({
                    title       = "Рендер информация машин " .. ((useCarInfo) ? "включен." : "выключен."),
                    text        = "Теперь информация машин будет " .. ((useCarInfo) ? "показываться." : "скрываться."),
                    icon        = icons.ICON_CHECKMARK,
                    duration    = 2
                }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? "Рендер информации машин " .. ((useCarInfo) ? "показан." : "скрыт.") : nil)
            }
        }
    }
})

imgui.OnFrame(fn { return isSampAvailable() }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.DL         = imgui.GetBackgroundDrawList()

    local sizeX, sizeY = getScreenResolution()
    
    if !isGamePaused() {
        if config.root.additions.carInfo.use && ((config.root.additions.carInfo.onlyInSpectator) ? user::getAloginStatus() : true) {
            for _, car in getAllVehicles() {
                local x, y, z = getCarCoordinates(car)
                local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                if doesVehicleExist(car) && isCarOnScreen(car) &&
                   getDistanceBetweenCoords3d(x, y, z, myx, myy, myz) < 50
                   && user::getAloginStatus() && useCarInfo
                {
                    local hp        = getCarHealth(car)
                    local _, id     = sampGetVehicleIdByCarHandle(car)
                    local carModel  = getCarModel(car)
                    local vehName   = vehicle::getName(carModel)
                    local sx, sy    = convert3DCoordsToScreen(x, y, z)

                    imguiText::renderTextObjects(self.DL, imgui.ImVec2(sx, sy), {
                        {
                            text = "HP: ",
                            size = config.root.additions.carInfo.textSize,
                            font = bold
                        },

                        {
                            text    = tostring(hp),
                            size    = config.root.additions.carInfo.textSize,
                            font    = regular,
                            color   = common::convertHex2ImVec4("8DFF85")
                        },

                        {
                            text = " · ",
                            size = config.root.additions.carInfo.textSize,
                            font = bold
                        },
                        
                        {
                            text    = (getCarDoorLockStatus(car) == 0) ? "Opened" : "Locked",
                            size    = config.root.additions.carInfo.textSize,
                            font    = regular,
                            color   = common::convertHex2ImVec4((getCarDoorLockStatus(car) == 0) ? "8DFF85" : "FF8585")
                        },
                        
                        {
                            text = " · ",
                            size = config.root.additions.carInfo.textSize,
                            font = bold
                        },
                        
                        {
                            text    = (isCarEngineOn(car)) ? "On" : "Off",
                            size    = config.root.additions.carInfo.textSize,
                            font    = regular,
                            color   = common::convertHex2ImVec4((isCarEngineOn(car)) ? "8DFF85" : "FF8585")
                        },

                        "NewLine",

                        {
                            text = string.format("%s[ID: %d]", vehName, id),
                            size = config.root.additions.carInfo.textSize,
                            font = bold
                        }
                    })
                }
            }
        } // if config.root.additions.carInfo.use

        for _, player in getAllChars() {
            local result, id = sampGetPlayerIdByCharHandle(player)
            if result {
                local charResult, char          = sampGetCharHandleBySampPlayerId(id)
                local x, y, z                   = ped::getBodyPartCoordinates(4, player)
                local myx, myy, myz             = getCharCoordinates(PLAYER_PED)
                local screenPosX, screenPosY    = convert3DCoordsToScreen(x, y, z)
                local charCheck                 = charResult && isCharOnScreen(char) && id != select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
                local distance                  = getDistanceBetweenCoords3d(x, y, z, myx, myy, myz)
                local clistColorHex             = string.format("%06X", sampGetPlayerColor(id) & 0xFFFFFF)

                if charCheck && user::getAloginStatus() {
                    local objects = {}

                    if config.root.cheats.wallhack.use && useWallhack && config.root.cheats.wallhack.imguiStyle {
                        for _, object in ({
                            {
                                text    = string.format("%s[%s] [X: %1.f]", sampGetPlayerNickname(id), id, distance),
                                color   = common::convertHex2ImVec4(clistColorHex),
                                size    = config.root.cheats.wallhack.textSize
                            },
                            
                            "NewLine"
                        }) {
                            table.insert(objects, object)
                        }
                    }

                    if config.root.additions.showAdmins.use && distance < 50 && !ped::isBehindWall(char) {
                        if local admin = admins::getAdminById(id) {
                            for _, object in ({
                                {
                                    text    = admin.nickname.ooc,
                                    color   = common::convertHex2ImVec4(config.root.additions.showAdmins.color),
                                    size    = config.root.additions.showAdmins.textSize
                                },

                                "NewLine"
                            }) {
                                table.insert(objects, object)
                            }
                        }
                    }

                    if config.root.additions.gunInfo.use && distance < 50 {
                        for _, object in ({
                            {
                                text = require("game.weapons").names[getCurrentCharWeapon(player)],
                                size = config.root.additions.gunInfo.textSize
                            },

                            "NewLine"
                        }) {
                            table.insert(objects, object)
                        }
                    }

                    if config.root.cheats.wallhack.use && config.root.cheats.wallhack.renderBones && useWallhack {
                        for _, boneIds in ({
                            { 6, 4 },
                            { 4, 22 }, { 22, 23 }, { 23, 24 },
                            { 4, 32 }, { 32, 33 }, { 33, 34 },
                            { 4, 3 },  { 3, 2 },
                            { 2, 52 }, { 52, 53 },
                            { 2, 42 }, { 42, 43 }
                        }) {
                            local xA, yA, zA = ped::getBodyPartCoordinates(boneIds[1], player)
                            local xB, yB, zB = ped::getBodyPartCoordinates(boneIds[2], player)
                            local start      = imgui.ImVec2(convert3DCoordsToScreen(xA, yA, zA))
                            local _end       = imgui.ImVec2(convert3DCoordsToScreen(xB, yB, zB))
                            local color      = imgui.ColorConvertFloat4ToU32(common::convertHex2ImVec4(clistColorHex))

                            self.DL::AddLine(start, _end, color, 2)
                        }
                    }
                
                    if #objects > 0 {
                        imguiText::renderTextObjects(self.DL, imgui.ImVec2(screenPosX, screenPosY), objects)
                    }
                }

                if config.root.additions.tracers.use && user::getAloginStatus() && useTraccers {
                    for i = 1, config.root.additions.tracers.maxLines {
                        if local bullet = bulletData[i] {
                            if bullet.enable && os.time() <= bullet.time {
                                local o, t = bullet.o, bullet.t
                                if isPointOnScreen(o.x, o.y, o.z) && isPointOnScreen(t.x, t.y, t.z) {
                                    local sX, sY    = convert3DCoordsToScreen(o.x, o.y, o.z)
						            local fX, fY    = convert3DCoordsToScreen(t.x, t.y, t.z)
                                    local hitColor  = common::convertHex2ImVec4(config.root.additions.tracers.hitColor)
                                    local missColor = common::convertHex2ImVec4(config.root.additions.tracers.missColor)
                                    local color     = imgui.ColorConvertFloat4ToU32((bullet.type == 0 || bullet.type == 3) ? missColor : hitColor)
                                    local dl        = imgui.GetBackgroundDrawList()

                                    dl::AddLine(imgui.ImVec2(sX, sY), imgui.ImVec2(fX, fY), color, 1)
                                    dl::AddCircleFilled(imgui.ImVec2(fX + 1.5, fY + 1.5), 3, color, 16)
                                }
                            }
                        }
                    }
                }
            }
        } // for _, player in getAllChars()

        if config.root.windows.roundMenu.use && user::getAloginStatus() {
            local render  = true
            local radius  = config.root.windows.roundMenu.radius
            local nearest = {
                [ROUND_MENU_SELECTED_MODE_PLAYER]  = ped::getNearestToScreenCenter(radius),
                [ROUND_MENU_SELECTED_MODE_VEHICLE] = vehicle::getNearestToScreenCenter(radius)
            }

            for _, key in roundMenuHotKey.keys {
                if !isKeyDown(key) {
                    render = false
                    break
                }
            }

            if render && !common::isInputsActive() {
                local sizeX, sizeY = getScreenResolution()
                local center       = imgui.ImVec2(sizeX / 2, sizeY / 2)
                local found        = ""

                freezedHotKeysCallbacks = true

                if isKeyJustPressed(VK_1) {
                    roundMenuSelectedMode = ($ == ROUND_MENU_SELECTED_MODE_VEHICLE)
                        ? ROUND_MENU_SELECTED_MODE_PLAYER
                        : ROUND_MENU_SELECTED_MODE_VEHICLE
                }

                self.DL::AddCircle(center, radius, -1, 64, 2)

                if local it = nearest[roundMenuSelectedMode] {
                    self.DL::AddLine(center, imgui.ImVec2(table.unpack(it.pos)), -1, 2)

                    if roundMenuSelectedMode == ROUND_MENU_SELECTED_MODE_VEHICLE {
                        local id            = getCarModel(it.handle)
                        local name          = vehicle::getName(id)
                        local result, vehId = sampGetVehicleIdByCarHandle(it.handle)

                        if result {
                            found = string.format("%s[ID: %d]", name, vehId)

                            for index, command in ({ "vrepair", "vspawn", "vfuel", "adm_vehid", "getcar" }) {
                                if isKeyJustPressed(_G["VK_" .. index + 1]) {
                                    sampSendChat(string.format("/%s %d%s", command, vehId, (command == "vfuel") ? " 90" : ""))
                                }
                            }
                        }
                    } else {
                        local _, id     = sampGetPlayerIdByCharHandle(it.handle)
                        local nickname  = sampGetPlayerNickname(id)

                        found = string.format("%s[%d]", nickname, id)
                        
                        for index, command in ({ "sp", "aheal", "stats", "pame", "gethere" }) {
                            if isKeyJustPressed(_G["VK_" .. index + 1]) {
                                sampSendChat(string.format("/%s %d", command, id))
                            }
                        }
                    }
                }

                for index, text in ({
                    "1 - переключение между режимами (поиск игроков или машин)",
                    found
                }) {
                    local font = (index == 1) ? regular : bold
                    local x    = center.x - font::CalcTextSizeA(18, math.huge, 0.0, text).x / 2
                    local y    = center.y + ((index == 1) ? radius + 20 : -radius - 30)

                    imguiText::renderTextObjects(self.DL, imgui.ImVec2(x, y), {{
                        text  = text,
                        size  = 18,
                        font  = font,
                        color = imgui.ImVec4(1, 1, 1, 1)
                    }})
                }

                for index, group in ({
                    {
                        "[2] Следить",
                        "[3] Вылечить",
                        "[4] Открыть статистику",
                        "[5] Открыть /pame",
                        "[6] Телепортировать к себе",
                    },
                    
                    {
                        "Починить [2]",
                        "Заспавнить [3]",
                        "Заправить [4]",
                        "Узнать владельца [5]"
                        "Телепортировать к себе [6]",
                    }
                }) {
                    local maxTextSize = imgui.ImVec2(0, 0)
                    local groupHeight = 0

                    for _, text in group {
                        local size = bold::CalcTextSizeA(18, math.huge, 0.0, text)
                        
                        if size.x > maxTextSize.x || size.y > maxTextSize.y {
                            maxTextSize = size
                        }

                        groupHeight += size.y + 2
                    }

                    groupHeight -= 2

                    for lineIndex, text in group {
                        local size  = bold10::CalcTextSizeA(18, math.huge, 0.0, text)
                        local color = (roundMenuSelectedMode == index) ? imgui.ImVec4(1, 1, 1, 1) : imgui.ImVec4(0.5, 0.5, 0.5, 1)
                        local x     = center.x + ((index == 1) ? -radius - 20 - maxTextSize.x : radius + 20 + (maxTextSize.x - size.x))
                        local y     = center.y - (groupHeight / 2) + ((lineIndex - 1) * 20)
                        local key   = lineIndex + 1

                        imguiText::renderTextObjects(self.DL, imgui.ImVec2(x, y), {{
                            text  = text,
                            size  = 18,
                            font  = bold,
                            color = color
                        }})
                    }
                }
            } else {
                freezedHotKeysCallbacks = false
            }
        }

        /**
         * Clickwarp implementation. Authors - FYP and we_sux team.
         * https://www.blast.hk/threads/15459/
         */
        if clickWarp.enabled && config.root.cheats.clickwarp.use && user::getAloginStatus() {
            local sx, sy = getCursorPos()
            local sw, sh = getScreenResolution()
            if sx >= 0 && sy >= 0 && sx < sw && sy < sh {
                local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
                local camX, camY, camZ = getActiveCameraCoordinates()
                local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
                if result && colpoint.entity != 0 {
                    local normal    = colpoint.normal
                    local pos       = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
                    local zOffset   = 300
                    
                    if normal[3] >= 0.5 { zOffset = 1 }

                    local result, colpoint2 = processLineOfSight(
                        pos.x,
                        pos.y,
                        pos.z + zOffset,
                        pos.x,
                        pos.y,
                        pos.z - 0.3,
                        true,
                        true,
                        false,
                        true,
                        false,
                        false,
                        false
                    )

                    if result {
                        pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

                        local curX, curY, curZ  = getCharCoordinates(playerPed)
                        local distance          = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
                        local text              = string.format("%.2fm", distance)
                        local color             = imgui.ImVec4(1, 1, 1, 1)

                        sy -= 2
                        sx -= 2

                        local tpIntoCar = nil
                        if colpoint.entityType == 2 {
                            local car       = getVehiclePointerHandle(colpoint.entity)
                            local carModel  = getCarModel(car)
                            if doesVehicleExist(car) && (!isCharInAnyCar(PLAYER_PED) || storeCarCharIsInNoSave(PLAYER_PED) != car) {
                                color   = imgui.ImVec4(1, 1, 1, 0.5) 
                                text  ..= " | " .. vehicle::getName(carModel) .. "\nУдерживайте ПКМ для телепортации в машину"
                                if isKeyDown(VK_RBUTTON) {
                                    tpIntoCar   = car
                                    color       = imgui.ImVec4(1, 1, 1, 1)
                                }
                            }
                        }

                        imguiText::addStroke(self.DL, text, imgui.ColorConvertFloat4ToU32(color), imgui.ImVec2(sx + 20, sy + 10), regular, 18)
                        
                        clickWarp.teleportation = {
                            tpIntoCar   = tpIntoCar,
                            pos         = pos
                        }
                    }
                }
            }
        } // if clickWarp.enabled && config.root.cheats.clickwarp.use && user::getAloginStatus()
    } /* if !isGamePaused()*/ else {
        for index, text in ({
            string.format("GAdmin v%s", $GADMIN_VERSION),
            "\nCopyright (C) " .. $COPYRIGHT_YEARS .. " The Contributors. All rights reserved.",
            "\n\nLicensed under the GNU General Public License v3 (GPLv3)."
        }) {
            self.DL::AddTextFontPtr((index == 1) ? bold : regular, 18, imgui.ImVec2((sizeX - imgui.CalcTextSize(text).x) / 2, sizeY - 70 + (index * 2)), -1, text)
        }
    }
})
