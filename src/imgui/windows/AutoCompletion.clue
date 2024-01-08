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

if #config.root.windows.autoCompletion.commands == 0 {
    config.root.windows.autoCompletion.commands = {
        { name = "/inv", description = "Открыть инвентарь" }, { name = "/mn", description = "Открыть главное меню" }, 
        { name = "/phone", description = "Достать телефон" }, { name = "/sms", description = "Отправить sms" }, 
        { name = "/pass", description = "Показать документ удостоверяющий личность" }, { name = "/anim", description = "Список анимаций" }, 
        { name = "/stop", description = "Сбросить анимацию" }, { name = "/pay", description = "Передать деньги" }, 
        { name = "/update", description = "Посмотреть последние обновления" }, { name = "/gps", description = "Открыть навигатор" }, 
        { name = "/walk", description = "Автоматическая походка" }, { name = "/run", description = "Автоматический бег" }, 
        { name = "/rep", description = "Задать вопрос администраторам" }, { name = "/ask", description = "Задать вопрос саппортам" }, 
        { name = "/channel", description = "Настроить канал рации" }, { name = "/slot", description = "Настроить подканал рации" }, 
        { name = "/id", description = "Поиск игрока" }, { name = "/afk", description = "Узнать, находится ли игрок в AFK" }, 
        { name = "/pame", description = "Посмотреть описание игрока" }, { name = "/mypame", description = "Управление описанием персонажа" }, 
        { name = "/dmypame", description = "Удалить описание персонажа" }, { name = "/action", description = "Установить/Убрать действие своего персонажа" }, 
        { name = "/time", description = "Информация о времени и дате" }, { name = "/clearchat", description = "Очистить чат" }, 
        { name = "/headmove", description = "Отключить поворот головы" }, { name = "/blind", description = "Активировать черный экран (для создания СС)" }, 
        { name = "/pattach", description = "Аттачи для премиум игроков" }, { name = "/dm", description = "Посмотреть урон персонажа" }, 
        { name = "/graffiti", description = "Нарисовать граффити" }, { name = "/charity", description = "Слить деньги" }, 
        { name = "/dice", description = "Бросить игральную кость" }, { name = "/coin", description = "Подкинуть монету" }, 
        { name = "/music", description = "Слушать музыку" }, { name = "/fish", description = "Ловить рыбу" }, 
        { name = "/charact", description = "Характеристики персонажа" }, { name = "/color", description = "Установить цвет клиста" }, 
        { name = "/help", description = "Открыть помощь по игре" }, { name = "/jleave", description = "Уволиться с работы" }, 
        { name = "/bag", description = "Надеть/снять мешок с головы игрока" }, { name = "/tie", description = "Связать/развязать игрока" }, 
        { name = "/notice", description = "Список уведомлений для персонажа" }, { name = "/b", description = "ООС чат" }, 
        { name = "/s", description = "Кричать" }, { name = "/w", description = "Шептать" }, 
        { name = "/r", description = "Рация" }, { name = "/d", description = "Чат департамента" }, 
        { name = "/m", description = "Мегафон" }, { name = "/mic", description = "Говорить в микрофон" }, 
        { name = "/me", description = "Действия от первого лица" }, { name = "/do", description = "Действия от третьего лица" }, 
        { name = "/n", description = "Писать в радио во время эфира" }, { name = "/try", description = "Попытка действия \"Удачно\" / \"Неудачно\"" }, 
        { name = "/todo", description = "добавляет к сказанным словам деепричастный оборот" }, { name = "/ame", description = "Действие от первого лица над головой" }, 
        { name = "/pame", description = "Описание персонажа от первого лица над головой" }, { name = "/pm", description = "Написать приватное ООС сообщение другому игроку" }, 
        { name = "/r", description = "Говорить в канал и все принадлежащие ему слоты" }, { name = "/rj", description = "Говорить в рабочую рацию ( рация для работ )" }, 
        { name = "/rr", description = "Говорить в определенный слот канала, в котором Вы находитесь" }, { name = "/rl", description = "Тихо говорить в канал и все принадлежащие ему слоты" }, 
        { name = "/rrl", description = "Тихо говорить в определенный слот канала, в котором вы находитесь" }, { name = "/slot", description = "Изменить подканал в своей рации" }, 
        { name = "/channel", description = "Изменить канал своей рации" }, { name = "/hpanel", description = "Панель управления домом" }, 
        { name = "/hevict", description = "Выселится из дома" }, { name = "/sdoor", description = "Постучать в дверь" }, 
        { name = "/tdoor", description = "Крикнуть в дверь" }, { name = "/bpanel", description = "Панель управления бизнесом" }, 
        { name = "/market", description = "Загрузить/Поставить прилавок" }, { name = "/sale", description = "Продать товар за лавкой" }, 
        { name = "/buy", description = "Закупить товар в лавку" }, { name = "/tk", description = "Активировать тревожную кнопку в бизнесе" }, 
        { name = "/dj", description = "Управление музыкой в бизнесе" }, { name = "/bm", description = "Говорить в микрофон бизнеса" }, 
        { name = "/makebm", description = "Выдать временный микрофон" }, { name = "/bskin", description = "Выдать временный скин" }, 
        { name = "/bmenu", description = "Посмотреть товары на продаже" }, { name = "/mycars", description = "Список Т/С игрока" }, 
        { name = "/cpanel", description = "Меню управления Т/С" }, { name = "/caract", description = "Описание Т/С" }, 
        { name = "/climit", description = "Управление ограничителем скорости транспорта" }, { name = "/cload", description = "Загрузить Т/С в багажник" }, 
        { name = "/park", description = "Припарковать Т/С" }, { name = "/fixcar", description = "Вернуть Т/С на место парковки" }, 
        { name = "/cspeed", description = "Управление спидометром" }, { name = "/csignal", description = "Поставить Т/С на сигнализацию" }, 
        { name = "/ceng", description = "Завести автомобиль" }, { name = "/clock", description = "Открыть/Закрыть Т/С" }, 
        { name = "/chood", description = "Открыть/Закрыть капот Т/С" }, { name = "/ctrunk", description = "Открыть/Закрыть багажник Т/С" }, 
        { name = "/cwindow", description = "Управление окнами Т/С" }, { name = "/roof", description = "Поднять/Опустить крышу Т/С" }, 
        { name = "/ctrailer", description = "Прицепить/Отцепить дом на колесах" }, { name = "/cbreak", description = "Взломать Т/С" }, 
        { name = "/eject", description = "Выбросить игрока из машины" }, { name = "/fill", description = "Заправить Т/С" }, 
        { name = "/aspawn", description = "респавнит игрока" }, { name = "/goto", description = "телепорт к игроку" }, 
        { name = "/gethere", description = "телепорт игрока к себе" }, { name = "/sp", description = "войти в наблюдение" }, 
        { name = "/unfreeze", description = "разморозить игрокa" }, { name = "/mute", description = "выдать блокировку чата" }, 
        { name = "/unmute", description = "снять блокировку чата" }, { name = "/stats", description = "статистика игрока" }, 
        { name = "/h", description = "чат операторов поддержки" }, { name = "/kick", description = "кикнуть игрока" }, 
        { name = "/a", description = "админ-чат" }, { name = "/ans", description = "ответ в репорт" }, 
        { name = "/tp", description = "список телепортов" }, { name = "/adm", description = "панель администратора" }, 
        { name = "/hp", description = "пополнить здоровье на 255 единиц" }, { name = "/adaction", description = "удалить действие" }, 
        { name = "/unjail", description = "выпустить игрока из деморгана" }, { name = "/jail", description = "отправить игрока в деморган" }, 
        { name = "/afrisk", description = "обыскать игрока" }, { name = "/aheal", description = "поднять игрока с земли" }, 
        { name = "/slap", description = "подбросить игрока вверх" }, { name = "/dpame", description = "удалить описание" }, 
        { name = "/weapons", description = "оружие у игрока" }, { name = "/sameip", description = "одинаковые ip адреса в игре" }, 
        { name = "/fbb", description = "ближайшие бумбоксы" }, { name = "/dfire", description = "удалить костёр рядом" }, 
        { name = "/alogin", description = "Авторизоваться как администратор" }, { name = "/pk", description = "Выдать PK игроку" }
    }
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
        local commands = {}
        for _, command in config.root.windows.autoCompletion.commands {
            if string.find("/" .. command.name, sampGetChatInputText(), 1, true) {
                table.insert(commands, command)
            }
        }
        return commands
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
                local text = string.format("%s - %s", command.name, command.description)
                local _pos = imgui.GetCursorPos()

                imguiAssets::addStrokedText(text, config.root.windows.autoCompletion.strokeSize)
                imgui.SetCursorPos(_pos)

                if imgui.Selectable(text, autoCompletion.position == pos)
                   || (autoCompletion.position == pos && isKeyJustPressed(VK_TAB))
                {
                    sampSetChatInputText(command.name)
                    autoCompletion.position = pos
                }
            }
        imgui.End()
        style::endWindowStyleChangeable("imgui.windows.AutoCompletion")
        self.style::reset()
    }
})
