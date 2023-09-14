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

@import "Common"        => common
@import "imgui.Assets"  => imguiAssets

local animations = {}

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
        def     = common::convertHex2ImVec4("5B5B5B"),
        hovered = common::convertHex2ImVec4("FFFFFF")
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
	local result    = false
	local rounding  = imgui.GetStyle().FrameRounding
   
    local fn limit(v, min = 0.0, max = 1.0) {
        return (v < min) ? min : ((v > max) ? max : v)
    }

    if !UI_ANIMATED_BUTTON {
        global UI_ANIMATED_BUTTON = {}
    }

	if !UI_ANIMATED_BUTTON[label] {
		UI_ANIMATED_BUTTON[label] = {
			radius  = 0
			clock   = {0, 0}
			pos     = nil
			size    = nil
			hovered = {
				state   = false
				before  = nil
				clock   = 0
				color   = colors.hovered
			}
		}
    }

	local this      = UI_ANIMATED_BUTTON[label]
    local label     = string.gsub(label, "##.*$", "")
	local textSize  = imgui.CalcTextSize(label)
    local p         = imgui.GetCursorScreenPos()
	
    if !size {
		local padding   = imgui.GetStyle().FramePadding
		size            = imgui.ImVec2(textSize.x + (padding.x * 2), textSize.y + (padding.y * 2))
    }

	if this.size {
        this.hovered.color = match this.hovered.state {
            true    => imguiAssets::bringVec4To($, colors.hovered, this.hovered.clock, duration[3]),
            false   => imguiAssets::bringVec4To($, colors.active, this.hovered.clock, duration[3]) 
        }

		imgui.GetWindowDrawList()::AddRect(
			p,
			imgui.ImVec2(p.x + this.size.x, p.y + this.size.y),
			imgui.ColorConvertFloat4ToU32(this.hovered.color),
			rounding,
			onHoveredFlags
		)
    }

	imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, rounding)
	imgui.PushStyleColor(imgui.Col.ChildBg, colors.def)
	    local pos = imgui.GetCursorPos()
	    imgui.SetCursorPos(imgui.ImVec2(pos.x + 1, pos.y + 1))
	    imgui.BeginChild(label .. ":UIANIMATEDBUTTON", imgui.ImVec2(size.x - 2, size.y - 2), false)
		    local dl = imgui.GetWindowDrawList()
		    if this.pos {
			    local alpha = 0.00

			    local timer = os.clock() - this.clock[2]
			    if timer <= duration[2] {
				    alpha = limit(1.00 - ((1.00 / duration[2]) * timer), 0.0, 1.0)
                }

			    local timer = os.clock() - this.clock[1]
			    if timer <= duration[1] {
				    alpha       = limit((1.00 / duration[1]) * timer, 0.0, 1.0)
				    this.radius = (size.x * 1.5 / duration[1]) * timer
                }

			    local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
			    dl::AddCircleFilled(
				    this.pos, 
				    this.radius, 
				    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(col.x, col.y, col.z, alpha)), 
				    64
			    )

			    local a, b = p, imgui.ImVec2(p.x + this.size.x, p.y + this.size.y)
			    local color = imgui.ColorConvertFloat4ToU32(colors.window)
	            dl::PathLineTo(a)
	            dl::PathArcTo(imgui.ImVec2(a.x + rounding, a.y + rounding), rounding, -3.0, -1.500)
	            dl::PathFillConvex(color)

	            dl::PathLineTo(imgui.ImVec2(b.x, a.y))
	            dl::PathArcTo(imgui.ImVec2(b.x - rounding, a.y + rounding), rounding, -1.5, -0.205)
	            dl::PathFillConvex(color)

	            dl::PathLineTo(imgui.ImVec2(b.x, b.y))
	            dl::PathArcTo(imgui.ImVec2(b.x - rounding, b.y - rounding), rounding, 1.5, 0.205)
	            dl::PathFillConvex(color)

	            dl::PathLineTo(imgui.ImVec2(a.x, b.y))


			    if alpha <= 0 { this.pos = nil }
            }

		    local ws, al = imgui.GetWindowSize(), imgui.GetStyle().ButtonTextAlign
		    imgui.SetCursorPos(imgui.ImVec2((ws.x - textSize.x) * al.x, (ws.y - textSize.y) * al.y))
		    imgui.TextUnformatted(label)
	    imgui.EndChild()
	imgui.PopStyleColor()
	imgui.PopStyleVar()

	local size          = imgui.GetItemRectSize()
	this.size           = imgui.ImVec2(size.x + 2, size.y + 2)
	this.hovered.state  = imgui.IsItemHovered() || os.clock() - this.clock[2] < 0
	if this.hovered.state != this.hovered.before {
		this.hovered.before = this.hovered.state
		this.hovered.clock  = os.clock()
    }

	if imgui.IsItemClicked() {
		this.radius     = 0
		this.pos        = imgui.GetMousePos()
		this.clock      = { os.clock(), os.clock() + duration[1] }
		result          = true
    }

	return result
}

return animations
