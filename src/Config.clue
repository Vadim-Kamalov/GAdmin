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

@define CONFIG_PATH         getWorkingDirectory() .. "\\" .. "GAdmin/config/Main.json"
@define DEFAULT_RENDER_SIZE 14

@import "Common" => common

static __config__ = {
    initialized = false,    // Module status. In config file it's always be true.
    def         = nil,

    // We need this to save config if it was changed (compare JSON file with self.root).
    jsonStrings = {
        file = "",
        root = ""
    },

    root = {
        online = {
            total       = 0,
            monday      = 0,
            tuesday     = 0,
            wednesday   = 0,
            thursday    = 0,
            friday      = 0,
            saturday    = 0,
            sunday      = 0
        },

        hotkeys = {
            mainWindow  = {30},
            acceptForm  = {73},
            showCursor  = {66},
            specReload  = {85},
            specCopy    = {0x12, VK_Q} // Alt + Q
        },

        windows = {
            adminList = {
                use                     = false,
                textAlignMode           = ALIGN_RIGHT,
                showAdminLvl            = true,
                textColorBasedOnClist   = true,
                strokeSize              = 1
            },

            playersNearby = {
                use                     = false,
                textAlignMode           = ALIGN_LEFT,
                showDistance            = true,
                showAdmins              = true,
                sortByDistance          = true, // Works only with `showDistance` enabled.
                maxPlayers              = 10,
                playerColorBasedOnClist = true,
                strokeSize              = 1
            },
            
            adminPanel = {
                show    = true,
                width   = 200,
                alpha   = 1.00,
                items   = {
                    { name = "NEXT", action = "{NEXT}", position = 1 },
                    { name = "SWITCH", action = "{SWITCH}", position = 2 },
                    { name = "BACK", action = "{BACK}", position = 3 },
                    { name = "STATS", action = "{STATS}", position = 4 },
                    { name = "SESSION", action = "{SESSION}", position = 5 },
                    { name = "FRISK", action = "{FRISK}", position = 6 },
                    { name = "EXIT", action = "{EXIT}", position = 7 }
                }
            },

            spectatorInformation = {
                use     = true,
                type    = 2
            },

            autoCompletion  = { use = false },
            checker         = { /* not implemented (fuck yea) */ },
            online          = { use = true },
            farChat         = { use = false },
            keyWatcher      = { use = false }
        },

        render = {
            size = {
                carInfo     = $DEFAULT_RENDER_SIZE,
                gunInfo     = $DEFAULT_RENDER_SIZE,
                admins      = $DEFAULT_RENDER_SIZE,
                wallhack    = $DEFAULT_RENDER_SIZE,
                fpsCounter  = $DEFAULT_RENDER_SIZE
            }
        },

        cheats = {
            tracers = {
                use         = false,
                maxLines    = 15,
                hitColor    = "FFC700",
                missColor   = "FFFFFF"
            },

            noCollision = { onChar = { use = false } },
            airbreak    = { use = false },
            wallhack    = { use = false }
        },

        additions = {
            fishEye = {
                use = false,
                fov = 101 // Safe range is `60 .. 110` without `skygrad.asi` ...
                          // ... plugin (that allows change fov within safe range without any visible artifacts).
            },
        
            fpsCounter = {
                use     = false,
                color   = "FFFFFF"
            },

            mention = {
                use     = false,
                color   = "4A86B6",
                alert   = { use = false } // TODO: implement
            },

            zoomSpectatorCamera = { use = false },
            swapLayout          = { use = false },
            idInKillList        = { use = false },
            deathNotifyInChat   = { use = false },
            showAdmins          = { use = true },
            gunInfo             = { use = false },
            autoLogin           = { use = false },
            autoAdminLogin      = { use = false },
            carInfo             = { use = false },
            spectatorActions    = { use = true }
        },

        fix = {
            chatOnVK_T = false
        },

        chat = {
            /**
            * { pattern = String|nil, colors = { old = String|nil, new = String } }...
            */
            changeColor = {},
        
            /**
             * { pattern = String|nil, color = String|nil }...
             */
            remove      = {}
        },

        user = {
            oocNickname = "",
            adminLvl = -1,

            password = {
                admin   = "",
                game    = ""
            },
        },

        binder = {
            commands = {
                gg = { message = "Приятной игры!" }
            }
        },

        notifications = {
            maxItems = 5 // 1 .. 5
        },

        movableWindows = {}
    }
}

/**
 * Save configuration file to $CONFIG_PATH.
 * @return void
 */
method __config__::save() {
    common::writeInFile($CONFIG_PATH, neatJSON(self.root), { sort = true, wrap = 40} )
}

/**
 * Save configuratin file to $CONFIG_PATH if it was changed.
 * @return void
 */
method __config__::saveIfChanged() {
    self.jsonStrings.root = encodeJson(self.root)
    if self.jsonStrings.file != self.jsonStrings.root {
        self::save()
    }
}

{
    if !__config__.initialized {
        __config__.def = __config__.root

        common::makeDirectoryTree({ "GAdmin", "GAdmin/temp", "GAdmin/config" })
        if !doesFileExist($CONFIG_PATH) {
            common::writeInFile($CONFIG_PATH, neatJSON(__config__.root, { sort = true, wrap = 40 }))
            __config__.jsonStrings.file = __config__.root
        } else {
            __config__.root, __config__.jsonStrings.file =
                decodeJson(common::readFileContent($CONFIG_PATH)),
                encodeJson($)
        }

        __config__.initialized = true
    }
}

return __config__
