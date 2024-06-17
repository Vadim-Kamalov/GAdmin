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
 * SPDX-License-Identifier: GPL-3.0-only
 */

@import "Common"        => common
@import "imgui.Assets"  => imguiAssets

local animations = {}

method animations::limit(v, min = 0.0, max = 1.0) {
    return (v < min) ? min : ((v > max) ? max : v)
}

method animations::getContrastColor(
    backgroundColor,
    colorA = imgui.ImVec4(0, 0, 0, 1),
    colorB = imgui.ImVec4(1, 1, 1, 1)
) {
    return ((1 - (0.299 * backgroundColor.x + 0.587 * backgroundColor.y + 0.114 * backgroundColor.z)) < 0.5) 
        ? colorA
        : colorB
}

/**
 * Draw animated and clickable text.
 *
 * @param label             string
 * @param text              string
 * @param font              ImFont|nil
 * @param areaToClickSize   ImVec2|nil
 * @param duration          number|nil
 * @param colors            table|nil
 * @return boolean, boolean (imgui.IsItemClicked(), imgui.IsItemHovered())
 */
method animations::clickableText(
    label,
    text,
    font = regular9,
    areaToClickSize = imgui.ImVec4(0, 0),
    duration = 0.2,
    colors = {
        def     = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovered = imgui.GetStyle().Colors[imgui.Col.Text]
    }
) {
    
    if !UI_CLICKABLE_TEXT {
        global UI_CLICKABLE_TEXT = {}
    }

    if !UI_CLICKABLE_TEXT[label] {
        UI_CLICKABLE_TEXT[label] = {
            color   = colors.def,
            hovered = {
                cur     = false,
                old     = false,
                clock   = nil
            }
        }
    }

    local this, result = UI_CLICKABLE_TEXT[label], nil
    {
        if font { imgui.PushFont(font) }

        local pos = imgui.GetCursorPos()
        imgui.SetCursorPos(imgui.ImVec2(
            pos.x + math.max(0, areaToClickSize.x / 2 - imgui.CalcTextSize(text).x / 2),
            pos.y + math.max(0, areaToClickSize.y / 2 - imgui.CalcTextSize(text).y / 2)
        ))
        imgui.TextColored(this.color, text)

        if font { imgui.PopFont() }
    
        imgui.SetCursorPos(pos)
        result = imgui.InvisibleButton(label, areaToClickSize)

        this.hovered.cur = imgui.IsItemHovered()
        if this.hovered.old != this.hovered.cur {
            this.hovered.old    = this.hovered.cur
            this.hovered.clock  = os.clock()
        }
    }

    if this.hovered.clock {
        if os.clock() - this.hovered.clock <= duration {
            this.color = imguiAssets::bringVec4To(
                $,
                (this.hovered.cur) ? colors.hovered : colors.def,
                this.hovered.clock,
                duration
            )
        } else {
            this.color = (this.hovered.cur) ? colors.hovered : colors.def
        }
    }

    return result
}

