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

@import "imgui.Windows"         => window
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Style"           => style

@import "game.samp.ChatInputBox"    => chatInputBox
@import "game.GReport"              => greport
@import "game.Spectator"            => spectator
@import "game.User"                 => user 
@import "game.sa.Vehicle"           => vehicle

@import "Algorithm" => algorithm
@import "Config"    => config
@import "Common"    => common

static enum /** @enum COMMAND_ARGUMENT */ {
    COMMAND_ARGUMENT_PLAYER_ID,
    COMMAND_ARGUMENT_PLAYER_NICKNAME,
    COMMAND_ARGUMENT_VEHID,
    COMMAND_ARGUMENT_CVEHID,
    COMMAND_ARGUMENT_HEALTH,
    COMMAND_ARGUMENT_ANY,
    COMMAND_ARGUMENT_REASON
}

local commands = {
    { "/inv", "Открыть инвентарь" },
    { "/mn", "Открыть главное меню" }, 
    { "/phone", "Достать телефон" },
    { "/sms", "Отправить sms", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/pass", "Показать документ удостоверяющий личность", COMMAND_ARGUMENT_PLAYER_ID },
    { "/anim", "Список анимаций" }, 
    { "/stop", "Сбросить анимацию" },
    { "/pay", "Передать деньги", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/update", "Посмотреть последние обновления" },
    { "/gps", "Открыть навигатор" }, 
    { "/walk", "Автоматическая походка" },
    { "/run", "Автоматический бег" }, 
    { "/rep", "Задать вопрос администраторам" },
    { "/ask", "Задать вопрос саппортам" }, 
    { "/channel", "Настроить канал рации" },
    { "/slot", "Настроить подканал рации" }, 
    { "/id", "Поиск игрока", COMMAND_ARGUMENT_PLAYER_NICKNAME },
    { "/afk", "Узнать, находится ли игрок в AFK", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/pame", "Посмотреть описание игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/mypame", "Управление описанием персонажа", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/dmypame", "Удалить описание персонажа" },
    { "/action", "Установить/Убрать действие своего персонажа" }, 
    { "/time", "Информация о времени и дате" },
    { "/clearchat", "Очистить чат" }, 
    { "/headmove", "Отключить поворот головы" },
    { "/blind", "Активировать черный экран (для создания СС)" }, 
    { "/pattach", "Аттачи для премиум игроков" },
    { "/dm", "Посмотреть урон персонажа", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/graffiti", "Нарисовать граффити" },
    { "/charity", "Слить деньги" }, 
    { "/dice", "Бросить игральную кость" },
    { "/coin", "Подкинуть монету" }, 
    { "/music", "Слушать музыку" },
    { "/fish", "Ловить рыбу" }, 
    { "/charact", "Характеристики персонажа" },
    { "/color", "Установить цвет клиста" }, 
    { "/help", "Открыть помощь по игре" },
    { "/jleave", "Уволиться с работы" }, 
    { "/bag", "Надеть/снять мешок с головы игрока" },
    { "/tie", "Связать/развязать игрока" }, 
    { "/notice", "Список уведомлений для персонажа" },
    { "/b", "ООС чат" }, 
    { "/s", "Кричать" },
    { "/w", "Шептать" }, 
    { "/r", "Рация" },
    { "/d", "Чат департамента" }, 
    { "/m", "Мегафон" },
    { "/mic", "Говорить в микрофон" }, 
    { "/me", "Действия от первого лица" },
    { "/do", "Действия от третьего лица" }, 
    { "/n", "Писать в радио во время эфира" },
    { "/try", "Попытка действия \"Удачно\" / \"Неудачно\"" }, 
    { "/todo", "Добавляет к сказанным словам деепричастный оборот" },
    { "/ame", "Действие от первого лица над головой" }, 
    { "/pame", "Описание персонажа от первого лица над головой" },
    { "/pm", "Написать приватное ООС сообщение другому игроку", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/r", "Говорить в канал и все принадлежащие ему слоты" },
    { "/rj", "Говорить в рабочую рацию ( рация для работ )" }, 
    { "/rr", "Говорить в определенный слот канала, в котором Вы находитесь" },
    { "/rl", "Тихо говорить в канал и все принадлежащие ему слоты" }, 
    { "/rrl", "Тихо говорить в определенный слот канала, в котором вы находитесь" },
    { "/slot", "Изменить подканал в своей рации" }, 
    { "/channel", "Изменить канал своей рации" },
    { "/hpanel", "Панель управления домом" }, 
    { "/hevict", "Выселится из дома" },
    { "/sdoor", "Постучать в дверь" }, 
    { "/tdoor", "Крикнуть в дверь" },
    { "/bpanel", "Панель управления бизнесом" }, 
    { "/market", "Загрузить/Поставить прилавок" },
    { "/sale", "Продать товар за лавкой" }, 
    { "/buy", "Закупить товар в лавку" },
    { "/tk", "Активировать тревожную кнопку в бизнесе" }, 
    { "/dj", "Управление музыкой в бизнесе" },
    { "/bm", "Говорить в микрофон бизнеса" }, 
    { "/makebm", "Выдать временный микрофон" },
    { "/bskin", "Выдать временный скин", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/bmenu", "Посмотреть товары на продаже" },
    { "/mycars", "Список Т/С игрока" }, 
    { "/cpanel", "Меню управления Т/С" },
    { "/caract", "Описание Т/С" }, 
    { "/climit", "Управление ограничителем скорости транспорта" },
    { "/cload", "Загрузить Т/С в багажник" }, 
    { "/park", "Припарковать Т/С" },
    { "/fixcar", "Вернуть Т/С на место парковки" }, 
    { "/cspeed", "Управление спидометром" },
    { "/csignal", "Поставить Т/С на сигнализацию" }, 
    { "/ceng", "Завести автомобиль" },
    { "/clock", "Открыть/Закрыть Т/С" }, 
    { "/chood", "Открыть/Закрыть капот Т/С" },
    { "/ctrunk", "Открыть/Закрыть багажник Т/С" }, 
    { "/cwindow", "Управление окнами Т/С" },
    { "/roof", "Поднять/Опустить крышу Т/С" }, 
    { "/ctrailer", "Прицепить/Отцепить дом на колесах" },
    { "/cbreak", "Взломать Т/С" }, 
    { "/eject", "Выбросить игрока из машины", COMMAND_ARGUMENT_PLAYER_ID },
    { "/fill", "Заправить Т/С" }, 
    { "/iban", "Перманентная (бессрочная) блокировка игрока", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_REASON },
    { "/banip", "Блокировать IP-адрес игрока", COMMAND_ARGUMENT_ANY, COMMAND_ARGUMENT_REASON },
    { "/veh", "Создать админ-транспорт" },
    { "/dveh", "Удалить админ-транспорт" },
    { "/dvehid", "Удалить админ-транспорт по ID" },
    { "/dvehall", "Удалить весь созданный админ-транспорт" },
    { "/aengine", "Изменить статус двигателя в машине" },
    { "/alock", "Изменить статус блокировки дверей в машине"},
    { "/settime", "Сменить время на сервере" },
    { "/makeleader", "Выдать лидерство игроку", COMMAND_ARGUMENT_PLAYER_ID },
    { "/bizinfo", "Информация о бизнесе" },
    { "/setprod", "Установить кол-во продуктов в бизнесе" },
    { "/unretest", "Снять ретест с аккаунта игрока", COMMAND_ARGUMENT_PLAYER_NICKNAME },
    { "/unwarn", "Снять предупреждение с игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/unban", "Снять блокировку с игрока", COMMAND_ARGUMENT_PLAYER_NICKNAME },
    { "/unbanip", "Разблокировать IP-адрес" },
    { "/adm", "Панель администратора" },
    { "/a", "Чат администрации" },
    { "/aspawn", "Заспавнить игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/tp", "Телепортация по местам" },
    { "/goto", "Телепортироваться к игроку", COMMAND_ARGUMENT_PLAYER_ID },
    { "/gethere", "Телепортировать игрока к себе", COMMAND_ARGUMENT_PLAYER_ID },
    { "/ptop", "Телепортировать игрока к другому игроку", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_PLAYER_ID },
    { "/sp", "Зайти в слежку за игроком", COMMAND_ARGUMENT_PLAYER_ID },
    { "/ans", "Ответить игроку", COMMAND_ARGUMENT_PLAYER_ID },
    { "/aa", "OOC чат от лица администратора" },
    { "/aafk", "Игроки в афк" },
    { "/stats", "Статистика игрока", COMMAND_ARGUMENT_PLAYER_ID }, 
    { "/afrisk", "Список предметов у игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/unfreeze", "Разморозить игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/weapons", "Список оружия у игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/aheal", "Пополняет HP-уровень игрока до 100 единиц", COMMAND_ARGUMENT_PLAYER_ID },
    { "/hp", "Пополнить свое здоровье до полного" },
    { "/sethp", "Установить HP-уровень игроку", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_HEALTH },
    { "/setworld", "Установить игроку виртуальный мир", COMMAND_ARGUMENT_PLAYER_ID },
    { "/setint", "Установить игроку интерьер мира", COMMAND_ARGUMENT_PLAYER_ID },
    { "/getcar", "Телепортировать к себе транспорт", COMMAND_ARGUMENT_CVEHID },
    { "/vrepair", "Восстановить HP-уровень транспорта до максимума", COMMAND_ARGUMENT_CVEHID },
    { "/getbuycar", "Телепортировать к себе личный транспорт", COMMAND_ARGUMENT_VEHID },
    { "/vspawn", "Заспавнить автомобиль", COMMAND_ARGUMENT_CVEHID },
    { "/adaction", "Удалить /action" },
    { "/dbuy", "Удалить GBUY обьявление" }, 
    { "/dpame", "Удалить описание игрока", COMMAND_ARGUMENT_VEHID },
    { "/gfmenu", "Панель управления граффити" },
    { "/gfids", "Список граффти в радиусе 100 метров" },
    { "/gfdell", "Удалить граффити по ID" },
    { "/mute", "Заблокировать IC-чат игрока", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_ANY, COMMAND_ARGUMENT_REASON },
    { "/bmute", "Заблокировать OOC-чат игрока", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_ANY, COMMAND_ARGUMENT_REASON },
    { "/unbmute", "Разблокировать OOC-чат игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/unmute", "Разблокировать IC-чат игрока", COMMAND_ARGUMENT_PLAYER_ID },
    { "/kick", "Отсоединить игрока от сервера", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_REASON },
    { "/jail", "Посадить игрока в ДеМорган", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_ANY, COMMAND_ARGUMENT_REASON },
    { "/unjail", "Вытащить игрока из ДеМоргана", COMMAND_ARGUMENT_PLAYER_ID },
    { "/warn", "Выдать игроку игровое предупреждение", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_REASON },
    { "/makemic", "Выдать игроку системный микрофон", COMMAND_ARGUMENT_PLAYER_ID },
    { "/leave", "Уволить игрока из фракции" },
    { "/house", "Телепортироваться к дому по номеру" },
    { "/biz", "Телепортироваться к бизнесу по номеру" },
    { "/vfuel", "Установить уровень топлива транспорту", COMMAND_ARGUMENT_CVEHID },
    { "/vspawnr", "Заспавнить весь транспорт в радиусе" },
    { "/adm_vehid", "Посмотреть принадлежность транспорта игроку", COMMAND_ARGUMENT_CVEHID },
    { "/ck", "Выдать Character Kill игроку", COMMAND_ARGUMENT_PLAYER_ID },
    { "/unck", "Снять Character Kill игроку", COMMAND_ARGUMENT_PLAYER_NICKNAME },
    { "/pk", "Выдать Player Kill игроку", COMMAND_ARGUMENT_PLAYER_ID },
    { "/ban", "Заблокировать аккаунт игрока", COMMAND_ARGUMENT_PLAYER_ID, COMMAND_ARGUMENT_ANY, COMMAND_ARGUMENT_REASON },
    { "/alogin", "Зайти на админ-дежурство" },
    { "/alogout", "Покинуть админ-дежурство" }
}

static autoCompletion = {
    position        = 1,
    clock           = os.clock(),
    commandsLength  = 1,
    condition       = fn {
        return !isGamePaused() && sampIsChatInputActive() && string.sub(sampGetChatInputText(), 1, 2)::find("/[A-Za-z]")
               && #sampGetChatInputText() >= 2
    }
}

imgui.OnFrame(fn { return autoCompletion.condition() && config.root.windows.autoCompletion.use }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar
        + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize

    self.suggestedList = (fn {
        local suggestedList = {}
        local inputText     = sampGetChatInputText()
        for _, command in commands {
            if string.find(inputText, "^" .. command[1] .. " ") { //! Working with command arguments.
                local index = 3

                while #command >= index {
                    if command[index] == COMMAND_ARGUMENT_ANY {
                        index += 1
                    } else {
                        local position = string.rep(" %S*", index - 3) .. " (%S*)"
                        if local argument = string.match(inputText, "^/%S+" .. position .. "$") {
                            local _, argumentStart      = string.find(inputText, "^/%S+" .. position)
                            local textBeforeArgument    = string.sub(inputText, 1, argumentStart - #argument - 1)

                            match command[index] /** COMMAND_ARGUMENT */ {
                                COMMAND_ARGUMENT_PLAYER_ID => {
                                    for itemIndex, id in ({ spectator.id, greport.player.id, user::getId() }) {
                                        if id != -1 {
                                            if local nickname = sampGetPlayerNickname(id) {
                                                table.insert(suggestedList, {
                                                    suggested   = textBeforeArgument .. ' ' .. id .. ' ',
                                                    description = nickname .. " (" .. ({
                                                        "игрок за которым вы следите",
                                                        "игрок за которым у вас закреплен GReport",
                                                        "ваш айди"
                                                    })[itemIndex] .. ")"
                                                })
                                            }
                                        }
                                    }

                                    if #argument > 0 {
                                        for id = 0, $SERVER_MAX_PLAYERS {
                                            if id != user::getId() && sampIsPlayerConnected(id) && (id == tonumber(argument) || string.find(id, argument, 1, true)) {
                                                local nickname = sampGetPlayerNickname(id)
                                                table.insert(suggestedList, {
                                                    suggested   = textBeforeArgument .. ' ' .. id .. ' ',
                                                    description = nickname
                                                })
                                            }
                                        }
                                    }
                                }

                                COMMAND_ARGUMENT_PLAYER_NICKNAME => {
                                    for itemIndex, nickname in ({ spectator.nickname, greport.player.nickname }) {
                                        if #nickname > 0 {
                                            table.insert(suggestedList, {
                                                suggested   = textBeforeArgument .. ' ' .. nickname .. ' ',
                                                description = ({
                                                    "Никнейм игрока за которым вы следите",
                                                    "Никнейм игрока за которым у вас закреплен GReport"
                                                })[itemIndex]
                                            })
                                        }
                                    }

                                    if #argument > 0 {
                                        for id = 0, $SERVER_MAX_PLAYERS {
                                            if id != user::getId() && sampIsPlayerConnected(id) {
                                                local nickname = sampGetPlayerNickname(id)
                                                if string.find(common::toLowerCase(nickname), common::toLowerCase(argument), 1, true) {
                                                    table.insert(suggestedList, {
                                                        suggested   = textBeforeArgument .. ' ' .. nickname .. ' ',
                                                        description = "Предложенный никнейм игрока"
                                                    })
                                                }
                                            }
                                        }
                                    }
                                }

                                COMMAND_ARGUMENT_HEALTH => {
                                    for _, health in ({ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }) {
                                        if string.find(tostring(health), argument, 1, true) {
                                            table.insert(suggestedList, {
                                                suggested   = textBeforeArgument .. ' ' .. health .. ' ',
                                                description = "Предложенный уровень здоровья"
                                            })
                                        }
                                    }
                                }

                                COMMAND_ARGUMENT_REASON => {
                                    for _, commandList in ({
                                        { "iban", "ban", "warn", "jail", {
                                            "Cheat",
                                            "DM",
                                            "NonRP drive",
                                            "Неролевое поведение"
                                        }},

                                        { "mute", "bmute", {
                                            "Оффтоп"
                                        }},

                                        { "kick", {
                                            "AFK on ROAD",
                                            "AFK without ESC",
                                            "AFK public place",
                                        }}
                                    }) {
                                        for _, commandName in commandList {
                                            if type(commandName) == "string" && ('/' .. commandName) == command[1] {
                                                for _, reason in commandList[#commandList] {
                                                    if string.find(common::toLowerCase(reason), common::toLowerCase(argument), 1, true) {
                                                        table.insert(suggestedList, {
                                                            suggested   = textBeforeArgument .. ' ' .. reason .. ' ',
                                                            description = "Предложенное наказание"
                                                        })
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                COMMAND_ARGUMENT_VEHID if spectator.status => {
                                    for vehId with string.gmatch(spectator::getInformation().vehicle, "%d+") {
                                        if (#argument == 0) ? true : string.find(vehId, argument, 1, true) {
                                            table.insert(suggestedList, {
                                                suggested   = textBeforeArgument .. ' ' .. vehId .. ' ',
                                                description = "Предложенная машина игрока за которым вы следите"
                                            })
                                        }
                                    }
                                }

                                COMMAND_ARGUMENT_CVEHID => {
                                    local fn insertSuggestionByPlayerVehicle(handle, description) {
                                        if isCharInAnyCar(handle) {
                                            if local car = storeCarCharIsInNoSave(handle) {
                                                local result, vehId = sampGetVehicleIdByCarHandle(car)
                                                if result {
                                                    local carId     = getCarModel(car)
                                                    local carName   = vehicle::getName(carId)

                                                    table.insert(suggestedList, {
                                                        suggested   = textBeforeArgument .. ' ' .. vehId .. ' ',
                                                        description = carName .. " (" .. description .. ")"
                                                    })
                                                }
                                            }
                                        }
                                    }

                                    insertSuggestionByPlayerVehicle(PLAYER_PED, "машина в которой вы сидите")
                                   
                                    if spectator.status {
                                        local result, handle = spectator::getHandle()
                                        if result {
                                            insertSuggestionByPlayerVehicle(handle, "машина игрока за которым вы следите")
                                        }
                                    }

                                    local streamVehicles = {}

                                    for _, car in getAllVehicles() {
                                        local result, vehId = sampGetVehicleIdByCarHandle(car)
                                        if result {
                                            local carId     = getCarModel(car)
                                            local carName   = vehicle::getName(carId)
                                            local handle    = PLAYER_PED

                                            if spectator.status {
                                                local result, spectatorHandle = spectator::getHandle()
                                                if result {
                                                    handle = spectatorHandle
                                                }
                                            }
                                            
                                            local dAX, dAY, dAZ = getCharCoordinates(handle)
                                            local dBX, dBY, dBZ = getCarCoordinates(car)

                                            local distance = getDistanceBetweenCoords3d(dAX, dAY, dAZ, dBX, dBY, dBZ)

                                            if distance != 0.0 { //! Skip spectator vehicle, since it already inserted.
                                                table.insert(streamVehicles, {
                                                    suggested   = textBeforeArgument .. ' ' .. vehId .. ' ',
                                                    description = string.format("%s[X: %1.f] (машина рядом)", carName, distance),
                                                    distance    = distance
                                                })
                                            }
                                        }
                                    }

                                    algorithm::bubbleSortByKey(streamVehicles, "distance")

                                    for _, item in streamVehicles {
                                        table.insert(suggestedList, item)
                                    }
                                }
                            }
                        }

                        index += 1
                    }
                }
            } elseif string.find("/" .. command[1], inputText, 1, true) {
                table.insert(suggestedList, {
                    suggested   = command[1] .. ' ',
                    description = command[2]
                })
            }
        }
        return suggestedList
    })()

    self.style = StyleChanger::new({
        WindowBorderSize    = 0,
        WindowPadding       = imgui.ImVec2(0, 0),
        WindowBg            = imgui.ImVec4(0, 0, 0, 0),
        ScrollbarSize       = 5
        ScrollbarBg         = imgui.ImVec4(0, 0, 0, 0)
    })

    autoCompletion.commandsLength = #self.suggestedList
    if autoCompletion.commandsLength < autoCompletion.position {
        autoCompletion.position = 1
    }

    if #self.suggestedList > 0 {
        imgui.SetNextWindowPos(imgui.ImVec2(chatInputBox::getPosition()))
        imgui.SetNextWindowSizeConstraints(imgui.ImVec2(0, 0), imgui.ImVec2(math.huge, 300))

        self.style::apply()
        style::beginWindowStyleChangeable("imgui.windows.AutoCompletion")
        imgui.Begin("imgui.windows.AutoCompletion", nil, self.flags)
            for pos, complete in self.suggestedList {
                imgui.PushFont(bold10)
                    local _pos          = imgui.GetCursorPos()
                    local itemCursorPos = imgui.GetCursorPos()

                    if imgui.Selectable("##" .. complete.suggested .. complete.description, autoCompletion.position == pos)
                       || (autoCompletion.position == pos && isKeyJustPressed(VK_TAB))
                    {
                        sampSetChatInputText(complete.suggested)
                        autoCompletion.position = pos
                    }
                    
                    imgui.SetCursorPos(_pos)
                    imgui.BeginGroup()
                        imgui.PushFont(bold10)
                            imguiAssets::addStrokedText(complete.suggested, config.root.windows.autoCompletion.strokeSize)
                            imgui.SameLine(nil, (#string.match(complete.suggested, "(%s*)$") > 0) ? 2 : 5)
                            imgui.SetCursorPosY(imgui.GetCursorPos().y + 1.5)    
                            imgui.PushFont(regular10)
                                imguiAssets::addStrokedText(complete.description, config.root.windows.autoCompletion.strokeSize)
                            imgui.PopFont()
                        imgui.PopFont()
                    imgui.EndGroup()
                
                    if autoCompletion.position == pos && !(imgui.IsWindowHovered() || imgui.IsMouseDown(0)) {
                        if (itemCursorPos.y - imgui.GetScrollY()) >= imgui.GetWindowHeight() {
                            imgui.SetScrollY(itemCursorPos.y)
                        } elseif itemCursorPos.y <= imgui.GetScrollY() {
                            imgui.SetScrollY(itemCursorPos.y)
                        }
                    }
                imgui.PopFont()
            }
        imgui.End()
        style::endWindowStyleChangeable("imgui.windows.AutoCompletion")
        self.style::reset()
    }
})
