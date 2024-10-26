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

@version 3.4.4

@import "Hook"             => hook
@import "Requests"         => requests
@import "Icons"            => icons
@import "Common"           => common
@import "Notifications"    => notify
@import "CompressedData"   => compressed
@import "CommandRequester" => commandRequester
@import "AutoUpdate"       => autoUpdate
@import "Config"           => config
@import "Assets"           => assets
@import "MovableWindows"   => movableWindows
@import "Timers"           => timers

@import "imgui.Style"       => style
@import "imgui.PlayerNotes" => playerNotes
@import "imgui.HotKey"      => HotKey
@import "imgui.Assets"      => imguiAssets

@import "game.Admins"    => admins
@import "game.GReport"   => greport
@import "game.Binder"    => binder
@import "game.User"      => user
@import "game.Spectator" => spectator

@define GADMIN_VERSION  "1.7.6"
@define SACHESS_VERSION "1.1"

@define COMMAND_DELAY       800
@define THEMES_URL          "https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/main/themes/Themes.xml"
@define AUTOUPDATE_URL      "https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/main/AutoUpdate.xml"
@define NICKNAME_COLORS_URL "https://raw.githubusercontent.com/Vadim-Kamalov/GAdmin/main/nickname-colors.conf"

@define SAMP_BASE                       getModuleHandle("samp.dll")
@define RECALL_UP_ADDR                  $SAMP_BASE + 0x65990
@define RECALL_DOWN_ADDR                $SAMP_BASE + 0x65A00
@define GET_BODY_PART_COORDINATES_ADDR  0x5E4280   

@define DEFAULT_FOV_VALUE 70

@define SERVER_NAME_TAGS_DISTANCE   20
@define SERVER_ADDRESS              "46.174.48.194"
@define SERVER_MAX_PLAYERS          600

@define COPYRIGHT_YEARS "2023-2024"

@define IS_ANY_MOUSE_BUTTON_CLICKED (imgui.IsMouseClicked(0) || imgui.IsMouseClicked(1) || imgui.IsMouseClicked(2))

@macro IMVEC4_TO_RGB(vector) { string.format("%02X%02X%02X", $vector.x * 255, $vector.y * 255, $vector.z * 255) }

@macro debugSuccessful(entryPoint, message) {
    sampfuncsLog(string.format(
        "{00FF00}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.SUCCESS] in <%s>:{FFFFFF} %s",
        os.date(),
        os.clock(),
        $entryPoint,
        $message
    ))
}

@macro debugWarning(entryPoint, message) {
    sampfuncsLog(string.format(
        "{FFA500}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.WARNING] in <%s>:{FFFFFF} %s",
        os.date(),
        os.clock(),
        $entryPoint,
        $message
    ))
}

@macro debugInformation(entryPoint, message) {
    sampfuncsLog(string.format(
        "{00BFFF}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.INFORMATION] in <%s>:{FFFFFF} %s",
        os.date(),
        os.clock(),
        $entryPoint,
        $message
    ))
}

@macro debugError(entryPoint, message) {
    sampfuncsLog(string.format(
        "{FF0000}[DATE: %s] [CLOCK: %.2f] [GADMIN.DEBUG.FATAL] in <%s>:{FFFFFF} %s",
        os.date(),
        os.clock(),
        $entryPoint,
        $message
    ))
}

@macro PLAYER_COLOR_TO_HEX(id) { string.format("%06X", sampGetPlayerColor($id) & 0xFFFFFF) }

static memory       = require("memory")
static encoding     = require("encoding")
static imgui        = require("mimgui")
static wm           = require("windows.message")
static ffi          = require("ffi")
static shell32      = ffi.load("shell32")
static effil        = require("effil")
static neatJSON     = require("neatjson")
static xml2lua      = require("xml2lua")
static sampev       = require("samp.events")
static vkeys        = require("vkeys")
static moonMonet    = require("MoonMonet")
static Vector3D     = require("vector3d")

static enum /* DIALOG_STYLE */ {
    DIALOG_STYLE_MSGBOX = 0,
    DIALOG_STYLE_INPUT,
    DIALOG_STYLE_LIST,
    DIALOG_STYLE_PASSWORD,
    DIALOG_STYLE_TABLIST,
    DIALOG_STYLE_TABLIST_HEADERS
}

require("moonloader")
math.randomseed(os.time())

static u8                       = encoding.UTF8
static spectatorCameraFov       = -1
static scriptLoadedWithGame     = false //! `true` only when called `sampev.onInitGame`.
static bulletData               = { lastId = 0 }
static nicknameColors           = {} //! { nickname: string, colors: number[] }...
static userThemes               = {} //! { author: string, version: string, title: string, link: string, description: string? = nil }...

local sendedAlogoutWarning  = false
local airbreak              = { status = false, coords = {} }
local fishEyeWeaponLock     = false
local userFullyConnected    = false

