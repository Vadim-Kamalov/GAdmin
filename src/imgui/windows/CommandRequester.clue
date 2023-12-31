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
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.HotKey"          => HotKey

@import "game.Admins" => admins

@import "Common"            => common
@import "CommandRequester"  => commandRequester

local sizeX, sizeY  = getScreenResolution()
local hotKey        = HotKey::new("imgui.windows.CommandRequester", { VK_LSHIFT, VK_Z }, "Принять форму")
                            ::registerCallback(commandRequester.hotKeyCallback)

imgui.OnFrame(fn { return commandRequester.states.frame }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize
    self.style      = StyleChanger::new({
        WindowBg            = common::convertHex2ImVec4($IMVEC4_TO_RGB!(imgui.GetStyle().Colors[imgui.Col.WindowBg]) .. "80")
        WindowRounding      = 0
        FrameRounding       = 0
        WindowBorderSize    = 0
        WindowPadding       = imgui.ImVec2(sizeX / 10, 10)
    })
    
    self.admin      = admins::getAdminById(commandRequester.current.id.from)
    self.command    = "/" .. commandRequester.current.command.splitted.name .. " " .. commandRequester.current.command.splitted.args
    self.timer      = string.format("Это окно исчезнет через %.1f секунд", 5 - (os.clock() - commandRequester.current.clock))

    if self.admin {
        self.style::apply()

        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, 70))

        imgui.Begin("imgui.windows.CommandRequester", nil, self.flags)
            imgui.PushFont(bold10)
                imgui.Text("Пришла форма от %s · Принять - %s", self.admin.nickname.ooc, tostring(hotKey))
                imgui.SameLine(sizeX / 2 - imgui.CalcTextSize(self.command).x / 2)
                imgui.Text(self.command)
                imgui.SameLine(sizeX - imgui.GetStyle().WindowPadding.x - imgui.CalcTextSize(self.timer).x)
                imgui.Text(self.timer)
            imgui.PopFont()
        imgui.End()

        self.style::reset()
    }
})
