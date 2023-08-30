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
@import "StyleChanger"  => StyleChanger
@import "imgui.Assets"  => imguiAssets
@import "Assets"        => assets

global enum {
    AUTOUPDATE_RESPONSE_WAITING,
    AUTOUPDATE_RESPONSE_OK,
    AUTOUPDATE_RESPONSE_BAD
}

local handler   = require("xmlhandler.tree")
local imguiData = {
    window = imgui.new.bool(),
    response = AUTOUPDATE_RESPONSE_WAITING,
    xml = {
        title = "",
        body = "",
        buttons = {
            first = "",
            second = ""
        }
    }
}

/**
 * Merge two tables into one.
 *
 * @param first table
 * @param second table
 * @return table
 */
local fn mergeTables(first, second) {
    for key, value of second {
        if type(value) == "table" && type(first[key] || false) == "table" {
            mergeTables(first[key], second[key])
        } else {
            first[key] = value
        }
    }
    return first
}

/**
 * Merges two JSON strings into a single file.
 *
 * @param file string   The file where the merged JSON string will be written.
 * @param first string  JSON
 * @param second string JSON
 * @return void
 */
local fn mergeJson(file, first, second) {
    if doesFileExist(src) {
        first, second = decodeJson(first), decodeJson(second)
        common::writeInFile(neatJSON(mergeTables(first, second), { sort = true, wrap = 40 }))
        @ifdef __GADMIN_DEBUG__ { $debugSuccessful!("AutoUpdate->mergeJson", file .. " | " .. first .. " | " .. second) }
    } else {
        @ifdef __GADMIN_DEBUG__ { $debugError!("AutoUpdate->mergeJson", file .. " doesn't exist!") }
    }
}

imgui.OnFrame(fn { return imguiData.window[0] }, fn(self) {
    self.flags = imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize
    self.style = StyleChanger::new({
        WindowPadding           = { new = imgui.ImVec2(10, 10), old = imgui.ImVec2(5, 5) },
        WindowBorderSize        = { new = 0, old = 1 },
        ChildBorderSize         = { new = 0, old = 1 },
        FrameBorderSize         = { new = 0, old = 1 },
        WindowRounding          = { new = 10, old = 5 },
        WindowBg                = { new = "222222", old = imgui.ImVec4(0.07, 0.07, 0.07, 1.00) },
        ScrollbarBg             = { new = "222222", old = imgui.ImVec4(0.12, 0.12, 0.12, 1.00) },
        ScrollbarGrab           = { new = "5B5B5B", old = imgui.ImVec4(0.00, 0.00, 0.00, 1.00) },
        ScrollbarGrabHovered    = { new = "838383", old = imgui.ImVec4(0.41, 0.41, 0.41, 1.00) },
        ScrollbarGrabActive     = { new = "424242", old = imgui.ImVec4(0.51, 0.51, 0.51, 1.00) },
        ChildBg                 = { new = "22222200", old = imgui.ImVec4(0.07, 0.07, 0.07, 1.00) },
        Button                  = { new = "5B5B5B", old = imgui.ImVec4(0.12, 0.12, 0.12, 1.00) },
        ButtonHovered           = { new = "838383", old = imgui.ImVec4(0.21, 0.20, 0.20, 1.00) },
        ButtonActive            = { new = "424242", old = imgui.ImVec4(0.41, 0.41, 0.41, 1.00) }
    })

    self.closeButtonStyle = StyleChanger::new({
        FrameRounding = { new = 6, reset = 5 }
    })

    local fn closeWindowWithResponse(response = AUTOUPDATE_RESPONSE_BAD) {
        imguiData.response, imguiData.window[0] = response, false
    }

    local sizeX, sizeY = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(600, 350))
    self.style::apply()
    
    imgui.Begin("gadmin.window.autoUpdate", imguiData.window, self.flags)
        imgui.BeginGroup(/* Header */)
            imguiAssets::textWithFont(imguiData.xml.title, bold15, nil)
            imgui.SameLine(555)
            self.closeButtonStyle::apply()
                if imgui.Button("", imgui.ImVec2(25, 25)) { closeWindowWithResponse() }
            self.closeButtonStyle::reset()
            // We can't just put the text in the button, because it just goes down with this font.
            // You can change the position through the style, but for some reason Y cannot be changed
            // (nothing will occur on change). Therefore, you have to display the text like this.
            imguiAssets::textWithFont("x", bold25, imgui.ImVec2(571, 3.5))
        imgui.EndGroup(/* Header */)
        imgui.SetCursorPosY(50)
        imgui.BeginChild("autoUpdate.child.body", imgui.ImVec2(0, 254), false)
            for line with string.gmatch(imguiData.xml.body, "[^\n]+") {
                line = string.match(line, "^%s*(.*)$")
                if string.find(line, "<header>.*</header>") {
                    imguiAssets::textWithFont(string.match(line, "<header>(.*)</header>"), bold14)
                } elseif string.find(line, "<newline.*") {
                    imgui.NewLine()
                } else {
                    imguiAssets::textWithFont(line, regular14)
                }
            }
        imgui.EndChild()
        imgui.BeginGroup(/* Footer */)
            imgui.PushFont(regular9)
                if imgui.Button(imguiData.xml.buttons.first, imgui.ImVec2(287.5, 25)) {
                    closeWindowWithResponse(AUTOUPDATE_RESPONSE_OK)
                }
                imgui.SameLine()
                if imgui.Button(imguiData.xml.buttons.second, imgui.ImVec2(287.5, 25)) {
                    self.closeWindowWithResponse()
                }
            imgui.PopFont()
        imgui.EndGroup()
    imgui.End()

    self.style::reset()
})

