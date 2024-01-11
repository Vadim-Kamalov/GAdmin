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

@import "AutoUpdate"    => autoUpdate
@import "Config"        => config

@import "imgui.Assets"          => imguiAssets
@import "imgui.Animations"      => animations
@import "imgui.StyleChanger"    => StyleChanger

local sizeX, sizeY = getScreenResolution()

imgui.OnFrame(fn { return autoUpdate.windowState }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar

    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(720, 350))

    local itemSpacing, windowPadding = imgui.GetStyle().ItemSpacing, imgui.GetStyle().WindowPadding

    imgui.Begin("imgui.windows.AutoUpdate", nil, self.flags)
        imguiAssets::textWithFont(autoUpdate.imgui.title, bold14, imgui.ImVec2(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(autoUpdate.imgui.title).x / 2, 10))

        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.WindowBg])
            imgui.BeginChild("imgui.windows.AutoUpdate.child", imgui.ImVec2(0, imgui.GetWindowHeight() - 70 - windowPadding.y), false)
                for line with string.gmatch(autoUpdate.imgui.body, "[^\n]+") {
                    line = string.match($, "^%s*(.*)$")
                    if string.find(line, "<header>.*</header>") {
                        imguiAssets::textWithFont(string.match(line, "<header>(.*)</header>"), bold14)
                    } elseif string.find(line, "<newline.*") {
                        imgui.NewLine()
                    } else {
                        imguiAssets::textWithFont(line, regular14)
                    }
                }
            imgui.EndChild()
        imgui.PopStyleColor()

        imgui.SetCursorPosY(imgui.GetWindowHeight() - 33 - windowPadding.y)
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.Button])
            imgui.BeginGroup()
                imgui.PushFont(regular12)
                    if animations::button(autoUpdate.imgui.buttons.first, imgui.ImVec2(imgui.GetWindowWidth() / 3, 30), 15) {
                        autoUpdate.response     = AUTOUPDATE_RESPONSE_OK
                        autoUpdate.windowState  = false

                        autoUpdate::update()
                    }

                    animations::hint("Эта версия установится.")
                    
                    imgui.SameLine()
                    
                    if animations::button(autoUpdate.imgui.buttons.second, imgui.ImVec2(imgui.GetWindowWidth() / 3 - 20, 30)) {
                        config.root.autoUpdate.skipVersionUpdate = autoUpdate.imgui.version

                        autoUpdate.response     = AUTOUPDATE_RESPONSE_BAD
                        autoUpdate.windowState  = false
                    }

                    animations::hint("Эта версия пропустится, окно не будет появляться до следующего обновления.")

                    imgui.SameLine()
    
                    if animations::button(autoUpdate.imgui.buttons.third, imgui.ImVec2(imgui.GetWindowWidth() / 3, 30)) {
                        autoUpdate.response     = AUTOUPDATE_RESPONSE_BAD
                        autoUpdate.windowState  = false
                    }

                    animations::hint("Это окно не будет появляться до следующего запуска скрипта.")
                imgui.PopFont()
            imgui.EndGroup()
        imgui.PopStyleColor()
    imgui.End()
})
