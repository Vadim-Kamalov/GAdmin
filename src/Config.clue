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

@define CONFIG_PATH         getWorkingDirectory() .. "/GAdmin/config/Main.json"
@define DEFAULT_RENDER_SIZE 14

@import "Common" => common

static enum /* NOTIFICATION_TYPE */ {
    NOTIFICATION_TYPE_DEFAULT,
    NOTIFICATION_TYPE_SCRIPT_MESSAGE,
    NOTIFICATION_TYPE_NONE
}

static __config__ = {
    initialized = false,    // Module initializing status.
    def         = nil,      // Same as `root`, but with default values.

    // We need this to save config if it was changed (compare JSON file with self.root).
    jsonStrings = {
        file = "",
        root = ""
    },

    root = {
        windows = {
            adminList = {
                use                     = false,
                sortByLvl               = false,
                textAlignMode           = 3,
                showAdminLvl            = true,
                textColorBasedOnClist   = true,
                strokeSize              = 1,
                countForScrollbar       = 10
            },

            playersNearby = {
                use                     = false,
                textAlignMode           = 1,
                showDistance            = true,
                showAdmins              = true,
                sortByDistance          = true, // Works only with `showDistance` enabled.
                maxPlayers              = 10,
                playerColorBasedOnClist = true,
                strokeSize              = 1
            },

            spectatorInformation = {
                use                 = true,
                type                = 2,
                showedHintFirstTime = false,
                columns             = {
                    { "Пинг",                   true },
                    { "ID аккаунта",            true },
                    { "Дата регистрации",       true },
                    { "Наличные/банк",          true },
                    { "Здоровье/броня",         true },
                    { "Фракция",                true },
                    { "Должность",              true },
                    { "Машина(-ы)",             true },
                    { "Стадия",                 true },
                    { "VIP статус",             true },
                    { "Предупреждения",         true },
                    { "Время в афк",            true },
                    { "Тек./макс. скорость",    true },
                    { "Выстрелы/попадания",     true },
                    { "Двигатель",              true },
                    { "Двери",                  true },
                }
            },
            
            killList = {
                use                     = false,
                displayTime             = true,
                hideDefaultKillList     = true,
                displayId               = true,
                playerColorBasedOnClist = true,
                strokeSize              = 1,
                textAlignMode           = 1,
                maxItems                = 5
            },

            notifications = {
                use         = true,
                maxItems    = 5
            },

            farChat = {
                use         = false,
                maxLines    = 8,
                strokeSize  = 1,
                ignore      = {},

                displayTime = true,

                // In cases when message can repeated (for example, /phone message can spam),
                // use this option. Delay in seconds.
                delay       = 2
            },
            
            playerChecker = { 
                use                     = false,
                notificationType        = 1,
                strokeSize              = 1,
                textAlignMode           = 3,
                displayOfflinePlayers   = true,
                playerColorBasedOnClist = true,
                players                 = {
                    /** { nickname = string, commentary = string|nil }... */
                }
            },

            autoCompletion = {
                use         = true,
                strokeSize  = 1,
                commands    = { /** { name = string, description = string }... */},
            },

            userInformation = {
                use             = false,
                showTime        = true,
                textAlignMode   = 3,
                strokeSize      = 1,
                display         = {
                    { "ID",                 true },
                    { "IC никнейм",         true },
                    { "OOC никнейм",        true },
                    { "Админ уровень",      true },
                    { "Пинг",               true },

                    "NewLine",

                    { "Общий онлайн",       true },
                    { "Онлайн за неделю",   true },
                    { "Онлайн за сессию",   true },

                    "NewLine",

                    { "Ответов всего",      true },
                    { "Ответов за неделю",  true },
                    { "Ответов за сесcию",  true }
                }
            },

            greport = {
                use                     = true,
                soundNotification       = true,
                preferNotifications     = true,
                reminderNotification    = true,
                remindSeconds           = 120,
                inputCopyButtons        = {
                    { "Приятной игры!",         "Приятной игры!" },
                    { "Передал",                "Передал." },
                    { "Нет тех. причины",       "Не чиним/лечим/телепортируем/спавним без технической причины." },
                    { "Пишите на форум",        "Пишите жалобу на форум, туда со всеми доказательствами." },
                    { "Слежу",                  "Слежу за игроком." },
                    { "Следите за новостями",   "Следите за новостями." }
                }
            },
            
            spectatorActions = {
                use         = true,
                windowSizeY = 100,
                buttons     = {
                    { "*Вы тут?*", "/ans ${{ SPECTATOR_ID }} Вы тут? Ответ в /b или /pm ${{ USER_ID }}", true },
                    { "ANS", "^/ans ${{ SPECTATOR_ID }} ", true },
                    { "AHEAL", "/aheal ${{ SPECTATOR_ID }}", true },
                    { "STATS", 3, true },
                    { "AFRISK", 5, true },
                    { "PAME", "/pame ${{ SPECTATOR_ID }}", true },
                    { "WARN", "^/warn ${{ SPECTATOR_ID }} ", true },
                    { "SLAP", "/slap ${{ SPECTATOR_ID }}", true },
                    { "SWITCH", 1, true },
                    { "GETBUYCAR", "^/getbuycar ", true },
                    { "BAN", "^/ban ${{ SPECTATOR_ID }} ", true },
                    { "KICK", "^/kick ${{ SPECTATOR_ID }} ", true },
                    { "BMUTE", "^/bmute ${{ SPECTATOR_ID }} ", true },
                    { "EXIT", 6, true },
                    { "ASPAWN", "/aspawn ${{ SPECTATOR_ID }}", true }
                    { "PK", "/pk ${{ SPECTATOR_ID }}", true }
                }
            },

            spectatorKeys = { use = true },
        },

        render = {
            size = {
                common = $DEFAULT_RENDER_SIZE
            }
        },

        cheats = {
            airbreak = {
                use                 = false,
                notificationType    = 1,
                speed               = 1.0
            },

            wallhack = {
                use                 = false,
                imguiStyle          = false,
                notificationType    = 1
            },

            clickwarp = { use = false }
        },

        additions = {
            fishEye = {
                use = false,
                fov = 101 // Safe range is `60 .. 110` without `skygrad.asi` ...
                          // ... plugin (that allows change fov within safe range without any visible artifacts).
            },

            disableServerMessages = {
                use             = false,
                anticheat       = false,
                punishments     = false,
                complaints      = false,
                questions       = false,
                adminActions    = false,
                playerActions   = false
            },

            commandRequester = {
                use                 = true,
                windowPositionY     = select(2, getScreenResolution()),
                displayType         = 2,
                secondsToHide       = 5,
                soundNotification   = true,
                allowedCommands     = {
                    { "pk",         4 },
                    { "ck",         4 },
                    { "slap",       4 },
                    { "unfreeze",   4 },
                    { "setworld",   4 },
                    { "setint",     4 },
                    { "dpame",      4 },
                    { "leave",      4 },
                    { "makemic",    4 },
                    { "unwarn",     4 },
                    { "aheal",      4 },
                    { "warn",       3 },
                    { "ban",        3 },
                    { "kick",       3 },
                    { "mute",       3 },
                    { "bmute",      3 },
                    { "iban",       3 },
                    { "jail",       3 },
                    { "vspawn",     2 },
                    { "vfuel",      2 }
                }
            },

            mention = {
                use                 = true,
                soundNotification   = true,
                notificationType    = 1, 
                color               = "4A86B6"
            },

            zoomSpectatorCamera = {
                use     = false
                step    = 5
            },

            tracers = {
                use                     = true,
                maxLines                = 15,
                hitColor                = "FFC700",
                missColor               = "FFFFFF",
                showOnlyForSpectator    = false,
                notificationType        = 1
            },

            shortCommands = {
                use         = true,
                commands    = {
                    vr  = "vrepair %s",
                    as  = "aspawn %s"
                    vs  = "vspawn %s",
                    ah  = "aheal %s",
                    af  = "afrisk %s",
                    uf  = "unfreeze %s",
                    g   = "goto %s",
                    gh  = "gethere %s",
                    gc  = "getcar %s",
                    gbc = "getbuycar %s",
                    pt  = "ptop %s"
                    jb  = "ans %s Пишите жалобу на форум, туда со всеми доказательствами",
                    asl = "ans %s Слежу за игроком",
                    ar  = "kick %s AFK on ROAD",
                    ak  = "kick %s AFK without ESC",
                    ap  = "kick %s AFK public place"
                }
            },

            autoLogin = {
                use             = false,
                accountPassword = "",
                aloginPassword  = ""
            },

            reportOneColor = {
                use     = true,
                color   = "FFFF00"
            },

            autoAlogout = {
                use             = false,
                warningSeconds  = 90,
                alogoutSeconds  = 120
            },
            
            carInfo = { 
                use             = false,
                onlyInSpectator = false
            },
            
            autoAACommand           = { use = false },
            hideSpectatorMenu       = { use = true },
            swapLayout              = { use = false },
            idInKillList            = { use = false },
            deathNotifyInChat       = { use = false },
            showAdmins              = { use = true },
            displayIdInIc           = { use = false },
            gunInfo                 = { use = false },
            autoAdminLogin          = { use = false },
            hideIpAddresses         = { use = false },
            changeNicknameColors    = { use = true }
        },

        fix = {
            chatOnVK_T = { use = true }
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
            oocNickname = "Администратор",
            adminLvl    = -1,

            online = {
                total = 0,
                weeks = {}
            },

            answers = {
                total = 0,
                weeks = {}
            },
        },

        autoUpdate = {
            hasUpdateInstalled  = false,
            skipVersionUpdate   = "0.0"
        },

        binds = {
            {
                keys        = {},
                value       = "/ans ${{ GET_ARGUMENT, 1 }} Приятной игры!",
                commandName = "gg",
                title       = "/gg"
            },

            { 
                keys        = {},
                value       = "/a Взял на слежку ${{ GET_ARGUMENT, 1 }} ID.\n/sp ${{ GET_ARGUMENT, 1 }}",
                commandName = "asp",
                title       = "/asp"
            },

            {
                keys        = {},
                value       = "/aspawn ${{ GET_ARGUMENT, 1 }}\n/aheal ${{ GET_ARGUMENT, 1 }}",
                commandName = "sph",
                title       = "/aspawn + /aheal"
            }
        },

        styleChangeableWindows  = {},
        hotKeys                 = {},
        movableWindows          = {},
        playerNotes             = {}
    }
}

/**
 * Save configuration file to $CONFIG_PATH.
 * @return void
 */
method __config__::save() {
    common::writeInFile($CONFIG_PATH, neatJSON(self.root), { sort = true, wrap = 40 } )
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

        local fn mergeTables(a, b) {
            for key, value of b {
                if type(value) == "table" {
                    if type(a[key]) == "table" {
                        mergeTables(a[key], value)
                    } elseif a[key] == nil {
                        a[key] = value
                    }
                } elseif a[key] == nil {
                    a[key] = value
                }
            }
        }

        mergeTables(__config__.root, __config__.def)

        __config__.initialized = true
    }
}

return __config__
