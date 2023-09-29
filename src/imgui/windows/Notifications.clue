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

@import "Notifications"         => notify
@import "Common"                => common
@import "Config"                => config
@import "Assets"                => assets

@import "imgui.Assets"          => imguiAssets
@import "imgui.Style"           => style
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Animations"      => animations
@import "imgui.drawList.Shadow" => shadow

local notifications = notify::get()

imgui.OnFrame(fn { return notify.active }, fn(self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.notifySize = math.min(5, #notifications)
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize
        + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoBringToFrontOnFocus

    self.style = StyleChanger::new({
        WindowBg            = "22222200"
        WindowBorderSize    = 0
        ChildBg             = "222222"
        ChildRounding       = 8
        ItemSpacing         = imgui.ImVec2(0, 15)
        WindowPadding       = imgui.ImVec2(0, 0)
    })

    self.notification = fn(notification, closeCallback) {
        imgui.BeginChild(tostring(notification.clock + os.time()), imgui.ImVec2(344, 65), false, self.flags)
            local pos = imgui.GetWindowPos()
            local size = imgui.GetWindowSize()
            shadow::apply(
                imgui.GetBackgroundDrawList(),
                imgui.ImVec2(pos.x + 5, pos.y + 5),
                imgui.ImVec2(size.x - 10, size.y - 10),
                24.0,
                100,
                2
            )
            
            imgui.SetCursorPos(imgui.ImVec2(12, 28))
            imgui.TextColored(notification.iconColor, notification.icon)
        
            imguiAssets::textWithFont(notification.title, bold10, imgui.ImVec2(52, 8))
        
            imgui.PushTextWrapPos((notification.buttons?.first && notification.buttons?.second) ? 255 : 339)
                imguiAssets::textWithFont(notification.text, regular9, imgui.ImVec2(52, 28))
            imgui.PopTextWrapPos()

            if notification.buttons?.first && notification.buttons?.second {
                local dl = imgui.GetWindowDrawList()
                local pos   = imgui.GetWindowPos()
                local size  = imgui.GetWindowSize()
                dl::AddLine(imgui.ImVec2(pos.x + 263, pos.y), imgui.ImVec2(pos.x + 263, pos.y + size.y), 0xFF5B5B5B, 1)
                dl::AddLine(imgui.ImVec2(pos.x + 263, pos.y + 32), imgui.ImVec2(pos.x + size.x, pos.y + 32), 0xFF5B5B5B, 1)

                imgui.BeginGroup()
                    if local this = notification.buttons.first {
                        imgui.SetCursorPos(imgui.ImVec2(263, 0))
                        if animations::clickableText(
                            "FIRST:" .. tostring(notification.clock + os.time()),
                            this.name,
                            regular9,
                            imgui.ImVec2(size.x - 263, 32),
                            0.25
                        ) {
                            this.call(closeCallback)
                        }
                    }

                    if local this = notification.buttons.second {
                        imgui.SetCursorPos(imgui.ImVec2(263, 33))
                        if animations::clickableText(
                            "SECOND:" .. tostring(notification.clock + os.time()),
                            this.name,
                            regular9,
                            imgui.ImVec2(size.x - 263, 32),
                            0.25
                        ) {
                            this.call(closeCallback)
                        }
                    }
                imgui.EndGroup()
            }
        imgui.EndChild()
    }

    local sizeX, sizeY = getScreenResolution()

    self.style::apply()
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX - 360, sizeY - 80 * self.notifySize))
    imgui.SetNextWindowSize(imgui.ImVec2(860, 80 * self.notifySize))

    style::beginWindowStyleChangeable("imgui.windows.Notifications")
    imgui.Begin("imgui.windows.Notifications", nil, self.flags)
        for i = 1, config.root.notifications.maxItems {
            if local notification = notify::get()[i] {
                if os.clock() - notification.clock >= notification.duration {
                    notification.pos = imguiAssets::bringFloatTo(-1, 380, notification.clock + notification.duration, 0.1)
                } elseif notification.pos < 380 {
                    notification.pos = imguiAssets::bringFloatTo(380, 0, notification.clock, 0.2)
                }

                if notification.pos == 380 {
                    notify::remove(i)
                }

                imgui.SetCursorPosX(notification.pos)
                self.notification(notification, fn {
                    notification.clock = os.clock() - notification.duration
                })
            }
        }
    imgui.End()
    style::endWindowStyleChangeable("imgui.windows.Notifications")
    self.style::reset()
})
