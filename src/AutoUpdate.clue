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

@import "Common" => common
@import "Assets" => assets
@import "Config" => config

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
 * Merges two JSON strings into a single file.
 *
 * @param file string   The file where the merged JSON string will be written.
 * @param first string  JSON
 * @param second string JSON
 * @return void
 */
method __autoUpdate__::mergeJson(file, first, second) {
    if doesFileExist(file) {
        first, second = decodeJson(first), decodeJson(second)
        common::writeInFile(file, neatJSON(assets::mergeTables(first, second), { sort = true, wrap = 40 }))
    }
}

/**
 * Update script with settings that passed in AutoUpdate.xml. **Must** called after `autoUpdate::checkUpdates(url)`!
 * @return void
 */
method __autoUpdate__::update() {
    local fn downloadCallback() {
        config.root.autoUpdate.hasUpdateInstalled = true
        thisScript()::reload()
    }

    if self.handler.root.AutoUpdate.merge {
        if #self.handler.root.AutoUpdate.merge.json > 1 {
            local this = self.handler.root.AutoUpdate.merge.json
            for _, json in this {
                local src   = getWorkingDirectory() .. "\\" .. json._attr.src
                local value = json[1]
                self::mergeJson(src, common::readFileContent(src), value)
            }
        } elseif #self.handler.root.AutoUpdate.merge.json == 1 {
            local this  = self.handler.root.AutoUpdate.merge.json
            local src   = getWorkingDirectory() .. "\\" .. this._attr.src
            local value = this[1]
            self::mergeJson(src, common::readFileContent(src), value)
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
    local downloadStatus        = require("moonloader").download_status
    local content               = ""
    local tempFileDestination   = getWorkingDirectory() .. "\\GAdmin\\temp\\AutoUpdate.xml"
    
    if config.root.autoUpdate.hasUpdateInstalled {
        config.root.autoUpdate.hasUpdateInstalled = false
        return
    }

    downloadUrlToFile(url, tempFileDestination, fn(id, status, p1, p2) {
        if status == downloadStatus.STATUS_ENDDOWNLOADDATA {
            content = xml2lua.loadFile(tempFileDestination)

            try {
                local parser = xml2lua.parser(self.handler)
                parser::parse(content)

                os.remove(tempFileDestination)

                if self.handler.root.AutoUpdate._attr.version != $GADMIN_VERSION 
                   && config.root.autoUpdate.skipVersionUpdate != self.handler.root.AutoUpdate._attr.version
                {
                    self.imgui.body             = string.match(content, "<body>%s*(.*)%s*</body>")
                    self.imgui.title            = self.handler.root.AutoUpdate.title
                    self.imgui.version          = self.handler.root.AutoUpdate._attr.version
                    self.imgui.buttons.first    = self.handler.root.AutoUpdate.buttons._attr.first
                    self.imgui.buttons.second   = self.handler.root.AutoUpdate.buttons._attr.second
                    self.imgui.buttons.third    = self.handler.root.AutoUpdate.buttons._attr.third
                    self.windowState            = true
               
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
        }
    }) 
}

return __autoUpdate__
