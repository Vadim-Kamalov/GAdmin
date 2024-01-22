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

@import "imgui.Windows"         => windows
@import "imgui.Assets"          => imguiAssets
@import "imgui.StyleChanger"    => StyleChanger
@import "imgui.Animations"      => animations

@import "Config" => config
@import "Common" => common

@define NOTE_POST_HOVER_ANIMATION_DURATION  0.4
@define NOTE_HOVER_ANIMATION_DURATION       0.3

static __playerNotes__ = {
    displayBuffer = {}
}

/**
 * Render user note.
 *
 * `note` configuration device:
 *
 * ```clue
 * {
 *     id           = string,
 *     title        = string,
 *     description  = string,
 *     display      = boolean
 * }
 * ```
 *
 * @param note table
 * @return void
 */
method __playerNotes__::renderNote(note) {
    local index = nil
    
    for checkIndex, checkNote in config.root.playerNotes {
        if note.id == checkNote.id {
            index = checkIndex
        }
    }

    self.displayBuffer[note.id] ??= imgui.new.bool(config.root.playerNotes[index].display || false)

    windows::new(note.id, {
        description = note.title,
        condition   = fn { return self.displayBuffer[note.id][0] },
        size        = { x = 0, y = 0 },
        initialize  = {
            fade = {
                clock   = 0,
                state   = false,
                before  = nil,
                alpha   = {
                    window  = 0.0,
                    text    = 0.0
                }
            },

            style = StyleChanger::new({
                WindowBorderSize    = 0
                WindowBg            = imgui.ImVec4(0, 0, 0, 0)
            })
        }
    }, fn(this) {
        this.var.style::apply()
        this::begin(this.id, fn {
            imgui.BeginGroup()
                imgui.PushFont(bold14)
                    imguiAssets::addStrokedText(note.title, (imgui.GetStyle().Colors[imgui.Col.WindowBg].w <= 0.4) ? 1 : 0)
                imgui.PopFont()

                imgui.PushFont(regular12)
                    imguiAssets::addStrokedText(note.body, (imgui.GetStyle().Colors[imgui.Col.WindowBg].w <= 0.4) ? 1 : 0)
                imgui.PopFont()
            imgui.EndGroup()

            if !this.isChangingWindowsPositions {
                if imgui.IsWindowHovered() && imgui.IsMouseReleased(0 /* ImGuiMouseButton_Left */) {
                    note.display                    = false
                    self.displayBuffer[note.id][0]  = false
                    imguiAssets::setCursorStatus(true)
                } else {
                    this.var.fade.state = imgui.IsWindowHovered() || os.clock() - $NOTE_POST_HOVER_ANIMATION_DURATION < 0

                    if this.var.fade.state != this.var.fade.before {
                        this.var.fade.before    = this.var.fade.state
                        this.var.fade.clock     = os.clock()
                    }

                    this.var.fade.alpha.window = imguiAssets::bringFloatTo(
                        $,
                        (this.var.fade.state && (common::isCursorActive() || !imguiAssets::getCursorStatus())) ? 0.7 : 0.0, 
                        this.var.fade.clock,
                        $NOTE_HOVER_ANIMATION_DURATION
                    )

                    this.var.fade.alpha.text = imguiAssets::bringFloatTo(
                        $,
                        (this.var.fade.state && (common::isCursorActive() || !imguiAssets::getCursorStatus())) ? 1.0 : 0.0,
                        this.var.fade.clock,
                        $NOTE_HOVER_ANIMATION_DURATION
                    )
                }
            }

            if local drawList = imgui.GetWindowDrawList() {
                drawList::AddRectFilled(
                    imgui.GetWindowPos(),
                    imgui.GetWindowPos() + imgui.GetWindowSize(),
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(
                        common::convertHex2ImVec4($IMVEC4_TO_RGB!(imgui.GetStyle().Colors[imgui.Col.ChildBg]), this.var.fade.alpha.window * 255)
                    )),
                    imgui.GetStyle().WindowRounding
                )

                local text = "Закрыть"
                local size = imgui.CalcTextSize(text)

                drawList::AddTextFontPtr(bold, 18, imgui.ImVec2(
                    (imgui.GetWindowWidth() - size.x) / 2,
                    (imgui.GetWindowHeight() - size.y) / 2
                ) + imgui.GetWindowPos(), imgui.ColorConvertFloat4ToU32(
                    common::convertHex2ImVec4($IMVEC4_TO_RGB!(imgui.GetStyle().Colors[imgui.Col.Text]), this.var.fade.alpha.text * 255)
                ), text)
            }
        })
        this.var.style::reset()
    })
}

/**
 * Initialize user notes that were previously
 * defined in `config.root.playerNotes` by user.
 *
 * @return void
 */
method __playerNotes__::initializeNotes() {
    for _, note in config.root.playerNotes {
        self::renderNote(note)
    }
}

/**
 * Create new note.
 *
 * @param note table
 * @return void
 */
method __playerNotes__::new(note) {
    local noteId = #config.root.playerNotes + 1
    
    for _, note in config.root.playerNotes {
        if local id = string.match(note.id, "^noteIndex%-(%d+)$") {
            if tonumber(id) == noteId {
                noteId += 1
            }
        }
    }

    note.id = "noteIndex-" .. noteId

    table.insert(config.root.playerNotes, note)
    self::renderNote(note)
}

/**
 * Remove note by it's index.
 *
 * @param index number
 * @return void
 */
method __playerNotes__::remove(index) {
    local id                    = config.root.playerNotes[index].id
    self.displayBuffer[id][0]   = false

    table.remove(config.root.playerNotes, index)
}

return __playerNotes__