static enum /* ALIGN_TYPE */ {
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
}

imgui.OnInitialize(fn {
    local glyphRanges = imgui.GetIO().Fonts::GetGlyphRangesCyrillic()

    icons::init(30)
    style::apply()
    
    global bold10      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 16.0, nil, glyphRanges)
    global bold9       = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 14.0, nil, glyphRanges)
    global bold12      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 16.0, nil, glyphRanges)
    global bold14      = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 20.0, nil, glyphRanges)
    global regular9    = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 14.0, nil, glyphRanges)
    global regular10   = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 15.5, nil, glyphRanges)
    global regular12   = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 16.0, nil, glyphRanges)
    global regular14   = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 19.0, nil, glyphRanges)
    global bold        = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellBold, 25.0, nil, glyphRanges)
    global regular     = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(compressed.cantarellRegular, 25.0, nil, glyphRanges)
    
    global shadowPng   = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", compressed.shadow), #compressed.shadow)
    global cburnett    = imgui.CreateTextureFromFileInMemory(imgui.new("const char*", compressed.cburnett), #compressed.cburnett)

    imgui.GetIO().IniFilename = nil
})

global fn main() {
    while !isSampAvailable() { wait(0) }

    encoding.default = "CP1251"

@ifndef __GADMIN_DEBUG__
{
    if sampGetCurrentServerAddress() != $SERVER_ADDRESS {
        thisScript()::unload()
    }
}

    /** 
     * Initializing hot keys that used in this module.
     */
    local hotKeyCallbacks = {}

    hotKeyCallbacks.airbreak = fn {
        if config.root.cheats.airbreak.use && user::getAloginStatus() {
            airbreak.status         = !$
            local notificationTitle = "AirBreak " .. ((airbreak.status) ? "включен." : "выключен.")
            local notificationText  = ""

            if airbreak.status {
                airbreak.coords     = { getCharCoordinates(PLAYER_PED) }
                notificationText    = "Чтобы выключить - нажмите эту клавиши повторно."
            } else {
                notificationText = "Чтобы опять включить, нажмите эту клавишу повторно"
            }
        
            if local notificationType = config.root.cheats.airbreak.notificationType {
                if notificationType != NOTIFICATION_TYPE_NONE {
                    notify::send({
                        icon        = icons.ICON_ARROW_UP
                        title       = notificationTitle
                        text        = notificationText
                        duration    = 2
                    }, (notificationType == NOTIFICATION_TYPE_SCRIPT_MESSAGE) ? notificationTitle : nil)
                }
            }
        }
    }

    hotKeyCallbacks.spectatorQuit = fn {
        if spectator.status {
            sampSendMenuSelectRow(SPECTATOR_MENU_EXIT)
        }
    }

    hotKeyCallbacks.switchCursorState = fn {
        imguiAssets::switchCursorStatus()
    }

    hotKeyCallbacks.switchSpectatorState = fn {
        if spectator.status {
            sampSendMenuSelectRow(SPECTATOR_MENU_SWITCH)
        }
    }

    hotKeyCallbacks.nextPlayerInSpectator = fn {
        if spectator.status {
            sampSendMenuSelectRow(SPECTATOR_MENU_NEXT)
        }
    }

    hotKeyCallbacks.previousPlayerInSpectator = fn {
        if spectator.status {
            sampSendMenuSelectRow(SPECTATOR_MENU_BACK)
        }
    }

    HotKey::new("main->spectatorQuit", { VK_I }, "Выйти из /sp", HOTKEY_CONDITION_ONLY_IN_SPECTATOR)
        ::registerCallback(hotKeyCallbacks.spectatorQuit)

    HotKey::new("main->airbreak", { VK_RSHIFT }, "Аирбрейк", HOTKEY_CONDITION_ONLY_NOT_IN_SPECTATOR)
        ::registerCallback(hotKeyCallbacks.airbreak)
        
    HotKey::new("main->switchCursorState", { VK_B }, "Переключить курсор", HOTKEY_CONDITION_ALWAYS)
        ::registerCallback(hotKeyCallbacks.switchCursorState)

    HotKey::new("main->switchSpectatorState", { VK_U }, "Обновить камеру в /sp", HOTKEY_CONDITION_ONLY_IN_SPECTATOR)
        ::registerCallback(hotKeyCallbacks.switchSpectatorState)

    HotKey::new("main->nextPlayerInSpectator", { VK_RIGHT }, "Следующий игрок в /sp", HOTKEY_CONDITION_ONLY_IN_SPECTATOR)
        ::registerCallback(hotKeyCallbacks.nextPlayerInSpectator)

    HotKey::new("main->previousPlayerInSpectator", { VK_LEFT }, "Предыдущий игрок в /sp", HOTKEY_CONDITION_ONLY_IN_SPECTATOR)
        ::registerCallback(hotKeyCallbacks.previousPlayerInSpectator)

    playerNotes::initializeNotes()
    binder::initializeBinds()
    notify::send({
        title   = "GAdmin успешно запущен!",
        text    = "GAdmin версии " .. $GADMIN_VERSION .. " успешно инициализирован.",
        icon    = icons.ICON_STAR
    })

    /**
     * Callback to handle all alogouts (reconnect, etc.) when AirBreak is active.
     */
    user::addOnAloginCallback("Main->AirBreak", fn (state) {
        if !state && airbreak.status {
            airbreak.status = false
        }
    })

    for id = 1, config.root.additions.tracers.maxLines {
        bulletData[id] = {
            enable  = false,
            o       = { x, y, z },
            t       = { x, y, z },
            time    = 0,
            type    = 0
        }
    }

    timers::add(fn { return true }, fn {
        requests::fetchNicknameColors()
        requests::fetchUserThemes()
@ifndef __GADMIN_DEBUG__
{
        if !autoUpdate.windowState {
            autoUpdate::checkUpdates($AUTOUPDATE_URL)
        }
}
    }, 300)

    common::makeDirectoryTree({ "GAdmin", "GAdmin/temp", "GAdmin/config", "GAdmin/logs", "GAdmin/profiles" })
    assets::changeWallhackState(false)

@ifndef __GADMIN_DEBUG__
{
    autoUpdate::checkUpdates($AUTOUPDATE_URL)
}

    $JMP_HOOK_NEW onRecallUpHook    = hook::new("void(__thiscall*)(void*)", onRecallUpHook, $RECALL_UP_ADDR)
    $JMP_HOOK_NEW onRecallDownHook  = hook::new("void(__thiscall*)(void*)", onRecallDownHook, $RECALL_DOWN_ADDR)

@ifdef __GADMIN_DEBUG__
{
    $debugInformation!("system", "samp.dll base address: 0x" .. bit.tohex($SAMP_BASE))
    $debugSuccessful!("system", "CInput::RecallUp hook installed. Base address: 0x" .. bit.tohex($RECALL_UP_ADDR))
    $debugSuccessful!("system", "CInput::RecallDown hook installed. Base address: 0x" .. bit.tohex($RECALL_DOWN_ADDR))
    
    import("DebugCommands")::init()

    $debugSuccessful!("system", "registered `gdebug.*` debug commands")
    $debugSuccessful!("system", "GAdmin " .. $GADMIN_VERSION .." compelety loaded!")
}

    sampRegisterChatCommand("gadmin", fn { mainWindow::switch() })

    loop {
        wait(0)

        timers::initialize()

        if common::isGamePaused() {
            if os.clock() - user.afkTimeClock >= 1 {
                user.afkTimeClock = os.clock()
                user::setAfkTime(user::getAfkTime() + 1)
            }
        } else {
            user::setAfkTime(0)
            sendedAlogoutWarning = false
        }

        for index, admin in admins {
            if !sampIsPlayerConnected(admin.id) {
                admins::remove(index)
            }
        }

        if os.clock() - config.clock >= 600 /* 10m */ {
            config::saveIfChanged()
            config.clock = os.clock()
        }

        if config.root.additions.autoAlogout.use && user::getAloginStatus() {
            if user::getAfkTime() == config.root.additions.autoAlogout.alogoutSeconds {
                user::setAloginStatus(false)
                sampSendChat("/alogout")
                assets::sendWindowsNotification(
                    WINDOWS_NOTIFICATION_ICON_SECURITY,
                    "GAdmin v" .. $GADMIN_VERSION,
                    "Вы провели в AFK на /alogin " .. user::getAfkTime() .. " секунд. Скрипт покинул дежурство."
                )
            } elseif user::getAfkTime() == config.root.additions.autoAlogout.warningSeconds && !sendedAlogoutWarning {
                sendedAlogoutWarning = true
                assets::sendWindowsNotification(WINDOWS_NOTIFICATION_ICON_SECURITY, "GAdmin v" .. $GADMIN_VERSION, string.format(
                    "Вы провели в AFK на /alogin %d секунд. У вас есть еще %d секунд что-бы зайти, иначе скрипт сам покинет дежурство.",
                    user::getAfkTime(),
                    config.root.additions.autoAlogout.alogoutSeconds - config.root.additions.autoAlogout.warningSeconds
                ))
            }
        }

        commandRequester::loop()
        spectator::loop()
        greport::loop()
        user::updateTime()

        if movableWindows.changingWindowsPositions {
            displayHud(movableWindows.viewMode != MV_ONLY_IN_SPECTATOR)
            displayRadar(movableWindows.viewMode != MV_ONLY_IN_SPECTATOR)
        }
        
        if config.root.windows.killList.hideDefaultKillList && config.root.windows.killList.use {
            memory.write(sampGetKillInfoPtr() /* int iEnabled */, 0x0, 0x4 /* sizeof(int) */)
        }

        if config.root.windows.autoCompletion.use && isKeyDown(VK_CONTROL) && autoCompletion.condition() {
            if os.clock() - autoCompletion.clock >= 0.15 {
                if isKeyDown(VK_UP) {
                    autoCompletion.clock = os.clock()
                    autoCompletion.position = ($ == 1) ? autoCompletion.commandsLength : $ - 1
                } elseif isKeyDown(VK_DOWN) {
                    autoCompletion.clock = os.clock()
                    autoCompletion.position = ($ == autoCompletion.commandsLength) ? 1 : $ + 1
                }
            }
        }

        if config.root.fix.chatOnVK_T.use && isKeyJustPressed(VK_T) && !common::isInputsActive() {
            sampSetChatInputEnabled(true)
        }

        if airbreak.status && config.root.cheats.airbreak.use {
            local heading                   = getCharHeading(PLAYER_PED)
            local camCoordX, camCoordY      = getActiveCameraCoordinates()
            local targetCamX, targetCamY    = getActiveCameraPointAt()
            local angle                     = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
            local difference                = 1.0
            local speed                     = config.root.cheats.airbreak.speed
            
            if isCharInAnyCar(PLAYER_PED) {
                heading     = getCarHeading(storeCarCharIsInNoSave(PLAYER_PED))
                difference  = 0.79
            }

            setCharCoordinates(PLAYER_PED, airbreak.coords[1], airbreak.coords[2], airbreak.coords[3] - difference)

            if !common::isCursorActive() {
                if isKeyDown(VK_W) {
                    airbreak.coords[1] += speed * math.sin(-math.rad(angle))
                    airbreak.coords[2] += speed * math.cos(-math.rad(angle))

                    if !isCharInAnyCar(PLAYER_PED) {
                        setCharHeading(PLAYER_PED, angle)
                    } else {
                        setCarHeading(storeCarCharIsInNoSave(PLAYER_PED), angle)
                    }
                } elseif isKeyDown(VK_S) {
                    airbreak.coords[1] -= speed * math.sin(-math.rad(heading))
                    airbreak.coords[2] -= speed * math.cos(-math.rad(heading))    
                }

                if isKeyDown(VK_A) {
                    airbreak.coords[1] -= speed * math.sin(-math.rad(heading - 90))
                    airbreak.coords[2] -= speed * math.cos(-math.rad(heading - 90))
                } elseif isKeyDown(VK_D) {
                    airbreak.coords[1] -= speed * math.sin(-math.rad(heading + 90))
                    airbreak.coords[2] -= speed * math.cos(-math.rad(heading + 90))
                }

                if isKeyDown(VK_SPACE) || isKeyDown(VK_UP) {
                    airbreak.coords[3] += speed / 2.0
                }

                if isKeyDown(VK_LSHIFT) || isKeyDown(VK_DOWN) && airbreak.coords[3] > -95.0 {
                    airbreak.coords[3] -= speed / 2.0 
                } 
            }
        }

        if config.root.additions.fishEye.use || config.root.additions.zoomSpectatorCamera.use {
            local fov = {
                user        = (config.root.additions.fishEye.use) ? config.root.additions.fishEye.fov : $DEFAULT_FOV_VALUE
                spectator   = (config.root.additions.zoomSpectatorCamera.use)
                    ? spectatorCameraFov
                    : $DEFAULT_FOV_VALUE
            }

            fov.spectator = ($ == -1) ? fov.user : $

            local currentFov    = (spectator.status) ? fov.spectator : fov.user
            local charTargeting = memory.getint8(getCharPointer(PLAYER_PED) + 0x528, false) == 19
            local shiperRifleId = 34

            if isCurrentCharWeapon(PLAYER_PED, sniperRifleId) && charTargeting {
                if !fishEyeWeaponLock {
                    cameraSetLerpFov(70, 70, 1000, 1)
                    fishEyeWeaponLock = true
                }
            } else {
                cameraSetLerpFov(currentFov, currentFov, 1000, 1)
                fishEyeWeaponLock = false
            }
        }
    }
}

$JMP_HOOK /** void(__thiscall*)(void*) */ onRecallUpHook(...) {
    if !(config.root.windows.autoCompletion.use && isKeyDown(VK_CONTROL) && autoCompletion.condition()) {
        onRecallUpHook(...)
    }
}

$JMP_HOOK /** void(__thiscall*)(void*) */ onRecallDownHook(...) {
    if !(config.root.windows.autoCompletion.use && isKeyDown(VK_CONTROL) && autoCompletion.condition()) {
        onRecallDownHook(...)
    }
}
