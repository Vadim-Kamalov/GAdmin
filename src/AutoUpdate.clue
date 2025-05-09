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

@import "Common"    => common
@import "Assets"    => assets
@import "Config"    => config
@import "Requests"  => requests

@import "imgui.Assets" => imguiAssets

static enum /* AUTOUPDATE_RESPONSE */ {
    AUTOUPDATE_RESPONSE_WAITING,
    AUTOUPDATE_RESPONSE_OK,
    AUTOUPDATE_RESPONSE_BAD
}

static __autoUpdate__ = {
    imgui = {
        title   = "",
        version = "",
        body    = "",
        buttons = {
            first   = "",
            second  = "",
            third   = ""
        }
    },
    
    windowState = false,
    handler     = require("xmlhandler.tree"),
    response    = AUTOUPDATE_RESPONE_WAITING,
    config      = nil
}

/**
 * Update script with settings that passed in AutoUpdate.xml. **Must** called after `autoUpdate::checkUpdates(url)`!
 * @return void
 */
method __autoUpdate__::update() {
    local fn downloadCallback() {
        local mustReloadScript                      = true
        config.root.autoUpdate.hasUpdateInstalled   = true

        for _, luaScript in script.list() {
            //! Compatible with a script that reloads each script when it changes.
            if luaScript.name == "ML-AutoReboot" {
                mustReloadScript = false
                break
            }
        }

        if mustReloadScript {
            lua_thread.create(fn {
                wait(5000) // to prevent possible `error in error handling` error message.
                script.this::reload()
            })
        }
    }

    if #self.handler.root.AutoUpdate.links.link > 1 {
        local files = {}

        for _, link in self.handler.root.AutoUpdate.links.link {
            local destination   = getWorkingDirectory() .. "\\" .. link._attr.destination
            local url           = link[1]

            table.insert(files, {
                url         = url,
                destination = destination
            })
        }

        assets::downloadFileList(files, downloadCallback)
    } elseif #self.handler.root.AutoUpdate.links.link == 1 {
        local this = self.handler.root.AutoUpdate.links.link
        assets::downloadFileList({{
            url         = this[1],
            destination = getWorkingDirectory() .. "\\" .. this._attr.destination
        }}, downloadCallback)
    }
}

/**
 * Check script updates. If there is any update - will called ImGui window, where user can
 * choose: download, skip version, close window. If user choosed `download`, will called `autoUpdate::download()`.
 *
 * @param url string $AUTOUPDATE_URL
 * @return void
 */
method __autoUpdate__::checkUpdates(url) {
    if config.root.autoUpdate.hasUpdateInstalled {
        config.root.autoUpdate.hasUpdateInstalled = false
        return
    }

    lua_thread.create(fn {
        requests::asyncHttpRequest("GET", url, nil, fn (response) {
            if response.status_code == 200 {
                try {
                    self.handler = assets::copyTable(require("xmlhandler.tree"))
                    local parser = xml2lua.parser(self.handler)

                    parser::parse(response.text)

                    if self.handler.root.AutoUpdate._attr.version != $GADMIN_VERSION 
                        && config.root.autoUpdate.skipVersionUpdate != self.handler.root.AutoUpdate._attr.version
                    {
                        self.imgui.body             = string.match(response.text, "<body>%s*(.*)%s*</body>")
                        self.imgui.title            = self.handler.root.AutoUpdate.title
                        self.imgui.version          = self.handler.root.AutoUpdate._attr.version
                        self.imgui.buttons.first    = self.handler.root.AutoUpdate.buttons._attr.first
                        self.imgui.buttons.second   = self.handler.root.AutoUpdate.buttons._attr.second
                        self.imgui.buttons.third    = self.handler.root.AutoUpdate.buttons._attr.third
                        self.windowState            = true
                        
                        imguiAssets::setCursorStatus(false)
@ifdef __GADMIN_DEBUG__
{ 
                        $debugSuccessful!("autoUpdate.init", "window is called. awaiting response from user.")
}
                    }
                } catch err {
                    self.response = AUTOUPDATE_RESPONSE_BAD
@ifdef __GADMIN_DEBUG__
{
                    $debugWarning!("xml2lua.parser(self.handler)", err)
}
                }
            } else {
                $debugWarning!("autoUpdate::checkUpdates", "failed to fetch " .. url .. ", response.status_code = " .. response.status_code)
            }
        }, fn (error) {
            $debugWarning!("autoUpdate::checkUpdates", "failed to fetch " .. url .. ", error = ")
            $debugWarning!("autoUpdate::checkUpdates", error)
        })
    })
}

