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

@import "imgui.Style"       => style
@import "imgui.Assets"      => imguiAssets
@import "imgui.Animations"  => animations

@import "game.GReport" => greport

@import "Config" => config
@import "Common" => common

style::registerWindow("imgui.windows.GReport", "Окно /greport")

local focusKeyboard = false

greport.window.answerInput ??=imgui.new.char[65535]()

addEventHandler("onWindowMessage", fn(event, wparam, lparam) {
    if (event == wm.WM_KEYDOWN || event == wm.WM_SYSKEYDOWN) && !imgui.GetIO().WantTextInput {
        if wparam == VK_ESCAPE && greport.window.state {
            greport.window::close()
            consumeWindowMessage(true, false)
            return
        }
    }
})

imgui.OnFrame(fn { return greport.window.state && !isGamePaused() && config.root.windows.greport.use }, fn(self) {
    self.flags = imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar

    local sizeX, sizeY = getScreenResolution()

    //! Close and open window animation.
    if greport.window.closeAndOpenAnimation.clock {
        if greport.window.recentlyOpened { //! Open animation.
            if os.clock() - greport.window.closeAndOpenAnimation.clock >= 0.2 {
                greport.window.recentlyOpened               = false
                greport.window.closeAndOpenAnimation.clock  = nil
                focusKeyboard                               = true
            } else {
                greport.window.closeAndOpenAnimation.alpha = imguiAssets::bringFloatTo($, 1, greport.window.closeAndOpenAnimation.clock, 0.2)
            }
        } else { //! Close animatiion.
            if os.clock() - greport.window.closeAndOpenAnimation.clock >= 0.2 {
                greport.window.state                        = false
                greport.window.closeAndOpenAnimation.clock  = nil

                imgui.StrCopy(greport.window.answerInput, "")
            } else {
                greport.window.closeAndOpenAnimation.alpha = imguiAssets::bringFloatTo($, 0, greport.window.closeAndOpenAnimation.clock, 0.2)
            }
        }
    }

    //! Handle `greport.window.recentlyOpened` variable. Need for open animation.
    if greport.window.closeAndOpenAnimation.alpha == 0 {
        greport.window.recentlyOpened               = true
        greport.window.closeAndOpenAnimation.clock  = os.clock()
    }

    imgui.SetNextWindowSize(imgui.ImVec2(600, 300))
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, greport.window.closeAndOpenAnimation.alpha)
    style::beginWindowStyleChangeable("imgui.windows.GReport")
    imgui.Begin("imgui.windows.GReport", nil, self.flags)
        local itemFullWidth = imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x * 2 
        
        imgui.SetCursorPosY(imgui.GetStyle().WindowPadding.y + imgui.GetStyle().ChildBorderSize)
        imgui.BeginChild("imgui.windows.GReport.header", imgui.ImVec2(0, 100), true, self.flags)
            imguiAssets::textWithFont(string.gsub(greport.player.nickname, "_", " ") .. "[" .. greport.player.id .. "]", bold14)
            imgui.SameLine(imgui.GetWindowWidth() - imgui.CalcTextSize("00:00").x * 1.2)
            imguiAssets::textWithFont(greport.player::getActiveTime(), bold10)
            imgui.PushTextWrapPos(imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x * 2)
            imguiAssets::textWithFont(greport.player.context, regular12)
        imgui.EndChild()
        imgui.BeginGroup()
            imgui.PushFont(regular12)
                imgui.BeginGroup()
                    imgui.SetNextItemWidth(itemFullWidth)

                    if focusKeyboard {
                        imgui.SetKeyboardFocusHere()
                        focusKeyboard = false
                    }

                    imgui.InputTextWithHint(
                        "##imgui.windows.GReport.greport.window.answerInput",
                        "Ответ на репорт / причина блокировки репорта / причина удаления репорта",
                        greport.window.answerInput,
                        ffi.sizeof(greport.window.answerInput)
                    )

                    animations::hint(
                        "Это поле не должно быть пустым.",
                        fn { return greport.window.noInputClock && (os.clock() - greport.window.noInputClock <= 1) && #ffi.string(greport.window.answerInput) == 0 },
                        nil,
                        common::convertHex2ImVec4("E46876")
                    )
                imgui.EndGroup()
                imgui.SetCursorPosY(imgui.GetCursorPos().y - 5)
            imgui.PopFont()        
            imgui.PushFont(bold10)
                if animations::button("Следить", imgui.ImVec2(itemFullWidth / 3, 25), nil, { 0, 0, 0.4 }) {
                    greport.player::spectate()
                }

                imgui.SameLine()

                if animations::button("Удалить", imgui.ImVec2(itemFullWidth / 3 - imgui.GetStyle().ItemSpacing.x * 2, 25), nil, { 0, 0, 0.4 }) {
                    if #ffi.string(greport.window.answerInput) == 0 {
                        greport.window.noInputClock = os.clock()
                    } else {
                        greport.player::remove(ffi.string(greport.window.answerInput))
                    }
                }
                
                imgui.SameLine()

                if animations::button("Поставить метку", imgui.ImVec2(itemFullWidth / 3, 25), nil, { 0, 0, 0.4 }) {
                    greport.player::setMapPoint()
                }

                if animations::button("Отправить в /a чат", imgui.ImVec2(itemFullWidth / 3, 25)) {
                    sampSendChat(string.format("/a %s[%d]: %s", greport.player.nickname, greport.player.id, greport.player.context))
                }

                imgui.SameLine()

                if animations::button("Заблокировать репорт игроку", imgui.ImVec2(itemFullWidth / 3 - imgui.GetStyle().ItemSpacing.x * 2, 25)) {
                    if #ffi.string(greport.window.answerInput) == 0 {
                        greport.window.noInputClock = os.clock()
                    } else {
                        imgui.OpenPopup("imgui.windows.GReport.timeSelection")
                    }
                }

                imgui.SameLine()

                if animations::button("Передать репорт", imgui.ImVec2(itemFullWidth / 3, 25), nil, { 0, 0, 0.4 }) {
                    greport.player::moveReportToAdministration()
                }

                for index = 1, 6 {
                    if animations::button(
                        "> " .. config.root.windows.greport.inputCopyButtons[index][1] .. "##imgui.windows.GReportIndex" .. index,
                        imgui.ImVec2(itemFullWidth / 3 - ((index == 2 || index == 5) ? imgui.GetStyle().ItemSpacing.x * 2 : 0), 25)
                    ) {
                        imgui.StrCopy(greport.window.answerInput, config.root.windows.greport.inputCopyButtons[index][2])
                    }

                    imgui.SameLine()
                    if index % 3 == 0 { imgui.NewLine() }
                }
            
                if animations::button("Ответить на репорт", imgui.ImVec2(itemFullWidth, 30), nil, { 0, 0, 0.4 }) {
                    if #ffi.string(greport.window.answerInput) == 0 {
                        greport.window.noInputClock = os.clock()
                    } else {
                        greport.player::answer(ffi.string(greport.window.answerInput))
                    }
                }
            imgui.PopFont()    
        imgui.EndGroup()

        if imgui.BeginPopupModal("imgui.windows.GReport.timeSelection", nil, self.flags) {
            imguiAssets::textWithFont("Выберите время (в минутах)", bold14)
            imgui.PushFont(regular12)
                for _, time in ({ 10, 30, 60, 90 }) {
                    if animations::button(
                        time .. "##imgui.windows.GReport.timeSelection",
                        imgui.ImVec2(imgui.GetWindowWidth() / 4 - 6.5, 25)
                    ) {
                        greport.player::blockReport(time, ffi.string(greport.window.answerInput))
                        imgui.CloseCurrentPopup()
                    }
                    
                    imgui.SameLine()
                }
            imgui.PopFont()
            imgui.NewLine()
            
            if animations::button("Отменить", imgui.ImVec2(imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x * 2, 30)) {
                imgui.CloseCurrentPopup()
            }
        }
    imgui.End()
    style::endWindowStyleChangeable("imgui.windows.GReport")
    imgui.PopStyleVar()
})
