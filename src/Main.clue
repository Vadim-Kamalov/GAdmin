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

@define COMMAND_DELAY   800
@define GADMIN_VERSION  "0.1"

@macro debugSuccessful(entryPoint, message)     { sampfuncsLog("{00FF00}__GADMIN__DEBUG__ [+][" .. $entryPoint .. "]:{FFFFFF} " .. $message) }
@macro debugWarning(entryPoint, message)        { sampfuncsLog("{FFA500}__GADMIN__DEBUG__ [~][" .. $entryPoint .. "]:{FFFFFF} " .. $message) }
@macro debugInformation(entryPoint, message)    { sampfuncsLog("{00BFFF}__GADMIN__DEBUG__ [?][" .. $entryPoint .. "]:{FFFFFF} " .. $message) }
@macro debugError(entryPoint, message)          { sampfuncsLog("{FF0000}__GADMIN__DEBUG__ [-][" .. $entryPoint .. "]:{FFFFFF} " .. $message) }

@macro PLAYER_COLOR_TO_HEX(id) { string.format("%06X", sampGetPlayerColor($id) & 0xFFFFFF) }

static memory       = require("memory")
static encoding     = require("encoding")
static imgui        = require("mimgui")
static wm           = require("windows.message")
static ffi          = require("ffi")
static neatJSON     = require("neatjson")
static xml2lua      = require("xml2lua")
static sampev       = require("samp.events")

encoding.default  = "CP1251"
static u8 = encoding.UTF8

require("moonloader")
math.randomseed(os.time())

static enum /* ALIGN_TYPE */ {
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
}

@import "Icons"             => icons
@import "Common"            => common
@import "Config"            => config
@import "CompressedData"    => compressed
@import "Notifications"     => notify

@import "game.User"         => user
@import "game.Spectator"    => spectator
@import "game.Admins"       => admins

@import "game.sa.Vehicle"   => vehicle
@import "game.sa.Ped"       => ped

@import "imgui.Style" => style

// All ImGui imports that uses some of font that defined here should connected after this function.
imgui.OnInitialize(fn {
    local glyphRanges = imgui.GetIO().Fonts::GetGlyphRangesCyrillic()

    icons::init(30)
    style::apply()
    
    global bold10      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 16.0, nil, glyphRanges)
    global bold14      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 22.0, nil, glyphRanges)
    global bold17      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 27.0, nil, glyphRanges)
    global bold15      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 23.0, nil, glyphRanges)
    global bold18      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 26.0, nil, glyphRanges)
    global bold25      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 33.0, nil, glyphRanges)
    global regular9    = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 14.0, nil, glyphRanges)
    global regular14   = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 19.0, nil, glyphRanges)
    global regular15   = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 23.0, nil, glyphRanges)
    global bold        = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 25.0, nil, glyphRanges)
    global regular     = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 25.0, nil, glyphRanges)
    
    global shadowPng   = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", compressed.shadow), #compressed.shadow)

    imgui.GetIO().IniFilename = nil
})

@import "MovableWindows"    => movableWindows
@import "AutoUpdate"        => autoUpdate

@import "imgui.Assets"          => imguiAssets
@import "imgui.drawList.Text"   => imguiText

global fn main() {
    while !isSampAvailable() { wait(0) }

    if sampGetCurrentServerAddress() != "46.174.48.194" {
        script::unload()
    }

    common::makeDirectoryTree({ "GAdmin", "GAdmin/temp", "GAdmin/config" })

    while true {
        wait(0)

        if spectator.status {
            if sampIsPlayerPaused(spectator.id) {
                if os.clock() - spectator.afk.clock >= 1 {
                    spectator.afk.time += 1
                    spectator.afk.clock = os.clock()
                }
            } else {
                spectator.afk.time = 0
            }
        }
    }
}

global fn onScriptTerminate(scr, quitGame) {
    if scr == script.this {
        config::saveIfChanged()
    }
}

global fn onWindowMessage(msg, wparam, lparam) {
    $SETUP_EVENT_MV!(msg, wparam)
}

global fn onReceivePacket(id) {
    if id == 36 || id == 32 || id == 37 {
        user::setAloginStatus(false)
    }
}

@ifdef __GADMIN_DEBUG__ {
    sampfuncsRegisterConsoleCommand("debug.enableWindow", fn(window) {
        config.root.windows[window].use = true
    })

    sampfuncsRegisterConsoleCommand("debug.setAlignMode", fn(mode) {
        config.root.windows.adminList.textAlignMode = tonumber(mode)
    })

    sampfuncsRegisterConsoleCommand("debug.addNotification", fn(title) {
        notify::send({
            buttons = {
                first = {
                    name    = "Закрыть"
                    call    = fn(close) { close() }
                }

                second = {
                    name = "AHelper govno"
                }
            }
        })
    })

    sampfuncsRegisterConsoleCommand("debug.getSpectatorInformation", fn(key) {
        print(spectator.id)
        print(spectator::getInformation()[key])
    })

    sampfuncsRegisterConsoleCommand("debug.addCheckerPlayer", fn(args) {
        table.insert(config.root.windows.playerChecker.players, {
            nickname    = string.match(args, "^(%S+) .*"),
            commentary  = string.match(args, "^%S+ (.*)")
        })
    })
}
