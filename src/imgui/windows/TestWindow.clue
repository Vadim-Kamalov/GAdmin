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

@import "imgui.Windows" => windows
@import "imgui.Animations" => animations
@import "imgui.HotKey"  => HotKey

@ifdef __GADMIN_DEBUG__ {
    windows::new("imgui.windows.TestWindow", {
        description = "Test window...",
        type        = MV_DEFAULT,
        condition   = fn { return true },
        size        = { x = 255, y = 252 },

        initialize  = {
            testNumber = 1
        }
    }, fn(self) {
        self::begin("JustTestWindow", fn {
            imgui.Text("Hello, world!")
            
            if imgui.Button("Increment test number") {
                self.var.testNumber += 1
            }
            
            animations::hint("Just testing this preety cool hint!")
            
            imgui.Text("Your test number is " .. tostring(self.var.testNumber))
           
            if imgui.Button("Execute changing windows positions") {
                self.executeChangingWindowsPositions()
            }
        })
    })
}
