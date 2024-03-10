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

@import "imgui.HotKey" => HotKey

@import "Notifications" => notify
@import "Icons"         => icons
@import "Config"        => config

/**
 * This macro is needs to configure `inputCopyButtons` by user. Used in `imgui.windows.Main` window, in settings section.
 */
@macro GREPORT_MAKE_CUSTOM_ELEMENT() { fn {
    global UI_GREPORT_CUSTOM_ELEMENT = UI_GREPORT_CUSTOM_ELEMENT || {
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[1][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[1][2]) },
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[2][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[2][2]) },
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[3][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[3][2]) },
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[4][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[4][2]) },
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[5][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[5][2]) },
        { imgui.new.char[144](config.root.windows.greport.inputCopyButtons[6][1]), imgui.new.char[255](config.root.windows.greport.inputCopyButtons[6][2]) },
    }

    imgui.SetCursorPosY(imgui.GetCursorPos().y + 2.5)
    imguiAssets::textWithFont("Заголовок", regular9)
    imgui.SameLine(imgui.GetWindowWidth() / 2)
    imguiAssets::textWithFont("Текст что вставится", regular9)
    
    for index = 1, 6 {
        local buffer = UI_GREPORT_CUSTOM_ELEMENT[index]
        imgui.SetNextItemWidth(imgui.GetWindowWidth() / 2 - 5)
        
        if imgui.InputText("##imgui.windows.GReport.titleIndex" .. index, buffer[1], ffi.sizeof(buffer[1])) {
            config.root.windows.greport.inputCopyButtons[index][1] = ffi.string(buffer[1])
        }
        
        imgui.SameLine()
        imgui.SetNextItemWidth(imgui.GetWindowWidth() / 2 - 10)
        
        if imgui.InputText("##imgui.windows.GReport.replaceIndex" .. index, buffer[2], ffi.sizeof(buffer[2])) {
            config.root.windows.greport.inputCopyButtons[index][2] = ffi.string(buffer[2])
        }
    }
}}

static __greport__ = {
    hotKey = nil,

    window = {
        state                   = false,
        recentlyOpened          = false, //! Only `true` for 0.2 seconds when `closeAndOpenAnimation.alpha == 0`.
        noInputClock            = nil,
        answerInput             = nil,
        closeAndOpenAnimation   = {
            alpha = 0,
            clock = nil
        }
    },

    dialog = {
        id          = -1,
        state       = false,
        awaiting    = {
            options = { false, nil },
            input   = { false, "value" },
            special = { false, nil }
        }
    }

    player = {
        receivedAt  = nil,
        clock       = nil,
        time        = nil,
        active      = false,
        nickname    = "",
        id          = -1,
        context     = ""
    }
}

__greport__.hotKey ??= HotKey::new("imgui.window.GReport", { 0xA2, 0x31 }, "Открыть/закрыть /greport")::registerCallback(fn {
    if local this = __greport__ {
        if #this.player.context > 0 || (this.player.receivedAt && (os.clock() - this.player.receivedAt <= 15)) {
            this.window::switch()
        }
    }
})

static enum /* GREPORT_OPTION */ {
    GREPORT_OPTION_SPECTATE = 0,
    GREPORT_OPTION_ANSWER,
    GREPORT_OPTION_REMOVE,
    GREPORT_OPTION_BLOCK,
    GREPORT_OPTION_TO_ADMINISTRATION,
    GREPORT_OPTION_SET_MAP_POINT
}

/**
 * Setup GReport main loop. Only for use in while-true loop!
 * @return void
 */
method __greport__::loop() {
    if self.player.clock && config.root.windows.greport.reminderNotification && !self.window.state && self.active {
        if os.clock() - self.player.clock >= config.root.windows.greport.remindSeconds {
            self.player.clock = os.clock()
            notify::send({
                title       = "Напоминание про /greport",
                text        = "Прошло " .. config.root.windows.greport.remindSeconds .. " с момента последнего открытия /greport.",
                duration    = 10,
                condition   = fn { return self.window.state },
                buttons     = {
                    first = {
                        name = "Открыть",
                        call = fn { self.window::switch() }
                    },

                    second = {
                        name = "Закрыть",
                        call = fn(close) { close() }
                    }
                }
            })
        }
    }
}

/**
 * Open window and dialog if `withDialog` parameter is equals to `true`.
 * 
 * @param withDialog boolean (default = true)
 * @return void
 */
method __greport__.window::open(withDialog = true) {
    if !self.state {
        self.closeAndOpenAnimation.alpha = 0
        self.state = true
        
        if local this = __greport__ {
            if !this.dialog.state && withDialog {
                this.dialog::call()
            }
        }
    } 
}

/**
 * Close window and dialog if `withDialog` parameter is equals to `true`.
 * 
 * @param withDialog boolean (default = true)
 * @return void
 */
method __greport__.window::close(withDialog = true) {
    if self.state {
        self.closeAndOpenAnimation.clock = os.clock()
        if withDialog {
            __greport__.player::closeDialogIfPresent()
        }
    }
}

/**
 * Open or close window by `self.state` status.
 *
 * @param withDialog boolean (default = true)
 * @return void
 */
method __greport__.window::switch(withDialog = true) {
    if self.state {
        self::close(withDialog)
    } else {
        self::open(withDialog)
    }
}

/**
 * Sends in chat `"/greport"`. Opens GReport dialog.
 * @return void
 */
