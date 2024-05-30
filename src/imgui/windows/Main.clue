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
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.HotKey"          => HotKey
@import "imgui.Style"           => style
@import "imgui.PlayerNotes"     => playerNotes
@import "imgui.drawList.Shadow" => shadow
@import "imgui.InputTextFilter" => InputTextFilter

@import "game.Binder"           => binder
@import "game.User"             => user
@import "game.samp.Player"      => sampPlayer
@import "game.ServerTables"     => serverTables

@import "Notifications"     => notify
@import "MovableWindows"    => movableWindows
@import "Assets"            => assets
@import "Config"            => config
@import "Common"            => common
@import "Icons"             => icons

local enum /* WINDOW_SELECTED_FRAME */ {
    WINDOW_SELECTED_FRAME_HOME,
    WINDOW_SELECTED_FRAME_SETTINGS,
    WINDOW_SELECTED_FRAME_KEYBINDS,
    WINDOW_SELECTED_FRAME_PLAYERS_CHECKER,
    WINDOW_SELECTED_FRAME_CUSTOMIZATION,
    WINDOW_SELECTED_FRAME_BINDER,
    WINDOW_SELECTED_FRAME_LOGS,
    WINDOW_SELECTED_FRAME_SERVER_TABLES,
    WINDOW_SELECTED_FRAME_NOTES,
    WINDOW_SELECTED_FRAME_STATISTICS
}

local enum /* WINDOW_WIDGET */ {
    WINDOW_WIDGET_SWITCH,
    WINDOW_WIDGET_SLIDER_INT,
    WINDOW_WIDGET_SLIDER_FLOAT,
    WINDOW_WIDGET_COLOR_PICKER,
    WINDOW_WIDGET_TYPE_SELECTOR,
    WINDOW_WIDGET_INPUT,
    WINDOW_WIDGET_CUSTOM,
    WINDOW_WIDGET_CONFIGURATION_IN_POPUP
}

static allowedLogs = {
    { "IC чат/действия", {} },
    { "OOC чат", {} },
    { "Действия/чат администраторов", {} },
    { "Килл-лист", {} },
    { "Входы/Выходы", {} }
}

local sizeX, sizeY = getScreenResolution()
static mainWindow = nil

local window = {
    state                 = false,
    frame                 = {},
    recentlyOpened        = false,
    closeAndOpenAnimation = { alpha = 0, clock = nil }
    menu                  = {
        UI_MENU_ITEMS   = {},

        selectedFrame           = WINDOW_SELECTED_FRAME_HOME,
        previousSelectedFrame   = WINDOW_SELECTED_FRAME_HOME,

        button  = imgui.GetStyle().Colors[imgui.Col.Button]
        width   = 60,
        state   = false,
        clock   = nil,

        alpha                       = 0,
        switchBetweenFramesAlpha    = 0
    },
    
    checker = {
        filter          = InputTextFilter::new(),
        playerNote      = imgui.new.char[65535]((config.root.windows.playerChecker.players[1]?.commentary) || ""),
        selectedPlayer  = (config.root.windows.playerChecker.players[1]) ? 1 : -1
    },
   
    customization = {
        editors         = nil,
        selectedId      = nil,
        copiedValues    = nil,
        
        colorPicker = {
            clock = nil,
            alpha = nil
        },

        moonMonet = {
            toggle = imgui.new.bool(),
            accent = imgui.new.float[4](0, 0, 0, 1)
        },

        combo = {
            buffer  = imgui.new.int(),
            array   = nil,
            size    = 0
        }
    },

    binder = {
        callPopup       = false,
        selectedBind    = 1,
        body            = {
            title   = imgui.new.char[20]((config.root.binds[1]?.title) || ""),
            value   = imgui.new.char[65535]((config.root.binds[1]?.value) || ""),
            command = imgui.new.char[144]((config.root.binds[1]?.commandName) || ""),
            delay   = imgui.new.int((config.root.binds[1]?.delay) || $COMMAND_DELAY)
        },

        popup = {
            inputParameter = imgui.new.char[256]()
        }
    },

    logs = {
        selected    = 1,
        voidQuote   = assets.voidQuotes[math.random(#assets.voidQuotes)],
        filter      = InputTextFilter::new()
    },

    serverTables = {
        selected    = 0,
        filter      = InputTextFilter::new()
    },

    notes = {
        selected    = 1,
        voidQuote   = assets.voidQuotes[math.random(#assets.voidQuotes)],
        title       = imgui.new.char[144](config.root.playerNotes[1]?.title || ""),
        body        = imgui.new.char[65535](config.root.playerNotes[1]?.body || ""),
        display     = imgui.new.bool(config.root.playerNotes[1]?.display || false)
    },

    popupModal = {
        body = nil, // function
        size = imgui.ImVec2(0, 0)
    },

    configuration = {
        { "windows", "Окна", {
            { "autoCompletion", "Авто-заполнение", {
                { "use", "TAB - вставить\nCTRL + Arrow Up/Down - переключение между элементами", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.autoCompletion.use) },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.autoCompletion.strokeSize) },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "vehicleSelectionPanel", "Выбор машины для спавна", {
                {
                    "use",
                    "Активация: ввод /veh без аргументов.\nДоступно только с 4 уровня и на /alogin",
                    WINDOW_WIDGET_SWITCH,
                    imgui.new.bool(config.root.windows.vehicleSelectionPanel.use)
                }
            }},
            
            { "userInformation", "Ваша статистика", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.userInformation.use) },
                { "showTime", "Отображать текущее время", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.userInformation.showTime) },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.userInformation.strokeSize) },
                { "textAlignMode", "Выравнивание текста", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.userInformation.textAlignMode), "Слева", "По центру", "Справа" },
                { "none", "Отображение элементов", WINDOW_WIDGET_CUSTOM, $USER_INFORMATION_CUSTOM_WIDGET!() }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "farChat", "Дальний чат", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.farChat.use) },
                { "displayTime", "Отображать время", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.farChat.use) },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.farChat.strokeSize) },
                { "delay", "Задержка между повторными сообщениями", WINDOW_WIDGET_SLIDER_INT, 2, 10, imgui.new.int(config.root.windows.farChat.delay) },
                { "maxLines", "Максимальное кол-во строк", WINDOW_WIDGET_SLIDER_INT, 1, 30, imgui.new.int(config.root.windows.farChat.maxLines) },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "spectatorActions", "Действия в /sp", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.spectatorActions.use) },
                { "windowSizeY", "Высота окна", WINDOW_WIDGET_SLIDER_INT, 50, 500, imgui.new.int(config.root.windows.spectatorActions.windowSizeY) },
                { "buttons", "Кнопки", WINDOW_WIDGET_CUSTOM, $SPECTATOR_ACTIONS_CUSTOM_WIDGET!() }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "spectatorInformation", "Информация об игроке", {
                { "use", "Работает только в режиме наблюдения", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.spectatorInformation.use) },
                { "type", "Количество столбцов на одной строке", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.spectatorInformation.type), "2", "4" },
                { "none", "Отображение элементов", WINDOW_WIDGET_CUSTOM, $SPECTATOR_INFORMATION_CUSTOM_WIDGET!() }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "spectatorKeys", "Клавиши игрока в /sp", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.spectatorKeys.use) }
            }},

            { "roundMenu", "Круговое меню поиска", {
                { "use", "Меню, в котором можно выбрать игрока/машину от центра экрана и выполнять разные действия.\nАктивация: удерживать соответствующий хоткей. (см. Горячие клавиши -> Круговое меню поиска)\nРаботает только на /alogin.", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.roundMenu.use) },
                { "radius", "Радиус поиска", WINDOW_WIDGET_SLIDER_INT, 100, 1000, imgui.new.int(config.root.windows.roundMenu.radius) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "killList", "Килл-лист", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.killList.use) },
                { "displayTime", "Отображать время", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.killList.displayTime) },
                { "displayId", "Отображать ID игроков", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.killList.displayId) },
                { "hideDefaultKillList", "Скрывать килл-лист игры", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.killList.hideDefaultKillList) },
                { "playerColorBasedOnClist", "Цвет игроков зависит от их клиста", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.killList.playerColorBasedOnClist) },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.killList.strokeSize) },
                { "textAlignMode", "Выравнивание текста", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.killList.textAlignMode), "Слева", "По центру", "Справа" },
                { "maxItems", "Макс. кол-во элементов", WINDOW_WIDGET_SLIDER_INT, 1, 100, imgui.new.int(config.root.windows.killList.maxItems) },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "notifications", "Оповещения", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.notifications.use) },
                { "maxItems", "Макс. кол-во оповещений", WINDOW_WIDGET_SLIDER_INT, 1, 5, imgui.new.int(config.root.windows.notifications.maxItems) },
                { "align", "Позиция оповещений", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.notifications.align), "Слева", "По центру", "Справа" }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "adminList", "Список админов", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.adminList.use) },
                { "showAdminLvl", "Отображать уровни администраторов", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.adminList.showAdminLvl) },
                { "sortByLvl", "Сортировать по уровням", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.adminList.sortByLvl) },
                { "textColorBasedOnClist", "Цвет зависит от клиста", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.adminList.textColorBasedOnClist) },
                { "textAlignMode", "Выравнивание текста", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.adminList.textAlignMode), "Слева", "По центру", "Справа" },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.adminList.strokeSize) }
                { "countForScrollbar", "Количество админов для появления скролла", WINDOW_WIDGET_SLIDER_INT, 1, 100, imgui.new.int(config.root.windows.adminList.countForScrollbar) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "playersNearby", "Список игроков рядом", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playersNearby.use) },
                { "showDistance", "Отображать дистанцию", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playersNearby.showDistance) },
                { "showAdmins", "Отображать администраторов", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playersNearby.showAdmins) },
                { "sortByDistance", "Сортировать по дистанции", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playersNearby.sortByDistance) },
                { "playerColorBasedOnClist", "Цвет зависит от клиста", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playersNearby.playerColorBasedOnClist) },
                { "textAlignMode", "Выравнивание текста", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.playersNearby.textAlignMode), "Слева", "По центру", "Справа" },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.playersNearby.strokeSize) },
                { "maxPlayers", "Максимальное кол-во игроков", WINDOW_WIDGET_SLIDER_INT, 1, 30, imgui.new.int(config.root.windows.playersNearby.maxPlayers) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "greport", "Улучшенный /greport", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.greport.use) },
                { "preferNotifications", "Использовать оповещения GAdmin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.greport.preferNotifications) },
                { "soundNotification", "Звуковое оповещение", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.greport.soundNotification) },
                { "inputCopyButtons", "Кнопки вставляющие текст в поле ввода", WINDOW_WIDGET_CUSTOM, $GREPORT_MAKE_CUSTOM_ELEMENT!() },
                { "reminderNotification", "Напоминание при долгом простое с активным репортом", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.greport.reminderNotification) },
                { "remindSeconds", "Время до напоминания при простое", WINDOW_WIDGET_SLIDER_INT, 10, 600, imgui.new.int(config.root.windows.greport.remindSeconds) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "playerChecker", "Чекер игроков", {
                { "use", "Игроки добавляются через раздел \"Чекер\" в меню.\nРаботает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playerChecker.use) },
                { "notificationType", "Тип оповещения при заходе/выходе игрока", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.playerChecker.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" },
                { "displayOfflinePlayers", "Отображать игроков в оффлайне", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playerChecker.displayOfflinePlayers) },
                { "playerColorBasedOnClist", "Цвет игрока зависит от клиста", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.playerChecker.playerColorBasedOnClist) },
                { "strokeSize", "Размер обводки", WINDOW_WIDGET_SLIDER_INT, 0, 5, imgui.new.int(config.root.windows.playerChecker.strokeSize) },
                { "textAlignMode", "Выравнивание текста", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.windows.playerChecker.textAlignMode), "Слева", "По центру", "Справа" },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "chess", "Шахматы", {
                { "use", "Активация по горячей клавише (см. Горячие клавиши -> Открыть/закрыть шахматы)", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.windows.chess.use) }
            }}
        }},

        { "cheats", "Читы", {
            { "airbreak", "Airbreak", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.cheats.airbreak.use) },
                { "notificationType", "Тип оповещения при нажатии на хоткей", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.cheats.airbreak.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" }
                { "speed", "Скорость", WINDOW_WIDGET_SLIDER_FLOAT, 0.5, 3.0, imgui.new.float(config.root.cheats.airbreak.speed) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "clickwarp", "ClickWarp", {
                { "use", "Работает только на /alogin\nТелепортация - колесико мыши.", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.cheats.clickwarp.use) }
            }},

            { "wallhack", "Wallhack", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.cheats.wallhack.use), fn {
                    if !config.root.cheats.wallhack.imguiStyle {
                        assets::changeWallhackState(config.root.cheats.wallhack.use && user::getAloginStatus())
                    }
                }},
                { "imguiStyle", "Использовать ImGui рендер", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.cheats.wallhack.imguiStyle), fn {
                    assets::changeWallhackState(!config.root.cheats.wallhack.imguiStyle)
                }},
                { "textSize", "Размер текста в ImGui рендере", WINDOW_WIDGET_SLIDER_INT, 5, 50, imgui.new.int(config.root.cheats.wallhack.textSize) },
                { "renderBones", "Рисовать кости на скине", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.cheats.wallhack.renderBones) },
                { "notificationType", "Тип оповещения при нажатии на хоткей", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.cheats.wallhack.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP }
        }},

        { "additions", "Прочее", {
            { "autoAdminLogin", "/alogin при спавне", {
                { "use", "Для автоматического ввода пароля включите и настройте авто-ввод паролей", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.autoAdminLogin.use) }
            }},

            { "swapLayout", "Авто-исправление команд", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.swapLayout.use) }
            }},

            { "autoAACommand", "Автоматический /aa", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.autoAACommand.use) }
            }},

            { "autoAlogout", "/alogout по времени", {
                { "use", "/alogout введется если вы простояли в афк больше разрешенного.", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.autoAlogout.use), fn {
                    if !config.root.additions.autoAlogout.use {
                        assets::workInBackground(false)
                    }
                }},
                { "warningSeconds", "Секунд до предупреждения", WINDOW_WIDGET_SLIDER_INT, 10, 600, imgui.new.int(config.root.additions.autoAlogout.warningSeconds) },
                { "alogoutSeconds", "Секунд до /alogout", WINDOW_WIDGET_SLIDER_INT, 10, 600, imgui.new.int(config.root.additions.autoAlogout.alogoutSeconds) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "autoLogin", "Авто-ввод паролей", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.autoLogin.use) },
                { "accountPassword", "Пароль от аккаунта", WINDOW_WIDGET_INPUT, imgui.new.char[48](config.root.additions.autoLogin.accountPassword) },
                { "aloginPassword", "Пароль от /alogin", WINDOW_WIDGET_INPUT, imgui.new.char[48](config.root.additions.autoLogin.aloginPassword) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "commandRequester", "Админские формы", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.commandRequester.use) },
                { "soundNotification", "Звуковое оповещение", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.commandRequester.soundNotification) },
                { "displayType", "Режим отображения полученной формы", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.additions.commandRequester.displayType), "Оповещение", "Полоса состояния снизу экрана" },
                { "windowPositionY", "Позиция полосы по Y", WINDOW_WIDGET_SLIDER_INT, 0, select(2, getScreenResolution()), imgui.new.int(config.root.additions.commandRequester.windowPositionY) },
                { "secondsToHide", "Время для закрытия формы", WINDOW_WIDGET_SLIDER_INT, 5, 30, imgui.new.int(config.root.additions.commandRequester.secondsToHide) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "idInKillList", "Айди в килл листе", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.idInKillList.use) }
            }},
            
            { "carInfo", "Информация о машине", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.carInfo.use) },
                { "onlyInSpectator", "Отображать только в /sp", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.carInfo.onlyInSpectator) },
                { "notificationType", "Тип оповещения при нажатии на хоткей", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.additions.carInfo.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" },
                { "textSize", "Размер шрифта", WINDOW_WIDGET_SLIDER_INT, 5, 50, imgui.new.int(config.root.additions.carInfo.textSize) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "shortCommands", "Короткие команды", {
                { "use", `vr = vrepair
as = aspawn
vs = vspawn
ah = aheal
uf = unfreeze
g = goto
gh = gethere
gc = getcar
gbc = getbuycar
pt = ptop
jb = ans <id> Пишите жалобу на форум
asl = ans <id> Слежу за игроком
ar = kick <id> AFK on ROAD
ak = kick <id> AFK without ESC
ap = kick <id> AFK public place`, WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.shortCommands.use) }
            }},

            { "reportOneColor", "Один цвет для репорта", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.reportOneColor.use) },
                { "color", "Цвет", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.reportOneColor.color) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "gunInfo", "Отображение оружия у игрока", {
                { "use", "Работает только на /alogin", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.gunInfo.use) },
                { "textSize", "Размер шрифта", WINDOW_WIDGET_SLIDER_INT, 5, 50, imgui.new.int(config.root.additions.gunInfo.textSize) },
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "zoomSpectatorCamera", "Отдаление камеры в /sp", {
                { "use", "Отдаление на колесико мыши в спектаторе", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.zoomSpectatorCamera.use) },
                { "step", "Шаг", WINDOW_WIDGET_SLIDER_INT, 1, 15, imgui.new.int(config.root.additions.zoomSpectatorCamera.step) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "displayIdInIc", "Отображение айди в IC", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.displayIdInIc.use) }
            }},
            
            { "showAdmins", "Показывать админов", {
                { "use", "Показывать администраторов на скине, если он таковым является", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.showAdmins.use) },
                { "textSize", "Размер шрифта", WINDOW_WIDGET_SLIDER_INT, 5, 50, imgui.new.int(config.root.additions.showAdmins.textSize) },
                { "color", "Цвет никнейма", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.showAdmins.color) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "hideIpAddresses", "Прятать IP адреса", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.hideIpAddresses.use) }
            }},
            
            { "hideSpectatorMenu", "Прятать меню в /sp", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.hideSpectatorMenu.use) }
            }},
            
            { "disableServerMessages", "Скрытие системных сообщений", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.use) },
                { "anticheat", "Сообщения античита", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.anticheat) },
                { "punishments", "Наказания от администраторов", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.punishments) },
                { "complaints", "Жалобы", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.complaints) },
                { "questions", "Вопросы", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.questions) },
                { "adminActions", "Действия администраторов", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.adminActions) },
                { "playerActions", "Действия игроков (/pame, GBUY, /caract, граффити)", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.disableServerMessages.playerActions) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },
            
            { "fishEye", "Рыбий глаз", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.fishEye.use) },
                { "fov", "Глубина", WINDOW_WIDGET_SLIDER_INT, 60, 110, imgui.new.int(config.root.additions.fishEye.fov) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "tracers", "Трассера", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.tracers.use) },
                { "showOnlyForSpectator", "Только выстрелы от игрока за которым вы следите", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.tracers.showOnlyForSpectator) },
                { "notificationType", "Тип оповещения при переключении на хоткей", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.additions.tracers.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" },
                { "hitColor", "Цвет попадания", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.tracers.hitColor) },
                { "missColor", "Цвет промаха", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.tracers.missColor) },
                { "maxLines", "Максимальное количество трассеров", WINDOW_WIDGET_CUSTOM, (fn(this) {
                    imgui.SetNextItemWidth(imgui.GetWindowWidth() - 10)
                    if imgui.SliderInt("##imgui.windows.Main.Settings.changeTraccersAmount", this[5], 1, 100) {
                        config.root.additions.tracers.maxLines = this[5][0]
                        for id = 1, config.root.additions.tracers.maxLines {
                            bulletData[id] = {
                                enable  = false,
                                o       = { x, y, z },
                                t       = { x, y, z },
                                time    = 0,
                                type    = 0
                            }
                        }
                    }
                }), imgui.new.int(config.root.additions.tracers.maxLines) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP }

            { "deathNotifyInChat", "Убийства в чат", {
                { "use", "Логирует убийства в чат", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.deathNotifyInChat.use) },
                { "color", "Цвет", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.deathNotifyInChat.color) }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "mention", "Упоминания в /a", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.mention.use) },
                { "soundNotification", "Звуковое оповещение", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.mention.soundNotification) },
                { "color", "Цвет упоминания", WINDOW_WIDGET_COLOR_PICKER, imguiAssets::convertHex2Float3(config.root.additions.mention.color) }
                { "notificationType", "Тип оповещения при упоминании", WINDOW_WIDGET_TYPE_SELECTOR, imgui.new.int(config.root.additions.mention.notificationType), "ImGui оповещение", "Сообщение в чат", "Отсутствует" }
            }, WINDOW_WIDGET_CONFIGURATION_IN_POPUP },

            { "changeNicknameColors", "Разные цвета никнеймов /a", {
                { "use", "Изменение цвета никнейма для тех кто внес вклад в разработку\nИзменяется исключительно в /a чате", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.additions.changeNicknameColors.use) }
            }},
        }},

        { "fix", "Исправления", {
            { "chatOnVK_T", "Чат на русскую T", {
                { "use", "", WINDOW_WIDGET_SWITCH, imgui.new.bool(config.root.fix.chatOnVK_T.use) }
            }}
        }}
    }
}

