/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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

@import "Common" => common
@import "Config" => config

local useWallhack = true

HotKey::new("imgui.windows.DrawListRender->wallhack", { VK_CONTROL, VK_Z }, "Wallhack")
      ::registerCallback(fn { useWallhack = !$ })

imgui.OnFrame(fn { return isSampAvailable() }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.DL         = imgui.GetBackgroundDrawList()

    local sizeX, sizeY = getScreenResolution()
    
    if !isGamePaused() {
        if config.root.additions.carInfo.use {
            for _, car in getAllVehicles() {
                local x, y, z = getCarCoordinates(car)
                local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                if doesVehicleExist(car) && isCarOnScreen(car) && getDistanceBetweenCoords3d(x, y, z, myx, myy, myz) < 50 {
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
            local _, id                     = sampGetPlayerIdByCharHandle(player)
            local charResult, char          = sampGetCharHandleBySampPlayerId(id)
            local x, y, z                   = ped::getBodyPartCoordinates(4, player)
            local myx, myy, myz             = getCharCoordinates(PLAYER_PED)
            local screenPosX, screenPosY    = convert3DCoordsToScreen(x, y, z)
            local charCheck                 = charResult && isCharOnScreen(char) && id != select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local distance                  = getDistanceBetweenCoords3d(x, y, z, myx, myy, myz)
            local clistColorHex             = string.format("%06X", sampGetPlayerColor(id) & 0xFFFFFF)

            if charCheck {
                if config.root.additions.gunInfo.use && distance < 50 {
                    imguiText::addColored(
                        self.DL,
                        "{FFFFFF}{" .. require("game.weapons").names[getCurrentCharWeapon(player)] .. "}",
                        imgui.ImVec2(screenPosX, screenPosY),
                        nil,
                        config.root.render.size.gunInfo,
                        1
                    )
                }

                if config.root.additions.showAdmins.use && distance < 50 {
                    for _, data in admins {
                        if id == data.id {
                            imguiText::addColored(
                                self.DL,
                                "{FF8585}{" .. data.nickname.ooc .. "}", 
                                imgui.ImVec2(screenPosX, screenPosY - 15), 
                                nil, 
                                config.root.render.size.admins, 
                                1
                            )
                        }
                    }
                }

                if config.root.cheats.wallhack.use && useWallhack {
                    imguiText::addColored(
                        self.DL,
                        string.format("{%s}{%s[%s] [X: %1.f]}", clistColorHex, sampGetPlayerNickname(id), id, distance),
                        imgui.ImVec2(screenPosX, screenPosY - 30), 
                        nil, 
                        config.root.render.size.wallhack, 
                        1
                    )
                }
            }

            if config.root.additions.tracers.use {
                for i = 1, config.root.additions.tracers.maxLines {
                    if local bullet = bulletData[i] {
                        if bullet.enable && os.time() <= bullet.time {
                            local o, t = bullet.o, bullet.t
                            if isPointOnScreen(o.x, o.y, o.z) && isPointOnScreen(t.x, t.y, t.z) {
                                local sX, sY    = convert3DCoordsToScreen(o.x, o.y, o.z)
						        local fX, fY    = convert3DCoordsToScreen(t.x, t.y, t.z)
                                local hitColor  = common::convertHex2ImVec4(config.root.additions.tracers.hitColor)
                                local missColor = common::convertHex2ImVec4(config.root.additions.tracers.missColor)
                                local color     = imgui.ColorConvertFloat4ToU32((bullet.type == 0) ? missColor : hitColor)
                                local dl        = imgui.GetBackgroundDrawList()

                                dl::AddLine(imgui.ImVec2(sX, sY), imgui.ImVec2(fX, fY), color, 1)
                                dl::AddCircleFilled(imgui.ImVec2(fX + 1.5, fY + 1.5), 3, color, 16)
                            }
                        }
                    }
                }
            }
        } // for _, player in getAllChars()
    } /* if !isGamePaused()*/ else {
        local text = string.format("GAdmin v%s", $GADMIN_VERSION)
        self.DL::AddText(imgui.ImVec2(sizeX - 100 - imgui.CalcTextSize(text).x / 2, sizeY - 40), -1, text)
    }
})