local autoUpdate = {}

/**
 * TODO: documentation for this
 */
autoUpdate.init = fn(url, XMLPath, onReadyCallback, afterDownloadCallback) {
    local downloadStatus    = require("moonloader").download_status
    local callbacks         = {}
    local content

    /**
     * TODO: documentation for this
     */
    method callbacks::download() {
        @ifdef __GADMIN_DEBUG__ { $debugInformation!("autoUpdate.init->callbacks::download", "start merging JSON file(s)") }

        if #handler.root.AutoUpdate.merge.json > 1 {
            local this = handler.root.AutoUpdate.merge.json
            for _, json in this {
                local src   = getWorkingDirectory() .. "\\" .. json._attr.src
                local value = json[1]
                mergeJson(src, getFileContent(src), value)
            }
        } elseif #handler.root.AutoUpdate.merge.json == 1 {
            local this  = handler.root.AutoUpdate.merge.json
            local src   = getWorkingDirectory() .. "\\" .. this._attr.src
            local value = this[1]
            mergeJson(src, getFileContent(src), value)
        }

        @ifdef __GADMIN_DEBUG__ { $debugInformation!("autoUpdate.init->callbacks::download", "start downloading file(s)") }
        if #handler.root.AutoUpdate.links.link > 1 {
            local files = {}
            for _, link in handler.root.AutoUpdate.links.link {
                local destination = getWorkingDirectory() .. "\\" .. link._attr.destination
                local url = link[1]

                @ifdef __GADMIN_DEBUG__ {
                    $debugInformation!("autoUpdate.init->callbacks::download", "inserting in files: destination = "
                        .. destination .. " | url = " .. url)
                }

                table.insert(files, {
                    destination = destination,
                    url = url
                })
            }
            assets::downloadFiles(files, afterDownloadCallback)
        } elseif #handler.root.AutoUpdate.links.link == 1 {
            local this = handler.root.AutoUpdate.links.link
            assets::downloadFiles({{
                destination = getWorkingDirectory() .. "\\" .. this._attr.destination,
                url = this[1]
            }}, afterDownloadCallback)
        }
        
        @ifdef __GADMIN_DEBUG__ { $debugInformation!("autoUpdate.init->callbacks::download", "done.") }
    }

    method callbacks::getVersion() {
        return handler.root.AutoUpdate._attr.version
    }

    downloadUrlToFile(url, XMLPath, fn(id, status, p1, p2) {
        if status == downloadStatus.STATUS_ENDDOWNLOADDATA {
            content = xml2lua.loadFile(XMLPath)

            local parser = xml2lua.parser(handler)
            local success, result = pcall(parser.parse, parser, content)
            if !success {
                @ifdef __GADMIN_DEBUG__ {
                    $debugWarning!("xml2lua in autoUpdate.init", result)
                }
                imguiData.response = AUTOUPDATE_RESPONSE_BAD
            } else {
                imguiData.xml.body              = string.match(content, "<body>%s*(.*)%s*</body>")
                imguiData.xml.title             = handler.root.AutoUpdate.title
                imguiData.xml.buttons.first     = handler.root.AutoUpdate.buttons._attr.first
                imguiData.xml.buttons.second    = handler.root.AutoUpdate.buttons._attr.second
                imguiData.window[0]             = true

                @ifdef __GADMIN_DEBUG__ { 
                    $debugSuccessful!("autoUpdate.init", "window is called. awaiting response from user.")
                }

                lua_thread.create(fn {
                    while true {
                        wait(0)
                        if imguiData.response == AUTOUPDATE_RESPONSE_OK {
                            onReadyCallback(callbacks)
                            break
                        } elseif imguiData.response == AUTOUPDATE_RESPONSE_BAD {
                            break
                        }
                    }
                })
            }
        }
    })
}

return autoUpdate