/**
 * Just open main window.
 * @return void
 */
method window::open() {
    if !self.state {
        self.closeAndOpenAnimation.alpha = 0
        self.state = true
    }
}

/**
 * Just close main window.
 * @return void
 */
method window::close() {
    if self.state {
        self.closeAndOpenAnimation.clock = os.clock()
    }
}

/**
 * Open or close window by `window.state`
 * @return void
 */
method window::switch() {
    if self.state {
        self::close()
    } else {
        self::open()
    }
}

method window.menu::item(label, icon, title, index, duration = {
    0.2,    //! clicked
    0.4,    //! post-hovered
    0.3,    //! hovered
    0.05,   //! fade-in when switching frame
    0.1     //! fade-out when switching frame
}) {
    local dl        = imgui.GetWindowDrawList()
    local colors    = {
        def     = imgui.GetStyle().Colors[imgui.Col.ChildBg]
        active  = imgui.GetStyle().Colors[imgui.Col.Button],
        hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered],
        text    = imgui.GetStyle().Colors[imgui.Col.Text]
    }

    colors.def     = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)
    colors.active  = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)
    colors.hovered = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)
    colors.text    = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)

    if local this = self.UI_MENU_ITEMS[label] {
        local cursor = imgui.GetCursorPos()
        
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, 0)
        if imgui.Button(label, imgui.ImVec2(window.menu.width, 35)) && self.selectedFrame != index {
            this.clock          = { os.clock(), os.clock() + duration[1] }
            this.clicked.clock  = { os.clock(), os.clock() }
        }
        imgui.PopStyleVar()

        if this.clicked.clock[2] {
            self.switchBetweenFramesAlpha = imguiAssets::bringFloatTo($, (self.width > 60) ? 0.25 : 0.5, this.clicked.clock[2], duration[4])

            if os.clock() - this.clicked.clock[2] >= duration[4] {
                self.previousSelectedFrame      = self.selectedFrame
                self.selectedFrame              = index
                self.switchBetweenFramesAlpha   = imguiAssets::bringFloatTo($, 0.00, this.clicked.clock[2] + duration[4], duration[5])
            }

            if os.clock() - this.clicked.clock[2] - duration[4] >= duration[5] {
                self.selectedFrame = index
                this.clicked.clock[2] = nil
            } 
        }

        if self.selectedFrame == index {
            this.color = imguiAssets::bringVec4To($, colors.active, this.clicked.clock[1], duration[3])
        } else {
            this.hovered.state = imgui.IsItemHovered() || os.clock() - this.clock[2] < 0
    
            if this.hovered.state != this.hovered.before {
                this.hovered.before = this.hovered.state
                this.hovered.clock  = os.clock()
            }

            this.color = imguiAssets::bringVec4To($, match this.hovered.state {
                true    => colors.hovered,
                false   => colors.def
            }, this.hovered.clock, duration[3])
        }
        
        dl::AddRectFilled(
            imgui.GetWindowPos() + cursor,
            imgui.GetWindowPos() + imgui.ImVec2(self.width, cursor.y + 35),
            imgui.ColorConvertFloat4ToU32(this.color)
        )

        imgui.SameLine(15)
        imgui.BeginGroup()
            imgui.SetCursorPosY(cursor.y + 17.5 - imgui.CalcTextSize(icon).y / 2.5)
            imgui.Text(icon)
            if self.width == 200 {
                imgui.PushFont(bold10)
                imgui.PushStyleColor(imgui.Col.Text, colors.text)
                imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, self.alpha / 255)
                    imgui.SameLine(40)
                    imgui.SetCursorPosY(cursor.y + 5)    
                    imgui.Text(title)
                imgui.PopStyleVar()
                imgui.PopStyleColor()
                imgui.PopFont()
            }
        imgui.EndGroup()
    } else {
        self.UI_MENU_ITEMS[label] = {
            clock   = { 0, 0 },
            color   = (self.selectedFrame == index) ? colors.active : colors.def,
            clicked = { clock = { 0, nil } },
            hovered = {
                state   = false,
                before  = nil,
                clock   = 0
            }
        }
    }
}

addEventHandler("onWindowMessage", fn(event, wparam) {
    if (event == wm.WM_KEYDOWN || event == wm.WM_SYSKEYDOWN) && !imgui.GetIO().WantTextInput {
        if wparam == VK_ESCAPE && window.state && !changingHotKey {
            window::close()
            consumeWindowMessage(true, false)
            return
        }
    }
})