method __greport__.dialog::call() {
    sampSendChat("/greport")
}

/**
 * Call option at GReport dialog.
 * @param listItemIndex GREPORT_OPTION
 * @return void
 */
method __greport__.dialog::callOptionAt(listItemIndex) {
    sampSendDialogResponse(32500, 0, 0, "")
    self.awaiting.options = { true, listItemIndex }
}

/**
 * Set in next input value that passed in this function.
 * @param value string
 * @return void
 */
method __greport__.dialog::setInputValue(value) {
    self.awaiting.input = { true, value }
}

/**
 * Get active time from time where self.active was set to true.
 * @return string Time as MM:SS.
 */
method __greport__.player::getActiveTime() {
    if self.time {
        local time      = os.date("*t")
        local minutes   = math.floor((time.min - self.time.min + 60) % 60)
        local seconds   = math.floor((time.sec - self.time.sec) % 60)
        return string.format("%02d:%02d", minutes, seconds)
    } else {
        return "00:00"
    }
}

/**
 * Spectate for player that created report.
 * @return void
 */
method __greport__.player::spectate() {
    if local this = __greport__ {
        sampSendChat("/sp " .. self.id)
        this.dialog.state = false
        this.window::close(true)
    }
}

/**
 * Remove this report with reason.
 * @param reason string
 */
method __greport__.player::remove(reason) {
    if local this = __greport__ {
        this.dialog::callOptionAt(GREPORT_OPTION_REMOVE)
        this.dialog::setInputValue(reason)
        this.dialog.state = false
        this.window::close(false)
        self::reset()
    }
}

/**
 * Allow player to set map point for report's sender.
 * @return void
 */
method __greport__.player::setMapPoint() {
    if local this = __greport__ {
        this.dialog::callOptionAt(GREPORT_OPTION_SET_MAP_POINT)
        this.dialog.state = false
        this.window::close()

        notify::send({
            title       = "Установите метку на карте",
            text        = "Зайдите в меню паузы, и на карте поставьте метку игроку.",
            icon        = icons.ICON_STAR,
            duration    = 5
        })
    }
}

/**
 * Block report for it's sender.
 *
 * @param time number   10 | 30 | 60 | 90
 * @param reason string Report block reason.
 * @return void
 */
method __greport__.player::blockReport(time, reason) {
    local allowed = {
        [10] = 0,
        [30] = 1,
        [60] = 2,
        [90] = 3
    } 

    if local listItem = allowed[time] {
        if local this = __greport__ {
            this.dialog::callOptionAt(GREPORT_OPTION_BLOCK)
            this.dialog.awaiting.special = { true, listItem }
            this.dialog::setInputValue(reason)
            this.dialog.state = false
            this.window::close(false)
            self::reset()
        }
    }
}

/**
 * Answer for report.
 *
 * @param answer string
 * @return void
 */
method __greport__.player::answer(answer) {
    if local this = __greport__ {
        this.dialog::callOptionAt(GREPORT_OPTION_ANSWER)
        this.dialog::setInputValue(answer)
        this.dialog.state = false
        this.window::close(false)
        self::reset()
    }
}

/**
 * Close dialog if it's active.
 * @return void
 */
method __greport__.player::closeDialogIfPresent() {
    if __greport__.dialog.state {
        sampSendDialogResponse(32500, 1, nil, nil)
    }
}

/**
 * Move report to the administration.
 * @return void
 */
method __greport__.player::moveReportToAdministration() {
    if local this = __greport__ {
        this.dialog::callOptionAt(GREPORT_OPTION_TO_ADMINISTRATION)
        this.dialog.state = false
        this.window::close(false)
        self::reset()
    }
}

/**
 * Reset all values that gathered in this report.
 * @return void
 */
method __greport__.player::reset() {
    self.receivedAt = nil
    self.time       = nil
    self.clock      = nil
    self.active     = false
    self.nickname   = ""
    self.id         = -1
    self.context    = ""
}

/**
 * Setup chat watcher. **Only for use in `onServerMessage` event!**
 * 
 * @param text string
 * @return void
 */
method __greport__::setupChatWatcher(text) {
    if !config.root.windows.greport.use { return }
   
    if local nickname, id = string.match(text, "^%| На вас был назначен репорт от игрока (.+)%[(%d+)]%.") {
        self.player.nickname    = nickname
        self.player.receivedAt  = os.clock() 
        self.player.id          = tonumber(id)

        if config.root.windows.greport.preferNotifications {
            notify::send({
                title       = "Пришел репорт от " .. string.gsub(nickname, "_", " "),
                text        = "У вас есть 15 секунд принять. Введите /grep(ort) или нажмите на " .. tostring(self.hotKey),
                icon        = icons.ICON_PERSON
                duration    = 15,
                condition   = fn { return self.window.state }
            })
        }

        if config.root.windows.greport.soundNotification {
            addOneOffSound(0, 0, 0, 1137)
        }
    }

    if string.find(text, "^%| Обработка репорта завершена%.") && self.player.active {
        self.window::close()

        if !self.window.state {
            self::reset()
        }

        if config.root.windows.greport.preferNotifications {
            notify::send({
                title       = "Обработка репорта завершена",
                text        = "Игрок был отсоединен от сервера.",
                icon        = icons.ICON_DENY,
                duration    = 3
            })
        }
    }
}

return __greport__