method animations::button(
    label,
    size,
    onHoveredFlags  = 15,
    duration        = { 0.2, 0.4, 0.3 },
    colors          = {
        def     = imgui.GetStyle().Colors[imgui.Col.Button],
        hovered = imgui.GetStyle().Colors[imgui.Col.ButtonHovered],
        active  = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
        window  = imgui.GetStyle().Colors[imgui.Col.WindowBg]
    }
) {
    local result = false
    local rounding = imgui.GetStyle().FrameRounding
    local id = label
   
    if !UI_ANIMATED_BUTTON {
        global UI_ANIMATED_BUTTON = {}
    }

    if !UI_ANIMATED_BUTTON[id] {
        UI_ANIMATED_BUTTON[id] = {
            radius  = 0
            clock   = { 0, 0 }
            pos     = nil
            size    = nil
            hovered = {
                state   = false
                before  = nil
                clock   = 0
                color   = imgui.ImVec4(
                    colors.hovered.x,
                    colors.hovered.y,
                    colors.hovered.z,
                    0.0
                )
            }
        }
    }

    local this      = UI_ANIMATED_BUTTON[id]
    local label     = string.gsub(label, "##.*$", "")
    local textSize  = imgui.CalcTextSize(label)
    local p         = imgui.GetCursorScreenPos()

    colors.def      = imgui.ImVec4($.x, $.y, $.z, imgui.GetStyle().Alpha)
    colors.hovered  = imgui.ImVec4($.x, $.y, $.z, imgui.GetStyle().Alpha)
    colors.active   = imgui.ImVec4($.x, $.y, $.z, imgui.GetStyle().Alpha)
    colors.def      = imgui.ImVec4($.x, $.y, $.z, imgui.GetStyle().Alpha)
 
    if !size {
        local padding = imgui.GetStyle().FramePadding
        size = imgui.ImVec2(textSize.x + (padding.x * 2), textSize.y + (padding.y * 2))
    }

    local pos   = imgui.GetCursorPos()
    local dl    = imgui.GetWindowDrawList()

    if this.size {
        this.hovered.color = match this.hovered.state {
            true => imguiAssets::bringVec4To($, colors.hovered, this.hovered.clock, duration[3]),
            false => imguiAssets::bringVec4To($, imgui.ImVec4(
                colors.hovered.x,
                colors.hovered.y,
                colors.hovered.z,
                0.0
            ), this.hovered.clock, duration[3])
        }

        dl::AddRectFilled(
            p - imgui.ImVec2(1, 1),
            imgui.ImVec2(p.x + size.x + 1, p.y + size.y + 1),
            imgui.ColorConvertFloat4ToU32(this.hovered.color),
            rounding,
            onHoveredFlags
        )
    }
    
    dl::AddRectFilled(p, p + size, imgui.ColorConvertFloat4ToU32(colors.def), rounding, onHoveredFlags)
    dl::PushClipRect(p + imgui.ImVec2(1, 1), p + size - imgui.ImVec2(1, 1))

    if this.pos {
        local alpha = 0.00

        local timer = os.clock() - this.clock[2]
        if timer <= duration[2] {
            alpha = self::limit(1.00 - ((1.00 / duration[2]) * timer), 0.0, 1.0)
        }

        local timer = os.clock() - this.clock[1]
        if timer <= duration[1] {
            alpha = self::limit((1.00 / duration[1]) * timer, 0.0, 1.0)
            this.radius = (size.x * 1.5 / duration[1]) * timer
        }

        local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
        dl::AddCircleFilled(
            this.pos, 
            this.radius, 
            imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, alpha)), 
            0xFF
        )
            
        if alpha <= 0 { this.pos = nil }
    }

    dl::PopClipRect()

    local al = imgui.GetStyle().ButtonTextAlign
    imgui.SetCursorPos(imgui.ImVec2((size.x - textSize.x) * al.x, (size.y - textSize.y) * al.y) + pos)
    imgui.TextUnformatted(label)

    imgui.SetCursorPos(pos)
    if imgui.InvisibleButton(id .. ".UI_ANIMATED_BUTTON", size) {
        this.radius     = 0
        this.pos        = imgui.GetMousePos()
        this.clock      = { os.clock(), os.clock() + duration[1] }
        result          = true
    }

    this.size           = imgui.ImVec2(size.x + 2, size.y + 2)
    this.hovered.state  = imgui.IsItemHovered() || os.clock() - this.clock[2] < 0
    
    if this.hovered.state != this.hovered.before {
        this.hovered.before = this.hovered.state
        this.hovered.clock  = os.clock()
    }

    return result
}

