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

@define CONFIG_PATH         getWorkingDirectory() .. "/GAdmin/config/Main.json"
@define DEFAULT_RENDER_SIZE 14

@import "Common" => common
@import "Assets" => assets

static enum /* NOTIFICATION_TYPE */ {
    NOTIFICATION_TYPE_DEFAULT,
    NOTIFICATION_TYPE_SCRIPT_MESSAGE,
    NOTIFICATION_TYPE_NONE
}

static __config__ = {
    initialized = false,      // Module initializing status.
    def         = nil,        // Same as `root`, but with default values.
    clock       = os.clock(), // Need for saving settings each 10 minutes.

    // We need this to save config if it was changed (compare JSON file with self.root).
    jsonStrings = {
        file = "",
        root = ""
    },

    root = {
        windows = {
            adminList = {
                use                     = false,
                sortByLvl               = true,
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
                sortByDistance          = true,
                maxPlayers              = 10,
                playerColorBasedOnClist = true,
                strokeSize              = 1
            },

            spectatorInformation = {
                use                 = true,
                type                = 1,
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
                    { "Модульный мир",          true },
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
                use      = true,
                maxItems = 5,
                align    = 3
            },

            farChat = {
                use         = false,
                maxLines    = 8,
                strokeSize  = 1,
                displayTime = true,
                ignore      = {}

                // In cases when message can repeated (for example, /phone message can spam),
                // use this option. Delay in seconds.
                delay = 2
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
                strokeSize  = 1
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

            roundMenu = {
                use    = false,
                radius = 300
            },

            chess                 = { use = true },
            vehicleSelectionPanel = { use = true },
            spectatorKeys         = { use = true }
        },

        render = {
            size = {
                common = $DEFAULT_RENDER_SIZE
            }
        },

        cheats = {
            airbreak = {
                use              = false,
                notificationType = 1,
                speed            = 1.0
            },

            wallhack = {
                use              = false,
                imguiStyle       = false,
                renderBones      = false,
                showDistance     = false,
                notificationType = 1,
                textSize         = 15
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
                soundNotification   = true
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
                use              = false,
                onlyInSpectator  = false,
                notificationType = 1,
                textSize         = 16
            },

            deathNotifyInChat = {
                use   = false,
                color = "AFAFAF"
            },
            
            showAdmins = {
                use         = true,
                color       = "FF8585",
                textSize    = 15
            },
            
            gunInfo = {
                use         = false,
                textSize    = 15
            },
            
            autoAACommand           = { use = false },
            hideSpectatorMenu       = { use = true },
            swapLayout              = { use = true },
            idInKillList            = { use = false },
            displayIdInIc           = { use = false },
            autoAdminLogin          = { use = false },
            hideIpAddresses         = { use = true },
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

        globalTheme             = nil,
        styleChangeableWindows  = {},
        hotKeys                 = { conditions = {} },
        movableWindows          = {},
        playerNotes             = {}
    }
}

/**
 * Save configuration file to $CONFIG_PATH.
 * @return void
 */
method __config__::save() {
    common::writeInFile($CONFIG_PATH, neatJSON(self.root, { sort = true, wrap = 40 }))
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

/**
 * Initialize configuration and make self.root, self.def available.
 * @return void 
 */
method __config__::initialize() {
    self.def = self.root

    common::makeDirectoryTree({ "GAdmin", "GAdmin/temp", "GAdmin/config", "GAdmin/logs" })

    if !doesFileExist($CONFIG_PATH) {
        self.jsonStrings.file = self.root
        self::save()
    } else {
        local settings = decodeJson(common::readFileContent($CONFIG_PATH))
        if settings && type(settings) == "table" {
            self.root             = settings
            self.jsonStrings.file = encodeJson(self.root)
        } else {
            local scriptInformationPath = string.format(
                "%s\\GAdmin\\logs\\CollectInformation (%s).log",
                getWorkingDirectory(),
                os.date("%Y%m%d-%H-%M-%S")
            )

            self.root             = self.def
            self.jsonStrings.file = encodeJson(self.root)

            $debugError!("config::initialize", "something went wrong with configuration. Configuration will be reset.")
            $debugError!("config::initialize", "saved script information in " .. scriptInformationPath)

            common::writeInFile($CONFIG_PATH, neatJSON(self.def, { sort = true, wrap = 40 }))
            lua_thread.create(fn {
                while !isSampAvailable() { wait(0) }
                common::writeInFile(scriptInformationPath, assets::collectScriptInformation())
                common::sendScriptMessage("Something went wrong with the settings file.")
                common::sendScriptMessage("The settings will be reset and information about the script will be written to the next file:")
                common::sendScriptMessage(scriptInformationPath)
            })

            return
        }
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

    mergeTables(self.root, self.def)
}

if local this = __config__ {
    if !this.initialized {
        this::initialize()
        this.initialized = true
    }
}

return __config__
