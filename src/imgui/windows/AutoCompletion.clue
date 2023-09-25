/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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

@import "game.samp.ChatInputBox" => chatInputBox

@import "Config" => config

static autoCompletion = {
    position        = 1,
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
        imgui.Begin("imgui.windows.AutoCompletion", nil, self.flags)
            for pos, command in self.foundCommands {
                local text = string.format("%s - %s", command.name, command.description)
                local _pos = imgui.GetCursorPos()

                imguiAssets::addStrokedText(text, config.root.windows.autoCompletion.strokeSize)
                imgui.SetCursorPos(_pos)

                /// TODO: Hotkey to replace `isKeyJustPressed(VK_TAB)`, fix with hotkey module implemented.
                if imgui.Selectable(text, autoCompletion.position == pos)
                   || (autoCompletion.position == pos && isKeyJustPressed(VK_TAB))
                {
                    sampSetChatInputText(command.name)
                    autoCompletion.position = pos
                }
            }
        imgui.End()
        self.style::reset()
    }
})