method animations::hint(
    label,
    hoverCallback = imgui.IsItemHovered,
    duration      = 0.2,
    hintColor     = imgui.GetStyle().Colors[imgui.Col.FrameBg],
    body,
    width
) {
    local originalPos   = imgui.GetCursorPos()
    local hovered       = hoverCallback()
    local id            = label
    local show          = true
    label               = string.gsub($, "##.*", "")

    imgui.SameLine(nil, 0)

    if !UI_HINTS {
        global UI_HINTS = {}
    }

    if !UI_HINTS[id] {
        UI_HINTS[id] = {
            focus  = body != nil,
            status = false,
            timer  = 0,
            width  = 0
        }
    }

    body ??= fn {
        for line with string.gmatch(label, "[^\n]+") {
            imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(line).x) / 2)
            imgui.Text(line)
        }
    }

    for uiId, hint of UI_HINTS {
        if uiId != id && os.clock() - hint.timer <= duration {
            show = false
        }
    }

    if local this = UI_HINTS[id] {
        if show && this.status != hovered {
            this.status = hovered
            this.timer  = os.clock()
        }

        local fn render(alpha) {
            local size      = imgui.GetItemRectSize()
            local screenPos = imgui.GetCursorScreenPos()
            local dl        = imgui.GetForegroundDrawList()
            local center    = imgui.ImVec2(screenPos.x - (size.x / 2), screenPos.y + (size.y / 2) - (alpha * 4) + 10)
            local a         = imgui.ImVec2(center.x - 10, center.y - size.y - 4)
            local b         = imgui.ImVec2(center.x + 10, center.y - size.y - 4)
            local c         = imgui.ImVec2(center.x, center.y - size.y + 3)
            local color     = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(hintColor.x, hintColor.y, hintColor.z, alpha))
            local flags     = imgui.WindowFlags.Tooltip + imgui.WindowFlags.NoResize 
                + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar 

            dl.Flags = imgui.DrawListFlags.AntiAliasedLines * 3

            dl::AddTriangleFilled(a, b, c, color)
            imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1))
            imgui.PushStyleColor(imgui.Col.PopupBg, hintColor)
            imgui.PushStyleColor(imgui.Col.Border, hintColor)
            imgui.PushStyleColor(imgui.Col.Text, self::getContrastColor(hintColor))
		    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
		    imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 6)
		    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, alpha)
                local fn maxWidth(text) {
                    local result = 0
                    for line with string.gmatch(text, "[^\n]+") {
                        if imgui.CalcTextSize(line).x > result {
                            result = imgui.CalcTextSize(line).x
                        }
                    }
                    return result
                }

                width ??= maxWidth(label) + imgui.GetStyle().WindowPadding.x * 2

                imgui.SetNextWindowSize(imgui.ImVec2(width, -1), imgui.Cond.Always)

                if this.focus {
                    imgui.SetNextWindowFocus()
                }

                imgui.Begin(id, nil, flags)
                    body()
                imgui.End()
		    imgui.PopStyleVar(3)
		    imgui.PopStyleColor(3)
        }

        if show {
            local between = os.clock() - this.timer
            if between <= duration {
                render((hovered) ? self::limit(between / duration, 0.00, 1.00) : self::limit(1.00 - between / duration, 0.00, 1.00))
            } elseif hovered {
                render(1.00)
            }
        }
    }

    imgui.SetCursorPos(originalPos)
}

method animations::keyCap(label, isPressed = false, size) {
    local dl        = imgui.GetWindowDrawList()
    local p         = imgui.GetCursorScreenPos()
    local rounding  = imgui.GetStyle().FrameRounding
    local colors    = {
        [true]  = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
        [false] = imgui.GetStyle().Colors[imgui.Col.Button]
    }    

    if !UI_KEY_CAP {
        global UI_KEY_CAP = {}
    }

    if !UI_KEY_CAP[label] {
        UI_KEY_CAP[label] = {
            status  = isPressed
            color   = colors[isPressed]
            clock   = nil
        }
    }

    if local this = UI_KEY_CAP[label] {
        if isPressed != this.status {
            this.status, this.clock = isPressed, os.clock()
        }

        if this.clock {
            this.color = imguiAssets::bringVec4To(colors[!isPressed], colors[isPressed], this.clock, 0.1)
        }

        local text      = string.gsub(label, "##.*", "")
        local textSize  = imgui.CalcTextSize(text)
        local textPos   = imgui.ImVec2(p.x + (size.x - textSize.x) / 2, p.y + (size.y - textSize.y) / 2)

        imgui.Dummy(size)
        dl::AddRectFilled(p, p + size, imgui.ColorConvertFloat4ToU32(this.color), rounding)
        dl::AddRect(p, p + size, imgui.ColorConvertFloat4ToU32(colors[true]), rounding, nil, 1)
   
        if this.color.w <= 0.5 {
            dl::AddText(imgui.ImVec2(textPos.x + 1, textPos.y + 1), 0xFF000000, text)
            dl::AddText(imgui.ImVec2(textPos.x - 1, textPos.y - 1), 0xFF000000, text)
            dl::AddText(imgui.ImVec2(textPos.x + 1, textPos.y - 1), 0xFF000000, text)
            dl::AddText(imgui.ImVec2(textPos.x - 1, textPos.y + 1), 0xFF000000, text)
        }

        dl::AddText(textPos, -1, text)
    }
}

