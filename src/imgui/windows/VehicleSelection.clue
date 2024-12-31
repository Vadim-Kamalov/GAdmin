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

@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.InputTextFilter" => InputTextFilter
@import "imgui.Animations"      => animations
@import "imgui.Style"           => style
@import "game.sa.Vehicle"       => vehicle
@import "Common"                => common

static vehicleSelectionPanel = {
    active  = false,
    closing = false,
    focus   = false,
    colors  = { nil, nil },
    filter  = nil,
    alpha   = {
        clock      = os.clock()
        background = 0,
        window     = 0
    }
}

style::registerWindow("imgui.windows.VehicleSelectionPanel", "Выбор машины для спавна")
addEventHandler("onWindowMessage", fn (event, wparam) {
    if event == wm.WM_KEYDOWN || event == wm.WM_SYSKEYDOWN {
        if wparam == VK_ESCAPE && vehicleSelectionPanel.active && !changingHotKey {
            vehicleSelectionPanel::close()
            consumeWindowMessage(true, false)
            return
        }
    }
})

/**
 * Open window to spawn selected vehicle,
 * @return void
 */
method vehicleSelectionPanel::open() {
    self.alpha.clock = os.clock()
    self.active      = true
    self.focus       = true

    imguiAssets::setCursorStatus(false)
}

/**
 * Close window.
 * @return void
 */
method vehicleSelectionPanel::close() {
    self.alpha.clock = os.clock()
    self.closing     = true

    imguiAssets::setCursorStatus(true)
}

imgui.OnFrame(fn { return vehicleSelectionPanel.active && !isGamePaused()) }, fn (self) {
    if local this = vehicleSelectionPanel {
        this.filter    ??= InputTextFilter::new()
        this.colors[1] ??= imgui.new.int(0)
        this.colors[2] ??= imgui.new.int(0)

        this.alpha.background = imguiAssets::bringFloatTo($, (this.closing) ? 0 : 128, this.alpha.clock, 0.5)
        this.alpha.window     = imguiAssets::bringFloatTo($, (this.closing) ? 0 : 255, this.alpha.clock, 0.5)
        
        if this.alpha.background == 0 && this.closing {
            this.closing = false
            this.active  = false

            this.colors[1][0], this.colors[2][0] = 0, 0

            this.filter::clear()
        }
    }

    self.id         = "imgui.windows.vehicleSelection"
    self.flags      = imgui.WindowFlags.NoTitleBar
    self.HideCursor = imguiAssets::getCursorStatus()
    self.style      = StyleChanger::new({
        WindowPadding = imgui.ImVec2(10, 10),
        ItemSpacing   = imgui.ImVec2(10, 10),
        FramePadding  = imgui.ImVec2(7, 7)
    })

    self.sizeX, self.sizeY = getScreenResolution()

    imgui.GetBackgroundDrawList()::AddRectFilled(
        imgui.ImVec2(0, 0),
        imgui.ImVec2(self.sizeX, self.sizeY),
        vehicleSelectionPanel.alpha.background << 24
    )

    self.style::apply()
    style::beginWindowStyleChangeable("imgui.windows.VehicleSelectionPanel")
    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, vehicleSelectionPanel.alpha.window / 255)
    imgui.SetNextWindowPos(imgui.ImVec2(self.sizeX / 2, self.sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSizeConstraints(imgui.ImVec2(400, 600), imgui.ImVec2(math.huge, math.huge))
    imgui.Begin(self.id, nil, self.flags)
        self.itemsWidth = imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x * 2

        imguiAssets::textWithFont("Выберите машину для спавна", bold14)

        imgui.BeginGroup()
            for index, color in vehicleSelectionPanel.colors {
                local title = ((index == 1) ? "Первый" : "Второй") .. " цвет"
                
                imgui.BeginGroup()
                    // For some reasons there's no `ItemSpacing.y` between these two elements on second group and
                    // iteration (why?), so we need these two ugly `if` statements here to align it by self.

                    if index == 2 { imgui.SetCursorPosY(imgui.GetCursorPos().y - 5) }
                    imguiAssets::textWithFont(title, bold10)
                    if index == 2 { imgui.SetCursorPosY(imgui.GetCursorPos().y + 5) }
                    
                    imgui.PushFont(regular10)
                        imgui.SetNextItemWidth((self.itemsWidth - imgui.GetStyle().WindowPadding.x) / 2)
                        if imgui.InputInt("##" .. self.id .. '.' .. title, color, nil, 1) {
                            color[0] = common::clamp($, 0, 255) 
                        }
                    imgui.PopFont()
                imgui.EndGroup()
                imgui.SameLine()
            }
        imgui.EndGroup()

        if vehicleSelectionPanel.focus {
            vehicleSelectionPanel.focus = false
            imgui.SetKeyboardFocusHere()
        }

        vehicleSelectionPanel.filter::draw(string.format("##%s.filter", self.id), "Поиск", self.itemsWidth)
        
        local filtered  = {}
        local filtering = #ffi.string(vehicleSelectionPanel.filter.buffer) != 0

        if filtering {
            for index, name in vehicle.names {
                if vehicleSelectionPanel.filter::passFilter(string.format("%s[ID: %d]", name, index + 399)) {
                    table.insert(filtered, { name = name, id = index + 399 })
                }
            }

            if #filtered == 1 && imgui.IsKeyPressed(imgui.Key.Enter) {
                local colors = vehicleSelectionPanel.colors
                sampSendChat(string.format("/veh %d %d %d", filtered[1].id, colors[1][0], colors[2][0]))
                vehicleSelectionPanel::close()
            }
        }

        imgui.BeginChild(self.id .. ".vehicles", imgui.ImVec2(
            self.itemsWidth,
            imgui.GetWindowHeight() - imgui.GetCursorPos().y - imgui.GetStyle().WindowPadding.y - imgui.GetStyle().ItemSpacing.x - 30
        ), false)
            imgui.SetCursorPos(imgui.ImVec2(7, 7))
            imgui.PushFont(bold10)
            imgui.BeginGroup()
                local clipper = imgui.ImGuiListClipper((filtering) ? #filtered : #vehicle.names)
                while clipper::Step() {
                    for index = clipper.DisplayStart + 1, clipper.DisplayEnd {
                        local item  = (filtering) ? filtered[index] : vehicle.names[index]
                        local name  = (filtering) ? item.name : item
                        local id    = (filtering) ? item.id : index + 399
                        local title = string.format("%s[ID: %d]", name, id)

                        if animations::button(string.format("%s##%s.vehicleId%d", title, self.id, id), imgui.ImVec2(
                            imgui.GetWindowWidth() - imgui.GetStyle().WindowPadding.x - 5,
                            25
                        ), nil, { 0, 0, 0.4 }) {
                            local colors = vehicleSelectionPanel.colors
                            sampSendChat(string.format("/veh %d %d %d", id, colors[1][0], colors[2][0]))
                            vehicleSelectionPanel::close()
                        }
                    }
                }
                imgui.Spacing()
            imgui.EndGroup()
            imgui.PopFont()
        imgui.EndChild()

        imgui.PushFont(bold10)
            if animations::button("Закрыть##" .. self.id, imgui.ImVec2(self.itemsWidth, 30), nil, { 0, 0, 0.4 }) {
                vehicleSelectionPanel::close()
            }
        imgui.PopFont()
    imgui.End()
    imgui.PopStyleVar()
    self.style::reset()
    style::endWindowStyleChangeable("imgui.windows.VehicleSelectionPanel")
})
