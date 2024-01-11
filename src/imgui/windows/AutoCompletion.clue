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

@import "game.samp.ChatInputBox" => chatInputBox

@import "Config" => config

local commands = {
    { "/inv", "Открыть инвентарь" }, { "/mn", "Открыть главное меню" }, 
    { "/phone", "Достать телефон" }, { "/sms", "Отправить sms" }, 
    { "/pass", "Показать документ удостоверяющий личность" }, { "/anim", "Список анимаций" }, 
    { "/stop", "Сбросить анимацию" }, { "/pay", "Передать деньги" }, 
    { "/update", "Посмотреть последние обновления" }, { "/gps", "Открыть навигатор" }, 
    { "/walk", "Автоматическая походка" }, { "/run", "Автоматический бег" }, 
    { "/rep", "Задать вопрос администраторам" }, { "/ask", "Задать вопрос саппортам" }, 
    { "/channel", "Настроить канал рации" }, { "/slot", "Настроить подканал рации" }, 
    { "/id", "Поиск игрока" }, { "/afk", "Узнать, находится ли игрок в AFK" }, 
    { "/pame", "Посмотреть описание игрока" }, { "/mypame", "Управление описанием персонажа" }, 
    { "/dmypame", "Удалить описание персонажа" }, { "/action", "Установить/Убрать действие своего персонажа" }, 
    { "/time", "Информация о времени и дате" }, { "/clearchat", "Очистить чат" }, 
    { "/headmove", "Отключить поворот головы" }, { "/blind", "Активировать черный экран (для создания СС)" }, 
    { "/pattach", "Аттачи для премиум игроков" }, { "/dm", "Посмотреть урон персонажа" }, 
    { "/graffiti", "Нарисовать граффити" }, { "/charity", "Слить деньги" }, 
    { "/dice", "Бросить игральную кость" }, { "/coin", "Подкинуть монету" }, 
    { "/music", "Слушать музыку" }, { "/fish", "Ловить рыбу" }, 
    { "/charact", "Характеристики персонажа" }, { "/color", "Установить цвет клиста" }, 
    { "/help", "Открыть помощь по игре" }, { "/jleave", "Уволиться с работы" }, 
    { "/bag", "Надеть/снять мешок с головы игрока" }, { "/tie", "Связать/развязать игрока" }, 
    { "/notice", "Список уведомлений для персонажа" }, { "/b", "ООС чат" }, 
    { "/s", "Кричать" }, { "/w", "Шептать" }, 
    { "/r", "Рация" }, { "/d", "Чат департамента" }, 
    { "/m", "Мегафон" }, { "/mic", "Говорить в микрофон" }, 
    { "/me", "Действия от первого лица" }, { "/do", "Действия от третьего лица" }, 
    { "/n", "Писать в радио во время эфира" }, { "/try", "Попытка действия \"Удачно\" / \"Неудачно\"" }, 
    { "/todo", "добавляет к сказанным словам деепричастный оборот" }, { "/ame", "Действие от первого лица над головой" }, 
    { "/pame", "Описание персонажа от первого лица над головой" }, { "/pm", "Написать приватное ООС сообщение другому игроку" }, 
    { "/r", "Говорить в канал и все принадлежащие ему слоты" }, { "/rj", "Говорить в рабочую рацию ( рация для работ )" }, 
    { "/rr", "Говорить в определенный слот канала, в котором Вы находитесь" }, { "/rl", "Тихо говорить в канал и все принадлежащие ему слоты" }, 
    { "/rrl", "Тихо говорить в определенный слот канала, в котором вы находитесь" }, { "/slot", "Изменить подканал в своей рации" }, 
    { "/channel", "Изменить канал своей рации" }, { "/hpanel", "Панель управления домом" }, 
    { "/hevict", "Выселится из дома" }, { "/sdoor", "Постучать в дверь" }, 
    { "/tdoor", "Крикнуть в дверь" }, { "/bpanel", "Панель управления бизнесом" }, 
    { "/market", "Загрузить/Поставить прилавок" }, { "/sale", "Продать товар за лавкой" }, 
    { "/buy", "Закупить товар в лавку" }, { "/tk", "Активировать тревожную кнопку в бизнесе" }, 
    { "/dj", "Управление музыкой в бизнесе" }, { "/bm", "Говорить в микрофон бизнеса" }, 
    { "/makebm", "Выдать временный микрофон" }, { "/bskin", "Выдать временный скин" }, 
    { "/bmenu", "Посмотреть товары на продаже" }, { "/mycars", "Список Т/С игрока" }, 
    { "/cpanel", "Меню управления Т/С" }, { "/caract", "Описание Т/С" }, 
    { "/climit", "Управление ограничителем скорости транспорта" }, { "/cload", "Загрузить Т/С в багажник" }, 
    { "/park", "Припарковать Т/С" }, { "/fixcar", "Вернуть Т/С на место парковки" }, 
    { "/cspeed", "Управление спидометром" }, { "/csignal", "Поставить Т/С на сигнализацию" }, 
    { "/ceng", "Завести автомобиль" }, { "/clock", "Открыть/Закрыть Т/С" }, 
    { "/chood", "Открыть/Закрыть капот Т/С" }, { "/ctrunk", "Открыть/Закрыть багажник Т/С" }, 
    { "/cwindow", "Управление окнами Т/С" }, { "/roof", "Поднять/Опустить крышу Т/С" }, 
    { "/ctrailer", "Прицепить/Отцепить дом на колесах" }, { "/cbreak", "Взломать Т/С" }, 
    { "/eject", "Выбросить игрока из машины" }, { "/fill", "Заправить Т/С" }, 
    { "/iban", "Перманентная (бессрочная) блокировка игрока" }, { "/banip", "Блокировать IP-адрес игрока" },
    { "/veh", "Создать админ-транспорт" }, { "/dveh", "Удалить админ-транспорт" },
    { "/dvehid", "Удалить админ-транспорт по ID" }, { "/dvehall", "Удалить весь созданный админ-транспорт" },
    { "/aengine", "Изменить статус двигателя в машине" }, { "/alock", "Изменить статус блокировки дверей в машине"},
    { "/settime", "Сменить время на сервере" }, { "/makeleader", "Выдать лидерство игроку" },
    { "/bizinfo", "Информация о бизнесе" }, { "/setprod", "Установить кол-во продуктов в бизнесе" },
    { "/unretest", "Снять ретест с аккаунта игрока" }, { "/unwarn", "Снять предупреждение с игрока" },
    { "/unban", "Снять блокировку с игрока" }, { "/unbanip", "Разблокировать IP-адрес" },
    { "/adm", "Панель администратора" }, { "/a", "Чат администрации" },
    { "/aspawn", "Заспавнить игрока" }, { "/tp", "Телепортация по местам" },
    { "/goto", "Телепортироваться к игроку" }, { "/gethere", "Телепортировать игрока к себе" },
    { "/ptop", "Телепортировать игрока к другому игроку" }, { "/sp", "Зайти в слежку за игроком" },
    { "/ans", "Ответить игроку" }, { "/aa", "OOC чат от лица администратора" },
    { "/aafk", "Игроки в афк" }, { "/stats", "Статистика игрока" }, 
    { "/afrisk", "Список предметов у игрока" }, { "/unfreeze", "Разморозить игрока" },
    { "/weapons", "Список оружия у игрока" }, { "/aheal", "Пополняет HP-уровень игрока до 100 единиц" },
    { "/hp", "Пополнить свое здоровье до полного" }, { "/sethp", "Установить HP-уровень игроку" },
    { "/setworld", "Установить игроку виртуальный мир" }, { "/setint", "Установить игроку интерьер мира" },
    { "/getcar", "Телепортировать к себе транспорт" }, { "/vrepair", "Восстановить HP-уровень транспорта до максимума" },
    { "/getbuycar", "Телепортировать к себе личный транспорт" }, { "/vspawn", "Заспавнить автомобиль" },
    { "/adaction", "Удалить /action" }, { "/dbuy", "Удалить GBUY обьявление" }, 
    { "/dpame", "Удалить описание игрока" }, { "/gfmenu", "Панель управления граффити" },
    { "/gfids", "Список граффти в радиусе 100 метров" }, { "/gfdell", "Удалить граффити по ID" },
    { "/mute", "Заблокировать IC-чат игрока" }, { "/bmute", "Заблокировать OOC-чат игрока" },
    { "/unbmute", "Разблокировать OOC-чат игрока" }, { "/unmute", "Разблокировать IC-чат игрока" },
    { "/kick", "Отсоединить игрока от сервера" }, { "/jail", "Посадить игрока в ДеМорган" },
    { "/unjail", "Вытащить игрока из ДеМоргана" }, { "/warn", "Выдать игроку игровое предупреждение" },
    { "/makemic", "Выдать игроку системный микрофон" }, { "/leave", "Уволить игрока из фракции" },
    { "/house", "Телепортироваться к дому по номеру" }, { "/biz", "Телепортироваться к бизнесу по номеру" },
    { "/vfuel", "Установить уровень топлива транспорту" }, { "/vspawnr", "Заспавнить весь транспорт в радиусе" },
    { "/adm_vehid", "Посмотреть принадлежность транспорта игроку" }, { "/ck", "Выдать Character Kill игроку" },
    { "/unck", "Снять Character Kill игроку" }, { "/pk", "Выдать Player Kill игроку" },
    { "/ban", "Заблокировать аккаунт игрока" }
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

    self.foundCommands = (fn {
        local commandList = {}
        for _, command in commands {
            if string.find("/" .. command[1], sampGetChatInputText(), 1, true) {
                table.insert(commandList, command)
            }
        }
        return commandList
    })()

    self.style = StyleChanger::new({
        WindowBorderSize    = 0,
        WindowPadding       = imgui.ImVec2(0, 0),
        WindowBg            = imgui.ImVec4(0, 0, 0, 0)
    })

    autoCompletion.commandsLength = #self.foundCommands
    if autoCompletion.commandsLength < autoCompletion.position {
        autoCompletion.position = 1
    }

    if #self.foundCommands > 0 {
        imgui.SetNextWindowPos(imgui.ImVec2(chatInputBox::getPosition()))
        imgui.SetNextWindowSizeConstraints(imgui.ImVec2(0, 0), imgui.ImVec2(math.huge, math.huge))

        self.style::apply()
        style::beginWindowStyleChangeable("imgui.windows.AutoCompletion")
        imgui.Begin("imgui.windows.AutoCompletion", nil, self.flags)
            for pos, command in self.foundCommands {
                local text = string.format("%s - %s", command[1], command[2])
                local _pos = imgui.GetCursorPos()

                imguiAssets::addStrokedText(text, config.root.windows.autoCompletion.strokeSize)
                imgui.SetCursorPos(_pos)

                if imgui.Selectable(text, autoCompletion.position == pos)
                   || (autoCompletion.position == pos && isKeyJustPressed(VK_TAB))
                {
                    sampSetChatInputText(command[1])
                    autoCompletion.position = pos
                }
            }
        imgui.End()
        style::endWindowStyleChangeable("imgui.windows.AutoCompletion")
        self.style::reset()
    }
})