/**
 * Render XML elements that listed below:
 *  <quote> ... </quote>, <ul> ... </ul>, <code> ... </code>,
 *  <b> ... </b>, <link> ... </link>, <header> ... </header>, <br/>, <newline/>
 *
 * Notice that `<br/>` (break line) is only available in `quote`, `ul`,
 * `code`, `b`, `link` and `header` elements.
 *
 * `<newline/>` is purposed to use **only** outside of this elements: in `body` section.
 *
 * @param text string
 * @return void
 */
method __autoUpdate__::renderXMLGroup(text) {
    local fn renderLine(line, type) {
        local index  = 1
        local parsed = {}
        local buffer = ""

        while #line >= index {
            local char = string.sub(line, index, index)
            if char == "<" {
                if #buffer > 0 {
                    table.insert(parsed, { tag = "plain-text", body = buffer })
                    buffer = ""
                }

                if local element, tag, body = string.match(string.sub(line, index), "^(<(%w+)>(.*)</%2>)") {
                    table.insert(parsed, { tag = tag, body = body })
                    index += #element
                } elseif local element, tag = string.match(string.sub(line, index), "^(<(%w+)/>)") {
                    table.insert(parsed, { tag = tag, body = "none" })
                    index += #element - 1
                }
            } else {
                buffer ..= char      
            }
            index += 1
        }

        if #buffer > 0 {
            table.insert(parsed, { tag = "plain-text", body = buffer })
        }

        imgui.PushTextWrapPos(imgui.GetWindowWidth())
        imgui.BeginGroup()
            for index, item in parsed {
                item.body = string.match($, "^%s*(.-)%s*$")

                match item.tag {
                    "b" => {
                        imgui.PushFont((type == "header") ? bold14 : bold12)
                            imgui.Text(item.body)
                        imgui.PopFont()
                    }

                    "plain-text" => {
                        imgui.Text(item.body)
                    }

                    "code" => {
                        if imgui.GetCursorPos().x == 0 {
                            imgui.SetCursorPos(imgui.GetCursorPos() + imgui.ImVec2(2, 2))
                        }

                        imgui.BeginGroup()
                            local pos     = imgui.GetCursorScreenPos()
                            local size    = imgui.CalcTextSize(item.body)
                            local padding = imgui.ImVec2(2, 2)

                            imgui.GetWindowDrawList()::AddRectFilled(
                                pos - padding,
                                pos + size + padding,
                                imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg]),
                                imgui.GetStyle().FrameRounding
                            )

                            imgui.Text(item.body)
                        imgui.EndGroup()
                    }

                    "link" => {
                        imgui.Text(item.body)
                        imguiAssets::setPreviousItemAbleToCopy(item.body)
                    }

                    "br" => {
                        imgui.NewLine()
                    }
                }

                if #parsed >= 2 && index != #parsed && item.tag != "br" {
                    imgui.SameLine(nil, 5)
                }
            }
        imgui.EndGroup()
        imgui.PopTextWrapPos()
    }

    for line with string.gmatch(text, "[^\n\r]+") {
        line = string.match(line, "^%s*(.*)")
        if local tag, body = string.match(line, "^<(%w+)>(.*)</%1>$") {
            match tag {
                "header" => {
                    imgui.PushFont(bold14)
                        renderLine(body, tag)
                    imgui.PopFont()
                }

                "ul" /* unordered list */ => {
                    imgui.PushFont(regular12)
                        local pos = imgui.GetCursorPos()
                        imgui.Bullet()
                        imgui.SetCursorPosY(pos.y - 1)
                        renderLine(body, tag)
                    imgui.PopFont()
                }

                "quote" => {
                    imgui.BeginGroup()
                        local cursor       = imgui.GetCursorPos()
                        local screenCursor = imgui.GetCursorScreenPos()

                        imgui.SetCursorPos(imgui.ImVec2(cursor.x + 10, cursor.y))
                        imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                            imgui.PushFont(regular12)
                                renderLine(body, tag)
                            imgui.PopFont()
                        imgui.PopStyleColor()

                        imgui.GetWindowDrawList()::AddRectFilled(
                            screenCursor,
                            imgui.ImVec2(screenCursor.x + 3, imgui.GetItemRectMax().y),
                            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TextDisabled])
                        )
                    imgui.EndGroup()
                }
            }
        } elseif string.find(line, "^<newline.+") {
            imgui.NewLine()
        } else {
            imgui.PushFont(regular12)
                renderLine(line)
            imgui.PopFont()
        }
    }
}

return __autoUpdate__
