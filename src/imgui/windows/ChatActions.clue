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

@import "game.samp.Chat"    => chat
@import "game.samp.Fonts"   => fonts
@import "game.Admins"       => admins
@import "game.samp.Player"  => player
@import "game.User"         => user
@import "imgui.Assets"      => imguiAssets
@import "imgui.Animations"  => animations
@import "Common"            => common
@import "Config"            => config

local enum /** @enum CHAT_ACTION_TYPE */ {
    CHAT_ACTION_TYPE_ADMIN,
    CHAT_ACTION_TYPE_PLAYER,
    CHAT_ACTION_TYPE_LINE
}

local window = {
    selected = {
        type = 0,
        params = {}
    }
}

local fn trimDots(str) {
    return string.gsub(str, "^%.+%s", "")::gsub("%s%.+$", "")
}

local fn hasStartDots(str) {
    local matched = string.match(str, "^(%.+)%s")
    return matched && (#matched == 2 || #matched == 3)
}

local fn hasEndDots(str) {
    local matched = string.match(str, "%s(%.+)$")
    return matched && (#matched == 2 || #matched == 3)
}

local fn joinSampChatStrings(text, index) {
    local result = trimDots(text)
    local i      = index - 1

    while i >= 0 {
        local previousText = sampGetChatString(i)::gsub("{......}", "")
        if hasEndDots(previousText) {
            result = trimDots(previousText) .. ' ' .. result
            i -= 1
        } else { break }
    }

    local i = index + 1

    while i < 100 {
        local nextText = sampGetChatString(i)::gsub("{......}", "")
        if hasStartDots(nextText) {
            result ..= ' ' .. trimDots(nextText)
            i += 1
        } else { break }
    }

    return result
}

imgui.OnFrame(fn { return isSampAvailable() && fonts::isAvailable() && config.root.windows.chatActions.use }, fn (self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.id         = "imgui.windows.ChatActions"
    
    local from = chat.scrollbar::getCurrentPosition()
    local to   = from + chat.scrollbar::getPagesize()

    local startX, startY = chat::getPosition()

    for index = from, to - 1 {
        local text, _, color = sampGetChatString(index)
              text = string.gsub($, "{......}", "")

        if #text == 0 {
            startY += chat::getStringHeight() + 1
            continue
        }

        local textWidth        = fonts::measureText(text)
        local cursorX, cursorY = getCursorPos()
        local vectorStart      = imgui.ImVec2(startX + ((chat::isTimestampEnabled()) ? chat::getTimestampWidth() + 5 : 0), startY)
        local vectorEnd        = imgui.ImVec2(vectorStart.x + textWidth, startY + chat::getStringHeight())

        startY += chat::getStringHeight() + 1
        
        if cursorX >= vectorStart.x && cursorX <= vectorEnd.x && cursorY >= vectorStart.y && cursorY <= vectorEnd.y && !imgui.IsPopupOpen(self.id) {
            local a, r, g, b = (color >> 24) & 0xFF, (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF
            local color      = (a << 24) | (b << 16) | (g << 8) | r
            local drawList   = imgui.GetBackgroundDrawList()

            drawList::AddCircleFilled(imgui.ImVec2(startX - 7, startY - 10), 5, 0xFF000000, 16)
            drawList::AddCircleFilled(imgui.ImVec2(startX - 7, startY - 10), 4, color, 16)

            if imgui.IsMouseReleased(1) {
                window.selected = { type = CHAT_ACTION_TYPE_LINE, params = { u8(text), u8(joinSampChatStrings(text, index)) } }
                imgui.OpenPopup(self.id)
                break
            }

            local found = {} //! [{
                             //!    type: CHAT_ACTION_TYPE,
                             //!    params: [ any... ],
                             //!    sizes: { finish: number, width: number }
                             //! }...]

            for _, admin in admins {
                local start = 1

                loop {
                    local s, e = string.find(text, admin.nickname.ooc, start, true)

                    if !s { break }

                    table.insert(found, {
                        type = CHAT_ACTION_TYPE_ADMIN,
                        params = { admin },
                        sizes = {
                            finish = fonts::measureText(string.sub(text, 1, e)),
                            width = fonts::measureText(string.sub(text, s, e))
                        }
                    })

                    start = e + 1
                }
            }

            for id = 0, $SERVER_MAX_PLAYERS {
                if sampIsPlayerConnected(id) && id != user::getId() && !admins::getAdminById(id) {
                    local nickname = sampGetPlayerNickname(id)
                    local start    = 1

                    loop {
                        local s, e = string.find(text, nickname, start, true)

                        if !s {
                            local nickname = string.gsub($, '_', ' ')
                            s, e = string.find(text, nickname, start, true)
                            if !s {
                                break
                            }
                        }

                        table.insert(found, {
                            type = CHAT_ACTION_TYPE_PLAYER,
                            params = { nickname, id },
                            sizes = {
                                finish = fonts::measureText(string.sub(text, 1, e)),
                                width = fonts::measureText(string.sub(text, s, e))
                            }
                        })

                        start = e + 1
                    }
                }
            }

            for _, action in found {
                local start  = imgui.ImVec2(vectorStart.x + action.sizes.finish - action.sizes.width, vectorEnd.y)
                local finish = imgui.ImVec2(start.x + action.sizes.width, start.y)
                
                if cursorX >= start.x && cursorX <= finish.x {
                    drawList::AddLine(start, finish, -1, 3)
                    if imgui.IsMouseReleased(0) {
                        window.selected = { type = action.type, params = action.params }
                        imgui.OpenPopup(self.id)
                    }
                }
            }
        }
    }

    if imgui.BeginPopup(self.id) {
        local buttonSize = imgui.ImVec2(math.max(imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x * 2, 180), 25)
        match window.selected.type {
            CHAT_ACTION_TYPE_ADMIN => {
                if local admin = window.selected.params[1] {
                    imgui.PushFont(bold12)
                        imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(string.format("%s[%d] (LVL: %d)", admin.nickname.ooc, admin.id, admin.lvl)).x / 2)
                        imgui.Text(admin.nickname.ooc)
                        imguiAssets::setPreviousItemAbleToCopy(admin.nickname.ooc, "Никнейм администратора скопирован", admin.nickname.ooc)
                        imgui.SameLine(nil, 0)
                        imgui.Text('[' .. admin.id .. ']')
                        imguiAssets::setPreviousItemAbleToCopy(admin.id, "ID администратора скопирован")
                        imgui.SameLine(nil, 0)
                        imgui.Text(" (LVL: " .. admin.lvl .. ')')
                        imguiAssets::setPreviousItemAbleToCopy(admin.lvl, "Уровень администратора скопирован")
                    imgui.PopFont()
                    imgui.PushFont(regular12)
                        if animations::button("Упомянуть##" .. self.id, buttonSize) {
                            sampSetChatInputEnabled(true)
                            sampSetChatInputText("/a @" .. admin.nickname.ooc .. ' ')
                            imgui.CloseCurrentPopup()
                        }

                        if animations::button("Следить##" .. self.id, buttonSize) {
                            sampSendChat("/sp " .. admin.id)
                            imguiAssets::setCursorStatus(true)
                            imgui.CloseCurrentPopup()
                        }
                    imgui.PopFont()
                } else {
                    // pointer to the `admin` may be null since it can be modified in the another thread
                    imgui.CloseCurrentPopup()
                }
            }

            CHAT_ACTION_TYPE_PLAYER => {
                if !sampIsPlayerConnected(window.selected.params[2]) { imgui.CloseCurrentPopup() }

                local nickname = window.selected.params[1]
                local id       = window.selected.params[2]

                imgui.PushFont(bold12)
                    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(string.format("%s[%d]", nickname, id)).x / 2)
                    imgui.Text(nickname)
                    imguiAssets::setPreviousItemAbleToCopy(nickname, "Никнейм игрока скопирован", nickname)
                    imgui.SameLine(nil, 0)
                    imgui.Text('[' .. id .. ']')
                    imguiAssets::setPreviousItemAbleToCopy(nickname, "ID игрока скопирован")
                imgui.PopFont()
                imgui.PushFont(regular12)
                    for _, command in ({ "/sp", "/stats", "/pame" }) {
                        if animations::button(command .. "##" .. self.id, buttonSize) {
                            sampSendChat(command .. ' ' .. id)
                            imguiAssets::setCursorStatus(true)
                            imgui.CloseCurrentPopup()
                        }
                    }
                imgui.PopFont()
            }

            CHAT_ACTION_TYPE_LINE => {
                imgui.PushFont(regular12)
                    for index, label in ({ "Скопировать", "Скопировать без переносов" }) {
                        if animations::button(label .. "##" .. self.id, buttonSize) {
                            setClipboardText(window.selected.params[index])
                            imgui.CloseCurrentPopup()
                        }
                    }
                imgui.PopFont()
            }
        }
        imgui.EndPopup()
    }
})
