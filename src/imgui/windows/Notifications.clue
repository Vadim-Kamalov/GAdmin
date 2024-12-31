/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2025 The Contributors.
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

@import "Notifications"         => notify
@import "Common"                => common
@import "Config"                => config
@import "Assets"                => assets

@import "imgui.Assets"          => imguiAssets
@import "imgui.Style"           => style
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Animations"      => animations
@import "imgui.drawList.Shadow" => shadow

style::registerWindow("imgui.windows.Notifications", "Оповещения")

imgui.OnFrame(fn { return notify.active && config.root.windows.notifications.use }, fn (self) {
    self.HideCursor = imguiAssets::getCursorStatus()
    self.align      = config.root.windows.notifications.align 
    self.notifySize = math.min(5, #notify::get())
    self.flags      = imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize
        + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoBringToFrontOnFocus

    self.style = StyleChanger::new({
        WindowBg            = "22222200"
        WindowBorderSize    = 0
        ChildBg             = imgui.GetStyle().Colors[imgui.Col.WindowBg]
        ChildRounding       = 8
        ItemSpacing         = imgui.ImVec2(0, 15)
        WindowPadding       = imgui.ImVec2(0, 0)
    })

    self.notification = fn (notification, closeCallback) {
        imgui.BeginChild(tostring(notification.clock + os.time()), imgui.ImVec2(344, 65), false, self.flags)
            local pos = imgui.GetWindowPos()
            local size = imgui.GetWindowSize()
            shadow::apply(
                imgui.GetBackgroundDrawList(),
                imgui.ImVec2(pos.x + 5, pos.y + 5),
                imgui.ImVec2(size.x - 10, size.y - 10),
                24.0,
                math.floor(math.floor(imgui.GetStyle().Alpha * 255) / 255) * 100,
                2
            )
            
            imgui.SetCursorPos(imgui.ImVec2(12, 28))
            imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.Text], notification.icon)
        
            imguiAssets::textWithFont(notification.title, bold10, imgui.ImVec2(52, 8))
        
            imgui.PushTextWrapPos((notification.buttons?.first && notification.buttons?.second) ? 255 : 339)
                imguiAssets::textWithFont(notification.text, regular9, imgui.ImVec2(52, 28))
            imgui.PopTextWrapPos()

            if notification.buttons?.first && notification.buttons?.second {
                local dl    = imgui.GetWindowDrawList()
                local pos   = imgui.GetWindowPos()
                local size  = imgui.GetWindowSize()
                local color = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                
                dl::AddLine(imgui.ImVec2(pos.x + 263, pos.y), imgui.ImVec2(pos.x + 263, pos.y + size.y), color, 1)
                dl::AddLine(imgui.ImVec2(pos.x + 263, pos.y + 32), imgui.ImVec2(pos.x + size.x, pos.y + 32), color, 1)

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
                            this.call?(closeCallback)
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
                            this.call?(closeCallback)
                        }
                    }
                imgui.EndGroup()
            }
        imgui.EndChild()
    }

    local sizeX, sizeY = getScreenResolution()

    self.animation = ({
        [ALIGN_LEFT] = {
            posX     = 0,
            show     = { from = -150, to = 15 },
            hide     = { from = 15, to = -150 },
            removeOn = -150
        },

        [ALIGN_CENTER] = {},
        [ALIGN_RIGHT]  = {
            posX     = sizeX - 360,
            show     = { from = 380, to = 0 },
            hide     = { from = -1, to = 380 },
            removeOn = 380
        }
    })[self.align]

    self.style::apply()
    imgui.SetNextWindowPos(imgui.ImVec2((self.align == ALIGN_CENTER) ? sizeX / 2 - 172 : self.animation.posX, sizeY - 80 * self.notifySize))
    imgui.SetNextWindowSize(imgui.ImVec2((self.align == ALIGN_CENTER) ? 344 : 860, 80 * self.notifySize))

    style::beginWindowStyleChangeable("imgui.windows.Notifications")
    imgui.Begin("imgui.windows.Notifications", nil, self.flags)
        for i = 1, config.root.windows.notifications.maxItems {
            if local notification = notify::get()[i] {
                if self.align != ALIGN_CENTER {
                    if os.clock() - notification.clock >= notification.duration {
                        notification.pos = imguiAssets::bringFloatTo(
                            self.animation.hide.from,
                            self.animation.hide.to,
                            notification.clock + notification.duration,
                            0.1
                        )
                    } elseif notification.pos < math.abs(self.animation.removeOn) {
                        notification.pos = imguiAssets::bringFloatTo(
                            self.animation.show.from,
                            self.animation.show.to,
                            notification.clock,
                            0.2
                        )
                    }

                    if notification.pos == self.animation.removeOn {
                        notify::remove(i)
                    }

                    imgui.SetCursorPosX(notification.pos)
                } else {
                    if os.clock() - notification.clock >= notification.duration {
                        if #notify.root == i {
                            notification.pos = imguiAssets::bringFloatTo(
                                0,
                                150,
                                notification.clock + notification.duration,
                                0.1
                            )
                        } else {
                            notification.alpha = imguiAssets::bringFloatTo(
                                1.0,
                                0.0,
                                notification.clock + notification.duration,
                                0.1
                            )
                        }
                    } elseif notification.pos > 0 {
                        notification.pos = imguiAssets::bringFloatTo(
                            149,
                            0,
                            notification.clock,
                            0.2
                        )
                    }

                    if notification.pos == 150 || notification.alpha == 0.0 {
                        notify::remove(i)
                    }

                    imgui.SetCursorPosY(notification.pos + imgui.GetCursorPos().y)
                }

                if notification.condition?() {
                    notification.clock      = os.clock() - notification.duration
                    notification.condition  = nil
                }
                
                imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, notification.alpha)
                    self.notification(notification, fn {
                        notification.clock = os.clock() - notification.duration
                    })
                imgui.PopStyleVar()
            }
        }
    imgui.End()
    style::endWindowStyleChangeable("imgui.windows.Notifications")
    self.style::reset()
})
