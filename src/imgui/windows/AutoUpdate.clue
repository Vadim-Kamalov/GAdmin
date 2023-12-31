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
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar
    self.style      = StyleChanger::new({
        WindowPadding   = imgui.ImVec2(0, 0)
        FrameRounding   = 0
        ItemSpacing     = imgui.ImVec2(2, 0)
        ChildBorderSize = 0
        ChildRounding   = 0
    })

    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(720, 350))

    local itemSpacing, windowPadding = imgui.GetStyle().ItemSpacing, imgui.GetStyle().WindowPadding

    self.style::apply()
        imgui.Begin("imgui.windows.AutoUpdate", nil, self.flags)
            imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, imgui.GetStyle().WindowRounding)
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.Button])
                imgui.BeginChild("imgui.windows.AutoUpdate.header", imgui.ImVec2(0, 40), true)
                    imguiAssets::textWithFont(
                        autoUpdate.imgui.title,
                        bold10,
                        imgui.ImVec2(10, 20 - imgui.CalcTextSize(autoUpdate.imgui.title).y / 2)
                    )

                    imguiAssets::textWithFont(
                        autoUpdate.imgui.version,
                        bold10,
                        imgui.ImVec2(
                            imgui.GetWindowWidth() - imgui.CalcTextSize(autoUpdate.imgui.version).x - 10,
                            20 - imgui.CalcTextSize(autoUpdate.imgui.version).y / 2
                        ) 
                    )
                imgui.EndChild()
            imgui.PopStyleVar()
            imgui.PopStyleColor()

            if local rectMin, rectMax = imgui.GetItemRectMin(), imgui.GetItemRectMax() {
                imgui.GetWindowDrawList()::AddRectFilled(
                    imgui.ImVec2(rectMin.x, rectMax.y - 4),
                    imgui.ImVec2(rectMax.x, rectMax.y),
                    imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ChildBg])
                )
            }

            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.WindowBg])
                imgui.SetCursorPos(imgui.ImVec2(5, 45))
                imgui.BeginChild("imgui.windows.AutoUpdate.child", imgui.ImVec2(0, imgui.GetWindowHeight() - 85 - windowPadding.y), true)
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

            imgui.SetCursorPosY(imgui.GetWindowHeight() - 40 - windowPadding.y)
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.GetStyle().Colors[imgui.Col.Button])
                imgui.BeginChild("imgui.windows.AutoUpdate.actions", imgui.ImVec2(0, 0), true)
                    imgui.PushFont(bold10)
                        if animations::button(autoUpdate.imgui.buttons.first, imgui.ImVec2(imgui.GetWindowWidth() / 3 - 1, 40), 15) {
                            autoUpdate.response     = AUTOUPDATE_RESPONSE_OK
                            autoUpdate.windowState  = false

                            autoUpdate::update()
                        }

                        animations::hint("Эта версия установится.")
                    
                        imgui.SameLine()
                    
                        if animations::button(autoUpdate.imgui.buttons.second, imgui.ImVec2(imgui.GetWindowWidth() / 3, 40)) {
                            config.root.autoUpdate.skipVersionUpdate = autoUpdate.imgui.version

                            autoUpdate.response     = AUTOUPDATE_RESPONSE_BAD
                            autoUpdate.windowState  = false
                        }

                        animations::hint("Эта версия пропустится, окно не будет появляться до следующего обновления.")

                        imgui.SameLine()
    
                        if animations::button(autoUpdate.imgui.buttons.third, imgui.ImVec2(imgui.GetWindowWidth() / 3, 40)) {
                            autoUpdate.response     = AUTOUPDATE_RESPONSE_BAD
                            autoUpdate.windowState  = false
                        }

                        animations::hint("Это окно не будет появляться до следующего запуска скрипта.")
                    imgui.PopFont()
                imgui.EndChild()
            imgui.PopStyleColor()
        imgui.End()
    self.style::reset()
})