style::registerWindow("imgui.windows.Main", "Основное окно")
HotKey::new("imgui.windows.Main", { VK_X }, "Открыть/закрыть это окно", HOTKEY_CONDITION_ONLY_IF_INPUTS_NOT_ACTIVE)::registerCallback(fn {
    if !movableWindows::isChangingWindowsPositions() {
        window::switch()
    }
})

mainWindow = window

imgui.OnFrame(fn { return !isGamePaused() && window.state }, fn(self) {
    self.flags  = imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar
    self.flags += (window.menu.width > 60) ? imgui.WindowFlags.NoInputs : 0

    //! Close and open window animation.
    if window.closeAndOpenAnimation.clock {
        if window.recentlyOpened { //! Open animation.
            if os.clock() - window.closeAndOpenAnimation.clock >= 0.2 {
                window.recentlyOpened               = false
                window.closeAndOpenAnimation.clock  = nil
            } else {
                window.closeAndOpenAnimation.alpha = imguiAssets::bringFloatTo($, 1, window.closeAndOpenAnimation.clock, 0.2)
            }
        } else { //! Close animatiion.
            if os.clock() - window.closeAndOpenAnimation.clock >= 0.1 {
                window.state                        = false
                window.closeAndOpenAnimation.clock  = nil
            } else {
                window.closeAndOpenAnimation.alpha = imguiAssets::bringFloatTo($, 0, window.closeAndOpenAnimation.clock, 0.2)
            }
        }
    }

    if window.closeAndOpenAnimation.alpha == 0 {
        window.recentlyOpened               = true
        window.closeAndOpenAnimation.clock  = os.clock()
    }
    
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(700, 455))

    style::beginWindowStyleChangeable("imgui.windows.Main")

    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, window.closeAndOpenAnimation.alpha)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
        imgui.Begin("imgui.windows.Main", nil, self.flags)
            {
                local pos   = imgui.GetWindowPos()
                local size  = imgui.GetWindowSize()
                shadow::apply(
                    imgui.GetBackgroundDrawList(),
                    imgui.ImVec2(pos.x + 5, pos.y + 5),
                    imgui.ImVec2(size.x - 10, size.y - 10),
                    24.0,
                    math.floor(math.floor(window.closeAndOpenAnimation.alpha * 255) / 255) * 100,
                    2
                )
            }

            imgui.SetCursorPos(imgui.ImVec2(60 + imgui.GetStyle().ItemSpacing.x, 7))
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, window.closeAndOpenAnimation.alpha - window.menu.alpha / 255 / 2 - window.menu.switchBetweenFramesAlpha)
            imgui.BeginGroup()
                local widthAuto = 640 - imgui.GetStyle().ItemSpacing.x * 2 - 1
                local heightAuto = imgui.GetWindowHeight() - 3
                if window.menu.selectedFrame == WINDOW_SELECTED_FRAME_HOME {
                    imgui.SetScrollY(0)
                    imgui.BeginChild("imgui.windows.Main.userStats", imgui.ImVec2(widthAuto, 100), true)
                        imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(5, 7))
                        imgui.BeginGroup()
                            imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(5, 5))
                            imgui.BeginGroup()
                                if local time = assets::getLocalTime() {
                                    imguiAssets::textWithFont(string.format(
                                        "%d-%d-%d %02d:%02d:%02d",
                                        time.wYear, time.wMonth, time.wDay,
                                        time.wHour, time.wMinute, time.wSecond
                                    ), bold10)

                                    local welcomePostfix = (time.wHour <= 10) ? "Доброе утро, " : (
                                                        (time.wHour >= 10 && time.wHour <= 17) ? "Добрый день, " : "Добрый вечер, ")

                                    imguiAssets::textWithFont(welcomePostfix .. user::getOOCNickname() .. "!", regular9)
                                    imguiAssets::textWithFont("Уровень администрирования - " .. user::getAdminLvl(), regular9)

                                    if local pos = imgui.GetCursorPos() { // imgui.SameLine() with different fonts.
                                        imguiAssets::textWithFont("Текущая версия GAdmin - ", regular9)
                                        imguiAssets::textWithFont("v" .. $GADMIN_VERSION, bold9, pos + imgui.ImVec2(132, 0))
                                    }
                                }
                            imgui.EndGroup()
                            imgui.SameLine(400)
                            imgui.BeginGroup()
                                if local answers, online = user::getAnswersCount(), user::getTime() {
                                    for index, item in ({
                                        "BeginGroup",
                                            "Онлайн",
                                            { "Всего",      string.format("%02d:%02d:%02d", online.total.hour, online.total.min, online.total.sec) },
                                            { "За неделю",  string.format("%02d:%02d:%02d", online.weekTotal.hour, online.weekTotal.min, online.weekTotal.sec) },
                                            { "За сессию",  string.format("%02d:%02d:%02d", online.session.hour, online.session.min, online.session.sec) },
                                        "EndGroup",
                                        "DetailedInformation:online",

                                        "SameLine",

                                        "BeginGroup",
                                            "Ответы",
                                            { "Всего",      answers.total },
                                            { "За неделю",  answers.weekTotal },
                                            { "За сессию",  answers.session }
                                        "EndGroup",
                                        "DetailedInformation:answers"
                                    }) {
                                        if type(item) == "string" {
                                            if local to = string.match(item, "^DetailedInformation:(%S+)$") {
                                                local title = ({ online = "Онлайн", answers = "Ответы" })[to] .. " по дням недели"
                                                local width = bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, title).x
                                                
                                                if local days = config.root.user[to].weeks[#config.root.user[to].weeks]?.days {
                                                    local items = {}
                                                    local write = fn (dayIndex, dayName) {
                                                        local value = (to == "answers") ? days[dayIndex] : ""

                                                        if to == "online" {
                                                            local time = assets::explodeDate(days[dayIndex] || 0)
                                                            value = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
                                                        }

                                                        local size = regular10::CalcTextSizeA(regular10.FontSize, math.huge, 0.0, dayName .. ": ")
                                                        size      += bold10::CalcTextSizeA(bold10.FontSize, math.huge, 0.0, tostring(value))

                                                        if size.x > width {
                                                            width = size.x
                                                        }

                                                        table.insert(items, { name = dayName .. ": ", value = tostring(value) })
                                                    }

                                                    for dayIndex = 2, #days {
                                                        write(dayIndex, ({
                                                            "Понедельник",
                                                            "Вторник",
                                                            "Среда",
                                                            "Четверг",
                                                            "Пятница",
                                                            "Суббота"
                                                        })[dayIndex - 1])
                                                    }

                                                    write(1, "Воскресенье")

                                                    width += 15

                                                    animations::hint(item, nil, nil, imgui.GetStyle().Colors[imgui.Col.WindowBg], fn {
                                                        imguiAssets::textWithFont(title, bold10)
                                                        for _, item in items {
                                                            imguiAssets::textWithFont(item.name, regular10)
                                                            imgui.SameLine(nil, 0)
                                                            imguiAssets::textWithFont(item.value, bold10)
                                                        }
                                                    }, width)
                                                }
                                            } elseif item == "BeginGroup" || item == "EndGroup" || item == "SameLine" {
                                                if item == "SameLine" {
                                                    imgui.SameLine(nil, 10)
                                                } else {
                                                    imgui[item]()
                                                }
                                            } else {
                                                imguiAssets::textWithFont(item, bold10)
                                            }
                                        } else {
                                            imgui.BeginGroup()
                                                imguiAssets::textWithFont(item[1] .. ":", regular9)
                                                imgui.SameLine()
                                                imguiAssets::textWithFont(tostring(item[2]), bold9)
                                            imgui.EndGroup()
                                        } 
                                    }
                                }
                            imgui.EndGroup()
                        imgui.EndChild()
                        
                        imgui.SetCursorPosY(imgui.GetCursorPos().y + 4 + imgui.GetStyle().ItemSpacing.x)
                        imgui.PushTextWrapPos(widthAuto + 50)
                        imgui.BeginGroup()
                            imguiAssets::textWithFont("GAdmin", bold14)
                            imguiAssets::textWithFont(
"Свободная программа, залицензированная под стандартной GNU General Public License v3 лицензией. 
Исходный код доступен для всех: каждый может внести свой вклад в разработку посредством пулл-реквестов 
или создания баг-репортов о найденных ошибках, или же создать отдельный скрипт основанный на этом, 
с учетом сохранения лицензии и открытости кода.", regular9)
                            imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(10, 0))
                            imgui.BeginGroup()
                                imguiAssets::textWithFont("GAdmin Repository:", bold10)
                                imgui.SameLine(nil, 10)
                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                                imguiAssets::textWithFont(thisScript().url, regular9)
                                imguiAssets::setPreviousItemAbleToCopy(thisScript().url)
                                imguiAssets::textWithFont("The Contributors:", bold10)
                                imgui.SameLine(nil, 23)
                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                                imguiAssets::textWithFont(thisScript().authors[1], regular9)
                                imguiAssets::setPreviousItemAbleToCopy(thisScript().authors[1])
                            imgui.EndGroup()
                            imguiAssets::textWithFont("Copyright (C) " .. $COPYRIGHT_YEARS .. " The Contributors. Licensed under the GNU General Public License v3.", regular9)
                            imgui.PopTextWrapPos()

                            imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 5))
                            imgui.PushFont(regular12)
                                imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(0, 10))
                                imguiAssets::textWithFont("Быстрые действия", bold14)
                                imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(0, 6))
                                
                                if animations::button("Изменить позицию окон", imgui.ImVec2(math.floor(widthAuto / 3), 30), 5) {
                                    window::close()
                                    movableWindows::executeChangingWindowsPositions()
                                }
                                    
                                imgui.SameLine()
                    
                                if animations::button((user::getAloginStatus()) ? "/alogout" : "/alogin", imgui.ImVec2(math.floor(widthAuto / 3) - 2, 30), 0)
                                   && window.menu.width <= 60
                                {
                                    sampSendChat((user::getAloginStatus()) ? "/alogout" : "/alogin")
                                }

                                imgui.SameLine()                

                                if animations::button("Собрать информацию о скрипте", imgui.ImVec2(math.floor(widthAuto / 3), 30), 10) {
                                    local filePath = string.format(
                                        "%s\\GAdmin\\logs\\CollectInformation (%s).log",
                                        getWorkingDirectory(),
                                        os.date("%Y%m%d-%H-%M-%S")
                                    )

                                    common::writeInFile(filePath, assets::collectScriptInformation())
                                    notify::send({
                                        title   = "Информация собрана в файл по пути ...",
                                        text    = filePath,
                                        icon    = icons.ICON_CHECKMARK
                                    })
                                }

                                animations::hint("Необходимо для создания баг-репортов.\nВ полученном логе ваши пароли будет заменены на \"***\".")
                                
                                if animations::button("Применить тему", imgui.ImVec2(math.floor(widthAuto / 3), 30), 5) {
                                    local theme = decodeJson(getClipboardText())
                                    if theme && type(theme) == "table" {
                                        config.root.styleChangeableWindows = theme
                                        thisScript()::reload()
                                    } else {
                                        notify::send({
                                            title   = "Ошибка!",
                                            text    = "Произошла ошибка при применении темы. Убедитесь, что вы скопировали правильную тему.",
                                            icon    = icons.ICON_WARNING
                                        })
                                    }
                                }
                                
                                animations::hint("Скрипт перезагрузится.##applyTheme")

                                imgui.SameLine()

                                if animations::button("Экспортировать тему", imgui.ImVec2(math.floor(widthAuto / 3) - 2, 30), 0) {
                                    setClipboardText(neatJSON(config.root.styleChangeableWindows, { sort = true, wrap = 40 }))
                                    notify::send({
                                        title   = "Успешно!",
                                        text    = "Экспортированная тема записана в ваш буффер обмена.",
                                        icon    = icons.ICON_CHECKMARK
                                    })
                                }

                                imgui.SameLine()

                                if animations::button("Открыть каталог тем", imgui.ImVec2(math.floor(widthAuto / 3), 30), 10)
                                   && #userThemes != 0
                                {
                                    window.popupModal.body = fn {
                                        imgui.SetCursorPos(imgui.ImVec2(5, 5))
                                        imgui.BeginGroup()
                                            imguiAssets::textWithFont("Каталог пользовательских тем", bold14)

                                            for index, theme in userThemes {
                                                imgui.BeginChild(
                                                    "userThemeIndex" .. index,
                                                    imgui.ImVec2(imgui.GetWindowWidth() - 10, (theme.description) ? 80 : 59),
                                                    true
                                                )
                                                    imgui.SetCursorPos(imgui.ImVec2(6, 6))
                                                    imgui.BeginGroup()
                                                        imguiAssets::textWithFont(theme.title, bold12)
                                                        imgui.SameLine()
                                                        imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(0, 1))
                                                        imguiAssets::textWithFont("v" .. theme.version, regular12, nil, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                                                        imgui.SameLine()
                                                        imgui.SetCursorPos(imgui.GetCursorPos() - imgui.ImVec2(0, 1))
                                                        imguiAssets::textWithFont("от", bold12)
                                                        imgui.SameLine(nil, 4)
                                                        imguiAssets::textWithFont(theme.author, regular12)

                                                        if local description = theme.description {
                                                            imguiAssets::textWithFont(description, regular12)
                                                        }

                                                        imgui.PushFont(bold10)
                                                            if animations::button(
                                                                "Установить##userThemeInstallIndex" .. index,
                                                                imgui.ImVec2(imgui.GetWindowWidth() - 12, 25)
                                                            ) {
                                                                style::downloadTheme(theme.link)
                                                                imgui.CloseCurrentPopup()
                                                            }
                                                        imgui.PopFont()
                                                    imgui.EndGroup()
                                                imgui.EndChild()
                                            }

                                            imgui.PushFont(bold10)
                                                if animations::button("Закрыть##imgui.windows.Main.CloseCurrentPopup", imgui.ImVec2(
                                                    math.max(300, imgui.GetWindowWidth() - 10),
                                                    30
                                                )) {
                                                    imgui.CloseCurrentPopup()
                                                }
                                            imgui.PopFont()
                                        imgui.EndGroup()

                                        window.popupModal.size = imgui.GetItemRectSize() + imgui.ImVec2(10, 10)
                                    }

                                    imgui.OpenPopup("imgui.windows.Main.Popup")
                                }

                                if #userThemes == 0 {
                                    animations::hint("Не удалось получить список пользовательских тем.\nПопробуйте перезагрузить скрипт и попытаться снова.")
                                }

                                if animations::button("Импортировать настройки", imgui.ImVec2(math.floor(widthAuto / 3), 30), 5) {
                                    local settings = decodeJson(getClipboardText())
                                    if settings && type(settings) == "table" {
                                        config.root = settings
                                        config::save()
                                        thisScript()::reload()
                                    } else {
                                        notify::send({
                                            title   = "Ошибка!",
                                            text    = "Произошла ошибка при применении темы. Убедитесь, что вы скопировали содержимое файла настроек.",
                                            icon    = icons.ICON_WARNING
                                        })
                                    }
                                }

                                imgui.SameLine()

                                if animations::button("Сбросить настройки", imgui.ImVec2(math.floor(widthAuto / 3) - 2, 30), 0) {
                                    config.root = config.def
                                    thisScript()::reload()
                                }

                                animations::hint("Сбросятся абсолютно все настройки. Скрипт перезагрузится.")

                                imgui.SameLine()

                                if animations::button("Экспортировать настройки", imgui.ImVec2(math.floor(widthAuto / 3), 30), 10) {
                                    local configuration = neatJSON(config.root, { sort = true, wrap = 40 })
                                    local filePath = string.format(
                                        "%s\\GAdmin\\config\\ExportSettings (%s).json",
                                        getWorkingDirectory(),
                                        os.date("%Y%m%d-%H-%M-%S")
                                    )

                                    common::writeInFile(filePath, configuration)
                                    notify::send({
                                        title   = "Настройки экспортированы в файл по пути ...",
                                        text    = filePath,
                                        icon    = icons.ICON_CHECKMARK
                                    })
                                }

                                if animations::button("Перезагрузить скрипт", imgui.ImVec2(widthAuto, 30)) {
                                    thisScript()::reload()
                                }
                            imgui.PopFont()
                            imgui.PopStyleVar()
                        imgui.EndGroup()
                    imgui.EndGroup()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_SETTINGS {
                    // forgive me for all of this code below (in current `window.menu.selectedFrame`).
                    for sectionIndex, section in window.configuration {
                        if sectionIndex == 4 { imgui.NewLine() }
                        imguiAssets::textWithFont(section[2], bold14)

                        for index, setting in section[3] {
                            imgui.BeginGroup()
                            imgui.PushFont(regular12)
                                if animations::toggleButton(((setting[4] != WINDOW_WIDGET_CONFIGURATION_IN_POPUP) ? setting[2] : "") .. "##imgui.windows.Main.setting." .. setting[2], setting[3][1][4]) {
                                    config.root[section[1]][setting[1]].use = setting[3][1][4][0]
                                    setting[3][1][5]?()
                                }
                            imgui.PopFont()

                            if setting[4] == WINDOW_WIDGET_CONFIGURATION_IN_POPUP {
                                imgui.SameLine()
                                imgui.PushFont(regular12)
                                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                                    if animations::clickableUnderlinedText(setting[2] .. "##imgui.windows.Main.setting.text", false, nil, {
                                        idle        = imgui.GetStyle().Colors[imgui.Col.Text],
                                        hovered     = imgui.GetStyle().Colors[imgui.Col.Text],
                                        selected    = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
                                    }) && window.menu.width <= 60 {
                                        window.popupModal.body = fn {
                                            imgui.PushFont(regular12)
                                                imgui.SetCursorPos(imgui.ImVec2(5, 5))
                                                imgui.BeginGroup()
                                                    imguiAssets::textWithFont(setting[2], bold14)
                                                    for _, item in setting[3] {
                                                        if item[1] != "use" {
                                                            if item[3] == WINDOW_WIDGET_SWITCH {
                                                                if animations::toggleButton(item[2] .. "##" .. item[1], item[4]) {
                                                                    config.root[section[1]][setting[1]][item[1]] = item[4][0]
                                                                    item[5]?()
                                                                }
                                                            } elseif item[3] == WINDOW_WIDGET_SLIDER_INT || item[3] == WINDOW_WIDGET_SLIDER_FLOAT {
                                                                imguiAssets::textWithFont(item[2], bold12)
                                                                imgui.PushItemWidth(imgui.GetWindowWidth() - 10)
                                                                    if imgui[((item[3] == WINDOW_WIDGET_SLIDER_INT) ? "SliderInt" : "SliderFloat")](
                                                                        "##imgui.windows.Main.setting." .. item[2] .. item[1], item[6], item[4], item[5]
                                                                    ) {
                                                                        config.root[section[1]][setting[1]][item[1]] = item[6][0]
                                                                    }
                                                                imgui.PopItemWidth()
                                                            } elseif item[3] == WINDOW_WIDGET_TYPE_SELECTOR {
                                                                imguiAssets::textWithFont(item[2], bold12)
                                                                imgui.PushItemWidth(imgui.GetWindowWidth() - 10)
                                                                    if imgui.SliderInt(
                                                                        "##imgui.windows.Main.setting." .. item[2] .. item[1],
                                                                        item[4],
                                                                        1,
                                                                        #item - 4,
                                                                        item[4 + item[4][0]]
                                                                    ) {
                                                                        config.root[section[1]][setting[1]][item[1]] = item[4][0]
                                                                    }
                                                                imgui.PopItemWidth()
                                                            } elseif item[3] == WINDOW_WIDGET_COLOR_PICKER {
                                                                local flags     = imgui.ColorEditFlags.NoInputs
                                                                local vector    = imgui.ImVec4(item[4][0], item[4][1], item[4][2], 1.00)
                                                                local hex       = $IMVEC4_TO_RGB!(vector)
                                                                local dl        = imgui.GetWindowDrawList()

                                                                imguiAssets::textWithFont(item[2], bold12)

                                                                local pos = imgui.GetCursorPos() + imgui.ImVec2(0, 3)
                                                                
                                                                imgui.SetCursorPos(imgui.ImVec2(pos.x + 7, pos.y + 5))
                                                                imguiAssets::textWithFont(hex, bold10, nil, vector)
                                                                imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 31, pos.y))
                                                                if imgui.ColorEdit3("##imgui.windows.main.Popup.colorEdit." .. item[1] .. item[2], item[4], flags) {
                                                                    config.root[section[1]][setting[1]][item[1]] = hex
                                                                }

                                                                dl::AddRect(
                                                                    pos + imgui.GetWindowPos(),
                                                                    imgui.GetItemRectMax(),
                                                                    imgui.ColorConvertFloat4ToU32(vector),
                                                                    imgui.GetStyle().FrameRounding,
                                                                    15,
                                                                    3
                                                                )

                                                                dl::AddRectFilled(
                                                                    imgui.GetItemRectMin(),
                                                                    imgui.GetItemRectMin() + imgui.ImVec2(4, 25),
                                                                    imgui.ColorConvertFloat4ToU32(vector)
                                                                )
                                                            } elseif item[3] == WINDOW_WIDGET_CUSTOM {
                                                                imguiAssets::textWithFont(item[2], bold12)
                                                                item[4](item)
                                                            } elseif item[3] == WINDOW_WIDGET_INPUT {
                                                                imguiAssets::textWithFont(item[2], bold12)
                                                                imgui.SetNextItemWidth(imgui.GetWindowWidth() - 10)
                                                                if imgui.InputText(
                                                                    "##imgui.windows.Main.Popup.input." .. item[1] .. item[2],
                                                                    item[4],
                                                                    ffi.sizeof(item[4])
                                                                ) {
                                                                    config.root[section[1]][setting[1]][item[1]] = ffi.string(item[4])
                                                                }
                                                            }
                                                        }
                                                    }
                                                
                                                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 5)
                                                    if animations::button("Закрыть##imgui.windows.main.Popup.close", imgui.ImVec2(imgui.GetWindowWidth() - 10, 30)) {
                                                        imgui.CloseCurrentPopup()
                                                    }
                                                imgui.EndGroup()

                                                window.popupModal.size = imgui.GetItemRectSize() + imgui.ImVec2(10, 10)
                                            imgui.PopFont()
                                        }

                                        imgui.OpenPopup("imgui.windows.Main.Popup")
                                    }
                                imgui.PopFont()
                            }

                            imgui.EndGroup()
                            
                            if index % 3 != 0 {
                                imgui.SameLine(match index % 3 { 1 => 205, 2 => 440 })
                            }

                            if setting[3][1][2] != "" {
                                imgui.PushFont(regular12)
                                    animations::hint(setting[3][1][2] .. "##imgui.windows.main.Popup.hint." .. setting[1], fn {
                                        return imgui.IsItemHovered() && window.menu.width <= 60
                                    })
                                imgui.PopFont()
                            }
                        }
                    }
                    imgui.NewLine()
                    imgui.Dummy(imgui.ImVec2(5, 5))
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_KEYBINDS {
                    imgui.SetScrollY(0)
                    imguiAssets::textWithFont("Горячие клавиши", bold14)
                    imgui.SameLine(nil, 10)
                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 4)
                    imguiAssets::textWithFont("ПКМ по кнопке откроет настройки бинда", regular10, nil, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 2)
                    imgui.BeginGroup()
                        for index, hotKey in allHotKeys {
                            if !string.find(hotKey.id, "^binderIndex%d+$") {
                                imgui.BeginGroup()
                                    imgui.PushFont(regular12)
                                        hotKey::render(imgui.ImVec2(100, 25))
                                    imgui.PopFont()    
                                    imgui.SameLine()
                                    imguiAssets::textWithFont(hotKey.description, bold10, imgui.GetCursorPos() + imgui.ImVec2(0, 4))
                                imgui.EndGroup()

                                imgui.SameLine(300)

                                if index % 2 == 0 {
                                    imgui.NewLine()
                                }
                            }
                        }
                    imgui.EndGroup()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_PLAYERS_CHECKER {
                    imgui.SetScrollY(0)
                    imgui.BeginGroup()
                        imguiAssets::textWithFont("Чекер игроков", bold14)
                        imgui.PushFont(regular9)
                            imguiAssets::textWithFont("Введите никнейм игрока", bold10)
                            window.checker.filter::draw("##imgui.windows.Main.CheckerFilter", "Никнейм", widthAuto / 2)
                            imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(6, 6))
                                imgui.BeginChild("imgui.windows.Main.CheckerFilter.Child", imgui.ImVec2(widthAuto / 2, 205), true, self.flags)
                                    for playerId = 0, $SERVER_MAX_PLAYERS {
                                        if playerId != user::getId() && sampIsPlayerConnected(playerId) {
                                            local nickname          = sampGetPlayerNickname(playerId)
                                            local playerInChecker   = false
                                        
                                            for _, player in config.root.windows.playerChecker.players {
                                                if player.nickname == nickname {
                                                    playerInChecker = true
                                                    break
                                                }
                                            }

                                            if window.checker.filter::passFilter(string.format("[%d] %s", playerId, nickname)) && !playerInChecker {
                                                if imgui.Selectable(string.format("[%d] %s", playerId, nickname)) {
                                                    window.checker.filter::setBufferText(nickname)
                                                }
                                            }
                                        }
                                    }
                                imgui.EndChild()
                            imgui.PopStyleVar()
                        imgui.PopFont()

                        imguiAssets::textWithFont("Заметка об игроке", bold10)
                        imgui.PushFont(regular9)
                            if imgui.InputTextMultiline(
                                "##imgui.windows.Main.CheckerPlayerDescription",
                                window.checker.playerNote,
                                ffi.sizeof(window.checker.playerNote),
                                imgui.ImVec2(widthAuto / 2, 100)
                            ) {
                                if local player = config.root.windows.playerChecker.players[window.checker.selectedPlayer] {
                                    player.commentary = ffi.string(window.checker.playerNote)
                                }
                            }
                        imgui.PopFont()

                        imgui.PushFont(bold10)
                            if animations::button("Добавить", imgui.ImVec2(widthAuto / 2, 30)) {
                                local commentary    = (ffi.string(window.checker.playerNote) == "") ? nil : ffi.string(window.checker.playerNote)
                                local nickname      = ffi.string(window.checker.filter.buffer)
                        
                                if nickname != "" {
                                    table.insert(config.root.windows.playerChecker.players, {
                                        nickname    = nickname,
                                        commentary  = commentary
                                    })

                                    window.checker.selectedPlayer = #config.root.windows.playerChecker.players

                                    imgui.StrCopy(window.checker.playerNote, commentary || "")
                                    window.checker.filter::clear()
                                }
                            }
                        imgui.PopFont()
                    imgui.EndGroup()
                    imgui.SameLine()
                    imgui.BeginGroup()
                        imguiAssets::textWithFont("Все игроки", bold10)
                        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(6, 6))
                            imgui.BeginChild("imgui.windows.Main.Checker.AllPlayers.Child", imgui.ImVec2(widthAuto / 2 - 5, 385), true, self.flags)
                                for index, player in config.root.windows.playerChecker.players {
                                    local id            = sampPlayer::getIdByNickname(player.nickname)
                                    local prefix        = ((id == nil) ? "[OFFLINE]" : "[ONLINE]") .. " "
                                    local prefixColor   = common::convertHex2ImVec4((id == nil) ? "FF8585" : "8DFF85") 

                                    imgui.PushFont(regular9)
                                        imgui.BeginGroup()
                                            local pos = imgui.GetCursorPos()
                                    
                                            if imgui.Selectable(
                                                "##imgui.windows.Main.Checker.Player." .. player.nickname,
                                                window.checker.selectedPlayer == index
                                            ) {
                                                window.checker.selectedPlayer = index
                                                imgui.StrCopy(window.checker.playerNote, player.commentary || "")
                                            }

                                            imgui.SetCursorPos(pos)
                                            imgui.TextColored(prefixColor, prefix)
                                            imgui.SetCursorPos(imgui.ImVec2(pos.x + imgui.CalcTextSize(prefix).x, pos.y))
                                            imgui.Text(player.nickname)
                                            imgui.SetCursorPos(pos)
                                        imgui.EndGroup()
                                    imgui.PopFont()
                                }
                            imgui.EndChild()
                        imgui.PopStyleVar()
                        
                        if animations::button("Удалить", imgui.ImVec2(widthAuto / 2 - 5, 30)) && window.checker.selectedPlayer != -1 {
                            local players = config.root.windows.playerChecker.players

                            table.remove(players, window.checker.selectedPlayer)
                            
                            if local player = players[#players] {
                                window.checker.selectedPlayer = #players
                                imgui.StrCopy(window.checker.playerNote, player.commentary || "")
                            } else {
                                imgui.StrCopy(window.checker.playerNote, "")
                            }
                        }
                    imgui.EndGroup()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_CUSTOMIZATION {
                    imgui.SetScrollY(0)
                    imguiAssets::textWithFont("Кастомизация", bold14)
                   
                    local childHeight = imgui.GetWindowHeight() - imgui.GetCursorPos().y - 6
                    local placeholders = {
                        //! There's no next elements(they're unused in our GUI):
                        //!
                        //! TitleBg, TitleBgActive, TitleBgCollapsed, MenuBarBg, CheckMark,
                        //! Tab, TabHovered, TabActive, TabUnfocused, TabUnfocusedActive,
                        //! DragDropTarget, NavHighlight, NavWindowingHighlight,
                        //! NavWindowingDimBg, ModalWindowDimBg.
                        Text                    = "Текст",
                        TextDisabled            = "Невыделенный текст",
                        WindowBg                = "Фон окна",
                        ChildBg                 = "Фон чайлда",
                        PopupBg                 = "Фон всплывающего окна",
                        Border                  = "Обводка",
                        BorderShadow            = "Тень обводки",
                        FrameBg                 = "Прочие элементы",
                        FrameBgHovered          = "Наведение на прочие элементы",
                        FrameBgActive           = "Нажатие на прочие элементы",
                        ScrollbarBg             = "Фон полосы-прокрутки",
                        ScrollbarGrab           = "Захват полосы-прокрутки",
                        ScrollbarGrabHovered    = "Наведение на захват полосы-прокрутки",
                        ScrollbarGrabActive     = "Нажатие на захват полосы-прокрутки",
                        Button                  = "Кнопка",
                        ButtonHovered           = "Наведение на кнопку",
                        ButtonActive            = "Нажатие на кнопку",
                        Header                  = "Заголовок",
                        HeaderHovered           = "Наведение на заголовок",
                        HeaderActive            = "Нажатие на заголовок",
                        Separator               = "Разделитель",
                        SeparatorHovered        = "Наведение на разделитель",
                        SeparatorActive         = "Нажатие на разделитель",
                        TextSelectedBg          = "Выделенный текст"
                    }

                    window.customization.combo.array ??= (fn {
                        local windowList = {}
                        
                        for _, item in registeredWindows {
                            table.insert(windowList, item.description)
                        }
                       
                        window.customization.combo.size = #windowList
                        return imgui.new["const char*"][#windowList](windowList)
                    })()

                    window.customization.selectedId = (fn {
                        local id = ""

                        for _, registeredWindow in registeredWindows {
                            if registeredWindow.description == ffi.string(
                                window.customization.combo.array[window.customization.combo.buffer[0]]
                            ) {
                                id = registeredWindow.id
                            }
                        }

                        return id
                    })()

                    window.customization.editors = (fn {
                        config.root.styleChangeableWindows[window.customization.selectedId] ??= {}
                        local editors = {}

                        for _, property in style::getBaseColors() {
                            local value = imgui.ImVec4(table.unpack(property[2]))
                            
                            for _, savedProperty in config.root.styleChangeableWindows[window.customization.selectedId] {
                                if type(savedProperty[2]) == "table" && property[1] == savedProperty[1] {
                                    value.x = savedProperty[2][1]
                                    value.y = savedProperty[2][2]
                                    value.z = savedProperty[2][3]
                                    value.w = savedProperty[2][4]
                                }
                            }

                            table.insert(editors, {
                                styleKey    = property[1],
                                name        = placeholders[property[1]],
                                id          = "imgui.windows.Main.Customization.ColorEdit[" .. property[1] .. "]",
                                value       = imgui.new.float[4](value.x, value.y, value.z, value.w)
                            })
                        }

                        return editors
                    })()

                    local fn changeConfigProperties(item) {
                        local containsProperty = false

                        for _, property in config.root.styleChangeableWindows[window.customization.selectedId] {
                            if property[1] == item.styleKey {
                                containsProperty    = true
                                property[2]         = { item.value[0], item.value[1], item.value[2], item.value[3] }
                            }
                        }

                        if !containsProperty {
                            table.insert(config.root.styleChangeableWindows[window.customization.selectedId], {
                                item.styleKey, { item.value[0], item.value[1], item.value[2], item.value[3] }
                            })
                        }
                    }

                    imgui.BeginChild("imgui.windows.Main.Customization.ColorEditors", imgui.ImVec2(380, childHeight), false, self.flags)
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imguiAssets::textWithFont(ffi.string(window.customization.combo.array[window.customization.combo.buffer[0]]), bold10)
                            imgui.PushFont(regular9)
                                for _, item in window.customization.editors {
                                    if imgui.ColorEdit4("##" .. item.id, item.value, imgui.ColorEditFlags.NoInputs) {
                                        config.root.styleChangeableWindows[window.customization.selectedId] ??= {}
                                        changeConfigProperties(item)
                                    }

                                    imgui.SameLine()
                                    imgui.Text(item.name)
                                }
                            imgui.PopFont()
                        imgui.EndGroup()
                    imgui.EndChild()
                    imgui.SameLine(nil, 6)
                    imgui.BeginChild("imgui.windows.Main.Customization.WindowSelector", imgui.ImVec2(243, childHeight), false, self.flags)
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            local widthAuto = imgui.GetWindowWidth() - 12

                            imguiAssets::textWithFont("Выберите окно", bold10)
                            imgui.SetNextItemWidth(widthAuto)
                            imgui.PushFont(regular9)
                                imgui.Combo(
                                    "##imgui.window.Main.Customization.Combo",
                                    window.customization.combo.buffer,
                                    window.customization.combo.array,
                                    window.customization.combo.size,
                                    imgui.ComboFlags.HeightLargest + imgui.ComboFlags.NoArrowButton
                                )
                            imgui.PopFont()

                            imgui.PushFont(bold10)
                                if animations::button("Скопировать тему", imgui.ImVec2(widthAuto, 30)) {
                                    local copiedValues = {}

                                    for _, property in window.customization.editors {
                                        table.insert(copiedValues, imgui.ImVec4(property.value[0], property.value[1], property.value[2], property.value[3]))
                                    }

                                    window.customization.copiedValues = copiedValues 
                                }

                                if animations::button("Вставить тему", imgui.ImVec2(widthAuto, 30)) {
                                    if local copiedValues = window.customization.copiedValues {
                                        for index, value in copiedValues {
                                            window.customization.editors[index].value[0] = value.x
                                            window.customization.editors[index].value[1] = value.y
                                            window.customization.editors[index].value[2] = value.z
                                            window.customization.editors[index].value[3] = value.w
                                        }
                                        
                                        for _, item in window.customization.editors {
                                            changeConfigProperties(item)
                                        }
                                    }
                                }
                    
                                animations::hint(
                                    "У вас не скопирована тема",
                                    fn { return window.customization.copiedValues == nil && imgui.IsItemHovered() },
                                    nil,
                                    common::convertHex2ImVec4("E46876")
                                )

                                if animations::button("Сбросить тему", imgui.ImVec2(widthAuto, 30)) {
                                    config.root.styleChangeableWindows[window.customization.selectedId] = nil
                                    style.windows[window.customization.selectedId]                      = StyleChanger::new({})
                                    for index, property in style::getBaseColors() {
                                        window.customization.editors[index].value[0] = property[2][1]
                                        window.customization.editors[index].value[1] = property[2][2]
                                        window.customization.editors[index].value[2] = property[2][3]
                                        window.customization.editors[index].value[3] = property[2][4]
                                    }
                                }

                                if animations::button("Применить для всех окон", imgui.ImVec2(widthAuto, 30)) {
                                    for _, win in registeredWindows {
                                        if win.id != window.customization.selectedId {
                                            config.root.styleChangeableWindows[win.id] = {}
                                            for _, source in window.customization.editors {
                                                table.insert(config.root.styleChangeableWindows[win.id], {
                                                    source.styleKey, { source.value[0], source.value[1], source.value[2], source.value[3] }
                                                })
                                            } 
                                        }
                                    }
                                }

                                imgui.BeginGroup()
                                    if animations::toggleButton("Использовать MoonMonet", window.customization.moonMonet.toggle) {
                                        window.customization.colorPicker.clock = os.clock()
                                    }

                                    window.customization.colorPicker.alpha ??= (window.customization.moonMonet.toggle[0]) ? 1.0 : 0.5

                                    if window.customization.colorPicker.clock {
                                        window.customization.colorPicker.alpha = imguiAssets::bringFloatTo(
                                            $,
                                            (window.customization.moonMonet.toggle[0]) ? 1.0 : 0.5,
                                            window.customization.colorPicker.clock,
                                            0.3
                                        )
                                    }

                                    imgui.BeginChild(
                                        "##imgui.windows.Main.Customization.MoonMonetPicker.child",
                                        imgui.ImVec2(widthAuto, 30),
                                        false,
                                        (window.menu.width > 60 || !window.customization.moonMonet.toggle[0]) ? imgui.WindowFlags.NoInputs : 0
                                    )
                                        local alpha = (window.customization.colorPicker.alpha == 1)
                                            ? 1.0 - window.menu.alpha / 255 / 2 - window.menu.switchBetweenFramesAlpha 
                                            : window.customization.colorPicker.alpha

                                        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
                                            imgui.SetNextItemWidth(widthAuto)
                                            if imgui.ColorEdit4(
                                                "##imgui.windows.Main.Customization.MoonMonetPicker",
                                                window.customization.moonMonet.accent,
                                                imgui.ColorEditFlags.NoSidePreview + imgui.ColorEditFlags.DisplayHex
                                            ) {
                                                local fn getColorArray() {
                                                    return {
                                                        { "Text", { "neutral1", 50 } },
                                                        { "TextDisabled", { "neutral1", 500 } },
                                                        { "WindowBg", { "accent1", 900 } },
                                                        { "ChildBg", { "accent2", 800 } },
                                                        { "PopupBg", { "accent2", 800 } },
                                                        { "Border", { "neutral1", "default" } },
                                                        { "BorderShadow", { "neutral2", "default" } },
                                                        { "FrameBg", { "accent1", 600 } },
                                                        { "FrameBgHovered", { "accent1", 500 } },
                                                        { "FrameBgActive", { "accent1", 400 } },
                                                        { "ScrollbarBg", { "accent1", 800 } },
                                                        { "ScrollbarGrab", { "accent2", 600 } },
                                                        { "ScrollbarGrabHovered", { "accent2", 500 } },
                                                        { "ScrollbarGrabActive", { "accent2", 400 } },
                                                        { "Button", { "accent1", 500 } },
                                                        { "ButtonHovered", { "accent1", 400 } },
                                                        { "ButtonActive", { "accent1", 300 } },
                                                        { "Header", { "accent1", 800 } },
                                                        { "HeaderHovered", { "accent1", 700 } },
                                                        { "HeaderActive", { "accent1", 600 } },
                                                        { "Separator", { "accent2", 200 } },
                                                        { "SeparatorHovered", { "accent1", 100 } },
                                                        { "SeparatorActive", { "accent1", 50 } },
                                                        { "TextSelectedBg", { "neutral1", 300 } }
                                                    }
                                                }

                                                local vector = imgui.ImVec4(
                                                    window.customization.moonMonet.accent[0],
                                                    window.customization.moonMonet.accent[1],
                                                    window.customization.moonMonet.accent[2],
                                                    window.customization.moonMonet.accent[3]
                                                )

                                                local colorU32      = imgui.ColorConvertFloat4ToU32(vector)
                                                local colors        = moonMonet.buildColors(assets::convertU32ToARGB(colorU32), 1.0, true)
                                                local colorArray    = getColorArray()

                                                for _, item in colorArray {
                                                    item[2] = (fn {
                                                        if item[2][2] == "default" {
                                                            local vector = imgui.GetStyle().Colors[imgui.Col[item[1]]]
                                                            return { vector.x, vector.y, vector.z, vector.w }
                                                        }

                                                        local a, r, g, b = assets::explodeARGB(colors[item[2][1]]["color_" .. item[2][2]])
                                                        return { r / 255, g / 255, b / 255, a / 255 }
                                                    })()
                                                }

                                                for index = 1, #colorArray {
                                                    config.root.styleChangeableWindows[window.customization.selectedId][index] = colorArray[index]
                                                }

                                                for index, item in colorArray {
                                                    window.customization.editors[index].value[0] = item[2][1]
                                                    window.customization.editors[index].value[1] = item[2][2]
                                                    window.customization.editors[index].value[2] = item[2][3]
                                                    window.customization.editors[index].value[3] = item[2][4]
                                                }
                                            }
                                        imgui.PopStyleVar()
                                    imgui.EndChild()
                                imgui.EndGroup()
                            imgui.PopFont()
                        imgui.EndGroup()
                    imgui.EndChild()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_BINDER {
                    imgui.SetScrollY(0)
                    
                    local childHeight = imgui.GetWindowHeight() - imgui.GetCursorPos().y - 6

                    imgui.BeginChild("imgui.windows.Main.binderMainChild", imgui.ImVec2(150, childHeight), true, self.flags)
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imguiAssets::textWithFont("Биндер", bold14)

                            imgui.SetCursorPosX(0)
                            imgui.BeginChild(
                                "imgui.windows.Main.binderMainChild.scrollableContent",
                                imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight() - 73),
                                false,
                                self.flags
                            )
                                imgui.SetCursorPos(imgui.ImVec2(6, 6))
                                imgui.PushFont(regular12)
                                    imgui.BeginGroup()
                                        for index, bind in config.root.binds {
                                            if animations::button(bind.title .. "##imgui.windows.Main.binderIndex" .. index, imgui.ImVec2(imgui.GetWindowWidth() - 12, 25)) {
                                                window.binder.selectedBind  = index
                                                window.binder.body.delay[0] = bind.delay || $COMMAND_DELAY

                                                imgui.StrCopy(window.binder.body.title, bind.title)
                                                imgui.StrCopy(window.binder.body.value, bind.value)
                                                imgui.StrCopy(window.binder.body.command, bind.commandName || "")
                                            }
                                        }
                                    imgui.EndGroup()
                                imgui.PopFont()
                            imgui.EndChild()

                            imgui.PushFont(bold10)
                                imgui.SetCursorPosY(imgui.GetWindowHeight() - 36)
                                if animations::button("Добавить##imgui.windows.Main.binder", imgui.ImVec2(imgui.GetWindowWidth() - 12, 30)) {
                                    local bindTitle         = "Бинд #"
                                    local bindTitleIndex    = #config.root.binds + 1
                                    
                                    for _, bind in config.root.binds {
                                        if local index = string.match(bind.title, "^Бинд #(%d+)$") {
                                            if tonumber(index) == bindTitleIndex {
                                                bindTitleIndex += 1
                                            }
                                        }
                                    }

                                    binder::newBind(bindTitle .. bindTitleIndex, "")
                                    
                                    window.binder.selectedBind  = #config.root.binds
                                    window.binder.body.delay[0] = $COMMAND_DELAY

                                    imgui.StrCopy(window.binder.body.title, "Бинд #" .. #config.root.binds)
                                    imgui.StrCopy(window.binder.body.value, "")
                                    imgui.StrCopy(window.binder.body.command, "")
                                }
                            imgui.PopFont()
                        imgui.EndGroup()
                    imgui.EndChild()

                    imgui.SameLine()

                    imgui.BeginChild("imgui.windows.Main.selectedBindBody", imgui.ImVec2(475, childHeight), true, self.flags)
                        if #config.root.binds == 0 {
                            local text = "У вас еще нет ни одного бинда"
                            local size = imgui.CalcTextSize(text)

                            imguiAssets::textWithFont(
                                text,
                                regular12,
                                imgui.ImVec2((imgui.GetWindowWidth() - size.x) / 2, (imgui.GetWindowHeight() - size.y) / 2),
                                imgui.GetStyle().Colors[imgui.Col.TextDisabled]
                            )
                        } else {
                            imgui.SetCursorPos(imgui.ImVec2(6, 6))
                            imgui.BeginGroup()
                                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0))
                                imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0)
                                imgui.PushFont(bold14)
                                    imgui.SetCursorPosX(1)
                                    imgui.SetNextItemWidth(200)
                                    if imgui.InputText(
                                        "##imgui.windows.Main.selectedBindBody.titleInput",
                                        window.binder.body.title,
                                        ffi.sizeof(window.binder.body.title)
                                    ) {
                                        config.root.binds[window.binder.selectedBind].title = ffi.string(window.binder.body.title)
                                    }
                                imgui.PopFont()
                                imgui.PopStyleColor()
                                imgui.PopStyleVar()

                                imgui.BeginGroup()
                                    imguiAssets::textWithFont("Команда", bold10)
                                    imgui.PushFont(regular12)
                                        imgui.SetNextItemWidth(215)
                                        if imgui.InputTextWithHint(
                                            "##imgui.windows.Main.selectedBindBody.commandInput",
                                            "Отсутствует",
                                            window.binder.body.command,
                                            ffi.sizeof(window.binder.body.command)
                                        ) {
                                            local newCommand            = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1")
                                            local newCommandCallback    = fn(args = "") {
                                                local arguments = {}

                                                for argument with string.gmatch(args, "[^%s]+") {
                                                    table.insert(arguments, argument)
                                                }

                                                binder::sendString(
                                                    newCommand,
                                                    config.root.binds[window.binder.selectedBind].value,
                                                    arguments,
                                                    config.root.binds[window.binder.selectedBind].delayBetweenMessages
                                                )
                                            }

                                            if newCommand != "" {
                                                if local sourceCommand = config.root.binds[window.binder.selectedBind].commandName {
                                                    if sampIsChatCommandDefined(sourceCommand) {
                                                        if !sampIsChatCommandDefined(newCommand) {
                                                            sampUnregisterChatCommand(sourceCommand)
                                                            sampRegisterChatCommand(newCommand, newCommandCallback)
                                                
                                                            config.root.binds[window.binder.selectedBind].commandName = newCommand
                                                        }
                                                    }
                                                } else {
                                                    if !sampIsChatCommandDefined(newCommand) {
                                                        config.root.binds[window.binder.selectedBind].commandName = newCommand
                                                        sampRegisterChatCommand(newCommand, newCommandCallback)
                                                    }
                                                }
                                            } else {
                                                if local sourceCommand = config.root.binds[window.binder.selectedBind].commandName {
                                                    if sampIsChatCommandDefined(sourceCommand) {
                                                        sampUnregisterChatCommand(sourceCommand)
                                                        config.root.binds[window.binder.selectedBind].commandName = nil
                                                    }
                                                } 
                                            }
                                        }

                                        animations::hint(
                                            "Эта команда уже зарегистрирована!\nПопробуйте другую команду.",
                                            fn {
                                                local command = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1") 
                                                return #command > 0
                                                    && sampIsChatCommandDefined(command)
                                                    && command != config.root.binds[window.binder.selectedBind].commandName 
                                            },
                                            nil,
                                            common::convertHex2ImVec4("E46876")
                                        )
                                    imgui.EndGroup()

                                    imgui.SameLine()

                                    imgui.BeginGroup()
                                        imgui.SetCursorPosY(imgui.GetCursorPos().y - 4)
                                        imguiAssets::textWithFont("Задержка", bold10)
                                        imgui.SetNextItemWidth(115)
                                        imgui.SetCursorPosY(imgui.GetCursorPos().y + 4)
                                        if imgui.InputInt("##imgui.windows.Main.selectedBindBody.delayInputInt", window.binder.body.delay, 10) {
                                            config.root.binds[window.binder.selectedBind].delay = window.binder.body.delay[0]
                                        }
                                    imgui.EndGroup()

                                    imgui.SameLine()

                                    imgui.BeginGroup()
                                        imgui.SetCursorPosY(imgui.GetCursorPos().y - 4)
                                        imguiAssets::textWithFont("Клавиши", bold10)
                                        for _, hotKey in allHotKeys {
                                            if local index = string.match(hotKey.id, "^binderIndex(%d+)$") {
                                                if tonumber(index) == window.binder.selectedBind {
                                                    imgui.SetCursorPosY(imgui.GetCursorPos().y + 4)
                                                    hotKey::render(imgui.ImVec2(123, 26), fn(self) {
                                                        hotKeysCallbacks[self.id].callback = fn {
                                                            binder::sendString(
                                                                config.root.binds[window.binder.selectedBind].commandName,
                                                                config.root.binds[window.binder.selectedBind].value,
                                                                nil,
                                                                config.root.binds[window.binder.selectedBind].delayBetweenMessages
                                                            )
                                                        }
                                                    })
                                                }
                                            }
                                        }
                                    imgui.EndGroup()
                                imgui.PopFont()
                                
                                imgui.PushFont(regular12)
                                    imguiAssets::textWithFont("Текст", bold10)
                                    imgui.SameLine(nil, 106)
                                    imgui.BeginGroup()
                                        imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                                            local pos = imgui.GetCursorPos()
                                            imguiAssets::textWithFont("знак ^ в начале линии", bold10)
                                            imgui.SameLine()
                                            imgui.SetCursorPosY(pos.y + 1)
                                            imguiAssets::textWithFont("вставит строку в поле ввода игры", regular10)
                                        imgui.PopStyleColor()
                                    imgui.EndGroup()
                                    imgui.PushFont(bold10)
                                        if animations::button("Вставить переменную##imgui.windows.Main.selectedBindBody", imgui.ImVec2(imgui.GetWindowWidth() - 12, 25)) {
                                            window.popupModal.body = binder::getPopupRenderer(window.binder.body.value, window.popupModal, fn (value) {
                                                config.root.binds[window.binder.selectedBind].value = value
                                            })

                                            window.binder.callPopup = true
                                        }
                                    imgui.PopFont()
                                    if imgui.InputTextMultiline(
                                        "##imgui.windows.Main.selectedBindBody.valueInput",
                                        window.binder.body.value,
                                        ffi.sizeof(window.binder.body.value),
                                        imgui.ImVec2(imgui.GetWindowWidth() - 12, imgui.GetWindowHeight() - imgui.GetCursorPos().y - 37)
                                    ) {
                                        config.root.binds[window.binder.selectedBind].value = ffi.string(window.binder.body.value)
                                    }
                                imgui.PopFont()

                                imgui.PushFont(bold10)
                                    if animations::button("Удалить бинд##imgui.windows.Main.selectedBindBody", imgui.ImVec2(imgui.GetWindowWidth() - 12, 25)) {
                                        for index, hotKey in allHotKeys {
                                            if local bindIndex = string.match(hotKey.id, "^binderIndex(%d+)$") {
                                                if tonumber(bindIndex) == window.binder.selectedBind {
                                                    hotKeysCallbacks[hotKey.id]     = nil
                                                    config.root.hotKeys[hotKey.id]  = nil

                                                    table.remove(allHotKeys, index)
                                                }
                                            }
                                        }

                                        if local command = string.gsub(ffi.string(window.binder.body.command), "^/(.*)", "%1") {
                                            if sampIsChatCommandDefined(command) {
                                                sampUnregisterChatCommand(command)
                                            }
                                        }

                                        table.remove(config.root.binds, window.binder.selectedBind)

                                        if #config.root.binds > 0 {
                                            window.binder.selectedBind  = #config.root.binds
                                            window.binder.body.delay[0] = config.root.binds[window.binder.selectedBind].delay || $COMMAND_DELAY

                                            imgui.StrCopy(window.binder.body.title, config.root.binds[window.binder.selectedBind].title)
                                            imgui.StrCopy(window.binder.body.value, config.root.binds[window.binder.selectedBind].value)
                                            imgui.StrCopy(window.binder.body.command, config.root.binds[window.binder.selectedBind].commandName || "")
                                        }
                                    }
                                imgui.PopFont()
                            imgui.EndGroup()
                        }
                    imgui.EndChild()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_LOGS {
                    imgui.SetScrollY(0)
                    imgui.BeginChild("imgui.windows.Main.logs.LogSelection", imgui.ImVec2(widthAuto, 32), true, self.flags)
                        imgui.SetScrollY(0)
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imguiAssets::textWithFont("Логи", bold14)
                            imgui.SameLine()
                            imgui.PushFont(regular12)
                                imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(5, 2))
                                imgui.BeginGroup()
                                    for index, section in allowedLogs {
                                        if animations::clickableUnderlinedText(
                                            section[1] .. "##imgui.windows.Main.logs.LogSelector",
                                            window.logs.selected == index
                                        ) {
                                            window.logs.selected = index
                                            window.logs.voidQuote = assets.voidQuotes[math.random(#assets.voidQuotes)]
                                        }

                                        imgui.SameLine(nil, 20)
                                    }
                                imgui.EndGroup()
                            imgui.PopFont()
                            imgui.NewLine()
                        imgui.EndGroup()
                    imgui.EndChild()

                    imgui.BeginChild(
                        "imgui.windows.Main.logs.SelectedLog",
                        imgui.ImVec2(widthAuto, imgui.GetWindowHeight() - imgui.GetCursorPos().y - 6),
                        true,
                        self.flags
                    )
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imgui.SetNextItemWidth(imgui.GetWindowWidth() - 12)
                            imgui.PushFont(regular12)
                                window.logs.filter::draw("##imgui.windows.logs.LogFilter", nil, imgui.GetWindowWidth() - 12)
                            imgui.PopFont()
                            
                            imgui.BeginChild(
                                "imgui.windows.Main.logs.Messages",
                                imgui.ImVec2(imgui.GetWindowWidth() - 12, imgui.GetWindowHeight() - imgui.GetCursorPos().y - 6),
                                false,
                                self.flags
                            )
                                imgui.SetCursorPos(imgui.ImVec2(6, 6))
                                imgui.BeginGroup()
                                    if #allowedLogs[window.logs.selected][2] == 0 {
                                        local text = window.logs.voidQuote
                                        imguiAssets::textWithFont(text, regular12, imgui.ImVec2(
                                            ((imgui.GetWindowWidth()) - imgui.CalcTextSize(text).x) / 2,
                                            ((imgui.GetWindowHeight() - imgui.GetCursorPos().y) - imgui.CalcTextSize(text).y) / 2
                                        ), imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                                    }
                                    
                                    for _, message in allowedLogs[window.logs.selected][2] {
                                        local fullText = string.format(
                                            "[%02d:%02d:%02d] %s",
                                            message.time.wHour,
                                            message.time.wMinute,
                                            message.time.wSecond,
                                            message.text
                                        ) 

                                        if window.logs.filter::passFilter(fullText) {
                                            imgui.BeginGroup()
                                                imguiAssets::textWithFont(string.format(
                                                    "[%02d:%02d:%02d]",
                                                    message.time.wHour,
                                                    message.time.wMinute,
                                                    message.time.wSecond
                                                ), bold10)
                                                imgui.SameLine(nil, 2)
                                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 1)
                                                imgui.PushFont(regular9)
                                                    imgui.TextWrapped(message.text)
                                                imgui.PopFont()
                                            imgui.EndGroup()

                                            imguiAssets::setPreviousItemAbleToCopy(fullText, nil, "Лог успешно скопирован в буффер обмена!")
                                        }
                                    }
                                imgui.EndGroup()
                            imgui.EndChild()
                        imgui.EndGroup()
                    imgui.EndChild()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_SERVER_TABLES {
                    imgui.SetScrollY(0)
                    imgui.BeginChild(
                        "imgui.windows.Main.serverTables.tableSelectorChild",
                        imgui.ImVec2(widthAuto, 60),
                        true,
                        self.flags
                    )
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imgui.PushFont(regular12)
                                imguiAssets::textWithFont("Таблицы", bold14)
                                imgui.SameLine(80)
                            
                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 3)
                                if animations::clickableUnderlinedText("Урон/эффекты оружий##serverTable", window.serverTables.selected == 0) {
                                    window.serverTables.selected = 0
                                }

                                imguiAssets::textWithFont("| Цены", regular12, imgui.GetCursorPos() - imgui.ImVec2(0, 2))
                                imgui.SameLine(80)
                                imgui.SetCursorPosY(imgui.GetCursorPos().y + 1)
                                for index, section in serverTables.prices {
                                    if animations::clickableUnderlinedText(section[1] .. "##serverTable", window.serverTables.selected == index) {
                                        window.serverTables.selected = index
                                        window.serverTables.filter::clear()
                                    }

                                    imgui.SameLine(nil, 20)
                                }
                                imgui.NewLine()
                            imgui.PopFont()
                        imgui.EndGroup()
                    imgui.EndChild()
                    imgui.BeginChild(
                        "imgui.windows.Main.serverTables.selectedTableChild",
                        imgui.ImVec2(widthAuto, imgui.GetWindowHeight() - imgui.GetCursorPos().y - 12),
                        true,
                        self.flags
                    )
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            local title = (window.serverTables.selected == 0)
                                ? "Урон/эффекты оружий"
                                : serverTables.prices[window.serverTables.selected][1]

                            imguiAssets::textWithFont(title, bold14)

                            if window.serverTables.selected == 0 {
                                imgui.Columns(#serverTables.weaponDamage[1], "imgui.windows.Main.serverTables.weaponDamage", true)
                                for sectionIndex, section in serverTables.weaponDamage {
                                    section.alpha ??= 1.0

                                    imgui.BeginGroup()
                                        for valueIndex, value in section {
                                            imgui.SetColumnWidth(valueIndex - 1, ({ 111, 69, 42, 39, 33, 46, 60, 224 })[valueIndex])
                                            if local value = string.gsub($, "%%", "%%%%") {
                                                imgui.PushFont((sectionIndex == 1) ? bold10 : regular9)
                                                    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, section.alpha - window.menu.alpha / 255 / 2 - window.menu.switchBetweenFramesAlpha)
                                                        imgui.Text(value)
                                                    imgui.PopStyleVar()
                                                    imgui.NextColumn()
                                                imgui.PopFont()
                                            }
                                        }
                                        imgui.Separator()
                                    imgui.EndGroup()

                                    if sectionIndex != 1 {
                                        if local posX, posY = getCursorPos() {
                                            local columnGroupStartX = imgui.GetWindowPos().x + 6 /* padding */
                                            local columnGroupEndX   = columnGroupStartX + imgui.GetWindowWidth() - 6 /* padding */
                                            local columnGroupStartY = imgui.GetItemRectMin().y - 4 /* separator spacing */ 
                                            local columnGroupEndY   = imgui.GetItemRectMax().y

                                            if imgui.IsWindowHovered() && (
                                                (posX >= columnGroupStartX && posX <= columnGroupEndX) &&
                                                (posY >= columnGroupStartY && posY <= columnGroupEndY)
                                            ) {
                                                section.alpha = 0.5

                                                if imgui.IsMouseClicked(0 /* ImGuiMouseButton_Left */) {
                                                    local WEAPON_NAME   = 1
                                                    local CALIBER       = 2
                                                    local LEGS_DAMAGE   = 3
                                                    local HANDS_DAMAGE  = 4
                                                    local GROIN_DAMAGE  = 5
                                                    local TORSO_DAMAGE  = 6
                                                    local HEAD_DAMAGE   = 7
                                                    local EFFECT        = 8

                                                    local text = section[WEAPON_NAME]

                                                    if #section[CALIBER] != 0 {
                                                        text ..= string.format("(%s)", section[CALIBER])
                                                    }

                                                    text ..= string.format(
                                                        ": Ноги и руки = %s, пах = %s, торс = %s, голова = %s",
                                                        section[LEGS_DAMAGE],
                                                        section[GROIN_DAMAGE],
                                                        section[TORSO_DAMAGE],
                                                        section[HEAD_DAMAGE]
                                                    )

                                                    if #section[EFFECT] != 0 {
                                                        local effect = string.gsub(section[EFFECT], "%%", "")
                                                        text ..= string.format(", эффект = %s", effect)
                                                    }

                                                    setClipboardText(text)
                                                    notify::send({
                                                        title   = "Параметры оружия скопированы",
                                                        text    = "Параметры " .. section[WEAPON_NAME] .. " скопированы в буффер обмена.",
                                                        icon    = icons.ICON_KEYBOARD
                                                    })
                                                }
                                            } else {
                                                section.alpha = 1.0
                                            }
                                        }
                                    }
                                }
                            } else {
                                local section = serverTables.prices[window.serverTables.selected][2]

                                imgui.PushFont(regular12)
                                    window.serverTables.filter::draw("##imgui.windows.serverTables.filter", nil, imgui.GetWindowWidth() - 12)
                                imgui.PopFont()

                                local fn centerAlign(font, text) {
                                    imgui.SetCursorPosX(
                                        (imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) -
                                        font::CalcTextSizeA(font.FontSize, math.huge, 0.0, text).x / 2
                                    )
                                }

                                local index = 1

                                imgui.BeginChild("imgui.windows.serverTables.tablesScroll", imgui.ImVec2(
                                    imgui.GetWindowWidth() - 12,
                                    0
                                ), false, self.flags)
                                    while #section >= index {
                                        local columnsCount  = (section[index + 2] && section[index + 3]) ? 4 : 2
                                        local iteratorPeek  = (section[index + 2] && section[index + 3]) ? 2 : 1

                                        imgui.Columns(columnsCount)

                                        for step = 1, iteratorPeek {
                                            local leftItemIndex     = index + (step * 2) - 2
                                            local rightItemIndex    = leftItemIndex + 1
                                            local alpha             = 1.00

                                            if !window.serverTables.filter::passFilter(string.format(
                                                "%s %s",
                                                section[leftItemIndex],
                                                section[rightItemIndex]
                                            )) {
                                                alpha = 0.5
                                            } elseif #ffi.string(window.serverTables.filter.buffer) > 0 {
                                                if imgui.GetCursorPos().y >= imgui.GetWindowHeight() || imgui.GetCursorPos().y <= imgui.GetScrollY() {
                                                    imgui.SetScrollY(imgui.GetCursorPos().y)
                                                }
                                            }

                                            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
                                                imgui.BeginGroup()
                                                    centerAlign(bold10, section[leftItemIndex])
                                                    imgui.BeginGroup()
                                                        imguiAssets::textWithFont(section[leftItemIndex], bold10)
                                                        imgui.NextColumn()
                                                    imgui.EndGroup()    
                                            
                                                    imgui.SameLine()
                                        
                                                    centerAlign(regular10, section[rightItemIndex])
                                                    imgui.BeginGroup()
                                                        imguiAssets::textWithFont(section[rightItemIndex], regular10)
                                                        imgui.NextColumn()
                                                    imgui.EndGroup()    
                                                imgui.EndGroup()
                                            imgui.PopStyleVar()

                                            if step == 1 && iteratorPeek == 2 {
                                                imgui.SameLine()
                                            }
                                        }

                                        index += iteratorPeek * 2

                                        imgui.Separator()
                                    }
                                imgui.EndChild()
                            }
                        imgui.EndGroup()
                    imgui.EndChild()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_NOTES {
                    local childHeight = imgui.GetWindowHeight() - imgui.GetCursorPos().y - 6
                    
                    imgui.BeginChild("imgui.windows.Main.noteList", imgui.ImVec2(150, childHeight), true)
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            imguiAssets::textWithFont("Заметки", bold14)

                            imgui.SetCursorPosX(0)
                            imgui.BeginChild(
                                "imgui.windows.main.noteList.selection",
                                imgui.ImVec2(imgui.GetWindowWidth(), imgui.GetWindowHeight() - 42 - imgui.GetCursorPos().y),
                                false
                            )
                                imgui.PushFont(regular12)
                                    imgui.SetCursorPosY(3)
                                    for index, note in config.root.playerNotes {
                                        imgui.SetCursorPosX(6)
                                        
                                        local size      = imgui.ImVec2(imgui.GetWindowWidth() - 12, 25)
                                        local title     = note.title
                                        local titleSize = regular12::CalcTextSizeA(regular12.FontSize, math.huge, 0.0, title)
                                        local dotsSize  = regular12::CalcTextSizeA(regular12.FontSize, math.huge, 0.0, "...")

                                        local postfix = ((titleSize.x - dotsSize.x) >= (size.x - 50)) ? "..." : "" 

                                        while (titleSize.x - dotsSize.x) >= (size.x - 50) {
                                            title       = string.sub($, 1, #$ - 1)
                                            titleSize   = regular12::CalcTextSizeA(regular12.FontSize, math.huge, 0.0, title)
                                        }

                                        if animations::button(title .. postfix .. "##noteSelectorIndex" .. index, size) {
                                            if local this = window.notes {
                                                this.display[0] = note.display
                                                this.selected   = index

                                                imgui.StrCopy(this.title, note.title)
                                                imgui.StrCopy(this.body, note.body)
                                            }
                                        }
                                    }
                                imgui.PopFont()
                            imgui.EndChild()

                            imgui.PushFont(bold10)
                                if animations::button("Добавить##imgui.windows.main.notes.add", imgui.ImVec2(imgui.GetWindowWidth() - 12, 30)) {
                                    playerNotes::new({
                                        title   = "Заметка " .. #config.root.playerNotes + 1,
                                        body    = "",
                                        display = false
                                    })

                                    if local this = window.notes {
                                        this.display[0] = false
                                        this.selected   = #config.root.playerNotes

                                        imgui.StrCopy(this.title, config.root.playerNotes[this.selected].title)
                                        imgui.StrCopy(this.body, "")
                                    }
                                }
                            imgui.PopFont()
                        imgui.EndGroup()
                    imgui.EndChild()
                    imgui.SameLine()
                    imgui.BeginChild(
                        "imgui.windows.main.notes.body",
                        imgui.ImVec2(widthAuto - 150 /* left-child width */ - imgui.GetStyle().ItemSpacing.x, childHeight),
                        true
                    )
                        imgui.SetCursorPos(imgui.ImVec2(6, 6))
                        imgui.BeginGroup()
                            if #config.root.playerNotes >= 1 {
                                local this      = window.notes
                                local id        = config.root.playerNotes[this.selected].id
                                this.display[0] = playerNotes.displayBuffer[id][0]

                                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0))
                                imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0)
                                imgui.PushFont(bold14)
                                    imgui.SetCursorPosX(1)
                                    imgui.SetNextItemWidth(imgui.GetWindowWidth() - 12 /* padding * 2 */)
                                    if imgui.InputText(
                                        "##imgui.windows.Main.notes.body.title",
                                        this.title,
                                        ffi.sizeof(this.title)
                                    ) {
                                        config.root.playerNotes[this.selected].title = ffi.string(this.title)
                                    }
                                imgui.PopFont()
                                imgui.PopStyleColor()
                                imgui.PopStyleVar()

                                imgui.BeginGroup()
                                    if animations::toggleButton("##imgui.windows.Main.notes.body.display", this.display) {
                                        config.root.playerNotes[this.selected].display = this.display[0]
                                        playerNotes.displayBuffer[id][0] = this.display[0]
                                    }

                                    imgui.SameLine()
                                    imguiAssets::textWithFont("Отобразить на экране", regular12)
                                imgui.EndGroup()

                                imgui.PushFont(bold12)
                                    animations::hint("Ваша заметка будет также как и остальные окна:\nеё можно кастомизировать и изменять ее положение.")
                                    imgui.Text("Описание заметки")
                                    
                                    if animations::button("Вставить переменную##imgui.windows.Main.notes.insertVariables", imgui.ImVec2(
                                        imgui.GetWindowWidth() - 12 /* padding * 2 */,
                                        25
                                    )) {
                                        window.popupModal.body  = binder::getPopupRenderer(this.body, window.popupModal, fn (value) {
                                            config.root.playerNotes[this.selected].body = value
                                        })
                                        window.binder.callPopup = true
                                    }
                                imgui.PopFont()
                                
                                imgui.PushFont(regular12)
                                    if imgui.InputTextMultiline(
                                        "##imgui.windows.Main.notes.body.description",
                                        this.body,
                                        ffi.sizeof(this.body),
                                        imgui.ImVec2(
                                            imgui.GetWindowWidth() - 12 /* padding * 2 */,
                                            imgui.GetWindowHeight() - imgui.GetCursorPos().y - 12 /* padding * 2 */ - 30 /* button size */
                                        )
                                    ) {
                                        config.root.playerNotes[this.selected].body = ffi.string(this.body)
                                    }
                                imgui.PopFont()

                                imgui.PushFont(bold10)
                                    if animations::button(
                                        "Удалить##imgui.windows.Main.notes.body.remove",
                                        imgui.ImVec2(imgui.GetWindowWidth() - 12 /* padding * 2 */, 30)
                                    ) {
                                        playerNotes::remove(this.selected)
                                        if local note = config.root.playerNotes[1] {
                                            this.display[0] = note.display
                                            this.selected   = 1

                                            imgui.StrCopy(this.title, note.title)
                                            imgui.StrCopy(this.body, note.body)
                                        }
                                    }
                                imgui.PopFont()
                            } else {
                                local text = window.notes.voidQuote
                                local size = regular12::CalcTextSizeA(regular12.FontSize, math.huge, 0.0, text)

                                imguiAssets::textWithFont(text, regular12, imgui.ImVec2(
                                    ((imgui.GetWindowWidth()) - size.x) / 2,
                                    ((imgui.GetWindowHeight() - size.y) - size.y) / 2
                                ), imgui.GetStyle().Colors[imgui.Col.TextDisabled])           
                            }
                        imgui.EndGroup()
                    imgui.EndChild()
                } elseif window.menu.selectedFrame == WINDOW_SELECTED_FRAME_STATISTICS {
                    local text = "Вкладка со статистикой будет реализована когда рак на горе свистнет."
                    local size = regular12::CalcTextSizeA(regular12.FontSize, math.huge, 0.0, text)

                    imguiAssets::textWithFont(text, regular12, imgui.ImVec2(
                        ((imgui.GetWindowWidth()) - size.x) / 2,
                        ((imgui.GetWindowHeight() - size.y) - size.y) / 2
                    ), imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                }
            imgui.EndGroup()
            imgui.PopStyleVar()

            if window.menu.clock {
                window.menu.width = imguiAssets::bringFloatTo($, (window.menu.state) ? 200 : 60, window.menu.clock, 0.1)
                window.menu.alpha = imguiAssets::bringFloatTo($, (window.menu.state) ? 255 : 0, window.menu.clock, 0.8)
            }

            imgui.SetCursorPos(imgui.ImVec2(0, 0))
            imgui.PushStyleVarFloat(imgui.StyleVar.ChildBorderSize, 0)
                imgui.SetCursorPosY(imgui.GetScrollY())
                imgui.BeginChild("imgui.windows.Main.menu", imgui.ImVec2(window.menu.width, imgui.GetWindowHeight()), true)
                    local color = imgui.GetStyle().Colors[imgui.Col.ChildBg]
                          color = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)

                    local textColor = imgui.GetStyle().Colors[imgui.Col.Text]
                          textColor = imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha)

                    imgui.GetWindowDrawList()::AddRectFilled(
                        imgui.GetWindowPos() + imgui.ImVec2(10, 10),
                        imgui.GetWindowPos() + imgui.ImVec2(window.menu.width, imgui.GetWindowHeight()),
                        imgui.ColorConvertFloat4ToU32(color)
                    )

                    imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.85))
                        imgui.SetCursorPos(imgui.ImVec2(5, 5))
                        if animations::button(icons.ICON_MENU .. "##imgui.windows.Main.menu.switch", imgui.ImVec2(50, 30)) {
                            window.menu.clock = os.clock()
                            window.menu.state = !$
                        }

                        if window.menu.width == 200 {
                            imgui.PushStyleColor(imgui.Col.Text, textColor)
                            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, window.menu.alpha / 255)
                                imgui.SameLine()
                                imguiAssets::textWithFont(
                                    "GAdmin v" .. $GADMIN_VERSION,
                                    bold10,
                                    imgui.ImVec2(122.5 - imgui.CalcTextSize("GAdmin v" .. $GADMIN_VERSION).x / 2, 11)
                                )
                            imgui.PopStyleVar()
                            imgui.PopStyleColor()
                        }
                    imgui.PopStyleVar()

                    imgui.SetCursorPosY(50)
                    imgui.BeginGroup()
                        window.menu::item("imgui.windows.Main.menu.home", icons.ICON_HOME, "Главная", 1)
                        window.menu::item("imgui.windows.Main.menu.settings", icons.ICON_HAMMER, "Настройки", 2) 
                        window.menu::item("imgui.windows.Main.menu.keybinds", icons.ICON_KEYBOARD, "Горячие клавиши", 3)
                        window.menu::item("imgui.windows.Main.menu.playerChecker", icons.ICON_PERSON, "Чекер игроков", 4)
                        window.menu::item("imgui.windows.Main.menu.customization", icons.ICON_PEN_BRUSH, "Кастомизация", 5)
                        window.menu::item("imgui.windows.Main.menu.binder", icons.ICON_CLIPBOARD, "Биндер", 6)
                        window.menu::item("imgui.windows.Main.menu.logs", icons.ICON_BOOK_OPEN, "Логи", 7)
                        window.menu::item("imgui.windows.Main.menu.serverTables", icons.ICON_VERTICAL_BAR_CHART, "Серверные таблицы", 8)
                        window.menu::item("imgui.windows.Main.menu.notes", icons.ICON_BOOKMARK_FILLED, "Заметки", 9)
                        window.menu::item("imgui.windows.Main.menu.statistics", icons.ICON_TREE_MAP, "Статистика", 10)
                    imgui.EndGroup()
                imgui.EndChild()
            imgui.PopStyleVar()
            
            if window.binder.callPopup {
                imgui.OpenPopup("imgui.windows.Main.Popup")
                window.binder.callPopup = false
            }

            if local rectMin, rectMax = imgui.GetItemRectMin(), imgui.GetItemRectMax() {
                // Render rects on menu corners to remove rounding.
                local dl    = imgui.GetWindowDrawList()
                local color = imgui.GetStyle().Colors[imgui.Col.ChildBg]
                      color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4($.x, $.y, $.z, window.closeAndOpenAnimation.alpha))
                
                dl::AddRectFilled(imgui.ImVec2(rectMax.x - 4, rectMin.y), imgui.ImVec2(rectMax.x + 0.5, rectMin.y + 7), color)
                dl::AddRectFilled(imgui.ImVec2(rectMax.x - 4, rectMax.y), imgui.ImVec2(rectMax.x + 0.5, rectMax.y - 7), color)

                if window.menu.width > 60 {
                    local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.WindowBg])
                    dl::AddRectFilled(imgui.ImVec2(rectMax.x, rectMin.y), rectMax + imgui.ImVec2(2, 0), color)
                }
            }

            //! Why we need this? Popup Modal dont resize itself if we have some custom elements from `animations` module (why?).
            //! We can use imgui.WindowFlags.AlwaysAutoResize flag, but window won't be centered, so we doing this.
            if imgui.IsPopupOpen("imgui.windows.Main.Popup") {
                imgui.SetNextWindowSize(window.popupModal.size)
                imgui.SetNextWindowPos(imgui.ImVec2((sizeX - window.popupModal.size.x) / 2, (sizeY - window.popupModal.size.y) / 2))
            }

            if imgui.BeginPopupModal("imgui.windows.Main.Popup", nil, self.flags + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar) {
                window.popupModal.body?()
            }
            imgui.EndPopup()
        imgui.End()
    imgui.PopStyleVar(2)
    
    style::endWindowStyleChangeable("imgui.windows.Main")
})
