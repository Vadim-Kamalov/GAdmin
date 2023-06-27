--[[
    GAdmin - Script for administators on gambit-rp.ru
    Copyright (C) 2023 The Contributors*.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    * You can find the contributors of the GAdmin project in the < CONTRIBUTORS > file.
]]--

local xml2lua       = require("xml2lua")
local handler       = require("xmlhandler.tree")
local imgui         = require("mimgui")
local neatJSON      = require("neatjson")

AUTOUPDATE_RESPONSE_WAITING = 1
AUTOUPDATE_RESPONSE_OK      = 2
AUTOUPDATE_RESPONSE_BAD     = 3

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
    },
}

---@param first table
---@param second table
---@return table
local function mergeTables(first, second)
    for key, value in pairs(second) do
        if (type(value) == "table") and (type(first[key] or false) == "table") then
            mergeTables(first[key], second[key])
        else
            first[key] = value
        end
    end
    return first
end

---@param src string
---@return string
local function getFileContent(src)
    local handle    = io.open(src, "r")
    local content   = handle:read("*all")
    handle:close()
    return content
end

--- Combines two JSON strings into one file.
---
---@param src string (path)
---@param first string
---@param second string
local function mergeJsonInFile(src, first, second)
    if doesFileExist(src) then
        local handle                = io.open(src, "w")
        local parsedTableFromXML    = decodeJson(first)
        local parsedTableFromHandle = decodeJson(second)
        local mergedTable           = mergeTables(parsedTableFromXML, parsedTableFromHandle)
        local finalJSON             = neatJSON(mergeTable, {sort = true, wrap = 40})

        print("[AutoUpdate.lua] Successfully written file to path " .. src)
        handle:write(finalJSON)
        handle:close()
    else
        print("[AutoUpdate.lua] File on path " .. src .. " does not exist.")
        print("[AutoUpdate.lua]", src, value)
    end
end

imgui.OnFrame(
    function() return imguiData.window[0] end,
    function(self)
        self.windowFlags       = imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize
        self.windowProperties  = {
            {"ImVec2", "WindowPadding", change = {10, 10}, reset = {5, 5}},
            {"Int", "WindowBorderSize", change = 0, reset = 1},
            {"Int", "ChildBorderSize", change = 0, reset = 1},
            {"Int", "FrameBorderSize", change = 0, reset = 1},
            {"Int", "WindowRounding", change = 10, reset = 5},
            {"ImVec4", "WindowBg", change = convertHex2ImVec4("222222"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "ScrollbarBg", change = convertHex2ImVec4("222222"), reset = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)},
            {"ImVec4", "ScrollbarGrab", change = convertHex2ImVec4("5B5B5B"), reset = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)},
            {"ImVec4", "ScrollbarGrabHovered", change = convertHex2ImVec4("838383"), reset = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)},
            {"ImVec4", "ScrollbarGrabActive", change = convertHex2ImVec4("424242"), reset = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)},
            {"ImVec4", "ChildBg", change = convertHex2ImVec4("222222", 0), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "Button", change = convertHex2ImVec4("5B5B5B"), reset = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)},
            {"ImVec4", "ButtonHovered", change = convertHex2ImVec4("838383"), reset = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)},
            {"ImVec4", "ButtonActive", change = convertHex2ImVec4("424242"), reset = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)}
        }

        self.closeButtonProperties = {
            {"Int", "FrameRounding", change = 6, reset = 5}
        }

        self.closeWindowWithResponse = function(response)
            imguiData.response = response or AUTOUPDATE_RESPONSE_BAD
            imguiData.window[0] = false
        end

        local sizeX, sizeY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 350))
        changeTheme:applySettings(self.windowProperties)

        imgui.Begin("AutoUpdate window", imguiData.window, self.windowFlags)
            imgui.BeginGroup(--[[ Header ]])
                textWithFont(imguiData.xml.title, bold15, nil)
                imgui.SameLine(555)
                changeTheme:applySettings(self.closeButtonProperties)
                    if imgui.Button("", imgui.ImVec2(25, 25)) then
                        self.closeWindowWithResponse()
                    end
                changeTheme:resetDefault(self.closeButtonProperties)
                -- We can't just put the text in the button, because it just goes down with this font.
                -- You can change the position through the style, but for some reason Y cannot be changed
                -- (nothing will occur on change). Therefore, you have to display the text like this.
                textWithFont("x", bold25, imgui.ImVec2(571, 3.5))
            imgui.EndGroup(--[[ Header ]])
            imgui.SetCursorPosY(50)
            imgui.BeginChild("AUTOUPDATE_BODY", imgui.ImVec2(0, 254), false)
                for line in string.gmatch(imguiData.xml.body, "[^\n]+") do
                    line = string.match(line, "^%s*(.*)$")
                    if string.find(line, "<header>.*</header>") then
                        textWithFont(string.match(line, "<header>(.*)</header>"), bold14)
                    elseif string.find(line, "<newline.*") then
                        imgui.NewLine()
                    else
                        textWithFont(line, regular14)
                    end
                end
            imgui.EndChild()
            imgui.SetCursorPosY(315)
            imgui.BeginGroup(--[[ Footer ]])
                imgui.PushFont(regular9)
                    if imgui.Button(imguiData.xml.buttons.first, imgui.ImVec2(287.5, 25)) then
                        self.closeWindowWithResponse(AUTOUPDATE_RESPONSE_OK)
                    end
                    imgui.SameLine()
                    if imgui.Button(imguiData.xml.buttons.second, imgui.ImVec2(287.5, 25)) then
                        self.closeWindowWithResponse()
                    end
                imgui.PopFont()
            imgui.EndGroup()
        imgui.End()

        changeTheme:resetDefault(self.windowProperties)
    end
)

