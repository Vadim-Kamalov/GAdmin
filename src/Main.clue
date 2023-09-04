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

static memory       = require("memory")
static encoding     = require("encoding")
static imgui        = require("mimgui")
static wm           = require("windows.message")
static ffi          = require("ffi")
static neatJSON     = require("neatjson")
static xm2lua       = require("xml2lua")

encoding.default  = "CP1251"
static u8 = encoding.UTF8

require("moonloader")

global enum /* ALIGN_TYPE */ {
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
}

@import "AutoUpdate"        => autoUpdate
@import "Icons"             => icons
@import "MovableWindows"    => movableWindows
@import "Common"            => common
@import "Config"            => config

global fn main() {
    while !isSampAvailable() { wait(0) }

    if sampGetCurrentServerAddress() != "46.174.48.194" {
        script::unload()
    }

    common::makeDirectoryTree({ "GAdmin", "GAdmin/temp", "GAdmin/config" })

    while true {
        wait(0)
    }
}
