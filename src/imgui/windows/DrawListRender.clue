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

@import "Assets"        => assets
@import "Icons"         => icons
@import "Notifications" => notify
@import "Common"        => common
@import "Config"        => config

@macro RENDER_CHANGE_CONFIGURATION() {
    (fn {
        global RENDER_CHANGE_CONFIGURATION_SLIDER =
            RENDER_CHANGE_CONFIGURATION_SLIDER || imgui.new.int(config.root.render.size.common)

        imgui.SetNextItemWidth(imgui.GetWindowWidth() - 10)
        if imgui.SliderInt(
            "##imgui.windows.Main.configuration.renderChangeSlider",
            RENDER_CHANGE_CONFIGURATION_SLIDER,
            10,
            50
        ) {
            config.root.render.size.common = RENDER_CHANGE_CONFIGURATION_SLIDER[0]
        }
    })
}

static clickWarp = {
    enabled         = false,
    teleportation   = {
        tpIntoCar   = nil,
        pos         = nil
    }
}

local useWallhack = true
local useCarInfo  = true
local useTraccers = true

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

/**
 * Show cursor.
 *
 * @author FYP
 * @author we_sux team
 * @author https://www.blast.hk/threads/15459/
 *
 * @param toggle boolean
 * @return void
 */
local fn showCursor(toggle) {
    if toggle {
        sampSetCursorMode(CMODE_LOCKCAM)
    }
}

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
                    local engine    = (isCarEngineOn(car)) ? "{8DFF85}{ON}" : "{FF8585}{OFF}"
                    local door      = (getCarDoorLockStatus(car) == 0) ? "{8DFF85}{OPEN}" : "{FF8585}{LOCK}"
                    local hp        = getCarHealth(car)
                    local _, id     = sampGetVehicleIdByCarHandle(car)
                    local carmodel  = getCarModel(car)
                    local vehname   = vehicle::getName(carmodel)
                    local sx, sy    = convert3DCoordsToScreen(x, y, z)

                    local firstText, secondText = 
                        string.format("{FFFFFF}{ID: }{8DFF85}{%s}{FFFFFF}{ HP: }{8DFF85}{%s}", id, hp),
                        string.format("{FFFFFF}{%s }%s{FFFFFF}{ / }%s", vehname, engine, door)
                    imguiText::addColored(self.DL, firstText, imgui.ImVec2(sx, sy), nil, config.root.render.size.carInfo, 1)
                    imguiText::addColored(self.DL, secondText, imgui.ImVec2(sx, sy + 15), nil, config.root.render.size.carInfo, 1)
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
                local onPlayerRenderText        = ""

                if charCheck && user::getAloginStatus() {
                    if config.root.cheats.wallhack.use && useWallhack && config.root.cheats.wallhack.imguiStyle {
                        onPlayerRenderText ..= string.format("{%s}{%s[%s] [X: %1.f]}{FFFFFF}{\n}", clistColorHex, sampGetPlayerNickname(id), id, distance)
                    }

                    if config.root.additions.showAdmins.use && distance < 50 && !ped::isBehindWall(char) {
                        if local admin = admins::getAdminById(id) {
                            onPlayerRenderText ..= "{FF8585}{" .. admin.nickname.ooc .. "}{FFFFFF}{\n}" 
                        }
                    }

                    if config.root.additions.gunInfo.use && distance < 50 {
                        onPlayerRenderText ..= "{FFFFFF}{" .. require("game.weapons").names[getCurrentCharWeapon(player)] .. "}{FFFFFF}{\n}"
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
                
                    if #onPlayerRenderText > 0 {
                        imguiText::addColored(
                            self.DL,
                            onPlayerRenderText,
                            imgui.ImVec2(screenPosX, screenPosY), 
                            nil, 
                            config.root.render.size.common, 
                            1
                        )
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