module = { _VERSION = "0.2" }

---@param url string                        URL to AutoUpdate.xml file.
---@param XMLPath string                    Path where the file from @param url will be installed. The file is NOT DELETED after
---                                         completion of work with it.
---@param onReadyCallback function          Function that is executed after successful loading of @param url.
---                                         The `callback` table is passed as an argument. which has
---                                         functions: `callback:download()` and `callback:getVersion()`.
---@param afterDownloadCallback function    Function that is executed after all files from AutoUpdate.xml have been successfully downloaded.
---@return void
---@author DZONE
module.init = function(url, XMLPath, onReadyCallback, afterDownloadCallback)
    local downloadStatus    = require("moonloader").download_status
    local callbacks         = {}
    local content           = nil

    --- **Since 0.1**
    ---
    --- Loads all <link destination="...">...</link> from AutoUpdate.xml.
    --- If the number of <linK> == 1 then only one will be downloaded. Otherwise, everything will be installed.
    --- `destination="..."` means the path where the file will be loaded from the working directory.
    --- `<link>...</link>` means the url of the file.
    ---
    --- **Since 0.2**
    ---
    --- Now you can merge JSON files from `<merge><json src="...">...</json>...</merge>`.
    --- Note that there can be only one `<merge>` tag, and <json> can only be in `<merge>`
    --- and its quantity is unlimited. The `src="..."` attribute means the path from the working directory.
    ---
    ---@return void
    function callbacks:download()
        print("[AutoUpdate.lua] Start merging JSON file(s)")
        if #handler.root.AutoUpdate.merge.json > 1 then
            local this = handler.root.AutoUpdate.merge.json
            for _, json in ipairs(this) do
                local src   = getWorkingDirectory() .. "\\" .. json._attr.src
                local value = json[1]
                mergeJsonInFile(src, getFileContent(src), value)
            end
        else
            local this  = handler.root.AutoUpdate.merge.json
            local src   = getWorkingDirectory() .. "\\" .. this._attr.src
            local value = this[1]
            mergeJsonInFile(src, getFileContent(src), value)
        end

        print("[AutoUpdate.lua] Start downloading file(s)")

        if #handler.root.AutoUpdate.links.link > 1 then
            local this  = handler.root.AutoUpdate.links.link
            local total = {}
            local time  = os.clock()
            for _, link in ipairs(this) do
                local destination   = getWorkingDirectory() .. "\\" .. link._attr.destination
                local scriptUrl     = link[1]
                local downloaded    = false
                lua_thread.create(function()
                    wait(1000) -- We need to add delay to avoid the "device or resource busy: device or resource busy" error.
                    downloadUrlToFile(scriptUrl, destination, function(id, status, p1, p2)
                        if status == downloadStatus.STATUS_ENDDOWNLOADDATA then
                            sampAddChatMessage("Успешно загружен файл \"" .. destination .. "\". Загрузка следующего через секунду.", -1)
                            print("[AutoUpdate.lua] File on path \"" .. destination .. "\" loaded!")
                            table.insert(total, 0)
                        else
                            print("[AutoUpdate.lua] Loading file from path \"" .. destination .. "\". Remaining " .. string.format("%d of %d.", p1, p2))
                        end
                    end)
                end)
                lua_thread.create(function()
                    while true do
                        wait(0)
                        if #this == #total then
                            afterDownloadCallback()
                            print("[AutoUpdate.lua] afterDownloadCallback called.")
                            break
                        else
                            if os.clock() - time >= 120 then
                                sampAddChatMessage("Что-то пошло не так, обновление не загружено.", -1)
                                print("[AutoUpdate.lua] 120 seconds have passed since all files started downloading. afterDownloadCallback will not be called.")
                                break
                            end
                        end
                    end
                end)
            end
        elseif #handler.root.AutoUpdate.links.link == 1 then
            local this          = handler.root.AutoUpdate.links.link
            local destination   = getWorkingDirectory() .. "\\" .. this._attr.destination
            local scriptUrl     = this[1]
            lua_thread.create(function()
                wait(1000)
                downloadUrlToFile(scriptUrl, destination, function(id, status, p1, p2)
                    if status == downloadStatus.STATUS_ENDDOWNLOADDATA then
                        sampAddChatMessage("Успешно загружен файл \"" .. destination .. "\".", -1)
                        print("[AutoUpdate.lua] File on path \"" .. destination .. "\" loaded!")
                    else
                        print("[AutoUpdate.lua] Loading file from path \"" .. destination .. "\". Remaining " .. string.format("%d of %d.", p1, p2))
                    end
                end)
            end)
        end
        print("[AutoUpdate.lua] callback:download() completed his work.")
    end

    function callbacks:getVersion()
        return handler.root.AutoUpdate._attr.version
    end

    downloadUrlToFile(url, XMLPath, function(id, status, p1, p2)
        if status == downloadStatus.STATUS_ENDDOWNLOADDATA then
            content = xml2lua.loadFile(XMLPath)

            local parser = xml2lua.parser(handler)
            local success, result = pcall(parser.parse, parser, content)
            if not success then
                print("[AutoUpdate.lua] Got error from xml2lua module: " .. result)
                print("[AutoUpdate.lua] Why? Most likely due to incorrect url to AutoUpdate.xml.")
                imguiData.response = AUTOUPDATE_RESPONSE_BAD
            else
                imguiData.xml.body              = string.match(content, "<body>%s*(.*)%s*</body>")
                imguiData.xml.title             = handler.root.AutoUpdate.title
                imguiData.xml.buttons.first     = handler.root.AutoUpdate.buttons._attr.first
                imguiData.xml.buttons.second    = handler.root.AutoUpdate.buttons._attr.second
                imguiData.window[0]             = true

                print("[AutoUpdate.lua] The window is called. We are waiting for a response from the user.")
                lua_thread.create(function()
                    while true do
                        wait(0)
                        if imguiData.response == AUTOUPDATE_RESPONSE_OK then
                            sampAddChatMessage("Обновление загружается...", -1)
                            onReadyCallback(callbacks)
                            break
                        elseif imguiData.response == AUTOUPDATE_RESPONSE_BAD then
                            break
                        end
                    end
                end)
            end
        end
    end)
end

return module