method animations::toggleButton(label, state, size = imgui.ImVec2(40, 20), duration = 0.3, colors = {
    enabled     = imgui.GetStyle().Colors[imgui.Col.FrameBgActive],
    disabled    = imgui.GetStyle().Colors[imgui.Col.FrameBg]
}) {
    local p         = imgui.GetCursorScreenPos()
    local dl        = imgui.GetWindowDrawList()
    local text      = string.gsub(label, "##.*$", "")
    local textSize  = imgui.CalcTextSize(title)
    local radius    = 6
    local result    = false
    local o         = {
        x = 4,
        y = p.y + (size.y / 2)
    }

    local alpha     = imgui.GetStyle().Alpha
    colors.enabled  = imgui.ImVec4($.x, $.y, $.z, alpha)
    colors.disabled = imgui.ImVec4($.x, $.y, $.z, alpha)

    local a = imgui.ImVec2(p.x + radius + o.x, o.y)
    local b = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)
    
    if !UI_TOGGLE_BUTTON {
        global UI_TOGGLE_BUTTON = {}
    }

    if local this = UI_TOGGLE_BUTTON[label] {
        imgui.BeginGroup()
            local pos   = imgui.GetCursorPos()
            result      = imgui.InvisibleButton(label, size)
            
            if result {
                state[0], this.clock = !$, os.clock()
            }

            if #text > 0 {
                imgui.SetCursorPos(pos + imgui.ImVec2(size.x + imgui.GetStyle().ItemSpacing.x, (size.y - textSize.y) / 2))
                imgui.Text(text)
            }
        imgui.EndGroup()

        if this.clock && os.clock() - this.clock <= duration {
            this.color  = imguiAssets::bringVec4To($, colors[(state[0]) ? "enabled" : "disabled"], this.clock, duration)
            this.pos    = imguiAssets::bringVec2To($, (state[0]) ? b : a, this.clock, duration)
        } else {
            this.color  = colors[(state[0]) ? "enabled" : "disabled"]
            this.pos    = (state[0]) ? b : a 
        }

        dl::AddRect(p, p + size, imgui.ColorConvertFloat4ToU32(this.color), 10, 15, 1)
        dl::AddCircleFilled(this.pos, radius, imgui.ColorConvertFloat4ToU32(this.color), 0xFF)
    } else {
        UI_TOGGLE_BUTTON[label] = {
            clock   = nil,
            color   = colors[(state[0]) ? "enabled" : "disaabled"],
            pos     = (state[0]) ? b : a
        }
    }

    return result
}

method animations::clickableUnderlinedText(label, state = false, duration = { 0.5, 0.3 }, colors = {
    idle        = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
    hovered     = imgui.GetStyle().Colors[imgui.Col.Text],
    selected    = imgui.GetStyle().Colors[imgui.Col.Text]
}) {
    local dl        = imgui.GetWindowDrawList()
    local id        = label
    local label     = string.gsub($, "##.*$", "")
    local result    = false

    if !UI_CLICKABLE_UNDERLINED_TEXT {
        global UI_CLICKABLE_UNDERLINED_TEXT = {}
    }

    if local this = UI_CLICKABLE_UNDERLINED_TEXT[id] {
        imgui.BeginGroup()
            local pos, p = imgui.GetCursorPos(), imgui.GetCursorScreenPos()
            
            imgui.TextColored(this.color, label)

            local s = imgui.GetItemRectSize()
            local hovered, clicked = imgui.IsItemHovered(), imgui.IsItemClicked()

            if this.hovered.state != hovered && !state {
                this.hovered.state = hovered
                this.hovered.clock = os.clock()
            }

            if clicked {
                this.clock = os.clock()
                result = true
            }

            if os.clock() - this.clock <= duration[1] {
                this.color = imguiAssets::bringVec4To(
                    $,
                    (state) ? colors.selected : ((hovered) ? colors.hovered : colors.idle),
                    this.clock,
                    duration[1]
                )
            } else {
                this.color = (state) ? colors.selected : ((hovered) ? colors.hovered : colors.idle)
            }

            if this.hovered.clock {
                if os.clock() - this.hovered.clock <= duration[2] {
                    this.hovered.alpha = imguiAssets::bringFloatTo(
                        $,
                        (this.hovered.state) ? 1.00 : 0.00,
                        this.hovered.clock,
                        duration[2]
                    )
                } else {
                    this.hovered.alpha = (this.hovered.state) ? 1.00 : 0.00
                    if !this.hovered.state {
                        this.hovered.clock = nil
                    }
                }

                local max, y = s.x / 2, p.y + s.y + 3
                local mid = p.x + max
                local color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(
                    this.color.x,
                    this.color.y,
                    this.color.z,
                    (this.hovered.state) ? imgui.GetStyle().Alpha : this.hovered.alpha
                ))

                dl::AddLine(imgui.ImVec2(mid, y), imgui.ImVec2(mid + (max * this.hovered.alpha), y), color, 3)
                dl::AddLine(imgui.ImVec2(mid, y), imgui.ImVec2(mid - (max * this.hovered.alpha), y), color, 3)
            }
        imgui.EndGroup()
    } else {
        UI_CLICKABLE_UNDERLINED_TEXT[id] = {
            color = (state) ? colors.selected : colors.idle,
            clock = os.clock() + duration[1],
            hovered = {
                state = state,
                alpha = (state) ? 1.00 : 0.00,
                clock = os.clock() + duration[2]
            }
        }
    }

    return result
}

return animations
