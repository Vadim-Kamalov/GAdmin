script_name     "GAdmin"
script_version  "1.0"

local mem = require('memory')
local encoding = require('encoding')
local imgui = require('mimgui')
local gnomeIcons = require("gadmin/gnome-icons")
local wm = require("windows.message")
local vkeys = require("vkeys")
local rkeys = require('gadmin/rkeys_modif')
local samp = require('lib.samp.events')
local ffi = require('ffi')
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local cjson = require("cjson")

encoding.default = 'cp1251'
local u8 = encoding.UTF8

-- FFI functions
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

-- КОНСТАНТЫ
CMD_DELAY = 800

function get_config()
    file = io.open("moonloader/config/gadmin.json", "r")
    data = cjson.decode(file:read("*a"))
    file:close()
    return data
end

function save_config(data)
    if data == nil then
        data = cfg
    end
    data = cjson.encode(data)
    file = io.open("moonloader/config/gadmin.json", "w")
    file:write(data)
    file:close()
end

function textWithFont(text, font, ImVec2_pos)
    imgui.PushFont(font)
        if ImVec2_pos then imgui.SetCursorPos(ImVec2_pos) end
        imgui.Text(text)    
    imgui.PopFont()
end

function create_config()
    def_data = {
        online = {
            total = 0,
            monday = 0,
            tuesday = 0,
            wednesday = 0,
            thursday = 0,
            friday = 0,
            saturday = 0,
            sunday = 0
        },
        hotkeys = {
            gadm = {77},
            acceptForm = {73},
            spectateCursor = {66},
            specReload = {85},
            disconnectSpecCopy = {0x12, 0x41}-- Alt + A
        },
        windowsPosition = {
            actionFrame = {
                x = select(1, getScreenResolution()) / 100,
                y = select(2, getScreenResolution()) / 1.1
            },
            playerStatsFrame = {
                x = select(1, getScreenResolution()) / 1.125,
                y = select(2, getScreenResolution()) / 1.6
            },
            playersNearby = {
                x = select(1, getScreenResolution()) / 1.125,
                y = select(2, getScreenResolution()) / 3
            }
        },
        windowsSettings = {
            playersNearby = {
                use = false,
                alpha = 0
            },
            playerStatsFrame = {
                mode = 1
            }
        },
        specAdminPanel = {
            show     = true,
            width    = 200,
            pos      = {x = select(1, getScreenResolution()) / 15, y = select(2, getScreenResolution()) / 2},
            alpha    = 1.00,
            items    = {
                {name = "NEXT", action = "{NEXT}", position = 1},
                {name = "SWITCH", action = "{SWITCH}", position = 2},
                {name = "BACK", action = "{BACK}", position = 3},
                {name = "STATS", action = "{STATS}", position = 4},
                {name = "SESSION", action = "{SESSION}", position = 5},
                {name = "FRISK", action = "{FRISK}", position = 6},
                {name = "EXIT", action = "{EXIT}", position = 7}
            }
        },
        chats = {},
        checker = {
            show                = true,
            showOfflinePlayers  = true,
            height              = 400,
            pos                 = {
                x = select(1, getScreenResolution()) / 2,
                y = select(2, getScreenResolution()) / 2
            },
            alpha               = 0.30,
            players             = {}
        },
        gg_msg = "Приятной игры!",
        adm_pass = "",
        game_pass = "",
        car_spec = false,
        autoEnter = false,
        aloginOnEnter = false,
        showGunInfo = false
    }
    save_config(def_data)
end

if not doesFileExist('moonloader\\config\\gadmin.json') then
    if not doesDirectoryExist('moonloader\\config') then
        createDirectory('moonloader\\config')
    end
    create_config()
end

-- ВРЕМЕННО
-- create_config()

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local cfg = get_config()
local alogin = false
local sendFormCommand = ""
local checkSendFormCommand = false
local players_platform = {}
local _showSpectateCursor = true
local popupId, popupNickname = 0, ""
local selectedTab = 1
local changeTheme = {}
-- для информации в спеке --
local in_sp = false
local changePosition = -1
local checking_stats = false
local last_checking_stats = 0
local last_speed_check = 0
local spectate_id = -1
local info_about = -1
local spec_textdraw = -1
local player_data = {}
local intWindows = {"actionFrame", "playerStatsFrame", "playersNearby"}
local infoMode = tonumber(cfg.windowsSettings.playerStatsFrame.mode)
local infoData = {
    {
        columnsNum = 4,
        columnsSize = {70, 100, 85, 145},
        size = {400, 170, 217},
        main = {{"hp", "Здоровье"},
                {"armour", "Броня"},
                {"speed", "Скорость"},
                {"ping", "Пинг"},
                {"money", "Наличные"},
                {"bank", "На банке"},
                {"fraction", "Фракция"},
                {"transport", "Транспорт"},
                {"house", "Дом"},
                {"reg_date", "Регистрация"},
                {"vip", "Вип"},
                {"game", "Игра"}},
        car = {{"car_hp", "HP car"},
               {"car_engine", "Двигатель"}}
    },
    {
        columnsNum = 2,
        columnsSize = {100, 100},
        size = {200, 313, 385},
        main = {{"hp", "Здоровье"},
                {"armour", "Броня"},
                {"speed", "Скорость"},
                {"ping", "Пинг"},
                {"money", "Наличные"},
                {"bank", "На банке"},
                {"fraction", "Фракция"},
                {"transport", "Транспорт"},
                {"house", "Дом"},
                {"reg_date", "Регистрация"},
                {"vip", "Вип"},
                {"game", "Игра"}},
        car = {{"car_hp", "HP car"},
               {"car_engine", "Двигатель"}}
    },
}
----------------------------
local sizeX, sizeY = getScreenResolution()
local session_online = 0
local short_cmds = {
    vr = "vrepair %s",
    vs = "vspawn %s",
    as = "aspawn %s",
    ah = "aheal %s",
    af = "afrisk %s",
    uf = "unfreeze %s",
    g = "goto %s",
    gh = "gethere %s",
    gc = "getcar %s",
    gbc = "getbuycar %s",
    jb = "ans %s Пишите жалобу на форум, туда со всеми доказательствами",
    asl = "ans %s Слежу за игроком",
    ar = "kick %s AFK on ROAD",
    ak = "kick %s AFK without ESC",
    ap = "kick %s AFK public place"

}

local formCommand, formStarter, form_secondsToHide = "", "", os.clock()

-- ИМГУИ ПЕРЕМЕННЫЕ
local show_main_menu = new.bool()
local answerGps = new.bool()
local show_online_menu = new.bool(true)
local playerChecker = new.bool(true)
local notification = new.bool()
local show_info_menu = new.bool()
local admin_form_menu = new.bool()
local show_action_menu = new.bool()
local newMainFrame = new.bool()
local specAdminPanel = new.bool()
local playersNearby = new.bool()
local playersNerbyTransparent = new.int(cfg.windowsSettings.playersNearby.alpha)
local aloginOnEnter = new.bool()
local autologin = new.bool()
local playersNearbyCheckbox = new.bool(cfg.windowsSettings.playersNearby.use)
local car_spec = new.bool(cfg.car_spec)
local gg_msg = new.char[256](cfg.gg_msg)
local game_pass = new.char[256](cfg.game_pass)
local adm_pass = new.char[256](cfg.adm_pass)

-- для хоткеев
local gadmKeys = {v = cfg.hotkeys.gadm}
local showSpectateCursor = {v = cfg.hotkeys.spectateCursor}
local acceptFormKeys = {v = cfg.hotkeys.acceptForm}
local specReloadKeys = {v = cfg.hotkeys.specReload}
local spDisconnectCopy = {v = cfg.hotkeys.disconnectSpecCopy}

function imgui.Input()
    -- TODO: написать свой инпут, чтобы не плодить кучу однотипного кода
end

function getPlayerIdByNickname(name)
    for i = 0, sampGetMaxPlayerId(false) do
        if sampIsPlayerConnected(i) then
            if sampGetPlayerNickname(i):lower() == tostring(name):lower() then
                return i
            end
        end
    end
    return -1
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(width / 2 - calc.x / 2)
    imgui.Text(text)
end

function getBodyPartCoordinates(id, handle)
    local pedPointer = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedPointer), vec, id, true)
    return vec[0], vec[1], vec[2]
end

imgui.OnInitialize(function()
    gnomeIcons.loadIcons(30)

    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()

    bold14 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 22.0, nil, glyph_ranges)
    bold17 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 27.0, nil, glyph_ranges)

    bold15 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 23.0, nil, glyph_ranges)
    bold18 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 26.0, nil, glyph_ranges)
    bold25 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 33.0, nil, glyph_ranges)
    regular9 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellRegular, 16.0, nil, glyph_ranges)   
    regular15 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellRegular, 23.0, nil, glyph_ranges)
    regulat12 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellRegular, 20.0, nil, glyph_ranges)

    bold = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellBold, 25.0, nil, glyph_ranges)
    regular = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(cantarellRegular, 25.0, nil, glyph_ranges)

    imgui.Theme()
end)

function setChatInputEnabledWithText(text)
    sampSetChatInputEnabled(true)
    sampSetChatInputText(text)
end

local buttonsPlaceholder = {
    {
        ["SPAWN"]       = function() sampSendChat("/spawn "..info_about) end,
        ["GETIP"]       = function() end,
        ["SLAP"]        = function() sampSendChat("/slap "..info_about) end,
        ["GIVE HP"]     = function() setChatInputEnabledWithText("/sethp "..info_about.." ") end,
        ["RESSURECT"]   = function() sampSendChat("/aheal "..info_about) end,
        ["KILL"]        = function() sampSendChat("/sethp "..info_about.." 0") end,
        ["PAME"]        = function() sampSendChat("/pame "..info_about) end
    },


    {
        ["*Вы тут?*"]   = function() sampSendChat("/ans "..info_about.." Вы тут? Ответ в /b") end,
        ["AFRISK"]      = function() sampSendMenuSelectRow(5) end,
        ["КВЕНТА"]      = function() end,
        ["GETBUYCAR"]   = function() setChatInputEnabledWithText("/getbuycar ") end,
        ["REPAIR"]      = function() setChatInputEnabledWithText("/vrepair ") end,
        ["STATS"]       = function() sampSendChat("/stats "..info_about) end,
        ["SWITCH"]      = function() sampSendMenuSelectRow(1) end
    }
}

local actionMenu = imgui.OnFrame(
    function() return show_action_menu[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        imgui.SetNextWindowSize(imgui.ImVec2(800, 70))
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.actionFrame.x, cfg.windowsPosition.actionFrame.y))

        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
        imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0.5)

        imgui.Begin("action_menu", show_action_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove)
            if imgui.Button("<<", imgui.ImVec2(50, 70)) then sampSendMenuSelectRow(2) end
            imgui.SameLine()

            imgui.BeginGroup()
                for k, v in pairs(buttonsPlaceholder[1]) do
                    if imgui.Button(k, imgui.ImVec2(100, 35)) then v()
                        if not _showSpectateCursor then _showSpectateCursor = true end
                    end

                    imgui.SameLine()
                end
                imgui.NewLine()
                imgui.BeginGroup() -- New line content
                    for k, v in pairs(buttonsPlaceholder[2]) do
                        if imgui.Button(k, imgui.ImVec2(100, 35)) then v()
                            if not _showSpectateCursor and index ~= 1 then _showSpectateCursor = true end
                        end

                        imgui.SameLine()
                    end
                imgui.EndGroup()
            imgui.EndGroup()

            imgui.SameLine()

            if imgui.Button(">>", imgui.ImVec2(50, 70)) then sampSendMenuSelectRow(0) end
        imgui.End()

        imgui.PopStyleVar(5)
    end
)

local checkerFrame = imgui.OnFrame(
    function() return playerChecker[0] and cfg.checker.show end,
    function(self)
        self.HideCursor         = _showSpectateCursor
        self.windowProperties   = {
            {"ImVec4", "ScrollbarBg", change = imgui.ImVec4(0.07, 0.07, 0.07, cfg.checker.alpha), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "WindowBg", change = imgui.ImVec4(0.07, 0.07, 0.07, cfg.checker.alpha), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"Int", "WindowBorderSize", change = 0, reset = 1}
        }

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.checker.pos.x, cfg.checker.pos.y))
        imgui.SetNextWindowSize(imgui.ImVec2(250, cfg.checker.height))
        changeTheme:applySettings(self.windowProperties)
    
        imgui.Begin("Checker Frame", playerChecker, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
            for index, player in ipairs(cfg.checker.players) do
                imgui.BeginGroup()
                    if sampIsPlayerConnected(getPlayerIdByNickname(player)) then
                        imgui.TextColored(hexToImVec4("66CC33"), "[ONLINE]")
                        imgui.SameLine(75)
                    else
                        if cfg.checker.showOfflinePlayers then
                            imgui.TextColored(hexToImVec4("FF0033"), "[OFFLINE]")
                            imgui.SameLine(75)
                        end
                    end
                    imgui.Text(u8"%s%s%s", player, sampIsPlayerConnected(getPlayerIdByNickname(player)) and "[" .. tostring(getPlayerIdByNickname(player) .. "]") or "")
                    if imgui.IsItemClicked() then
                        sendNotification(
                            gnomeIcons.ICON_PERSON,
                            sampIsPlayerConnected(getPlayerIdByNickname(player)) and "Айди игрока скопирован!" or "Никнейм игрока скопирован!",
                            "Скопировано у игрока \"" .. player .. "\"",
                            "",
                            5
                        )
                        if sampIsPlayerConnected(getPlayerIdByNickname(player)) then
                            setClipboardText(tostring(getPlayerIdByNickname(player)))
                        else
                            setClipboardText(player)
                        end
                    elseif imgui.IsItemHovered() then
                        local rect          = imgui.GetItemRectMax()
                        local playerTag     = sampIsPlayerConnected(getPlayerIdByNickname(player)) and "[" .. tostring(getPlayerIdByNickname(player))  .. "]" or ""
                        local textSize      = imgui.CalcTextSize(player .. playerTag)
                        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(rect.x - textSize.x, rect.y + 3), imgui.ImVec2(rect.x, rect.y + 3), -1, 2)
                    end
                imgui.EndGroup()
                -- TODO: We can align this group by `width / 2 - textSize.x / 2`.
            end
        imgui.End()
        changeTheme:resetDefault(self.windowProperties)
    end
)

local notificationInit = {
    icon = gnomeIcons.ICON_WARNING,
    title = "Notification Initialize",
    firstLine = "Notification Initialize Description | 1st line",
    secondLine = "Notification Initialize Description | 2nd line",
    secondsToHide = 5,
    systemTime = os.clock(),
    positionY = 0,
    aplha = 1
}

local notificationFrame = imgui.OnFrame(
    function() return notification[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2 - 250, notificationInit.positionY))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 75))

        local notificationStyle = {
            {"ImVec2", "FramePadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "WindowPadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "ItemSpacing", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "ItemInnerSpacing", change = {0, 0}, reset = {2, 2}},
            {"Int", "WindowBorderSize", change = 0, reset = 1},
            {"ImVec4", "WindowBg", change = hexToImVec4("303030"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)}
        }

        changeTheme:applySettings(notificationStyle)

        imgui.Begin("Notification", notification, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
            imgui.SetCursorPos(imgui.ImVec2(15, 32))
            imgui.Text(notificationInit.icon == -1 and gnomeIcons.ICON_LIGHTBULB_FILLED or notificationInit.icon)

            textWithFont(notificationInit.title, bold18, imgui.ImVec2(53, 6))
            textWithFont(notificationInit.firstLine, regular12, imgui.ImVec2(53, 36))
            textWithFont(notificationInit.secondLine, regular12, imgui.ImVec2(53, 52))

            if os.clock() - notificationInit.systemTime >= notificationInit.secondsToHide then
                notificationInit.secondsToHide = 999
                lua_thread.create(function()
                    while notificationInit.positionY ~= -80 do
                        wait(5)
                        notificationInit.positionY = notificationInit.positionY - 40
                    end
                end)
            end

            if notificationInit.positionY == -80 then notification[0] = false end
        imgui.End()

        changeTheme:resetDefault(notificationStyle)
    end
)

local playersNearbyFrame = imgui.OnFrame(
    function() return playersNearby[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.playersNearby.x, cfg.windowsPosition.playersNearby.y))
        imgui.SetNextWindowSize(imgui.ImVec2(250, 287))

        local playersNearbyAlpha = {
            {"ImVec4", "ScrollbarBg", change = imgui.ImVec4(0.07, 0.07, 0.07, cfg.windowsSettings.playersNearby.alpha), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "WindowBg", change = imgui.ImVec4(0.07, 0.07, 0.07, cfg.windowsSettings.playersNearby.alpha), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"Int", "WindowBorderSize", change = 0, reset = 1}
        }

        changeTheme:applySettings(playersNearbyAlpha)

        imgui.Begin("playersNearby", playersNearby, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
            if changePosition == 3 then
                somePlayers = {"VANYA", "El_Capone", "DZONE", "Tyler_Carter", "Samuel_Jones", "Anthony_Hughes", "Christopher_Rivera", "Devin_Johnson", "Julian_Hall", "Xavier_Gray", "Gavin_Jenkins", "Jacob_Baker", "Alex_Hill", "Antonio_Parker", "Alexander_Phillips", "Luke_Jones", "Aidan_Butler", "Alexander_Phillips", "Samuel_Jones", "Anthony_Hughes", "Christopher_Rivera", "Devin_Johnson", "Julian_Hall", "Xavier_Gray", "Gavin_Jenkins", "Samuel_Jones", "Anthony_Hughes", "Christopher_Rivera", "Devin_Johnson", "Julian_Hall", "Xavier_Gray", "Gavin_Jenkins"}
                for i = 1, #somePlayers do
                    imgui.SetCursorPosX(100 - imgui.CalcTextSize(somePlayers[i]).x / 2)
                    imgui.Text(somePlayers[i])
                end
            else
                for _, player in ipairs(getAllChars()) do
                    result, id = sampGetPlayerIdByCharHandle(player)

                    color = sampGetPlayerColor(id)
                    if result then
                        nickname = sampGetPlayerNickname(id)
                        resultDistance, handle = sampGetCharHandleBySampPlayerId(id)
                        resultDistanceSpec, handleSpec = sampGetCharHandleBySampPlayerId(tonumber(info_about))
                        if resultDistance then
                            distanceA1, distanceA2, distanceA3 = getCharCoordinates(handle)
                            if resultDistanceSpec then distanceB1, distanceB2, distanceB3 = getCharCoordinates(handleSpec) end
                        end
                    end

                    if result and id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) and id ~= tonumber(info_about) then
                        imgui.SetCursorPosX(250 / 2 - imgui.CalcTextSize((
                            nickname.."["..id.."][X: "..math.floor(getDistanceBetweenCoords3d(distanceA1, distanceA2, distanceA3, distanceB1, distanceB2, distanceB3)).."]"
                        )).x / 2)
                        imgui.TextColored(hexToImVec4(("%06X"):format(bit.band(color, 0xFFFFFF))), ("%s[%s] [X: %1.f]"):format(nickname, id,
                            getDistanceBetweenCoords3d(distanceA1, distanceA2, distanceA3, distanceB1, distanceB2, distanceB3)
                        ))
                        if imgui.IsItemClicked() then
                            imgui.OpenPopup("playerInfo")
                            popupId, popupNickname = id, nickname
                        end
                    end
                end
            end

            imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
            if imgui.BeginPopup("playerInfo") then
                imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
                    imgui.BeginGroup()
                        imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
                            thisPlayerInfo = popupNickname.."["..popupId.."]"

                            imgui.SetCursorPos(imgui.ImVec2(100 - imgui.CalcTextSize(thisPlayerInfo).x / 2, 5))
                            imgui.Text(thisPlayerInfo)
                            imgui.SetCursorPosY(10 + imgui.CalcTextSize(popupNickname).y)
                            if imgui.Button("STATS", imgui.ImVec2(200, 30)) then
                                sampSendChat("/stats "..popupId); imgui.CloseCurrentPopup()
                                if not _showSpectateCursor then _showSpectateCursor = true end
                            end
                            if imgui.Button("PAME", imgui.ImVec2(200, 30)) then
                                sampSendChat("/pame "..popupId); imgui.CloseCurrentPopup()
                                if not _showSpectateCursor then _showSpectateCursor = true end
                            end
                            if imgui.Button("SPEC", imgui.ImVec2(200, 30)) then
                                sampSendChat("/sp "..popupId); imgui.CloseCurrentPopup()
                                if not _showSpectateCursor then _showSpectateCursor = true end
                            end
                        imgui.PopStyleVar()
                    imgui.EndGroup()
                imgui.PopStyleVar()
            end
            imgui.PopStyleVar()

        imgui.EndPopup()
        imgui.End()

        changeTheme:resetDefault(playersNearbyAlpha)
    end
)

local selectedTab = 1

local adminForm = imgui.OnFrame(
    function() return admin_form_menu[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, 70))

        local adminFormStyle = {
            {"ImVec4", "WindowBg", change = imgui.ImVec4(0.07, 0.07, 0.07, 0.50), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"Int", "WindowRounding", change = 0, reset = 5},
            {"Int", "FrameRounding", change = 0, reset = 5},
            {"Int", "WindowBorderSize", change = 0, reset = 1}
        }

        changeTheme:applySettings(adminFormStyle)

        imgui.Begin("admin_form_menu", admin_form_menu, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
            imgui.SetCursorPosY(10)
            imgui.BeginGroup()
                imgui.SetCursorPosX(15)
                imgui.Text("Форма от "..formStarter.." | Выполнить форму - "..rkeys.getKeysName(cfg.hotkeys.acceptForm))
                imgui.SameLine()
                imgui.SetCursorPosX(sizeX / 2 - imgui.CalcTextSize("/"..formCommand).x / 2)
                imgui.Text("/"..formCommand)
                imgui.SameLine()
                imgui.SetCursorPosX(sizeX / 1.3 - imgui.CalcTextSize("Это окно исчезнет через %.1f секунд.").x / 2)
                imgui.TextDisabled(("Это окно исчезнет через %.1f секунд."):format(5 - (os.clock() - form_secondsToHide)))
            imgui.EndGroup()

            if os.clock() - form_secondsToHide >= 5 then
                admin_form_menu[0], formStarter, formCommand = false, "", ""
            end
        imgui.End()
        changeTheme:resetDefault(adminFormStyle)
    end
)

local mainFrame = imgui.OnFrame(
    function() return show_main_menu[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(800, 600))
        imgui.Begin("GAdmin", show_main_menu, imgui.WindowFlags.NoTitleBar)

        imgui.Text("Текст /gg")
        imgui.SameLine()
        if imgui.InputText("##gg_msg", gg_msg, sizeof(gg_msg)) then
            cfg.gg_msg = str(gg_msg)
            save_config()
        end

        imgui.Text("Пароль от аккаунта")
        imgui.SameLine()
        if imgui.InputText("##game_pass", game_pass, sizeof(game_pass)) then
            cfg.game_pass = str(game_pass)
            save_config()
        end

        imgui.Text("Пароль от админки")
        imgui.SameLine()
        if imgui.InputText("##adm_pass", adm_pass, sizeof(adm_pass)) then
            cfg.adm_pass = str(adm_pass)
            save_config()
        end
        if imgui.Button("Настроить позицию окон") then
            imgui.OpenPopup("windowsPosition")
        end

        if imgui.Checkbox("Отображение ближайших игроков в /sp", playersNearbyCheckbox) then
            cfg.windowsSettings.playersNearby.use = playersNearbyCheckbox[0]
            save_config()
        end

        if imgui.SliderInt("Прозрачность окна с ближайшими игроками", playersNerbyTransparent, 0, 100) then
            cfg.windowsSettings.playersNearby.alpha = playersNerbyTransparent[0] / 100
            save_config()
        end

        if rkeys.HotKey("Главное меню", gadmKeys, imgui.ImVec2(100, 20)) then
            cfg.hotkeys.gadm = gadmKeys.v
            rkeys.changeHotKey(openMainMenu, gadmKeys.v)
            save_config()
        end
        if rkeys.HotKey("Принятие формы", acceptFormKeys, imgui.ImVec2(100, 20)) then
            cfg.hotkeys.acceptForm = acceptFormKeys.v
            rkeys.changeHotKey(acceptForm, acceptFormKeys.v)
            save_config()
        end

        if rkeys.HotKey("Открытие курсора в /sp", showSpectateCursor, imgui.ImVec2(100, 20)) then
            cfg.hotkeys.spectateCursor = acceptFormKeys.v
            rkeys.changeHotKey(showSpectateCursor, showSpectateCursor.v)
            save_config()
        end

        if rkeys.HotKey("Spec reload", specReloadKeys, imgui.ImVec2(100, 20)) then
            cfg.hotkeys.specReload = specReloadKeys.v
            rkeys.changeHotKey(_specReload, specReloadKeys.v)
            save_config()
        end

        if rkeys.HotKey("Копировать никнейм за которым следите при его выходе", spDisconnectCopy, imgui.ImVec2(100, 20)) then
            cfg.hotkeys.specReload = spDisconnectCopy.v
            rkeys.changeHotKey(specDisconnectCopy, spDisconnectCopy.v)
            save_config()
        end

        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
        if imgui.BeginPopupModal("windowsPosition", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
            imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)

            imgui.BeginGroup()
                imgui.PushStyleVarVec2(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
                if imgui.Button("Окно быстрых действий в /sp", imgui.ImVec2(300, 50)) then
                    changePosition = 1
                elseif imgui.Button("Окно со статистикой игрока в /sp", imgui.ImVec2(300, 50)) then
                    changePosition = 2
                elseif imgui.Button("Окно с ближайшими игроками в /sp", imgui.ImVec2(300, 50)) then
                    changePosition = 3
                elseif imgui.Button("Закрыть окно", imgui.ImVec2(300, 50)) then imgui.CloseCurrentPopup() end
                imgui.PopStyleVar()
            imgui.EndGroup()

            imgui.PopStyleVar()
        end
        imgui.PopStyleVar()

        imgui.EndPopup() -- Should be here
        imgui.End()
    end
)

local onlineFrame = imgui.OnFrame(
    function() return show_online_menu[0] end,
    function(player)
        player.HideCursor = _showSpectateCursor
        local full_online = string.format("Общий онлайн: %02d:%02d:%02d", cfg.online.total / 3600,cfg.online.total / 60 % 60, cfg.online.total % 60)
        local temp_online = string.format("Онлайн за сессию: %02d:%02d:%02d", session_online / 3600, session_online / 60 % 60, session_online % 60)
        size = {imgui.GetStyle().WindowPadding.x*2 + imgui.CalcTextSize(temp_online).x,
        imgui.GetStyle().ItemSpacing.y + imgui.GetStyle().WindowPadding.y*2 + imgui.CalcTextSize(temp_online).y + imgui.CalcTextSize(full_online).y}

        local onlinePosX, onlinePosY = sizeX - size[1], sizeY - size[2]
        if admin_form_menu[0] then onlinePosY = sizeY - size[2] - 35 else onlinePosY = sizeY - size[2] end

        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 0)

        imgui.SetNextWindowSize(imgui.ImVec2(size[1], size[2]))
        imgui.SetNextWindowPos(imgui.ImVec2(onlinePosX, onlinePosY))
        imgui.Begin("GAdmin_online", show_online_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)

        imgui.Text(full_online)
        imgui.Text(temp_online)

        imgui.PopStyleVar()

        imgui.End()
    end
)

local infoFrame = imgui.OnFrame(
    function() return show_info_menu[0] end,
    function(player)
        if sampIsPlayerConnected(tonumber(spectate_id)) then
            player_data["armour"] = sampGetPlayerArmor(spectate_id)
            player_data["game"] = (players_platform[tonumber(spectate_id)] and players_platform[tonumber(spectate_id)] or "N/A")
            local res, ped = sampGetCharHandleBySampPlayerId(spectate_id)
            if res then player_data["ped"] = ped end
            if res and isCharInAnyCar(player_data["ped"]) then
                player_data["car"] = storeCarCharIsInNoSave(player_data["ped"])
                local car = player_data["car"]
                player_data["car_hp"] = getCarHealth(car)
                player_data["car_model"] = getCarModel(car)
                player_data["car_name"] = getCarName(player_data["car_model"])
                res, player_data["car_id"] = sampGetVehicleIdByCarHandle(car)
                player_data["car_engine"] = isCarEngineOn(car) and "Заведён" or "Заглушен"
            else
                player_data["car"] = nil
                player_data["car_hp"] = nil
                player_data["car_model"] = nil
                player_data["car_name"] = nil
                player_data["car_id"] = nil
                player_data["car_engine"] = nil
            end
        end

        player.HideCursor = _showSpectateCursor
        local info = infoData[infoMode]
        imgui.SetNextWindowSize(imgui.ImVec2(info.size[1], (player_data["car"] and info.size[3] or info.size[2])))
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.playerStatsFrame.x, cfg.windowsPosition.playerStatsFrame.y))
        imgui.Begin("GAdmin_info", show_info_menu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove)

        imgui.CenterText(tostring(player_data["nick"]) .. "[" .. spectate_id .. "]")
        imgui.Columns(info.columnsNum, "##player_info", true)
        for i = 1, 4 do imgui.NextColumn() end
        imgui.Separator()
        for num, size in pairs(info.columnsSize) do
            imgui.SetColumnWidth(num, size)
        end
        for k, v in pairs(info.main) do
            imgui.Text(v[2])
            imgui.NextColumn()
            imgui.Text(tostring(player_data[v[1]]))
            imgui.NextColumn()
            if (k % (info.columnsNum / 2) == 0) and k ~= #info.main then
                imgui.Separator()
            end
        end

        imgui.Columns(1)
        imgui.Separator()
        if player_data["car"] and info.car then
            local car = player_data["car"]
            imgui.CenterText(player_data["car_name"] .. "[" .. player_data["car_id"] .. "]")
            imgui.Columns(info.columnsNum, "##player_cars_info", true)
            for i = 1, 4 do imgui.NextColumn() end
            imgui.Separator()
            for num, size in pairs(info.columnsSize) do
                imgui.SetColumnWidth(num, size)
            end

            for k, v in pairs(info.car) do
                imgui.Text(v[2])
                imgui.NextColumn()
                imgui.Text(tostring(player_data[v[1]]))
                imgui.NextColumn()
                if (k % (info.columnsNum / 2) == 0) and k ~= #info.car then
                    imgui.Separator()
                end
            end

            imgui.Columns(1)
            imgui.Separator()
        end


        imgui.End()
    end
)

function sortedTableByPosition()
    local sortedTable = {}
    for i = 1, #cfg.specAdminPanel.items do
        table.insert(sortedTable, cfg.specAdminPanel.items[i].position, cfg.specAdminPanel.items[i])
    end

    for j = 1, #cfg.specAdminPanel.items do
        if sortedTable[j] == nil then table.remove(sortedTable, j) end
    end
    return sortedTable
end

local ARGUMENT_REGEXP = [[{.*="(.*)"}]]

local selectedButton = 1
local specActionsData = {
    -- DEFAULT_FUNCTIONS [1-8]

    ["NEXT"]        = function() sampSendMenuSelectRow(0) end,
    ["SWITCH"]      = function() sampSendMenuSelectRow(1) end,
    ["BACK"]        = function() sampSendMenuSelectRow(2) end,
    ["STATS"]       = function() sampSendMenuSelectRow(3) end,
    ["SESSION"]     = function() sampSendMenuSelectRow(4) end,
    ["FRISK"]       = function() sampSendMenuSelectRow(5) end,
    ["EXIT"]        = function() sampSendMenuSelectRow(6) end,
    ["GG"]          = function() sampSendChat("/ans "..info_about.." "..cfg.gg_msg) end,

    -- SPEC_PLAYER_INFO_FUNCTIONS [8-13]

    ["SP_ID"]       = function() return info_about end,
    ["SP_NICK"]     = function() return sampGetPlayerNickname(tonumber(info_about)) end,
    ["SP_HP"]       = function() return sampGetPlayerHealth(tonumber(info_about)) end,
    ["SP_ARM"]      = function() return sampGetPlayerArmor(tonumber(info_about)) end,
    ["SP_PING"]     = function() return sampGetPlayerPing(tonumber(info_about)) end,

    -- CAR_FUNCTIONS [13-16]

    ["SP_CAR_HEALTH"]   = function() return player_data["car_hp"] end,
    ["SP_CAR_NAME"]     = function() return player_data["car_name"] end,
    ["SP_CAR_ENGINE"]   = function() return player_data["car_engine"] end,

    -- ARGUMENT_FUNCTIONS [16-19]
       
    [ [[SEND_CHAT]] ]            = function(arg) sampSendChat(arg:match(ARGUMENT_REGEXP)) end,
    [ [[ADD_CHAT_MESSAGE]] ]     = function(arg) sampAddChatMessage(arg:match(ARGUMENT_REGEXP), -1) end,
    [ [[SEND_SP_ANSWER]] ]       = function(arg) sampSendChat("/sp "..info_about.." "..arg:match(ARGUMENT_REGEXP)) end
}

function doSpecActions(action)
    for k, v in pairs(specActionsData) do
        if action:find("{"..k.."}") then v()
        elseif action:find("{"..k.."=\"(.*)\"}") then v(u8(action)) end
    end
end

local _specAdminPanel = imgui.OnFrame(
    function() return specAdminPanel[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        local adminPanelSize = 7
        local sortedTable = sortedTableByPosition()

        for i = 1, #cfg.specAdminPanel.items do
            adminPanelSize = adminPanelSize + 37
        end

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.specAdminPanel.pos.x, cfg.specAdminPanel.pos.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(cfg.specAdminPanel.width, adminPanelSize))

        local specAdminPanelChange = {
            {"ImVec2", "WindowPadding", change = {7, 7}, reset = {5, 5}},
            {"ImVec2", "ItemSpacing", change = {0, 7}, reset = {5, 5}},
            {"Int", "FrameBorderSize", change = 0, reset = 1},
            {"Int", "WindowBorderSize", change = 0, reset = 1},
            {"ImVec4", "WindowBg", change = hexToImVec4("21242A", cfg.specAdminPanel.alpha), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "Button", change = hexToImVec4("444751"), reset = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)},
            {"ImVec4", "ButtonHovered", change = hexToImVec4("303238"), reset = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)},
            {"ImVec4", "ButtonActive", change = hexToImVec4("444751"), reset = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)},
            {"ImVec2", "ButtonTextAlign", change = {0.5, 0.5}, reset = {0.5, 0.5}}
        }

        local doAction = function(i)
            subAction = string.gsub(cfg.specAdminPanel.items[i].action, "[%{%}]", "")
            for key, value in pairs(specActionsData) do
                if key:find(subAction) then value() end
            end
        end

        if not isCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if wasKeyPressed(VK_UP) then
                if selectedButton == 1 then selectedButton = #sortedTable else
                    selectedButton = selectedButton - 1
                end
            elseif wasKeyPressed(VK_DOWN) then
                if selectedButton == #sortedTable then selectedButton = 1 else
                    selectedButton = selectedButton + 1
                end
            elseif wasKeyPressed(VK_SPACE) then
                subAction = string.gsub(sortedTable[selectedButton].action, "[%{%}]", "")
                for key, value in pairs(specActionsData) do
                    if key:find(subAction) then value() end
                end
                selectedButton = 1
            end
        end

        changeTheme:applySettings(specAdminPanelChange)
        imgui.PushFont(bold15)
            imgui.Begin("specAdminPanel", specAdminPanel, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
                for k, v in pairs(sortedTable) do
                    imgui.BeginGroup()
                    math.randomseed(os.clock())
                        imgui.PushStyleColor(imgui.Col.Button, hexToImVec4(k == selectedButton and "303238" or "444751"))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, hexToImVec4(k == selectedButton and "444751" or "303238"))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, hexToImVec4(k == selectedButton and "303238" or "444751"))
                            imgui.Button("##"..v.name..math.random(1, 1000000), imgui.ImVec2(186, 30))
                        imgui.PopStyleColor(2)

                        imgui.SameLine(imgui.GetCursorPos().x + 93 - imgui.CalcTextSize(v.name).x / 2 - 5)
                        imgui.BeginGroup()
                            imgui.SetCursorPosY(imgui.GetCursorPos().y - 1)
                            imgui.Text(v.name)
                        imgui.EndGroup()
                    imgui.EndGroup()

                    if imgui.IsItemClicked() then doAction(k) end
                end
            imgui.End()

        imgui.PopFont()
        changeTheme:resetDefault(specAdminPanelChange)
    end
)

local menuProperties = {
    width = 80,
    selectedTab = 1
}

local mainWindow = imgui.OnFrame(
    function() return newMainFrame[0] end,
    function(self)
        imgui.SetNextWindowSize(imgui.ImVec2(900, 500))
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

        local activeMenuButtonStyle = {
            {"ImVec4", "Button", change = hexToImVec4("303030"), reset = hexToImVec4("242424")},
            {"ImVec4", "ButtonActive", change = hexToImVec4("303030"), reset = hexToImVec4("242424")},
            {"ImVec4", "ButtonHovered", change = hexToImVec4("303030"), reset = hexToImVec4("303030")}
        }

        local postMenuStyle = {
            {"ImVec2", "ButtonTextAlign", change = {0.5, 0.5}, reset = {0.5, 0.8}},
            {"ImVec4", "ButtonActive", change = hexToImVec4("4F4F4F"), reset = hexToImVec4("4F4F4F")}
        }

        local menuStyle = {
            {"ImVec4", "Button", change = hexToImVec4("242424"), reset = hexToImVec4("4F4F4F")},
            {"ImVec4", "ButtonHovered", change = hexToImVec4("303030"), reset = hexToImVec4("616161")},
            {"ImVec4", "ButtonActive", change = hexToImVec4("242424"), reset = hexToImVec4("4F4F4F")}
        }

        local windowStyle = {
            {"ImVec2", "WindowPadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "FramePadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "ItemSpacing", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "ItemInnerSpacing", change = {0, 0}, reset = {2, 2}},
            {"ImVec2", "ButtonTextAlign", change = {0.5, 0.8}, reset = {0.5, 0.5}},
            {"Int", "WindowBorderSize", change = 0, reset = 1},
            {"Int", "ChildBorderSize", change = 0, reset = 1},
            {"Int", "FrameBorderSize", change = 0, reset = 1},
            {"ImVec4", "ChildBg", change = hexToImVec4("242424"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "WindowBg", change = hexToImVec4("303030"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "Button", change = hexToImVec4("4F4F4F"), reset = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)},
            {"ImVec4", "ButtonHovered", change = hexToImVec4("616161"), reset = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)},
            {"ImVec4", "ButtonActive", change = hexToImVec4("4F4F4F"), reset = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)}
        }
    
        local fill = function(ImVec2_size, ImVec2_pos, ImVec4_color, rounding)
            imgui.SetCursorPos(ImVec2_pos)
            imgui.PushStyleVarFloat(imgui.StyleVar.ChildRounding, rounding or 0)
            imgui.PushStyleColor(imgui.Col.ChildBg, ImVec4_color)
                imgui.BeginChild(tostring(ImVec2_pos), ImVec2_size, true)
                imgui.EndChild()
            imgui.PopStyleColor()
            imgui.PopStyleVar()
        end

        local menuButton = function(icon, text, ImVec2_pos, tabForChange)
            if tabForChange == menuProperties.selectedTab then
                changeTheme:applySettings(activeMenuButtonStyle)
            end

            if menuProperties.width == 80 then
                imgui.SetCursorPos(ImVec2_pos)
                if imgui.Button(icon, imgui.ImVec2(35, 35)) then
                    menuProperties.selectedTab = tabForChange
                end
            elseif menuProperties.width > 80 then
                imgui.SetCursorPos(ImVec2_pos)
                if imgui.Button("##menuButton["..text, imgui.ImVec2(menuProperties.width - ImVec2_pos.x * 2, 35)) then
                    menuProperties.selectedTab = tabForChange
                end
                textWithFont(text, bold15, imgui.ImVec2(70, ImVec2_pos.y + 6.5))
                imgui.SetCursorPos(imgui.ImVec2(ImVec2_pos.x + 2, ImVec2_pos.y + 16))
                imgui.Text(icon)
            end

            changeTheme:resetDefault(activeMenuButtonStyle)
        end

        changeTheme:applySettings(windowStyle)

        imgui.Begin("Animation Window", newMainFrame, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
            imgui.BeginChild("Left-bar", imgui.ImVec2(menuProperties.width, 0), false)
            changeTheme:applySettings(menuStyle)
                imgui.SetCursorPos(imgui.ImVec2(23, 20))
                if imgui.Button(gnomeIcons.ICON_MENU, imgui.ImVec2(35, 35)) then
                    if menuProperties.width == 80 then
                        lua_thread.create(function()
                            while menuProperties.width ~= 240 do
                                wait(1)
                                menuProperties.width = menuProperties.width + 40
                            end
                        end)
                    elseif menuProperties.width == 240 then
                        lua_thread.create(function()
                            while menuProperties.width ~= 80 do
                                wait(1)
                                menuProperties.width = menuProperties.width - 40
                            end
                        end)
                    end
                end

                imgui.BeginGroup() -- Child content
                    imgui.BeginGroup() -- Title
                        textWithFont("GAdmin", bold18, imgui.ImVec2(83, 25))
                        textWithFont("v"..thisScript().version, regular9, imgui.ImVec2(162, 32))
                    imgui.EndGroup()
                    menuButton(gnomeIcons.ICON_HOME, "Главная", imgui.ImVec2(21, 78), 1)
                    menuButton(gnomeIcons.ICON_VERTICAL_BAR_CHART, "Статистика", imgui.ImVec2(21, 123), 2)
                imgui.EndGroup()
                fill(imgui.ImVec2(10, 0), imgui.ImVec2(menuProperties.width - 10, 0), hexToImVec4("242424"))
            changeTheme:resetDefault(menuStyle)    
            imgui.EndChild()

            imgui.SameLine()
            imgui.SetCursorPos(imgui.ImVec2(menuProperties.width, 0))
            changeTheme:applySettings(postMenuStyle)

            imgui.PushStyleColor(imgui.Col.ChildBg, hexToImVec4("303030"))
                imgui.BeginChild("MainContent", imgui.ImVec2(0, 0), false)
                    if menuProperties.selectedTab == 1 then
                        imgui.BeginGroup() -- Logo
                            textWithFont("GAdmin", bold25, imgui.ImVec2(17, 14))
                            textWithFont("v"..thisScript().version, regular15, imgui.ImVec2(120, 23))
                        imgui.EndGroup()
                        imgui.PushFont(bold18)
                            imgui.SetCursorPos(imgui.ImVec2(10, 450))
                            if imgui.Button("Выйти из админки", imgui.ImVec2(900 - menuProperties.width - 20, 40)) then
                                -- TODO
                            end
                        imgui.PopFont()
                    end
                imgui.EndChild()
            imgui.PopStyleColor()

            changeTheme:resetDefault(postMenuStyle)
        imgui.End()

        changeTheme:resetDefault(windowStyle)
    end
)

function onWindowMessage(msg, wparam, lparam)
    if msg == wm.WM_SYSKEYDOWN or msg == wm.WM_KEYDOWN then
        if show_main_menu[0] and wparam == vkeys.VK_ESCAPE and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            show_main_menu[0] = false
        end
    elseif msg == wm.WM_LBUTTONUP and changePosition ~= -1 then
        cfg.windowsPosition[intWindows[changePosition]].x,
        cfg.windowsPosition[intWindows[changePosition]].y = bit.band(lparam, 0xFFFF), bit.band(bit.rshift(lparam, 16), 0xFFFF)

        save_config()
        sendNotification(gnomeIcons.ICON_COLLAPSE, "Настройки сохранены.", "Позиция окна успешно сохранена!", "", 5)
        showCursor(false, false)
        displayHud(true)
        displayRadar(true)
        consumeWindowMessage(true, false)

        changePosition = -1
        show_action_menu[0], show_info_menu[0], playersNearby[0] = false, false, false
        show_main_menu[0] = true
    elseif msg == wm.WM_RBUTTONUP and changePosition ~= -1 then
        sendNotification(gnomeIcons.ICON_COLLAPSE, "Отменено.", "Смена позиции окна отменена.", "", 5)
        show_main_menu[0] = true
        displayHud(true)
        displayRadar(true)
        showCursor(false, false)

        changePosition = -1
        show_action_menu[0], show_info_menu[0] = false, false
    end
end

function main()
    while not isSampAvailable() do wait(0) end

    if sampGetCurrentServerAddress() == "46.174.48.194" then
        sampAddChatMessage("GAdmin успешно запущен", -1) 
    else
        sampAddChatMessage("GAdmin работает только на sa.gambit-rp.ru", -1)
        script:unload()
    end

    -- инициализируем все команды
    sampRegisterChatCommand("gadm", gadm_cmd)
    sampRegisterChatCommand("sp", spectate)
    sampRegisterChatCommand("test", function(arg)
        infoMode = tonumber(arg:match("(%d+)"))
        cfg.windowsSettings.playerStatsFrame.mode = infoMode
        save_config()
    end)
    sampRegisterChatCommand("wh", function()
        nameTagOn()
    end)

    -- сокращенные командыs
    sampRegisterChatCommand("pk", pk_cmd)
    sampRegisterChatCommand("rec", reconnect)
    sampRegisterChatCommand("gg", gg_cmd)
    sampRegisterChatCommand("asp", asp_cmd)
    for k, v in pairs(short_cmds) do
        sampRegisterChatCommand(k, function(arg)
            if arg then
                sampSendChat("/" .. v:format(arg))
            end
        end)
    end


    -- инициализируем все хоткеи
    openMainMenu =       rkeys.registerHotKey(cfg.hotkeys.gadm, 1, gadm_cmd)
    showCursorInSpec =   rkeys.registerHotKey(cfg.hotkeys.spectateCursor, 1, changeSpecCursorMode)
    acceptForm =         rkeys.registerHotKey(cfg.hotkeys.acceptForm, 1, sendFormCommand)
    _specReload =        rkeys.registerHotKey(cfg.hotkeys.specReload, 1, specReload)
    specDisconnectCopy = rkeys.registerHotKey(cfg.hotkeys.disconnectSpecCopy, 1, spectateDisconnectCopy)

    -- инициализируем шрифты для рендера на экране
    local font_flag = require('moonloader').font_flag
    local font = renderCreateFont('Verdana', 10, font_flag.BOLD + font_flag.SHADOW)


    while true do
        wait(0)
        if car_spec[0] then
            for _, car in pairs(getAllVehicles()) do
                local x, y, z = getCarCoordinates(car)
                local myx, myy, myz = getCharCoordinates(PLAYER_PED)
                if doesVehicleExist(car) and isCarOnScreen(car) and getDistanceBetweenCoords3d(x, y, z, myx, myy, myz) < 50 then
                    local engine_status = isCarEngineOn(car) and "{8dff85}ON" or "{ff8585}OFF"
                    local door_status = getCarDoorLockStatus(car) == 0 and "{8dff85}OPEN" or "{ff8585}LOCK"
                    local hp = getCarHealth(car)
                    local result, id = sampGetVehicleIdByCarHandle(car)
                    local carmodel = getCarModel(car)
                    local vehname = getCarName(carmodel)
                    local sx, sy = convert3DCoordsToScreen(x, y, z)
                    local text = "ID: {8dff85}" .. id .. " {FFFFFF}HP: {8dff85}" .. hp
                    local text2 = vehname .. " [" .. engine_status .. "{FFFFFF} / " .. door_status .. "{FFFFFF}]"
                    renderFontDrawTextAlign(font, text, sx, sy, 0xFFFFFFFF, 2)
                    renderFontDrawTextAlign(font, text2, sx, sy + 15, 0xFFFFFFFF, 2)
                end
            end
        end

        if show_info_menu[0] and cfg.showGunInfo then
            for _, player in ipairs(getAllChars()) do
                local idResult, id = sampGetPlayerIdByCharHandle(player)
                local charResult, char = sampGetCharHandleBySampPlayerId(id)
                local posX, posY, posZ = getBodyPartCoordinates(2, player)
                local screenPosX, screenPosY = convert3DCoordsToScreen(posX, posY, posZ)

                if charResult then
                    renderFontDrawTextAlign(font, require("game/weapons").names[getCurrentCharWeapon(player)], screenPosX, screenPosY, 0xFFFFFFFF, 2)
                end
            end
        end

        if cfg.specAdminPanel.show then specAdminPanel[0] = show_info_menu[0] end
        show_action_menu[0] = show_info_menu[0]
        if cfg.windowsSettings.playersNearby.use then playersNearby[0] = show_info_menu[0] else playersNearby[0] = false end

        if in_sp and not isCursorActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
            if wasKeyPressed(1) or wasKeyPressed(37) then sampSendMenuSelectRow(2) end
            if wasKeyPressed(2) or wasKeyPressed(39) then sampSendMenuSelectRow(0) end
        end

        if changePosition ~= -1 then
            if in_sp then
                sampAddChatMessage("Сперва нужно покинуть /sp", -1)
                changePosition = -1
            else
                showCursor(true, true)
                displayHud(false)
                displayRadar(false)
                currentX, currentY = getCursorPos()

                cfg.windowsPosition[intWindows[changePosition]].x = currentX
                cfg.windowsPosition[intWindows[changePosition]].y = currentY

                show_main_menu[0] = false
                show_action_menu[0], show_info_menu[0], playersNearby[0] = true, true, true
            end
        end

        --TODO
        -- if cfg.aloginOnEnter and string.len(cfg.adm_pass) ~= 0 then
        --     local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)

        --     if result and sampGetPlayerScore(id) == 1 then
        --         sampSendChat("/alogin")
        --         break
        --     end
        -- end
    end
end


function samp.onPlayerQuit(id)
    players_platform[id] = nil
end

local formCommands = {
    "ban %d+ %d+ .*",
    "jail %d+ %d+ .*",
    "mute %d+ %d+ .*",
    "warn %d+ .*",
    "iban %d+ %d+ .*",
    "ck %d+",
    "pk %d+",
    "setworld %d+ %d+"
}

function samp.onSendCommand(command)
    for k, v in ipairs(formCommands) do
        if string.lower(command):find("/"..v..".*") then
            checkSendFormCommand = true
            sendFormCommand = command
        end
    end
end

function samp.onShowMenu()
    return not cfg.specAdminPanel.show
end

function samp.onServerMessage(color, text)
    local result, id        = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nickname          = sampGetPlayerNickname(id)

    text = u8(text)

    if text:find("Вы успешно авторизовались как администратор") or text:find("Вы уже авторизировались") and color == -1 then
        alogin = true
    end

    for k, v in ipairs(formCommands) do
        if text:find("%[A%] .*%[%d+%]: /"..v) and color == 866792362 then
            formStarter, formStarterId, formCommand = text:match(u8"%[A%] (.*)%[(%d+)%]: /(.*)")
            if formStarterId ~= id then
                form_secondsToHide = os.clock()
                admin_form_menu[0] = true
            end
        end
    end
    if checkSendFormCommand then
        if text:find("%|.*У вас нет доступа для использования данной команды%.") then
            sampSendChat("/a "..sendFormCommand)
            checkSendFormCommand = false
            sendFormCommand = ""
            return false
        else
            checkSendFormCommand = false
            sendFormCommand = ""
        end
    end
    if text:find("Администратор.*// "..formStarter) and color == -10270806 then
        admin_form_menu[0], formStarter, formCommand = false, "", ""
    end

    for color in string.gmatch(text, "%x%x%x%x%x%x") do
        print(color, text)
    end
end

function getIdByMatchedNickname(nickname)
    local result, playerId = false, -1

    if string.lower(nickname):find("[0-9a-z%[%]%(%)%$@_=]+") --[[ SA-MP Nickname RegExp (without A-Z, because argument in lowercase) ]] then
        if string.len(nickname) <= 2 then sampAddChatMessage("{ffff00}|{ffffff} Длина /sp [ nickname ] должна быть больше двух.", -1) else
            for i = 0, sampGetMaxPlayerId(false) do
                if sampIsPlayerConnected(i) and sampGetPlayerScore(i) == 1 then
                    if string.lower(sampGetPlayerNickname(i)):find(".*"..string.lower(nickname)) then
                        table.insert(findedNicknames, sampGetPlayerNickname(i))
                    end
                end

                if i == sampGetMaxPlayerId(false) then sendSpec = true end
            end

            if sendSpec then
                if #findedNicknames == 1 then
                    result, playerId = true, getPlayerIdByNickname(findedNicknames[i])
                elseif #findedNicknames == 0 then
                    sampAddChatMessage("{FFFF00}|{FFFFFF} По {4a86b6}"..nickname.."{FFFFFF} не найдено совпадений", -1)
                else
                    sampAddChatMessage(("{4a86b6}[SP]{ffffff} По %s найдено %s совпадений:"):format(nickname, #findedNicknames), -1)
                    for i = 1, #findedNicknames do
                        sampAddChatMessage("{FFFF00}|{FFFFFF} "..findedNicknames[i].." {4a86b6}["..getPlayerIdByNickname(findedNicknames[i]).."]", -1)
                    end
                end

                sendSpec = false
            end
        end
    end

    return result, playerId
end

function samp.onShowDialog(dialogId, style, title, button1, button2, text)
    local title, button1, button2, text = u8(title), u8(button1), u8(button2), u8(text)

    if cfg.autoEnter and string.len(cfg.game_pass) > 3 and style == 3 then
        if text:find("Для продолжения игры, Вам необходимо авторизоваться") then
            sampSendDialogResponse(dialogId, 1, 0, cfg.game_pass)
            return false
        end
    end

    if style == 3 and button1 == "Далее" and button2 == "Отмена" and text:find(".*{4a86b6}Авторизация.*{FFFFFF}Введите пароль:.*") and string.len(cfg.adm_pass) ~= 0 then
        sampSendDialogResponse(dialogId, 1, 0, cfg.adm_pass)
        return false
    end

    if text:find("Информация о игроке") and checking_stats then
        print("i have checked stats")
        text = text:gsub("{......}", "")
        player_data["nick"], info_about = text:match("Информация о игроке (.+)%[(%d+)]")
        player_data["money"], player_data["bank"] = text:match("Деньги%: (%$[%-]?%d+)\nБанк%: (%$[%-]?%d+)\n")
        player_data["fraction"] = text:match("Фракция: (.-)\n")
        player_data["transport"] = text:match("Транспорт: (.-)\n")
        player_data["house"] = text:match("Дом: (.-)\n")
        player_data["vip"] = text:match("Премиум аккаунт: (.-)\n")
        player_data["reg_date"] = text:match("Дата регистрации: (.-)\n")


        sampSendDialogResponse(dialogId, 0, 0, "")
        checking_stats = false
        return false
    end
end

function change_sp(new_id)
    spectate_id = new_id
    in_sp = true
    show_info_menu[0] = in_sp
    lua_thread.create(function()
        wait(1)
        if new_id ~= info_about and os.clock() - last_checking_stats > 1 and not sampIsDialogActive() and not checking_stats then
            checking_stats = true
            sampSendMenuSelectRow(3) -- sampSendChat("/stats " .. spectate_id)
            last_checking_stats = os.clock()
        end
    end)
end

function samp.onShowTextDraw(id, data)
    if data.text:find("~y~%(%d+%)") then
        spec_textdraw = id
        change_sp(data.text:match("%((%d+)%)"))
        return false
    end
    if data.text:find("ID Akkay") then
        return false
    end
end

function samp.onTextDrawHide(id)
    if id == spec_textdraw then
        in_sp = false
        show_info_menu[0] = in_sp
        spectate_id = -1
    end
end

function samp.onTextDrawSetString(id, text)
    if id == spec_textdraw or (spec_textdraw == -1 and text:find("~y~%(%d+%)")) then
        spec_textdraw = id
        change_sp(text:match("%((%d+)%)"))
    end
    if text:find("HP") and text:find("Ping") then
        players_platform[tonumber(info_about)] = #text:match("Android: (.+)") == 2 and "Mobile" or "PC"
        player_data["hp"] = tostring(text:match("HP: (%d+)"))
        player_data["ping"] = tostring(text:match("Ping: (%d+)"))
        player_data["speed"] = tostring(text:match("(%d+) / [%-]?%d+"))
    end
end

function spectate(arg)
    local findedNicknames = {}
    local sendSpec = false

    if arg:find("[0-9]+") then
        sampSendChat("/sp "..arg)
    elseif string.lower(arg) == "off" then
        sampSendChat("/unsp")
    elseif string.lower(arg):find("[0-9a-z%[%]%(%)%$@_=]+") --[[ SA-MP Nickname RegExp (without A-Z, because argument in lowercase) ]] then
        if string.len(arg) <= 2 then sampAddChatMessage("{ffff00}|{ffffff} Длина /sp [ nickname ] должна быть больше двух.", -1) else
            for i = 0, sampGetMaxPlayerId(false) do
                if sampIsPlayerConnected(i) and sampGetPlayerScore(i) == 1 then
                    if string.lower(sampGetPlayerNickname(i)):find(".*"..string.lower(arg)) then
                        table.insert(findedNicknames, sampGetPlayerNickname(i))
                    end
                end

                if i == sampGetMaxPlayerId(false) then sendSpec = true end
            end

            if sendSpec then
                if #findedNicknames == 1 then
                    sampSendChat("/sp "..getPlayerIdByNickname(findedNicknames[1]))
                elseif #findedNicknames == 0 then
                    sampAddChatMessage("{FFFF00}|{FFFFFF} По {4a86b6}"..arg.."{FFFFFF} не найдено совпадений", -1)
                else
                    sampAddChatMessage(("{4a86b6}[SP]{ffffff} По %s найдено %s совпадений:"):format(arg, #findedNicknames), -1)
                    for i = 1, #findedNicknames do
                        sampAddChatMessage("{FFFF00}|{FFFFFF} "..findedNicknames[i].." {4a86b6}["..getPlayerIdByNickname(findedNicknames[i]).."]", -1)
                    end
                end

                sendSpec = false
            end
        end
    else
        sampAddChatMessage("{ffff00}|{ffffff} Введите /sp [ id / nickname / off ]", -1)
    end
end

function gadm_cmd()
    show_main_menu[0] = not show_main_menu[0]
end

local days_of_week = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"}

lua_thread.create(function()
    while true do
        wait(1000)
        session_online = session_online + 1
        cfg.online.total = cfg.online.total + 1
        local week_name = days_of_week[tonumber(os.date("%w")) + 1]
        cfg.online[week_name] = cfg.online[week_name] + 1
    end
end)

function specReload()
    if in_sp and not sampIsChatInputActive() and not isCursorActive() then
        sampSendMenuSelectRow(1)
    end
end

function changeSpecCursorMode()
    if show_info_menu[0] then
        _showSpectateCursor = not _showSpectateCursor
    end
end

function reconnect(delay)
    local delay = tonumber(delay) or 1

    sampDisconnectWithReason(quit)
    sendNotification(gnomeIcons.ICON_WARNING, "Переподключение.", "Переподключение через "..tostring(delay).." секунд.", "", delay)
    lua_thread.create(function()
        wait(delay * 1000)
        sampSetGamestate(1)
    end)
end

function sendFormCommand()
    if not isCursorActive() and admin_form_menu[0] then
        if formCommand:find("pk %d+") then
            pk_cmd_id = formCommand:match("pk (%d+)")
            sampSendChat("/jail "..pk_cmd_id.." 20 PK`ed // "..formStarter)
            admin_form_menu[0], formStarter, formCommand = false, "", ""
        elseif formCommand:find("ck %d+") then
            ck_cmd_id = formCommand:match("ck (%d+)")
            sampSendChat("/ans "..ck_cmd_id.."CK by "..formStarter)
            lua_thread.create(function()
                wait(CMD_DELAY)
                sampSendChat("/ck "..ck_cmd_id)
            end)
            admin_form_menu[0], formStarter, formCommand = false, "", ""
        else
            sampSendChat("/"..formCommand.." // "..formStarter)
            admin_form_menu[0], formStarter, formCommand = false, "", ""
        end
    end
end

function pk_cmd(arg)
    local id = arg:match("(%d+)")
    if id ~= nil then
        lua_thread.create(function()
            sampSendChat("/jail " .. id .. " 20 PK`ed")
            wait(CMD_DELAY)
            sampSendChat("/aheal " .. id)
        end)
    end
end

function gg_cmd(arg)
    local id = arg:match("(%d+)")
    if id ~= nil then
        sampSendChat("/ans " .. id .. " " .. cfg.gg_msg)
    end
end

function asp_cmd(arg)
    local id = arg:match("(%d+)")
    if id ~= nil then
        lua_thread.create(function()
            sampSendChat("/sp " .. id)
            wait(CMD_DELAY)
            sampSendChat("/a взял на слежку " .. id .. " ID.")
        end)
    end
end

function sendNotification(icon, title, firstLine, secondLine, secondsToHide)
    notification[0] = true
    notificationInit = {
        icon = icon,
        title = title,
        firstLine = firstLine,
        secondLine = secondLine,
        secondsToHide = tonumber(secondsToHide),
        systemTime = os.clock(),
        positionY = 0
    }

    lua_thread.create(function()
        while notificationInit.positionY ~= 40 do
            wait(1)
            notificationInit.positionY = notificationInit.positionY + 5
        end
    end)
end

local spectateDisconnectNickname = nil

function samp.onDisplayGameText(style, time, text)
    if text:find("~b~Player.*") then
        sendNotification(
            gnomeIcons.ICON_PERSON,
            player_data["nick"].." отключился.",
            "Скопировать его ник - "..rkeys.getKeysName(cfg.hotkeys.disconnectSpecCopy),
            "Скопировать можно только в течении 10 секунд.",
            10
        )

        spectateDisconnectNickname = player_data["nick"]

        lua_thread.create(function()
            while true do
                wait(0)
                if os.clock() - notificationInit.systemTime >= notificationInit.secondsToHide then
                    spectateDisconnectNickname = nil
                    break
                end
            end
        end)

        return false
    end
end

function spectateDisconnectCopy()
    if spectateDisconnectNickname then
        if setClipboardText(spectateDisconnectNickname) then
            sendNotification(gnomeIcons.ICON_PERSON, "Никнейм игрока скопирован!", spectateDisconnectNickname.." записан в буфер обмена.", "", 5)
            spectateDisconnectNickname = nil
        end
    else
        sendNotification(gnomeIcons.ICON_CLOSE, "Ошибка!", "Никто не отключался,", "или прошло 10 секунд с момента отключения игрока.", 5)
    end
end

function hexToImVec4(hex, aplha)
    local alpha = alpha or 1.00
    return imgui.ImVec4(
        tonumber("0x"..hex:sub(1,2)) / 255, tonumber("0x"..hex:sub(3,4)) / 255, tonumber("0x"..hex:sub(5,6)) / 255, alpha
    )
end
-- Debug console commands
sampfuncsRegisterConsoleCommand("execute.notification", function(arg)
    if string.find(arg, "\".*\" \".*\" \".*\" %d+") then
        local title, firstLine, secondLine, secondsToHide = string.match(arg, "\"(.*)\" \"(.*)\" \"(.*)\" (%d+)")
        sendNotification(-1, title, firstLine, secondLine, secondsToHide)
    else
        print("execute.notification usage: execute.notification \"[title : String]\" \"[1st line : String]\" \"[2nd line : String]\" [secondsToHide : Int]")
    end
end)

sampfuncsRegisterConsoleCommand("execute.specAction", function(arg)
    doSpecActions(arg)
end)

sampfuncsRegisterConsoleCommand("execute.specAdminPanel", function() specAdminPanel[0] = not specAdminPanel[0] end)

sampfuncsRegisterConsoleCommand("execute.form", function ()
    admin_form_menu[0], formStarter, formCommand = true, "DEBUG_EXECUTE_FORM", "me DEBUG_EXECUTE_FORM"
    form_secondsToHide = os.clock()
end)

sampfuncsRegisterConsoleCommand("execute.passwords", function()
    print(cfg.adm_pass, cfg.game_pass)
end)

sampfuncsRegisterConsoleCommand("execute.cursor", function() print(_showSpectateCursor) end)
sampfuncsRegisterConsoleCommand("execute.newMenu", function() newMainFrame[0] = not newMainFrame[0] end)
sampfuncsRegisterConsoleCommand("execute.addChecker", function(nickname)
    table.insert(cfg.checker.players, nickname)
    save_config(cfg)
end)

-- ниже лучше ничего не трогать
sendchat = sampSendChat
addchatmessage = sampAddChatMessage

function sampSendChat(text)
    sendchat(u8:decode(text))
end


function sampAddChatMessage(text, color)
    addchatmessage(u8:decode(text), color)
end

function changeTheme:applySettings(table)
    for i = 1, #table do
        if table[i][1] == "ImVec2" then
            imgui.GetStyle()[table[i][2]] = imgui.ImVec2(table[i].change[1], table[i].change[2])
        elseif table[i][1] == "Int" then
            imgui.GetStyle()[table[i][2]] = table[i].change
        elseif table[i][1] == "ImVec4" then
            imgui.GetStyle().Colors[imgui.Col[table[i][2]]] = table[i].change
        end
    end
end

function changeTheme:resetDefault(table)
    for i = 1, #table do
        if table[i][1] == "ImVec2" then
            imgui.GetStyle()[table[i][2]] = imgui.ImVec2(table[i].reset[1], table[i].reset[2])
        elseif table[i][1] == "Int" then
            imgui.GetStyle()[table[i][2]] = table[i].reset
        elseif table[i][1] == "ImVec4" then
            imgui.GetStyle().Colors[imgui.Col[table[i][2]]] = table[i].reset
        end
    end
end

function imgui.Theme()
    local style, colors, color = imgui.GetStyle(), imgui.GetStyle().Colors, imgui.Col
    local ImVec2, ImVec4 = imgui.ImVec2, imgui.ImVec4

    imgui.SwitchContext()
    --==[ STYLE ]==--
    style.WindowPadding     = ImVec2(5, 5)
    style.FramePadding      = ImVec2(5, 5)
    style.ItemSpacing       = ImVec2(5, 5)
    style.ItemInnerSpacing  = ImVec2(2, 2)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing     = 0
    style.ScrollbarSize     = 10
    style.GrabMinSize       = 10

    --==[ BORDER ]==--
    style.WindowBorderSize  = 1
    style.ChildBorderSize   = 1
    style.PopupBorderSize   = 1
    style.FrameBorderSize   = 1
    style.TabBorderSize     = 1

    --==[ ROUNDING ]==--
    style.WindowRounding    = 5
    style.ChildRounding     = 5
    style.FrameRounding     = 5
    style.PopupRounding     = 5
    style.ScrollbarRounding = 5
    style.GrabRounding      = 5
    style.TabRounding       = 5

    --==[ ALIGN ]==--
    style.WindowTitleAlign      = ImVec2(0.5, 0.5)
    style.ButtonTextAlign       = ImVec2(0.5, 0.5)
    style.SelectableTextAlign   = ImVec2(0.5, 0.5)

    --==[ COLORS ]==--
    colors[color.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[color.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[color.WindowBg]               = ImVec4(0.07, 0.07, 0.07, 1.00)
    colors[color.ChildBg]                = ImVec4(0.07, 0.07, 0.07, 1.00)
    colors[color.PopupBg]                = ImVec4(0.07, 0.07, 0.07, 1.00)
    colors[color.Border]                 = ImVec4(0.25, 0.25, 0.26, 0.54)
    colors[color.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[color.FrameBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.FrameBgHovered]         = ImVec4(0.25, 0.25, 0.26, 1.00)
    colors[color.FrameBgActive]          = ImVec4(0.25, 0.25, 0.26, 1.00)
    colors[color.TitleBg]                = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.TitleBgActive]          = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.TitleBgCollapsed]       = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.MenuBarBg]              = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.ScrollbarBg]            = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.ScrollbarGrab]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[color.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[color.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[color.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[color.SliderGrab]             = ImVec4(0.21, 0.20, 0.20, 1.00)
    colors[color.SliderGrabActive]       = ImVec4(0.21, 0.20, 0.20, 1.00)
    colors[color.Button]                 = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.ButtonHovered]          = ImVec4(0.21, 0.20, 0.20, 1.00)
    colors[color.ButtonActive]           = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[color.Header]                 = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.HeaderHovered]          = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[color.HeaderActive]           = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[color.Separator]              = hexToImVec4("4F4F4F")
    colors[color.SeparatorHovered]       = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.SeparatorActive]        = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.ResizeGrip]             = ImVec4(1.00, 1.00, 1.00, 0.25)
    colors[color.ResizeGripHovered]      = ImVec4(1.00, 1.00, 1.00, 0.67)
    colors[color.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.95)
    colors[color.Tab]                    = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[color.TabHovered]             = ImVec4(0.28, 0.28, 0.28, 1.00)
    colors[color.TabActive]              = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[color.TabUnfocused]           = ImVec4(0.07, 0.10, 0.15, 0.97)
    colors[color.TabUnfocusedActive]     = ImVec4(0.14, 0.26, 0.42, 1.00)
    colors[color.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[color.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[color.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[color.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[color.TextSelectedBg]         = ImVec4(1.00, 0.00, 0.00, 0.35)
    colors[color.DragDropTarget]         = ImVec4(1.00, 1.00, 0.00, 0.90)
    colors[color.NavHighlight]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[color.NavWindowingHighlight]  = ImVec4(1.00, 1.00, 1.00, 0.70)
    colors[color.NavWindowingDimBg]      = ImVec4(0.80, 0.80, 0.80, 0.20)
    colors[color.ModalWindowDimBg]       = ImVec4(0.00, 0.00, 0.00, 0.70)
end

function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then -- слева
        renderFontDrawText(font, text, x, y, color)
    end
    if align == 2 then -- по центру
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end
    if align == 3 then -- справа
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
	nameTag = false
end

function getCarName(id)
    id = tonumber(id)
    car_nums = {525, 552, 437, 582, 431, 510,
    490, 488, 497, 420, 416,
    472, 528, 406, 407, 408, 428,
    438, 443, 471, 485, 486, 524,
    530, 531, 532, 544, 571,
    572, 574, 596, 597, 598, 509}
    car_names = {"Towtruck", "Utility Van", "Coach", "Newsvan", "Bus", "Mountain Bike",
    "FBI Rancher", "SAN News Maverick", "Police Maverick", "Taxi", "Ambulance",
    "Coastguard", "FBI Truck", "Dumper", "Firetruck", "Trashmaster", "Securicar",
    "Cabbie", "Packer", "Quad", "Baggage", "Dozer", "Cement Truck",
    "Forklift", "Tractor", "Combine Harvester", "Firetruck LA", "Kart",
    "Mower", "Sweeper", "Police Car (LSPD)", "Police Car (SFPD)","Police Car (LVPD)", "Bike"}
    for k, v in pairs(car_nums) do
        if id == v then
            return car_names[k]
        end
    end
    return getGxtText(getNameOfVehicleModel(id))
end

function onReceivePacket(id)
    if (id == 36 or id == 32 or id == 37) then -- closed conn, wrong srv pass, banned
        alogin = false
    end
end

-- File: 'Cantarell-Bold.otf' (69196 bytes)
cantarellBold = "7])#######)*bH;'/###[H7+>)322'Ql#v#RxMT9hKp%W:6)##87)###JiT9r1)%S;bE>#Xk$##v5:t8qjjcDOA'##?2dw'%;,h<C?aXq>q+##kw(##Wf+e=L,Y?qx*dw'ZWe--#/ue=E<4xF?r)##K'^w'7vA0FZ/'kcn7*##k5+##GtBUC#BOdM)QOk+P=r-$f'TqL'&d;HtRr92>M[w'E3n0F^ENi`SICwKHk%##Pr[=BNnI87'fX&#SJf--w:]=Bemd^0Y<q92E](##Q1CiF<BxCNB5hQavTi--g7?>#/VNh#4xn.p.ge<6'..w#Blx&#`eotOm1MIMF=/cVoke2'm+Zw0PMYY#.hAG2'>uu#nNK:#lq8auWWf]$1'9kMh@$##f6%##(V<j0vEec;<3]V$Ze5AO$]X&#<,LF%0op:#`%eS%/rQS%^U/V/q3PuuE4hEo:h$(#=mgv7B:F&#ED1Z#srC*Mc>8S#i.$##+SO;.h3`l]8=P&#4.;t-ZkwfNLi_U#<B`T./lUZ#*0)t-V(ofLB#TfL::^?.[/-j'>h-?$3W,#>3LHZ$dX+,M0=?v$9mmr[3X;s%Z45Dk9-AT&0YW>5:6]p&j$lcM;?x5'mVMMp<H=Q'i;[PfLf;L)1]YYu'5>>#0>###2,IwK.(1B#wJFSR<UL^#5<w4]1:h#$3<g%b2C-?$#sQA43LHZ$RepiB0=?v$q]<;R3X;s%<%Zca9-AT&_ur1p:6]p&UXbPA;?x5'kBslS<H=Q'LLI2T]qxM)&n95o+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%Rm>G2WMhA5)p4L#Vrd'&YJ7A4>36R*A=@_/2O/F%A[u1BE;Qq2e+Be6m%L`E@x&?-/`?VH?qTJD<[6^GK.75&W*?X1:*G_&VR?M9I^MDFZkk>-W*f'&5ef'&)=Z'8:si+M5If>-cFII-8)m<-fQqw-pm-qLI4urL6#/qLIwXrLIQ-5Nh0n+#;1SnL$NpnL:*8qLGWdD-lIe2Mw6;PMw'crLNwtRMM`7(#-Us-$-o^%O7juG-g&l?-CbDE-$^mL-QMYdM]mrpL$SxqLxT`/#(TC5BE9Q@0#8ujtT.Pk+a:p^f?_n-$>N_w'_j;MB`]iQj+O;_8K.R9`HHO-Z-pl%=/mC5BWV6^5rw4R*C9g'&G-QY5+v4L#vSWiBT1PcDlE`>Hn2iKY@5scE<<i`FBt9/D6pjG<=;tjtYBDP8DX=gG&>.FHMeZ<0+9IL2>*e-3<6i41f&@UCVpIKF&6FVC^x2s7:8QhFsl<6&h=r*HhxtLF%g9fFM>4sLX2oiL8H%oD#SI+H-6eYH#g1eGvRb-631(O;iG3VCd6u?-BdiM1+sDSC7;ZhFgLqk1T+IU;Yg>[947V.G'fC90rxuhFH-B5B8tDU)2?ijE2MD5B&?^kEdjeUCCt7FH-ESE-rGnC-=;G;&:4//G/3`$H(Av-GWPX$HAm@bF&B8I<a_%##C^'=-Pk,-0f[&*#TZO.#3^GW-1SNe$#Cl>-<9i5U+xZiMFi7(#43h'#/v^L&TAe>-B2K<&qR(UDeVpg2D?@P1BpJF4CC^>-#-,.Zu?l051#'58[,'K2*Og+M%c@(#Mi)M-p?dA%-'7L2.rn@-a=hM1`=hM1o+]p8Pt[rHNn[f$)iH]FpB7L#E&w9)'Ns.Ct*39BcuiS8A:x+H7$7rLgO,.#R/(t-(H<RMZPr'#&T3rLnX+rL:2CkL?wXrLn@dt7gPc/amE;/#ooao7.t@eEA5Mq1+>Z1FCT5fG=h8OtlxtLF`C/C/O`V5BMx$[T_'ufD?gURE(Z$6B%uEGHwww<:x1TpTwJ?&4blRB$ujFD'>^cp8'<H&#tUB#$>A@&,Pee8.qk$v#Fle&,Ur./LVMsYl+*[0#0Ni,#x(eK#GLpM#xV+Q#BZ2W#r=lu#bKt]#62N`#HBno#abCv#Heww#Y?kx#v86$$3p2%$K=FE$YldG$ZQiK$%^OM$APhN$T=wO$VrFU$]LpY,:T+^,Z;1_,9FBb,p8/e,T[eh,5t^j,O*gU-+[r<-=Bx=-Nsk>-er?@-(YEA-:@KB-[_SM-1%`k-E)1Z-erH[-Rv(s-'nIt-9<+u-Js'v-tXWx-fV+'.(8V8.hxd<.__Qs.*x$-/2:I-/>_*./FwN./`pp//uktY/HZh]tTle+Mb:H&#T4KM#WKDO#D%7S#R/sW#:$4]#I2gKMEUfo#WIuu#_EdL/s,$$$[;TkL;l?(#UkiYGR;>5Swv_YY;cPM^Q6b`a3TTYl@-t]#2[e],XlVP0+jXV7f`su?JI(2L2hW3k[sK&#gHoj(B*A&,qpS3k(*WA5Eo)5k8$k3k`6A3kp)54k%@b#$/PrudqtbAk$sFuuZ$H7v@W=2vxWi0v=AE-vjAq+vCCr(vqCG'v0=X]u'X`ku'/wguoY6gu]gteuOHFeue;0UuV_5NutmtIuQH=Iu?nIHu7U%HuwI>FuKOrBmpYFAmKN`?m7O5>moCN<mW`?vl*-+9mlK.8m[k(rlPXcqlJFGqlD.#ql.Gsol&/Noli;6nl@Y_bl-C=Xle3MVlGkDKl[i??lG2C>l>aOxk*e7<lNlA9lb#U6lTB+xk6hUfkYV02ktKt1kn3O1kh'=1k^LI0kxn^IjJ6nVi8@,2;'iF&#S,a2.d[k,Ml9-##cfq#5&/5##*;G##.GY##2Sl##6`($#:l:$#>xL$#B.`$#F:r$#JF.%#NR@%#R_R%#Vke%#Zww%#_-4&#c9F&#gEX&#kQk&#o^''#sj9'#wvK'#%-_'#)9q'#-E-(#1Q?(#5^Q(#9jd(#=vv(#A,3)#E8E)#IDW)#MPj)#Q]&*#Ui8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#rhc+#vtu+#$+2,#(7D,#,CV,#0Oi,#4[%-#-$###-G31#4`W1#KX#3#bE24#gK;4#lQD4#qji4#vpr4#$-85#(3A5#,E]5#3^+6#5d46#:j=6#B,c6#HP_n#8ut.#>$S-#3kf=#99v3#Sd0+$N4C/#X==&#E*20$^=$,$hHO&#VVH,$Rw<x#->M0$TM=.#N1ba%:Ec._Yfw1BWgZA+2bqY,P'.DEH5XxtYvl.L<HSoRJa1,)`31Jql&*DsfW-Grdf_G2re&#57:nS%.V:v#K[K;6BK'8Il,E`sPcRfL/S3JL7@G`N?'@YP?q_xOKp8SR/>##RYoLiTYvqIqx+<JLg8$2K##[iKu+WfLxc_lJ=_C#$-PNh#u<*1#o<W;QNL-##,8>>#'bR0:)im90V#:B#&),##%G$0#?sn@tnq51K7XN=$l*$o[n(>$,6fk>,(g7Op1SGs-aq0hL(V6GE2J,W-J:2I$SDkk(H4Ke6enfi'Vl8>,sjai06l7(5QN%29mC2A=4WViB`W=SII>[Eenp,kbW$J3#kd`4#0d46#IVL7#n$X9#7$-;#PmD<##Jc>#?:%@#d^0B#-^ZC#U7#F#mhlF#-[.H#HZXI#82'sLZ=IQMDB*;QUo6JU(Tw7[I*'Abhxn4f-t@`jF]2SnXnb.qoMSxt4=E5&M&7)*m-`S.'Epf1B:'v5b`,)<9Z22BRI?AFn>LPJ0%>DNM8clSw&iuY@4Vf_[)ducrRt1g.q.DjG`;SncTHcr$,G##@<(g(o?I5/9c3#5fl5)<7HZPASRd]F#)3/L?'[YPUPllSjt&)W.mNS[Jkw(agiISe-hr(jIfDSnfdm(s,]h;$HT1g(eRY;-+Q,g1GOT;6dM'g:*LO;?C5A/C_0jYG%/</LA-eYP^+7/U-jWS[Lq*)aun,/h?#UYl[w'/qxuOYu>hAm&ZfjA+'9T/1GO^;6fS0g:,RX;?TC$aEqAL5J7@u`NXl$jT$$M>Y@xui^]vG>c#upig56f`jQ485on2a`s4+[s$P#%H)mwLs-3vuG2OtGs6lrpG;2qBs?NokGDkm=sH1lfGMMj8sQjhaGV0g3sZLe[G`ic.sd/bVGiK`)smh^QGr.VLZ#JNl/(gL>Z,-Kg/1II9Z5fGb/:,F4Z>HD]/CeB/ZG+AW/LG?*ZPd=R/U*<%ZYF:M/_c8vYc)7H/hE5qYlb3C/q(2lYuD$^m&ax/B+'wWm/Cu*B4`sRm8&r%B=BpMmA_nvAF%mHmJAkqAO^iCmS$hlAX@f>m]]dgAb#c9mf?abAk[_4mox]]At>ONT%ZMw)*wKIT.=Jr)3YHDT7vFm)<<E?T@XCh)EuA:TI;@c)NW>5TRt<^)W:;0T[V9X)as7+Te96S)jU4&Tnr2N)s8+I<$T#ig(qw:<-7vcg1St5<6pr^g:6q0<?RoXgCom+<H5lSgLQj&<QnhNgU4gw;ZPeIg_mcr;d3bDghO`m;ml^?gq2V:$#NNYN'kL,$,1KTN0MI'$5jGON90Fx#>LDJNBiBs#G/AENKK?n#Ph=@NT.<i#YJ:;N^g8d#c-76NgH,C^kah4Qo&jxAtH$K6&exsa*+wE6/Guna3ds@68*ria<Fp;6AcndaE)m66JEk_aNbi16S(hYaWDf,6]adTaa'c'6fCaOaj`_x5o&^JasBUEt$_MeH)%L7t-AJ`H2^H2t6$GZH;@E-t?]CUHD#B(tH?@PHM[>#tQx<KHV>;tsZZ9FH`w7osd=6AHiY4jsmv2<Hr<+7[#X#V0(uw([,;vP01Wt#[5trK0::qtZ>VoF0CsmoZG8c&kKQQ3$PnO[NT4N.$YPLVN^mJ)$c3IQNgOG$$llELNp2Du#uN6g6&k49b*0*Fq.IoR*3h)]680./b<F^Z9@c[-eD'TU9IIq_ENnOeNT<snZYX'xg_w+J<d>38-i^@&tm-#,'tS^1O'ukY$,;j,O0WhT$5tf'O9:eO$>VcxNBsaJ$G8VW3KRHeBOnC7nS4B`BXP@2n]m>ZBb3=-nfN2:'kp`%[c=:ZMF.#nt7TPp;-iV5W-#j-+%Wl-+%32a,Fu@ViF)M/+%`>kdGqWd<Bkkos7-2vLF0ehmMIB+9B+)YVC;V<j0P%VeG%^4rC&TFvB$IlT8xGA>Bi>pKF7+G(&M[O<B0&%mBg[+p81(=2Cm*cp8u2j=B0Gae$3g-CJ4X/+%3j?_J2Iae$XU2x9:0G(&GqMhP4X/+%Zt[q;$7/XCIkZOO>ElC&XUDX:4Oae$XIQ@9<6G(&A(:oD>T<.3XvfG3M57A-CDVT.LGcdG7mL5/bx^kE0$@RMmD5kM6^XnMm;pNM;S=RMmD5kMx]XnMq`1hND<En:vOX-O61$1OOthd-nu-+%aH;7D$EpKFoj[:CH2*:B+)YVCI/#dM)qJjM/vDN;.RucEoNZJ;@7pcEmZ;,<^>NDF/J-d3,K_w-aGHOM_$1oM*H*-GBCffG&'AUCNp7UC#AokMQ,:oMs`POMQ#uRMc4WOD%Lv<B:>-lE3.jiF-ESD=Iqh]GmZA)4jeV)4@l#=C?qae$:S#.-@tae$fvmwpJjlC&hZhTCui#lE0=TF%X4`D4pxGs-fc)PM,@LSMXV6VBC&orLlZ)DHnWrTCBHg;-&`8N-DQp;-&cAN-GvCp.n.?LF2l<I$0/q[^P8`%'&^=jVCNqoM*iw.O.+E2O0u3/OP5W2O,M`PMjf-TM9D@#8QN>8J=EtW-GF1beGsTNMfVai2hX7fG3Y<I$v_;I$AqEI$PFRR2P']LM>eov78SfS8(F*W-7LUU)]%.+%^(.+%f@.+%:#(W-<1B@'iI.+%%;jS8'J8p8cU`X-$g-+%0_*W--VA@''G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8/xxp8thO<B0ZX7D--r3=CK-44CK-44?n7LM%>,k2Z]F_J5sH_J5sH_Jb-Fu7*HX7D'+OGH&%G(&P;hjM=:oQMg*-(HxVKSDAEi`F8HIk=,7@LMmqvh2kTN,3Jl2i-[Sa3XCR8791qcP9UgA,3Z(Z,3+.9@'5>iHmDSlC5*G%'ItrY1FA6m5MImK8/-Q@@H7qhQMTecHMVrdL2qXPHMB0eL2M=;iFm/pgF4LNO+)BkG3&CIe-*@+IH-:@LMG&*i2(Hd50k2+hFw)9kEVNYOFY/3CAY/3CAY/3CA+?tQjXwZ'].@ILM$8aI3>.B?.bgIoDY/,d3_@Mt->:[hM^edhM>%Gc-b'5L>-77LMtrvhMeumL2Y-/d3Vg`&.FkNiMXnSN-^qSN-`-50.QW^jM^e_).RZTNM^aQL2U^&g2NEUkF3e3d3$]=oM;)3i2u*3d35JX%8%wxc32`h;-FaQi$b8P)YZ)3i2i3TkM:a&k$FbSR9d;B,3kNE,3QTgmUZ/N.3T.s,4Z/N.3[n0B6i_;u7duxc3rw)W-Dj>kk0j>kk>QKjMWJX%8*vxc38w*W-)uVkF?6+W-Em>kk1m>kklwVkF1m>kklwVkF4Yh;-=&F_$B@3u7vl]G3lWaG3lWaG3lWaG3lWaG31UeG3.Re;-lu+G-2o'S-2o'S-mu+G-mu+G-<op=99',d3BG'`$^i/K<WqvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMmrvhMv9wL2KGRR2CI[hM>u+G-nu+G-nu+G-XhlI9E',d3nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-nu+G-=op=9?',d3avVE-pu+G-teldMp.<iMs<EM2?SdA5f7,dM+:NiM+:NiMS<NiM8;NiM8;NiM8;NiM8;NiM50lo$AYTj2NW1s7OW1s7OW1s73X0s7UTJkX]FKkX;b7LM;qJjMo%NY$@WKjMBqJjM3rJjM3rJjMPqJjMQwSjMCwSjMCwSjMWWYd$7[;<Jm'8r8(I,p8.g:<Jm'8r8eaB<Jm-S79Lvxc3^)g;-rVYd$7[;<Jm-S79Lvxc3^)g;-rVYd$SQ#w7M[+p8&E2p8'NM59p%J59o#M59p%J59<'f;-'q(P-LjmF9#wxc35c-W-I$n?g5$n?gBf?vei,gjMp-gjMp-gjMJ_im$8f`sfo9oR9.obsfm-S79N',d3)v+G-SB$i$?rF]HrN:79-?ojLt7kvLfjAjMW:ArLovSjMp&^jMI:ArLx)TNM]_ZhM]_ZhM_gZL2eAK,3UPp;-g%K,M+#879Nw,D-O*H`-,-ak+4h<iMZ)b+.R0ohM2mmhM%lmhM&rvhMPrvhMPrvhMOsvhMOsvhM_rvhM_rvhMPrvhMPrvhMPrvhMQx)iMow)iMow)iM`x)iM`x)iM3$*iM3$*iM%$*iM',*M2JchD4f7,dM')3iM')3iMD(3iMD(3iMD(3iMD(3iMc[+S9a#/>BP#kSM]f6;B+)YVCMD[20X^IUC-mgoDHX#c%bZ=&581<&5*dYA5*dYA5*dYA5*dYA5*dYA5xK]A5:n0s73X0s73X0s73X0s73X0s7Y(d;-%JSZ$$mjv%ejAjMYX]v7Y?/s7Y(d;-1pRQ-1pRQ-1pRQ-1pRQ-.5SnMPtAN2eNY88f7,dM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM%rJjM&xSjMA#TjMA#TjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM&xSjM'(^jMB)^jMB)^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM'(^jM0E^N2LPnn2e$]hM>u+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-(v+G-))Gc-1):UDrCY[?*G%'I61be$XWu3F'Iw3F'Iw3F'Iw3F'Iw3F%=e3F-9IL2?1`,37u_kLXGp;-VPp;-WPp;-XPp;-YPp;-ZPp;-j%K,ML5q-NOkAjMF*W#MvvSjMosANMVaQL2fuU*43r*cH+HOVCt>]:Cc>^G3fdfH3DSFvBndR:C8T87*9+Rd3=imfGH;)=-q8&F-;Gg@5^aZI<j0v<B/GqoDwAXVC#VRfG1TfUC5=^b%Y(+SM(H[oD3h?=(<$kCI^^<C4$'kjEidIqCXORFH,iViF*JVEHQZ.rL`EWhFGE]'.AU*iMa%J`GaKitBtr>LFvY9oD>D?LF,vCeGuP2e.vq`7B&2>s/=xEcH$D2iFFpu8.1rw+H9XK/De00eQEQY_&HOrG3hl-+%<*xG3u_8@'=H0NM(6199`Yud3p+dfGv.@bHE)vW-H%3@0H:;H4d]:&5Gk=2CIYL)4<^$x-Pe7LM7],034;:WCm<DtB$N'kEFxnq.nu,(5/I+IHDjTNM5af+4r*]u-P[%1MhrAN2EG[88Y#&'.OC@lL70P<8U00oLQj.jLVedhMfkmhM2olUA,(F6)iVs:'.cF&#$<aufgi1F?VE#pJ?sO8';WE1#:n@-#B<x-#(?)4#c:w0#Ylj1#&hGN#Q^V4#EE24#KlsL#+m?0#/0:/#rONL#>.92#:3m3#cQD4#M>S5#&3A5#,9J5#^fa1#5j=6#4^+6#<,c6#<vO6#wqG3#GJ:7#F>(7#KD17#Yx&2#T]U7#Tih7#1.d3#/C[8#a7I8#g=R8#+5B2#pnE9#ob39#w0k9#w$X9#Kki4#,OB:#+C0:#0I9:#VF^2#9b^:#9np:#SL;4#@)9M#A4KM#E@^M#ILpM#MX,N#Qe>N#UqPN#Y'dN#^3vN#b?2O#fKDO#jWVO#ndiO#rp%P#v&8P#$3JP#(?]P#,KoP#0W+Q#4d=Q#8pOQ#<&cQ#@2uQ#D>1R#GA(7#uOLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#fF[8#CIpM#k[3T#ohET#stWT#w*kT#%7'U#)C9U#-OKU#7)02#@Z^U#5hpU#9t,V#=*?V#A6QV#EBdV#vVL7#@NvV#MZ2W#QgDW#UsVW#Y)jW#^5&X#bA8X#fMJX#jY]X#nfoX#rr+Y#=/IS#x.GY#%,###'Bvr#*GlY#8AFe#0Y1Z#4fCZ#8rUZ#<(iZ#@4%[#D@7[#HLI[#LX[[#Pen[#Tq*]#X'=]#]3O]#a?b]#eKt]#iW0^#mdB^#qpT^#u&h^##3$_#'?6_#+KH_#/WZ_#3dm_#7p)`#;&<`#?2N`#C>a`#E8<)#*YN1#'5n0#/SE1#+`sh#KV/a#OcAa#SoSa#W%ga#[1#b#`=5b#dIGb#hUYb#lblb#pn(c#t$;c#x0Mc#&=`c#*Irc#.U.d#2b@d#6nRd#:$fd#>0xd#B<4e#FHFe#JTXe#Nake#Rm'f#V#:f#Z/Lf#_;_f#cGqf#gS-g#k`?g#olQg#sxdg#w.wg#%;3h#)GEh#-SWh#1`jh#5l&i#9x8i#=.Ki#A:^i#EFpi#IR,j#M_>j#QkPj#Uwcj#Y-vj#^92k#bEDk#fQVk#j^ik#nj%l#rv7l#v,Jl#$9]l#(Eol#,Q+m#0^=m#4jOm#8vbm#<,um#@81n#DDCn#HPUn#L]hn#Pi$o#Tu6o#X+Io#]7[o#aCno#eO*p#i[<p#mhNp#qtap#u*tp##70q#'CBq#+OTq#/[gq#3h#r#7t5r#;*Hr#?6Zr#CBmr#GN)s#KZ;s#OgMs#Ss`s#W)ss#[5/t#`AAt#dMSt#hYft#lfxt#pr4u#t(Gu#x4Yu#'J1;$*M(v#.Y:v#2fLv#6r_v#:(rv#>4.w#B@@w#FLRw#JXew#Neww#Rq3x#V'Fx#Z3Xx#_?kx#cK'#$gW9#$kdK#$op^#$s&q#$w2-$$%??$$)KQ$$-Wd$$1dv$$5p2%$9&E%$=2W%$A>j%$EJ&&$IV8&$McJ&$Qo]&$U%p&$Y1,'$^=>'$bIP'$fUc'$jbu'$nn1($r$D($v0V($$=i($(I%)$,U7)$0bI)$4n[)$8$o)$<0+*$@<=*$DHO*$HTb*$Lat*$Pm0+$T#C+$X/U+$];h+$aG$,$eS6,$i`H,$mlZ,$qxm,$u.*-$#;<-$'GN-$+Sa-$/`s-$3l/.$7xA.$;.T.$?:g.$CF#/$GR5/$K_G/$OkY/$Swl/$W-)0$[9;0$`EM0$dQ`0$h^r0$lj.1$pv@1$t,S1$v&/P#xlk.#X#s4#mSl##WH4.#gAU/#Z#(/#gSq/#MDx1$*Q42$;UF.#C]F2$8@O*$4pb2$8&u2$t0;0$>8:3$BDL3$FP_3$J]q3$KM17#9o64$T%I4$X1[4$]=n4$aI*5$eU<5$ibN5$mna5$q$t5$u006$#=B6$'IT6$+Ug6$/b#7$3n57$7$H7$;0Z7$?<m7$CH)8$GT;8$f2>>#m9.5/9Mg%F<,KJ:^RB87WPs%OFT];$:(K;60?;2B-[P$BR9jU$%UqN$*8Fa$4/]P%DV7H%b#mN%8NTU%WLk*&DWI)&.g71&Fa,7&SHe<&gefA&l=-G&q;VK&**9Q&XhKb&'mRh&+t/m&AILr&,m,v&88b&'fl[-'76^2'<*R8''eU?'aA%H'8M`O'lf5V'N]T^'gfed'C/;k'):>J(A$e4(J_=:(m=d?(RBlB(9K$O(*ti[(3$,+)nZMw(F#(7)11Q_)u?ot)1T4u)m/cB*1[G7*f$ZZ*C4iK*q1Ku*VF7h*p&3l*Ex/u*J-?(+v,tA+kg'R+bSqv+k-Xe+s&_3,U6F2,Js0V,MfhC,/c:K,w?`S,tDf],q=cf,,3+q,=o-%--iU,-qW@5-01[@-D;-o-^-9^-Ft_0.N_ax-7uZ<.]GvG.5Lcn.l?pY.*?xx.Vkh,/LWI5/[Ih?/kjEI/&PHS/@gG_/mcnl/<,xt/D>m,01*3X0&?%T0V#)[05pGc0ePBj0O=-s0p/TB1FcB71S-w@1P29f15=Ou14>tm1K3<x1v[M-2E)`82rdH`2Cu,O2YclZ2PJ,(39JKj2hr3q2k+^B3Am_43YdS:3$%JE3jZxM3#>%X3hCi%4OUMh38_2p3oWd<4:n%.4Ijx64M+V[4Kt7I4^B.x4<9Am482G;57[%*56sip51;3e5E*Ho5^xf#6c_G,6O0Z46KRMl6VTMl6-;6@7%oU<7kdIE7`6Bn7k;?[7d%wd7a<T380lf#8RRo68Ct(H8rmYk8T#6W84Kt^8[mRe8.<D19k;ds8a6EI9(XtF9:s@M9Y&XY9&N%.:E-@t9`IQD:S5)5:V1&>:?[Jb:4$BN:Lt=Z:ivAj:.#O#;M+]2;DTw=;M-<I;jP#S;_r,[;t>5g;CnXr;O^A+<E018<HwDE<S^&N<A#'V<7r,%=xnIm<RGgr<QwXv<AS^?=Ga:)=V^8/=Y=43=UAg7=MkO;=G.Z[=Fs_D=_W8J=S1+N=.l.U=4,'Z=,q4_=w@tb=p8>g=S/n9>4Vu,>/os:>-'Y?>SKAF>sZ^_>O.Ml>4fY8?jFK$?+AG0?3dO;?%@v@?F7kF?hXIM?%3:W?<9J^?sA/f?'4Fj?P^3'@GX[.@9'xQ@-t5D@<QZL@D5]Y@>mD.AY3@*A:>6PACpt;Ada`AA-'6HAOB`TAVNM]A;8/fAZpg0B=Vg(B1-bJBl,+7BJ39CBSjpgBRaYWB#kN+C1ltvB+>mHC#?b3Cl%LWC,'wXCdt?aCHI(hCeQjuCxU+GDig:5DKU$ADa)bJDtI,%E&kd=E9lnUE`l<NEX<L`E/][qE`NE'F^kM2FW6h[F,87QFo?obFZM^gFEb)qFjb9<GsG3+GFId5GHTs>G8aaFGmC9OG>mJZGmW4gG/gLpGv_@#H/?C-H>GR6H1e'@H_19KHd[^oH8CXZH,9LdH?1'4InLG%I.79OIur]?IHHxJIu'FVI<^HaI.J</JUm;uII>N'J2A*/J$F08J1E6AJmS$IJ&4tRJ3QQ]J1SWfJ3X^oJ:8a#KKvi6Ks#xBKaeWNKfQBWKPmB`K?Ah-L,`_pKo$`xKNXY)Lv'90LMqW7L;6X?LgW7FL8'mLLpDvTL[XjfLep>pL%Cc@MtwQ2MhXS?Mb[-MMikxZM_=_hMCAmtM'Er*Nfma7N`KYDN7]OONE-7YNJVtcNqA^oN0,=(O>Y`6OUhvEO$n?qO'4abO^6<jOkuGtOfb)'PlM>1PQW_XP0I?IPp'JrPlbBdPU.26QMi*(QFYPPQEuECQ+i5XQT<&cQQ2pkQN7vtQL0s'RK2#1RSbi:RmGuDRoCrMRK72UR'o5]RYk^dR#WlhR-vCiR8D%jRDi[jRN14kRZUkkRg$LlR/d84Spe.rRY&RuRL[M#SFf3(SYDY-SMK;>SiBmaS1_bSS*iGXSf3QaSFof0TT(t$T[E#9T,2sfT0:['U6Df$UsCuHUo0M6Uh%PdU]t:QUl5_TU5#(xUw%SvUBjrBV/6F4V%K=<V@85pVUt_iVD@>pV@8_tV?62#W<1eBWV-7JWUpLmWr0psW)+w>XUbh*X7R(2X9vnVX=0u#.&URC*^JHw`GO44$j0un.cxFo.,0sI:?P5FsS8^:%r5Kf'QhPQs4KfNIZFuq-<hjh'-O+F)l((Jsq/Bnf)qh<dP0ig$Sgjm)B?h8&k#Ops]3#N#9nr]b$LPYYgd*u-$Kb/*UP9EsD4GPsS<EDsR2N;6$LrCsfZsDsCf-w#PjRI:l]HctKHEDsc4`_tR`Ys-alllL@S)JsF7r5/I9oHs+#TkLbiYs-<DXgL7I[Fsc4YUZMV;Q0XHpu$a9:]sGILxL0iKF&tRU:s/6ew#G*H[O:cLL0anv$0w_W;MlM`mO3'xObN[pX_BHda%v[;p@j@3^B`wxt#IlZ8%1kT7Cl?pktin]%Q6mIWMCrCxKG4h2N7W@fOXZ=sTim^Z$D)N+Kstt]tIB%u,$i#*fUrsl%9J>PLsvCPswDPYqbrhgK4cdYqdQC^smx>4&#7PfaE)M[X#v.-)g0Z.(U5gU.p$bw'3(tAFisM=,&2Ohq>rEW.M&H^,wF*l-hII*r%qKt,uNN7/Xo04/077v5kd[[sX,?Ys.#eb)B<KI(Q*1Re/2>_t#m2w.u(89^K.w^%WX=pC9`qkth2h)k9:V^O#DWId]WBh%b8::5+;pktWA>lL$]se+V_d:-CE5f(R*B>c=?RoO3dvb:8[$],H]Xj)`*)YKE8=FZo8kOXoQq9W[pbiHS]<4u_1Hn]c<*fF9^IfO2:t[^u/?TXWIDN';rpVoZ@_5%mQR^tQ7gCIK56.(:S42t@Jbdt,dC%48h`fO`C0vt9=3Y#9pil$@H$Kshv277m9VmhPYZYs>Ukk4>Q80Mx:;UsWfVRs.9nt5b<CV%D<5a$<tfstd]oO8-Eev7Xv>_-mN6`$&_0^sG'HR@1e9.t@LrCsm8dw)l[1'<DxGL0DMt&>88*Ds6,=it=e@_Od:oHsoxQYs_,i)bO'P%;$oZ4&=dtTsBq@_O<Ijh'_4YX#5$aU$6<l:tm6-xOl?7Gs,s_RsMe_Rs)$T@Ogs9N't+6f1LpYucF.,Ds.-dR/CPaLBr&og`G*]c`]<I=-V-,FM9OQQst2$9/jZVX,eBbjLfd_.tu;T-7x0Lk)%H'VHZZVRs+T)d$m.TQsBo=Qst%UUsQxkwL^KwcXsXC_t3U7l8Rp[e:.f-KsK=^X8O/'c;MQKctwC]b,:C-Fs@x(u#TR.pt8F%`tKNJu#+gINsVkQ],VH?uLA.F'MnD9vL^<:.(.x>bs`NW9%dbr9]O$9og`LVgt.CsktrB:iO%%)[KmWD$tjuqd-B=n92v%r9t/M/+0E'g@_Z?hUi_h`hOx1n#7w'RktAw_fsdQ6(W-<vNsa6`sOM?0+)9%5`*7aP]O9A3qB*Vki%22tlrfdwq$.QaDsnp0.(fEo-UdZTI2e&`L='n%F0FwJ@_%#Kc%h[]^8BOZgt&v.a-82$Un#o6eK[e#iEA6ucOdaG*YX-0Z$MkOoGK-VRs)fRL'<M[X,fIfJb1Zw,)%(%J[<$(j%rOb>dR@+wpS.GPs>-*U-K-*U-9RCx2#<,FVk`ZctoSZ[bGU#J6pDQ?p'e0.(9eiJ2)]JHs;lXFD($A_tiVh?%Sw`WI2HZ[+qV3`sgk5Z%&PPuq-l8f?VhQe%;'+htMPle$V7p,K'`]DswXC9fmqTU-C3a7.UVqLGU:pb%u;DGs9*vP2+5:aO&u#vXW5%g$wv/0RR3jq/47w82D?W::N>/F-Y)_w/H5u>#*%KEs[ph_%a:+Rn^Ot0j@w$.:4<__*e02Gsm8autS>[eOgMXRD`GW@rjsJ:`7<OKYO5HMn,Ro&:?pEc%Zdbbt+Mx'-*>Pj)F^vXWPbcDjf?*=8J7C].o,%(M4ja-IGB[X#dus?t;-hIL3KtQ%+&G@kPMoC8#gTj(^;+O0F?@,<n*0T%)aKh^#4<=,HxR[s;v0.v`'UG=$)ork^jIJ1CxP:v1*:)vxQav:mwB6vwHxG?T09J`ae98.o;:>#+^6pLvdVm1t<YDs`X08eagsY-5aXZ,hUxI_rm8>#_-A.vQ;w@8`tG0)-bGxkQI#-)cZ-S[wWV:vNP%6vgLgX6DCMp+scDF4#r#m%E_rn%=fH],MhAbai4RcVI5`hL-^M(aN%=>#f9?6v_SUb/jn4p8qB/v05Mql%WpWG]Xr3V:-:m.j67X:vQoh#v3%e[WKn<9Y.UwRn%d6vu*smsLR4gh?+$,_JEm@8:ZOg@kiZ;>#SR?qMwwHIGsdMxb%LPg:m%b99-1''M[Ppu,Er?tLH,`#vw:I4*rSKC,YhDA+4i0^mt?D]/=W9OJv3#>Yf/k0T&)F`s,WB(*H9=JsCDNdt#wlA4SPe@+=-&HsDo)qO:_djZax.s7>0rI?p>3rEU?U13e26?fJ=Kc%QA`[s'Ax'-^ZWx)'Da;KL@Ng:,m<ahX4cGpYt>#-/YvaLB8ht>69gT.8(;m/RI.+%[v=W6#E,+2v5^b2VtYX,?q*o/Vvo7jl7dR/]WAds3O1%*Q6F4J/Q#+Dj'ZRsNg(ZsfZ(Zshw($YD[;7%e5$hc`:NeU3Wj`sesv8%qWIXGg%+gL_Bf8%'OQwLZ3&_OIw^0guY.1g(&pkt63dNsqggq$>NRQsAk5NsWrkn.OD.`*Q(jZsm7/ws6ACs)#7mSf0=KG3f^K;:GS/ptD7R4ZvZ[qO]QgnGP_5iGms)'J)<J2L%icV%hdv]ORSrgdmrH@`eYH=qkS#3u&`$Un4$*G]QK)ACo&J:CQN8@]ep)x+bP_jonm5]s-f_EIB9T*)q>>2p@Zt3J'+)Gsj+Kua*VNq))DSwVV0x,)=)r*AE_2rOf]freK]8:-LgoI1S`OL^m)ZeOVrT<7%Gjv8:x0V29%fCmGEge(oP3[fw-<(f(M_Mcl$lQ%&4^oL_)+iBaHpEs35t*DQPfGj7deUbVq=Efnp#EE2[S]t0AWc6rHd3D0QE5-3ux?%5SY,)l&k/X]u'hO*S370>a>%-I;8m.Pa8`tltkr)'TjMn'.H.Z,_(b%s)4^Ft&W&AW8s1DTYmP'H6GPse?W`sM[DVQ/ak&F*,ZO0vPpoOq#GU?2Ao/1d$Cg(I%KEsD5.k977-bsc`FRR+8/-)Jq-^tclC.)2nnAk?:B.)_lQN'6_K@%`E5.(r]7br*mQN'C50X:I3dNsFQn?9kSRfLKYaU6ilQI2)WWDs-;G:&+-8rDH9%$$GEP:&K)G'S5'-[Ka`*15DUJX><QUF3*CJ,*x&?Gsxer=-J12iL`FTI((nkiqa#j0,W(f34U2Sk+7'Q8MiVHtl;Fpdst0Lk)muP^tuH(2t(i%Y-7N_t(d$Yt(A_ZQs$2lOI>fOwL4/9:-oa(;&8Y:C/KRaRKRa][s.3NPAbf.%5JGCT5j6kS9Vl;*eFks]5diulKsaYcsuI<3M]+elLXopcNOAb<utRe>6GL/B-@w@C<<XGesG.wl)BI@kt03i;&q8d-IS)P6aOJG6jP65.(w()k(,N;Os#;r;&<t,gDR^Y-?h3nD8ce'iBc3nL0<2A+D[$R10$1/Dk=URnbV<ia22&IWnIb)>Wsfal%DNDu,GF'iB<@I`%HqK]l3bj#-;-J'A7&Sg1qLBVo>BBCIFm<gO(obD48Akn.XP5hofbfP'ZBXvLg'4?1VJ.<&CO>+D=PRN'PUtJ-OdJN-8^^0/@AUqm&eH$gBfM'M2%RhK%G9[Qj:un8]G2eLPJTwkDQZ&MJxjZs&[hBs__R<&[.#32_6)B5H_$J:pDWRs;Qjdt]f4l85YZ=>Ii)N'[UhF.O]RN';p3n/NZ-.CB`RN'20d<-tvOC.rJvmS]5#<-D,Xa%rfRN'-@L=PIi[bMd_dEjPlUIUtZJ$l'mPo)sZ/IU:ah,)aZ%)tL>J$l94vq$5KP:?`bkj)/rN+M`,okt9SSe$YE//Vk.6m'QE//VW0L`tRbFGsWU5I6dk[`tc;KQtx_Up0]i4Qsw6DZsvL.FM3[=_5,88';Rg%G14=*N'QH0wL(p7d)(s)1BNa(9.2'QjsuuUG#X&%)$WHk3oEiRN'[&b);.bF-lctX'XjR#.:e3NM`KsA7%o,P#l;F0-)ZsRN'L$Od:I-=lpqPLs(cS+?-lEZp/&Tl,*KYwH`?9Hp/-3RDsA*qc)8*rE3_LsQ/S6n6eeeZVsc39@4^rHC=6u6R*Uqh'8$vj[+.x8d6i]'>&OC3^eMpFoLSi:>&5F'$pN7][saQvCs@)=ICI9CYe&rB>&lsJ431BEm)9vP^t'>clsHJLI1.du)M_#W#tP'U>&6-TIU&@_qoRUadL@X3XC=62kXq6;48V.]X?2qo5@lOSwsbVS.(CL9:@4f)W@,(4rLASYLqI&sA#l0+R-secw.I=k[+$fk?B*V9O+%Ttoil)1baYu*]+ko?I2,h:R[_'1-)LfBl)Ln0W.Ogm>tadx>-]M6T/V.el)D0v^=_0PGsp;GhLwbs#Tr[V[=we8]X(_Q?&Ys#qL5fIaL7,$9IRbC$$@r)&*AQ9Es7k?x-FOL'8S<$j:).+N0wLIws'pm?&0U=qL)Q*@&Fw`'/,,8BNc(l<3Hx(4SAG0.Db`hZD-*Q$EB=^%8wi;Gs>>).0.>++ET2m?$RU9S/f1FPs[b:XcX_^?TaASPs*Ru]sthqs)J8)62LG/.(jD7ug_.<noo-p^FZf*s[1]HX1A-UwsB<;p)Zj9>XEW,]kTp[,)>#4ciFJ6>#+:x0v3D*Iq6F7@#93f:dmLIc%oxD[.h0rO/@Iln.k:ml/[K=uLE>j+rFIJ#cXMjv5Xb<>#N4tX%kL'j]<Ts9%0.snI5x$wulTs?r;Kv20aj/0v-k?(8G,$+qU(I(sSAW:vYResO1=%Kb,M<nouf'DqdYtr-V%Dh>fxu9s):F'*?0LG)3Wr<1wFhk%)<kPVI<BIrP7@qe@J0U[[R8_1+eAnfbB0U[rT)N'S5[p0+p0Hs2-(7@@j8A&?cPPL^(5eoSS`t(&tJF2QoAA&Y2<9rJ.jqHo'6Yst[NLsKnEWs[9vwG-JhGHo*ujH5^*jLG2IDIxdGtLwZQ+)Vn]]tkVWDsgM4`O0x6rHfrGf$hl)nM<J3ILcXntH6mjfMf1tuLUvpA&YN:+M.tlDI+%d<-xHcw0J6Z^s#84J_enjqI=co/17E<<qDUg^sIdvCs6k2DsS4Jq)F;pD3N<$nOaOv]kAX0;FYg-Ndw,SqO0N+U%R<&Q]L0We%1I]]tx1Zu7$cYV%(ag=:RBKPL1uUDjF(vgONsV<%uZrak8W`mJbs%+iYI(K#MU?e1'mPo)4M2.(>F8N's@%cI;;C9$)(Aq)PisulSZ=jOg`D^4YJUbYJ6=3<*hdfOaL+U%[uOjBP*:a%@q=Ds(ifbhvUYV%stOCfQZu0SbA[v5[rJpOCcFQ%pEv>>6B(P&I_hWHsYpk&dO-h((8<Ds#)U,).F#Fs2xc$GelJLs'jokt3=?jt]h>Z%I?Wd$#r3&goOv,)%_E1cbL_RsM#9TseERk%qh@h$%^1_8n?`Hd6Zt#u#-*DspVOg&=76Sswl5w)><Z,)1M+lSeoGf$Fwco)r8*kEVQidYLs(QYLTs8F_4iP'vbDUH_b_*iU=3ba?^XdpqN-@O/1;_togvQ1Y-1aOh<s=4@Jt]t;tp,)RGa9%N*&,SaTwJU,nulI$'`0_Z5x3Nmr6N9kVtq-5DYcp$fK1Y1w:b%2SiFoRXtYGo[<BB,b^00m,9oOb-klreEVX#a)51'U>1jra1hW-]c8wtx>KMsDJ&lSPlX]W&+C[,+pM:NFkZ/UjFf5IcF&[S[ibgO0GP^t>XG1B]/6]-VgWnLFN$C#HI_X#(A#FsF9oHsD8=7.LR[[G,'%mFs^:lFIYsa%H`'i2jd'jKk:6iO9p_s-+NemF($i[mp4Lo$#Z%VN0M4oODh`bS()x[m$;Fo$tmxuL_^BdOtpkCK>g$uk<*]]t]mtj)OQ/@A^6v<BTN)&_D^AD^D@uXVA=5<cK-7RR,'irZm&&FsSm<ttif#D/LO1lOMO8I$V<Dt.<u0lOelt`Ot'@+M(@Pl$)g[vt>;8IC_$P%+&MXatrfrGs*VBdOB(,48aa=Isf.f=%>S$@b>2gkLS*Ys2U-WQL?OK&pSmA7%Q9sn%.WDOsEFJCoAq8dX2sYg$`@;uSNO9x^_?eqOHmZ]L`sg>YeD/wS:>]fOHB_15p/-aO7@HbZARkcHZDOgOb_1rhu+v`K#Dw,d#,UhOl&*.?1fJu:p-%e%4I;8eM8FddDf@_OD5aUr9Q^D[$ud:Wd=9x^$XMoXN#dESQ,Od%c>Le6,.Ce6f`ZaI4xs>Gb:/<ThNFb.'-S^tl;tTsb<#Ys<*4101oubsAK6?&RFB7Atdn3S6xUBiS(XZja_'TlFc,o%$,)Zs5[:(E_X>r->Jo'E__ln.;Sk$F,==X(s.U@FsY4L#dkx@lOCmt5KE3L#(I&JsTZS]tWV?ctE*T`t@dQctK6YX5cQpHO&g2#`M`9oOrp#=M^<>1PD,1^XFl9mVN9)eOveYQ8hGP^t8*KJsO9,sOuF8WWkc3m$SD]VLXDYp75lT6-qG0qsE^JwapkXo[xcefh-X]tsZDq+C/RciCL(bgGK_rg?l`uu_<0Ic%S<<0>ww%f$T`omD5XZ1>B@DrOB(Z*SXh,TRGGNf$qm67JiHTREsp6iGw4fnOaI9E]^)=OQUL5msa1*m)?GM7@sqL5/HrU10EKl*MK=qxt3bP7*DWokthtlhLur$N'5)XTsj,5IU7mal];X;_t;PFitI#KEsu/0u]@,^,NkPUYs^6sZa_cL`WFqdCqO@86$(oCOSa&_btOwJ%4V<a7%(c%T%Xx;7%i^OIsK3*)s`IQP9-Gkw5jYl^t>OkZsn(dajS+TEsGWPct>cSEbavcHYH4tL'wWM.ow04_1mWWOri-cWVftIh%,X++EI9je,%lL1%_dD-HcxMd%cQj[rF_<[bKw&=cvNTN'XS=@Fv$5V#bNG:l<_@)t@rJ[UNtT`IO'$AJSvO[U*5/Gs(3Skgp5R99NgZW82enGgJ,1q,n@%=sHGXX#t-D:$5x%%48'aqQ=I47eAmA_tMb$E-%nK4AtJ$4Aj9?wt0*9B%`3.Ssl2QbMl*-@F*2M;t7ij_TG[:pO'(jEJG9[1>aYWN;qNFbVgm/:%<tqI[^(aNY@WK1YCT>1a-DOgO*DZdGn3dXPxbb@jp;k()P1386^mC^s[4Ne)Ax0N69$&VD.sDa%=A$gL9BiYR[>L#Y#iffGBR)*-*n2/%)'tMZQI9`I=1KGEo>/KHkKe+6m4/EeiTC4kbA*pOUx1<E5[%e%Zx74YHE,UD$40T%/[sDs'ZQO&AiRRJj>GSLtv_ls?VGwcrER_<KF`0_/4WkJfE<lt%uWLsT9SE%n,dXMQQ<rOxX/WWThnVU-L8lOGOW.(-f;Cs[VL?DC%N6E$Qm5LEJmP'57Hfpu,V*r5X/.(UbCI4Vg?CEMbjotZd0JsuHlne=jQ@+?Q6iLE+UsJ*Im]t,%#dtu_Q^t<.6VsogcYsqDkn.Zl(o/nx5=ljO]BiuH:VZHt$c;gTTN'.@/.(QfB6t%(t(9t.tkt,T_6N5XWM:igP^tq:L[cBNLS##Pkh0F*n$=.dq9n6Q]ioI*i31mBvN1;If8-$%EDau-#G>R,.&@'aGUbbE74-Y=7ssmZPB&?XHL0Md:+Mf7TU-i/2GsTFs-$+2%N'W2d-I.1Yk]a6OR.l+n'lNnH4/:$i5fYcekKY4F]sJo7Ksi0e[j`:)Lsm;3jT=U;_t%)7N'^Wwqixbj[sl3R]->po1505eKs.qs_T7#us%DNvJ2xG3</b7-QYc21]U@o=oO.xAX=bRVW-1O?hP97=@lM.EL8.Eues(,h?u^U(CjoJVx[c+kfO:7+_IT<X;8irp4LL<)#KMA4c693)_tqTYqDErqsCBUlCA2;(=%ExccKv=vtO^:cRj'47FZ,5T)WH_YoOUaL/uRbgh9hZn`O]5xI:pDE6.Imk*PrUE(7<8>7%P&87.Od5.([ge`tTpm-)NhWo)nCK-:2vUxl=?uEf1M?Ns:8eLE-BefOFKYiWR>5oW6*AZU$bvNSw[cV%ldv]OPINp;/in@@>CxC/_a<ps=RS0qmp7:CRTA@]4wvF]RT;AC@H^O&&/nt>*N;OsI52.18xqh:_XgUuhQk=&P*>s%wvKGN;r<Gs$=$t.DxUbruvAa/BopCsstK3$p-Rb`jl0^tJ;P=RJJmdp8)4GIHGXDsSMrh)+kEI)NJJ$l8?Kc2871gi<`oCs.0U-%.6)+M0cv8.5tK+MCU#Vf:vCT#-UjJf?,*[t=4,.MGo7'*,M).h9]*9.m=^RsJ9aU$U=EDsZ5u>#vRa_*tOmVs-7DC&0GGg):+npe`N,T%sT#r$BM#r$EE5.(+Z9C)##awt79SjObE+<T==T^$8B:-Jn]#tO9e2r`qjTrT/#7vuMW_+ZurY[-G75>#u)86v.QsWW-r3&[Ltkf(%Y=>#.BF*vLOInV8<aX#fR`O34fFc%W-6tnee57.ZP<7.$do[g.fe^%$VhV%Bq.t3/epkt8e*Y,qSoktp#U:v8`A2vn^M(m.us,6_7e(W`^W:v/3fo%imW:v<Kl&vGfpQB-/Q2bUrn`%nWlgGac:x&nGmt>dJ6.(_a-5):>5'tH(+=&L2WCN<;7+3DupgLDxSfLau(Us4&h$F.aKs-8r1^Q69^3ML^@NsN<qEsr@mw)Bf5%.@l8%Q+?hXsviD60QY_pfm-(+*xh(^dP3I*.b)d9MYfE/%?%tQW;*5=>JB0.(tE2CE:T^>dX6MC4'k`,MP;Y$M)RW2MRM:[Mmki<deY^1PsLZn(L8SptLIo>-:?ZH.)/ZILuLXfid:2??VRbOsel,bRPs=ROI$Ert`L*@0rBgdOj93@=H4eKs9'$%+J(r[ek3-msp*ok=HofcNb;#68MtL5guca<uL6f2(_P7dkR+cjLX;2rt6q%q)qSdT%Uslt>4E5.(_qjLsP.[w#>-0em?h=n),Aq58Qt'%0/IHiLKF5gL$guBa&LhDFZ:%^0e^Kk=t7Lh^voO?-=Lj6.%83GQe&_d8VlBwKf<OOMHS>WOdE&stu,%x-)M/0MHf7Vs<*410/S)E-<>Lt%PLk/OnwJKsV?oq)CphC*<eoC*V(j*MfB3mLa;iC*#rls-F($.MC9xu-LutgL1xaxHT/'r$_i$FNo<'osiwE'*KC(11m4+@O5W2-)9/1.q6Z2-)_'Vu82:OZsCtuYs@56=>_<nw#r*7F`^B>QJYZ<49+.6)kZ0[$MZ7=[Xhh)TJ4Mc+;<?%j:X^/jUE9;<M$,F0t*olB&=&bGO:fsZsHm&UD7]T6ssFje(;e_wO2E,0)Gox=u``Gb=]+tNh&QaEsC>,ft-kd-)Rt(UMK3j<dB+P=PCcRN'U5GPss6[a$er,K#&%KEsvAww#)1Lk)M'b$'>eY8TX>LJsuol$FYsM19_RB`twGf]t,L+6%E]DO4/,-_/?,.N'j'b);r8F]sUDdYsr17.(V)Ku?&XNmAxqpUs]5okt_W#IO8G<oE-=CeOXBb<TUHQsH';T(Ki&gsOEGqhl<8mtO3$E+;htIh%<V#c[W5,pO.t=l770+at:wtdt=*T:H>3/:H;sw0SK,gTFmGLx98#?`/rDqD&d%<*nKq4.($<t@R2c[$6'^Pnne-[,i,R>.)0r$.%c]be=TwVU2%R4=>pW$x-bs]kLU/?B&a:A7uPK>W2#^EhLH=YLs6;5U2edmxs%W-tL$x31'+.=W2d..WfT`$]-lsOq2[-IQs(Yam)Rvkw5(OoDsNfn&*DPJ6NKco:L)]#j_2(-REA=.10CUA02R))D5XnT#t*h7D&aJI.)q`5?&lpMQsc0E)>ut.G7>QG/f/$BZ.gvD,gll5Z%QEIQsxeGo)0gc,>To)Kbq*KTbqxoS_jBhc/.B2-)9n<7uXPK_-D,qNO?#[ULCu1#lrL;))u$KEsNYrk&kumRs^eV[%-cJhp_n@D&*iKu)hE5>#X:14lR:SN'bK+Wis7ViKiwUfoGn4R3g%7C)-_`otkI%0-8Fk5oisef1'[nuu7k@,c@*/>Gx2VY5cJ:>#60h%v'`cHl8&G/_FrsCn0$%XC)DFc%LN&2n8x?]rGHE+[tQ1b%'d<vG@ZO93p]NcOLsokt2#U:vgJQ9vGdk7<McqtiQHFVH45S:v;Xh[9D`^/`jw/PSh=-'Q0=h[%Q&mt>S3fHsHUtkM1DJ_s_IR&*x=j4u6qx;'@4nH3H(5=>okd-):hInLW8?B&<e/f)w5dBtPCq`&RGfj:0a&Es?(]rMN68_s&M[&*0QkTu[fq@-dj(P1fN,k(frB69i#vFs#l?nE9v,o%UFw5/'9nDs-':5MU%C<P(qpX>m&@Mh;K82Uqrwv-ko?I2/Gb<hd`)/8w)%i$W=clsa+n*.K>g*.')l*.Gl<hcQ_$&2ZMk+.qaPqI4'G5Bc=$sI=rv/)+5ZILuLXfiu_-b=X_tOsl`0105b6wL`d7'0eM6?&74#V6)EwW%*i^Zp?66^sRij._1@H[FrY*DsgWn&*&0wjt3U4%AoFQU_AYm=`dlr'st^0]l<wmx,m*Cc`i[U:vu'o&vO.qWGh`GtNvp_f:L$8vu?H;vL8$R#63Qp&e-wF,I$WxI_jQsuu0Dvs;B6F]upLb7eLN;>#%0H*MFwKs/?kOJ(i=`,D]55>#*V/3v6BGLKM<;s@QmhFri^8>#+n66vhEuFut`CfUl(U:v3bdo]?w#5JnU:>#xhopL_x2`FE8%Vm4B-O=[2]^55;_X4?OSM'xKX:vab24G(eC5F$%a=,KGb=,M+Z%3W?c]>SJ<JiKJc;-=Ox^$[GXDs;?bp:3-xablv7f:hB1-)LG1-)2V_d%a)mt>2?5.(r(<ia&)F`sqL[&*M@@0u2R<+&WCp]s1mNC/E^5=><iXZ-vN%C/=tj#GPMPD/#^EhLe.(PscZ3.(tuWX,GC01Lp5HN[E8:A0-xKhY@+=Gs14Cw-v_AoMJ$cjL-bJ+gFYmu1w?310swYg;b@wYsZQ5U2Wr+480-bh*4o#Og3N>tN6o`s['1>We5ZPYs'SYtPZf`G)$G@wsw.fD&BrS48-KJxtlZ?8%p9$cDCvbQ'K'b);IwISo[CL,Mk'bRsc(5:RevJHs;_wD&Oh@i0/#3-)GiQ`H%iWZsM'6YsJR3=>U^a73wTZ$tw(+=&8,&,umuJA&BcnrLT]FGQTdASsVght1H'Tt1d0e*.X.<oIQd%j:%U7a=`-4QMsNwq7:^t]YR4NCRFi&[sB5v69PNUA5eL[,*ZE8H+Lk*ot,wa?Mg@]qLZoMxL.5Ec>G)(kbLK?OAkE-Dshvu%0urjXPtHTN'moc]53RK]sLB*7IchcYsBG]Ps'uQ_<;V>_tlr?qLs-@GXOYwJYE,Jc%pL?lnDD-:?1th%221L%B;Ysa%CD,FjdB8f(%_WtAs9QhO8a$#TxtWI%LbQ.RkxBN'_a>$^64C^s<*410@$t,O[CrC*s)Uq;*#r6pSPEO8.=1Dsa[hs)5LrU6pWYF#plIu%xJm*)sx8e;Y4mnLd?:`l8_[w0e6tWsmd9.:em0H2VYoi'bmS:va.N`oEI^'a.0+p8+)0_,^8prJ-uu,)aZ][$sUnbT(uruOVd+P4dSn:&8B@gg_qRU-k4MRSDi0fu$b%I-*dh;@HJj;7-&3jLh<o$=%?D.)j7p?0^sRN'`w7KmW#q2N.bBis)ALv#_i=o.qk%WskoNAUf,k5tYk7_OSt$J:/15(fRkIeU]A>r6w+mN=)=5XK_D,iOi(0*ZZrV=_.Fq`SkV@/lSho7Mrmu#TeS-xOR[[O0?GB0Mw%EO^bYwg1$[JAXcl&RfT.#vAg^4-8pcT.v'UR10r,Ejt,#l9[X2i6?-.6>##3>aOF/W0VJQSM'k<:>#mJm1v2lBOj_Lg?LFv,6/&-%J6E(opUc.E6.hP+#M=OCEsN?.[BB8cg='<9S%]t/=>whV8t$P>B&QVG=l*mQN'F$=m8k;srR%(O;7Jh*T.ox.q)w#BK3pomVsTlKh^7Ao1t*olB&[+TIhf45k:C?5.(;ZT?)1mJP8%a(pfk[LiOc?08%ZYGFsL2(r$i*:7AY7':u6CK?.U`^B#R?NMU5fNGs6&@#M:/)bt'f'(/'UFE&$(hsM:0EjLIVBnfbF2@Bfm7*bI*V3g@o&Ps$L7.(]t&Z6d^Pw.SGc_<ICIB@Xw/;%L)mt>%--d$2A3.(P-^/)cVGbs3ZOE&M[6uuA6xg)9ZTx@QU.aF3O'e;qiDCAv/<)iQ)d1)9</ts:m#pOrqR'Kc>uF%F62:LI^-t$hbQidC6I[FA:Qhhk_nctur+48gM$RV(L,^@Q-NL`kAAW`e#5OKAjFtOjgid]*%Xp$vO5$5+,]3g*?_MsZ<qEsE[hs)N=$Unu6$)*brWF&wJm*)086[b@VYTpJlX`s`1L<.I[leh$)1OB>Y9/`pcW<0F1vq$mjJs-;2:&P&LS>MU2C8%80LmhnVG&us*GD'>8UAcr<TfLEQrUsZatBal[d;-0pUp$2P-<-Zi.jLFf`UsR*5.(_)kpsPK6?&n6fcP2BqhTOnVpBLW*L>q0aU$[/4FsiRXOO^'?<BnQU21XiEAU$a]]tI39MsA5,H2SG+IsPlxxt&&qT7>_0]sM7VP%XHPI(@P./h'?#97vHh3]GJK'%6r_qa]WBvc@CQ&-6MEm)%+R1G:k'j%f^l0%rG@&mceuR.MgS]t=Noktc[[Hs0xJZKF4/JG8,&`Yj6M``1,b(S10ec%8XrPA(XHh>A[G2rn<*7%^Am20'UFE&FPU.13qCpTT64Ws/d>X-Br:[0BhNh:503GsY-bW-4*o^-vgDxL2tbs%fTqb3s0]<-`<Z91P._<H0oaNs^/?Ys$R=g$kN.19cI]X?3wx5@)L4.Bbk+5pW3Ab'f0?ggGpmVsjhT-M:O1=8+YlSJ1*NVDgXD_/<np/1RYN7.B)3-)*$[ktD9/F-r7/F-jO/F-MOXw8AwXlpY:cv[UkI#Q#1@b:QLB/`tJsxL84nYs;FKv)kZob-ImksDCPZVsRe&r$G]`T.Z@pq-#OH=0dSTv)e3.(Wi=18Ej.nt>ws$giWh,WM7S>xsS=ojLZ+.Y8fr$ni$cNZs8$)Zs*BJh^2Nv91:9Sb`fGoDsg2Jq)M/]:&SS:j(?YRq$r,LpL?xgRJHtD_/@.>]sa=/#*;Q9Es)46[$R(q]jAk=:$iQ7U1l.nusOLcat%V<gLbRmj)o+(]jNog`5nkeLTjc$[do+wqdh>9LT,tQm._7hmV6J(@Mv40('$wwRU:Jdp%9m&nfSdgp.BoC1KD'9EdQ;hs._YH-)S?>@[MrbjL>U4oPJ[aSAbRe5pE@TPs#.eqLf=EXI,Wg8.nhgF;C6Ge-ZeHe-uBRw9>.Cls+J5B&i.*)M1xEB-mI=O%<Yb's4Ws8[U6Q+7v3wTM?7'.tYw7>-MV.JM6wL]$^F(2t8V?R8KqLxLTM9[sL3>O^3%AnPqrU.(ic?.%CXXw-OsU*MjcG7.?F410r0[U$5[LHcF>8_sIDKv)?[qBu*vkHrUOJj0pa]1'(F-^Oue6UCBuV>-q]%#%:;:Ac79C&,X7vK2Z:&+M_'1-)k,^IOb-p+MN.*vsk-UHmx7XgL2.vLMH:*Zs=bx(M&c%rs5vn_4W4#itaK]CMOg5atJ3?C<m]K;CZ&Jp&fKEt_&geh(jN3t_wogfVdQBp.rb6l/k]>eHJa<.=&HV`tY4Q91Is`Vhp,aEsj7SptoDvd.5Amw)96ZH.m)dReDh.Q'R^MtC2[vIM:FIq$Bv?I2Bcn/1'[Hd)M-tp[Sakt>gIfV3/EZUs4x+]sA?1s)$UkHr3sUJ:hL*T.b7RN'TQ+kL3Mo3SAG;p$$gUt12;=UZMeBdsKsj4oqK94Bh,?QBFu?RVjlP*lV)_#$[TB_W>Z.htEJJPsLXVD%_HN:H##pkt=G[Ss_abit9F)dD8[3Nh?2U-`T?U77YjR/`j2QRJukUj1PXg[5XnZ,MJmx#M&@<2MoQt8tr7-T/g>qc)1jtW6:ZBBcFQ%FiwW)Zs5wX9V&L.L^2)X&G[QXC3Cah'/Gmn>t(UGwcR`*]+K7T>QK($(/AB*19mjet:BQ8[9%^ht>x@B_-GGKt:]Z4.1FT'T.MN(Rs=Ww615g%x=i]PEIaA6.(QY=Z-R6RF.1D0fCgKuGsF4fHs@*WfLP?tt,E1G`s(@J#*8M.7nL;+@9N[^Zp2nd*.O[)K#-;2;e5`<GsvYFv-Al&8MYW54M:vqNIk=7.(0m.1t6+T.(nKh87kOw#ZMJ;4],b>uL=8u$kUX[6KLPQiAo;kL:+Pe_W,/_o-s(Rn3P;W>tx3okt&xNs^/NKnO#vhD3^@HF)JD<mOLt;p$28,%K3U/jdaibh9`G,Wp)5ZRsRB9EsUF(2t[KQZs.ClK./fDufjvUHsQ<dw)5EiqmRkG=6II8V%qLWZsQ?ZYsqp4=>lkd-)5wYjsRP>B&MP6=>KU-.DSa=YD<q#gDEKu=8uJe0>>hvq-f9xK>Ipo]tmYOE&XI[C3Q8`b.F<)ks#'<Rs=KCh>qUp6[[x$0)ZQRws[.HD-w*HD-Dwu1Ng:^3MCiIVs_8b0>d`F2t'UFE&iSZILq/*j:'CJs@b9FQM]T[/;0/9vd(pO(<Oiwlg=vb<L?Ju6RtMLs(+?:vY*p$4Am;#^cwn8XY0V98SiB]^c'ufn/gXE+)ea&nj1R.i9o.5Zkc3iZs?#Ms(NF5bsNrjX%H)Zwkw7mLO4.;/)ZA7iGY_1d%r_W>0c.Z,)(mD^];QIc%H+)Ws?^ZX5;9onOrQobJ;%XCl%e&S<f[Njt[Ot,)qq)v3-^Z+;E:1lOv^Kk4m^F/_uthpO?[acOMZ>(-L2<r6f,%HhE-TEsMe4sLDBVEscXH-)Ix_vstn59QJPD`t[_19L<#^9M1?<rMD(Cd%p_jY0EcNb.VYbsNvBPh3ZfqhoC[^J%4:PO/@:hlBb'Nh5ks)34^@bbOpKJPsCtZRs2ATxVEDfnO4lbP;i]L]r4E5.(,*b_hXP$Q/SI5B&.r8r6';T^4NDp]sImx]rC?5.(rO%fJf/gn/E1w<c[(%0)u($Cuc$*^%m:^TgsP,4MCt_.t%O=E&'.@p((92].coINI]@l4%04U>tfjkv-SI4)Q>+oVsYhpTVaP6=>,4^.XsB?X.>;5F`&*2-)AD)ot>`GW-U1w.t0W)E--K6a$ii@O4HZ6O44RJH8gWkO4C2P4V[iuBaNv,=&[jLF)=0oT`g8j**WqWb,Cv7YI.HVgt]wn`t*o,NsWX`Gs^x:(EwL,Fs83m[sJ`G+DlJ[O;M33#-l#b_LuGv]sYaE:$8'b))>irfMYx.T%/;,3t_PZwupX&x>?B@rm).:>#oL.wui8mddYYUfsrIPY#R;X4;g'O^,=B]EBo$+w6B-wwuELl;#-YF<k]A;ighZw,)XXT:vjrw*vP3f&M-6vGa1]<>#DKq%vKLX^N6sI+2Iw/f1^=GN/giYxub]Z^GDkNS7Km,F.>W=:vGPJ2Lh?M/`Z*KbEZ#X31C<T:vU@r$vu%M(M`8n4eD(5>>T4TFe+c6jcSx^D&?`f&us38#*^Z>q9D-/]%P>Jc=F[WPZJ-<5&:wW:v^rE,v(vm*h,GFbD=-Y:v%Ti'&Ss/#MW<DR%(25d2Hv#2vVIRo<HGR'NJ0G>#d_e'&fu8hLR@)b;j*u202jQ:v;[.#vk/j1S#b-?V?S*?5SQn7-mp(<k<Qj@tPuh:$MAO3L3t8%S4D7.%A$5=>HBww#:38F`e]0^tdeXj)T_j)Etv(NrgEqmAAKHI)H$=E,T9xntl+lr)#rh<dYOV$YrT)N'wCDm$Qf@Q/:GT9R>bRO&B>^g`_k*4T8`>FsigVmM7Hwl$cotq-_WH-)8ppHM/Pj$>]I$6M4#/qL&*)PMNeex%rsOp.'M6?VCIdERj2&CsC,3-)1^B^ue/NE-YuTZ$ip&+;]#:1'[YT?)_:B$%-1-P5AZT7aV.4N0&vUG#TmqZYB/3,Jop#0`OHAWQh*`R8L^RA%tTb20[PZxIf/gn/5P^m(#G(q>k@;@GCk8<-Q^xrLH#4Osf=9C/'UC6_F;v,g1&:V;Y[Dq[UA5Is.9i'/YRb:9a%00SRc#:;^?ngLUpst,^n_$0hR[$bOr+W%n1X8969@+4555>##id5v;)?'=O'2LFIPRV6,Z5.v/H+2#qp0/usUYRs`,2&iReo[gV6r/cANqUsm^nKW'`NbOvcokt`.qktBs_LKlu>pOSiKx9;(fcO2[W4V+XEdDT$5b@;_FDuClc=lE7:>#0pQ#vcpIcN-Cu3`@i]=uNQx,)<:%Vm9HQ:vE3'Z?pGS`tTr?4@upOPpu9H6jqY(7I=-g;&s?')3]fX,)JNQ`E[9<>#7@5(vT3k@*SSv?$Y$*l%cT-70AQsdt5b0xge6=_Uto>tOuTXcJmrOp$$n'9U]p:eOL`/jOd,oktmm:@_3WGxB,9@fO@[[;TOHQsH7Q5X4P_b%vnl)G6[?+U]wt-cr('=>#;obfL&gfJlH$t'MWc.<C_m7<rw3'L87N-j:/a12'D>inSclDZs5C(#,,P-W-UcHE#]m)'8rP/LVc3iZs[JQhK*:?piUto9dv>-s.FB],)'wNn3v8#r$NsJr$ipMFi]XZ^VnXj=#'.Y`tuO2q1Hra'a_d:^sP-=C)o$x<VSDL+vO0?hg$DiX.x65>#7qc&vi?RU1ZMBNCn,<5&s7<>#5hC(v*d;HC5[Qo$bdDqLj73K:rkb2-pmpt5=5(JsUSc^t;AIHj,U-^O&vQ?;2Zoi'X]Q:vK20#vhLv<[GSavO$w2bj$5^rG6<,MTsqIx^k&'3)gMCXsKJHL0/OgLBnx?I2>JfW&j.Ertr2Jq)*$RRr^/LXs-AD6j:1vq-+G5bs3ZOE&+e(rZn6TN'aHuGsiTrw=?KfuG'[_bt?ltitC0S71v3ie_1ZAe_H]&vt2ht;.Jmm8%.+n2(W6tDMDp+Dsp^;L_f-TgZZOsM/VWh:ok@/UP,Zd>%d]GX=;Lq06/toxG$c?XfGX[&M/jjZsOxKEs/GT4&,+Goug(d^?(6A8UP-(K%W]4FDPtBK1*m6cDtg1-)nk1-)p59Wg0k,ar21;m2a2#iR'&+Ds*]hs)t2HL0c<9i>;Vn*)owug;.>7MsQ:qEs7%0k$G@wn%4'nS15Zp+%+B@ggZ(om/hCt'*Zr)suJwgC-rrI/M574@=1nFd*R,<jL#6wBXt1C5M%/AqLjFF7O0cgJf;ea6WZVmJf5LsQWg9wLCT-,)O$*g;-KSx.%l$A[0F^XPK$<-)OAgha+26c:t+a3XC`^g/)aIl'@f,F2CT'&b-5c7xB%/nt>cG6.(r0NiEw9KNsdEWGsFK6m'BR7SEjhD5VmA#OMvcbjLg]_Es]W_p$I]9e=/;Z1QK=tfDi+Ip.>x7Km#rX`[dEeFsRm;$gnjLeLBe*cR>dvOFt?_eOlBim*K=8PZh1I-SAQ`S%r$vDNJLZ9X.(Zn%U/6f(ILh]t5V&fta.?(dC'<csQ]($uXZhR@/v0=>0v_5M3&EO^;b=9..N$sZ+;.<-uj'$B_un,)p1kqH%jN[tWDhVEErvTDu^AbGaC0GsM[*(47]d@+ugpq-JHeIZ0LIf%2k*XDUkTSL:ShC%sm&+;l&wCs,ffX#pc.1L?>oht_e[<&$<qv$fuOh,ZM+wLM/h-UR_Ph,d$+&uaX6)Ivi#I6A5bk869%cD]($K2$Yk'8tGDrtedEB-14V[%*t>#-)t>#-GfN&P.iRUINmIhiMq_EswrLHEB%9Ps5Q>IspxrA&G(Ku5>_T`n&)DXs;`%:HkE-Dsb;dw)P8>:Z`5TL:=o_7%Bn%=Y$AXh,o;Sh,]*g3ocIHsILurqIJLBN0``^B#b+110i]5]M0Vh[O]VeA-U,A>-)'650iKTv)5IlU?s4=f6L0&+;)>G1M@Lv*t'UFE&qe7*nB[:j:[X5L,Pg/o.ET/T&rk4I6'8YRsA_@nL@[WJsxSJ=#&)F`sL&QI:$HFr$5E;o7cO2F%O'/f:S/Kr$]hPQs8fulL3prMsfLEko:h]kTaY?ct9kkE&xKoeU&F.NMg[m>#qG)[%#?@u5mAfgPq6:827eQ]L7D7`XUC(GsfLdVs#VdVsL<%[sx^cFu.M]nLfn_P'oxEb7+1D>^Gt44Q;$['Xdv?eshXNWo<p@N%c<C/e'Y4oWna_W$[4+:<fkGc%7^7itQ39/;cbc9uR_=OMWkgf;Ti9s/P5'R]b]777BB8HsLwass8Zf#*^3Y0hB6`0_r&Vp.qZbLKgIxP*_0nlL-$Mx$;UJKs>_<ssVq)e)QevXLj/f$Kgamvt:X,]k?KU:vGb2wuFNKIRXh33L+?5ipA$t,)$1k(4+M7>#:AGuuq%Erd=NUg(3SrIhWQ64)+_EI1(V1.1#v9>#fv5oL2%0@Ql3VY5TlT:v_8Xwu;7=WY46i?Y/S_V$DM8>#cxmxuaWHElsB&Gjpsjo7_es,)qL7h%@RJCaV-YeVUp5HLPPp<ldnlYsN)`Zsgu#r$+G>'t^;LF&UWC?pP.jqHo'6YstnjLshIpZg*4YbML.3IWbjPmW3q&x=OFa`sHT2&b&[/W-8HR$9S%Hh^h.T58CU+&uFPP3@2sxdsToAn.bGc*Vp5&+;d`i/YchA;/WYT?),f1J8$vp/)OlHu#``WU8Q'O$IBn%=YD,o,_i+iFIZYc7%8*EjLthYh2t5$$tvA,B&2ctj)It8XsOkkvcPIWDsJkww#3?827(NFo$VswXuH7xg)1*SL@6;E0;Q6SN'MkYQsq9bUg=K?eq;aV$YJ?i.=@K11pKSj[5p>MU6MT6^s0p%31qcvZsfGMs(J.gas6Iq@%Y`n%>G)*K;uU3LpXe.v?/Dc/2U^m.ML%,JIaA6.(2C&MNsrHaPQ#-Is[Q%qLmi*<>/Hf%u4BJYmV'xcW@C;bR*j6xbAoV>6`b]A,E)^dMRN/FM[E@*NdIj$#XgQ[BeXN0>1xV,<F3fnLIH*^-Q$he6'K?HLxi>j(rE2e$uIT)N7ov##2i]e6C-re6HRpx4<4-.DAd2,#eORhCYwm&F.,R7;^su'*H?OCNFOMQAEwRP^e%]6'9*<jLCX=e`=mEX0Uh/v$tN=X18n#d,9]@I2xG/I?g/JcTvo-T.(@cls#/oB&@m?I2<cp_-aiE*H,m(d%0N=-M't;@E%m'xREx`i';9a/MAgGWk+`@LsXnR+%3SUhO&k#D-I,Kf$q_v;-[Pu0.V6uNB_x(7<]5YaBgO.4=#osZs+jm*)tRvTIFt%S%9a'P&[q9PsYtr$#1^;.C%'2-)N@8ptL(/Y%L:6qDCUhkFCH410.bKhLe,:kLeL>gL<DcDs6*1.(7NeCs?j.;Mq-d0L:ptwNkRre7egp5/FQUA&dvl5:FCO0PZEH6_[;9G.a:k%7X30aX7CORJEDc-67'F3Phr5'd[;9G.aC0A7X8K&>ASf'8,=`jt^ge%Y[:Yw7jp0B#'[.V$rW(KD:QgnSm^L,EapsNP?*Td+$(^fLge_`N9,['tR0TZ.tij-u6DGJ-]NBG.a7e%@Uo*ds]`=r)K90G.35I4ArDp]>E:4W7Sm,jNo0o?tm2gv.lnW.(N.?3Pa4FBoR%7.(feZVs.$QNs$?c*VjLhF&$=<m)MR=c'3.s<-Y/E6.`iV4AW)aj;v$B[s:/i*+f,QJ+;%U3gE7TPsuKA)TY^MO8C0uJ1m)sXu>*jm)^nb<mV<h,dqFNZs6%4Q/]6?<)K_jI(ql10)0*kxuNhh(mI]*hBP7wAO)8q1&nTgVBjihkJo,Aa*J$kp.p0Lk)@483M6]0h9gZx4prUEN0dd37RenjqI8V/W9,UtiC_>YW-J8naGCFT_4-]DU2tw)-vus>s/w4U]9C)aG<BMs;(Y+6P]2bJI(3RJYsXRa6&Cji2E'/cT>ujXU]FoFRsbGdYsxGR&*D/N'kR_,xOP9bLC1jlSf;+rPZcd_Hsf&]MsCp:B)Soa$O,ge'8MQeNOkQEM=pgT)&a,&F7r'2`.H7K^f_C0A7&j?qMjqWJs5kN$MLVKhtF]ht6jlRaEpdGGaf*'7&xg=e;T9$;U?S(%Mtp$x4WZQ48QJmn&rOg$9JEnvt:q6]G6<P=91mx#MaI>_$_35R3lrb4O:L$qL[)Po7bbe3oCGwGsOi8f)au%uE5XI+Qx1up>wrVGs4SnOri.Hm'3mKeH7`A*uk:YwPN_$.2cR4N0</1.q6Z2-)<`;HDb4@MhcVc8.r=#JXa$/v?[&10);M_%+6nCe6RIe;-'Wc_$^V7E&ZQeUQ%MdWs.<$Q//t,eMC90.(5p$dNl$>S:jn0Ps4_o#*%vP^tA@^E=,aeAGoGSYMm&n5N4m?Ys3j8A&D:l=SwhaZs6Qcq?7J4jLGT/SsU+CW.+;^ItWOq`$#lsL3-YvIs-L;Rsv<$9/%@'UsRBjl*3<WQA*;E,s(;pDs_2HI-u+Hs-H,n`A=lP6:&$te$s>m*)W]D6fW2E6sw%Q##D#`OA%'2-)hU0utDsuB&64KfL.vOCLZhRa&:#C)EQDKZd)C[Vs_&:[b-DX(MDO<(t@gW#._OUEOtn$X&vrMj0OA6.(QJ%Y5[USN'<#(<-';B8%-ecE#gebLBaH%+;@YKh^x51Oo&bTN'2M/)t$M>WMG>=Cp_Y9MTBeERS?G&X[<`oCsXp>$$wLXn[.^2:)<3G/f[e<jfig1DsAoa3&>qDetN.1]tmCLv#rUP_XN>ruZ%v_8.6iXX,fx(W-7EKR*K^lt>;s5=>Da-5)be`?8ghYcaj?Ss-Md:*MNUNG#nK/=>LoSk+vY/ENgtQlLh03MM`X%:.:aT4/@EZ`t$G%'Mu.5G-@MArLv>c[rC-JHsfHM.1qD67Jh((_oiHbkM*Ho>-d`HT-Jkv5.S?ufLpE;X-Vqg6iG(-Y#0x[e%Ef&*tNgVcM5hC3t*c@uM5eB/f=XuSfsk8;Z^OLdMr,w^t7X-T-f'3#O^9ie$[j`B#:FT#$940v)#HL=PD$Y0p)],/:l';/:=i6:B=aQ#B?UkCIs>&b$HPUeSHRFNY8-sUVeK:gLN_.o@PjZ`tiFk_Mh':o-xCqWASS6X.XuUG#r?[*.i3orMER:h$4(kviZ-*c;x@6bR-,;Q/5BLv#SWP_XpVE;R@.4N.`++1LTJ+'G]x+K#X+Gh)n)d<-PB2:%TgTl)c]'IV`SM=-WKZe%h8F+;vNTN'L:##=9:<DsO2WX,,+RO&KF`0_AFOq)JeDJR;7UvGWJ`mN>$TkO50YdQYY3_S$bnRWh5ERicA#iTY6;O%ZM5V$BQ;b72uG=PsVFdAPrbH4:<s/2O9VRs*6mNs:_%Hshr]h9jhG<R%v*Dsv7c$*cLL*RT[Ir$6.LFiL_h)3?bNgRFrXoO69BCCJu(4L)DDr$h<07@U&'Ms0'83gr7liCTcQXCEh)b3aP)FiAsoeA^53OUkE-DsU;dw)ied@+1E7@Y*&)W-$PM'J%k4eHdc34Ar]7brDgMOsY_iGsY[csO:SVRZ+9AB4G'Go3/*,(*P`[[s[$D4%]Pbgf(q+cIh?sW%Sj)Y,P6r_EqWY$.uN=,%DVd&MMFa;tND*Z1Ukw;-HQI-b$SWeL01i>5.W:L&a8Ms(Z)1.(MYp-$^C:SsKl94Lo,3CEUc3-)sXe1'bS@.)`NCl/0`'^O;g0Y#08ZlE=9`MN3xm8%8`c^qh1F/)BwGbVGcOFiD)i,).Z>7%DI:Yn_TiGskB)mfw(Le$?l<.%8JdRV;c?,WV#P?gprw[sQ'=IH@%aF2[1U0`=IUCEQ_@$rBT8RJi3<v:8[-LII11/`NI3j0L1MCWG^,CWu*vI:<1&[do+wqd5V:7%[&_-h3q0</4/E:6(l#r7e^w],3m9W-uEVd4,:1M%[*nMQIp8smUUv&-/)oZg$10TVkd[[sNG]VhWcBw^Za5=>kG6LKj2QRJ22PcKE4lwY@gfLZNG>W'T86=>Z^Sm'Ct[nLocQj:?HLRuo'[G&R6VQs%&YOI+pINI/r1(t%O=E&N=U@FTAVN'h&P[7:NM^sFjq*M)KB.*)JTI:X2JFit$-Fi)3AZHi/pk&(O$:TxS/(82PqB#I%KEsgs?w#:P0r7%,Zh2*_%r$HNwI:&j/Esf>hr*jH5V8Saf6EHUJX>^'6@Y*%Vb;a:.T.;_WO&CNs343Z6hC-VkHr9A?d)qBWO&jxGRI1f-F%SacI%c2Cfs7>Bmtlu`=,aTc^t&((@O-p&Fs[tc3uItDL%3Si(f6t:_nCrF(.k-hkLjcs/8e.al(F?0.(wIDRI4&0:[Lfqf[,%xUL%)WhBeO&w6+f#bsrln?57V%3qs@3(*]x3-)ZLi>[%BrX/u$8.(g<VXZZsGSfvibGM@P+484xd8.US>g)pT06(0VT3g$c:#mMVfwY<X=>Z(B7s.vPcA5d7$l$`C:E>r9a0_FERI:qLdb8ISF<qjVn,)i?iZs?G9Es*l_.*e)`-IBdRhaALxKs3^?W%Lx/L5R6I'oae93;=evI:ln8U)sJc-H;[$@%kDL+<a8eF<]W+O4VtjM<'t=<8IIED#n=trZMcm<cV+KPn0k2;lGpmVsG)/Psk[rS%0.`G)D5JZLvD:jTvBrqVID:^s=]#.C6qsX>MvXYH)ZjbIA8_ut94xPJ-ZNfH.V+at;vhUH&.jt>-ccfV$CVuU>hD<%W><R[VQap>=qsL'jni=#qk3fHpEvc%OvX2T$J+GRvVQ@F'lC_tw.)Xsd;]nf9XVVRvk,xTAZennL(ihGn?Hc%pJNn'PQOT89H9j(W==S4n)N*Es2$UnRi4i9.BNDs9%S0qs1Oh8bc6L,f&2N'&6GPsah/Es(d(k$Pq4.(IRD=*<R9Es9Yt0&.DErL94urLd_rR%T(BIMNfTlsQU#<-gdOo$`,W1%#3fCO5-(1MenI?t;2BC/Dn,bskH`NRMj`,)dh*.%hw5w%-p2:6'07ZQ#vE`sUrNK(2/reU>;47.FOP<&KD`n@TT+,WG**gLe#5$M?%S$tkKFF41Ff5u`k?G&O-VCEZSVN'm1U&Op`+DskUEH&`Zj586$,Isj^w)$kd1br[VVN'X3QQsvk`8g?T&<7k[;EIdJ6.(LxSas6kd-)COZ?t)8)f:fs:_t'-;r6,Va,)tcQ2&J(p,)ol]@=DshC*WZFc%B<vt,S-QbDo2bebXAj;&1&e-IaU$r$v>xq$&t(%+T#KEsH'P^%s[,%+I>A=,qI,Fsu]X2^oZ4.(9-:+M%w6vtk+sbtmv$M5he.CDhHX$4&HR+)HvvS%Uwtt50.e'k8Hoh'm$P4ArV_7%[379-4%`b.MlTQsWKeSs/?UHI5NPI(Yxr)eD>roCK72P<)+bjtcG.dtTRR=G=Awbk&l'19%rdhoZehk/RZa7..rkCAs)NPW6PY6YxC@/SaA7A`dx8aAl5m+ui9N]H#U`^>cjk(b8E7hdm>Jc%_nna6EsdaO:+D#lgoY()2P/R.r+b<6Utv8@7%PQs<8:MsS-]G`e7m)-/BwD@A-i^sRoJf)aRE5<+Rsn%pM+]Ww#-GsRaW_Of-Cg@+t,bsVVVjY>/&^kM>k@+';N)u0/1$%2<w,_9bQ^tX>clsIOToe`'jU&H4;O^U:LlOT2X9s'Y$r$H1ba%761.(7._,)gxu4*2iuq$b,m,)LG#l&/6i[OsECutk$1e6Ah>tLIKihL^@a'Wt0dI:QM1pO%2;g%u7jq6V__f#i20>G?`2GsDBfr'q%=gL/m_Es0pLs(FUsanf('u5d44-)T94-)qeVN'gTQQs9ETIp&P^EsWZ2U.:i@3qA(Ctuf=4-)5lVN'2HKn$w#:1'/A61'd=27I<H2r),B@gg+A'%NS&A?tRL=E&DtQ@F9+T`tXnxrL-iBnfmr]qQDET*I&sVN'q&?7%VoF=#R+]a#KoF`sWk/.(bLB6s@vb]tx&w'8F[qVZN[N7a%][bTMO_pOgrlt5,78;eqTFW-<bU0Pw?V0P:(0sLf^T?dwSJ]tZDF:r(2pkt&B`^Opdbit+_pF)3h(jO:uo*DK[ESV9;92s-v&K#cW_D.7/[w#rImm'#h^kA)+k<LRSc^tfh#Ns,H)c<mgk<:@T<Hrht[6s%`?q&1]SeC1731'RnBe6<VV*Ig4.c<omvS/goM(?^='iBv%m<C[.2Gs9%WL'lamiL-llgLjC.JrW2-N'WUDa*LP&E3U?ubMkYl:rm(x^sp(Vo[DN]qHniSd2N;nw#bJ2FMp2kG>mT)iO.6hXTju-H%8]X0QQp8sm*dA%-iWVqQE2uOFJiAb%$$8-v[_7aEv?PSE0<Q101cuR.W`ap-jK*8]FfifZhQE@X:A,B4MQ#DK3MXoOB_%Hs.mSO/ortKrso^%uqhqs)v`3QmsFkOX2wCb%*^k>GQl:[BDi>6:R3(d*aUsQ/tXD$t06@qe$:T,27I[0qk#$(*2eS.(18*lAZO;xHuBlxsj]gIra^0N'N5GPs))c>#xgOO19/[w#;M$4JfuVN'w$)=:fss<:k-KI(('Vk+,;&(*XMS_8KD,bs<u,D-GL.U.?D9Es5c(H-.Op$.rU0hLXXi^sOFXcs6L1).F+`MM:V6^tIhj/1xtJgOM'TPo:vvCsg%@A-Crh_%C'07I$uPd-px/EscA*0pFwBw,7MFO0.$Ec%IHi&1gxVN':(Rx-]oiSMIeq@-a*R]-RIFm_Wb_asmpBo.p=_$0AlwL$NwP^tQJ1@-L:sE-=01[-mtcq;s<2OLCo(#laj;W#O8P/$H`LDdcMWm)KR9Es,'b);0Z<1sL+iEI`>6.(Dc&Es'ld-)Y#.osY3CF&BVP+;8,P7I%qwE=q$Dk^_>09nR?4`OY5Em$p-eh0dlqI19K4`OZ6[it-h:$%@Su'<T/*KVg%I;oj/<W#gO0,..(j*MgICbt&67Q0`&:w,eW1aB[meXAlxSF6<b&u$k5'tm+6Jc%j&3?ovFc$S6HSiQxD0pt)Kc#[=Mxv2tOQ9;vA#PVH?pEsT/<)iAQ-T%Z>ie(DAest78`=kgx0aOe$ZRs_FH4.f$>oE2Kv`%Yf%8ognost@=171&d3$MM9NR%Pc83PH-[qO/$rktCd.lA&%f&6Rix;h<ig)l%I^UFYn0B>UUin/<gtXAm7wYs=U0(*fe+b$58][sb^;`sRM^v)5sgMTM[Smlkk*9'k$r]tOgPatp'AHs&mQX5pd$fdcLEp*5g$01G7L7_p.`DsTjP^thZ_X%Q8.`=q-]@>A4OKV*_PDI0O,k(433<q3kd]%uGDrttZ$]>)MZIs(-l,1M`qioxNG]O:Dc]sTK4Is`uwfL%H4GsHGX3LmR7Xc'C_?%f8M<LR98C41d0hL<XS:Ld6mL9e)n0)L1qt5T^+P&#DV9L<$EU/XW3.(`PNf$cTR<6Xjj$Y;ORoOk,JLOHO[(%/mpQVY5=)r(?m]sM&Tn$Mh6kORv3kOou4kOdPb?9C*P*=bd/7L?ek,)V,`mO+AKZ$1I0-dYj#R/a:C$%8KU?KEMW`t/i/gL@=L19WT)19Tfdt.B#M@X=,N=Lvq/N'FYEds.gxHo=4w=ch0Bm/)@8tsL_XE&8>2q%0]OT0x#*RsA;qEs6l+[$P4.2ur2BI&:rw':,Ux'/+ulQsuO81'__`R%@,oj:g:]stwH6I`[Jdp.,pINI%mw^H;wbdtL%:sLws[UrL$%K#`n;Ea1Q91'klcIs^(fn7E7[1'9uxeC^G,F%_Hin75ou6%Xg[RsjO<Ls[p&r$oMrCss,`g%7&NI(_*q#ts)2ak1sxq$eu@tt&^6f(-Lfe(kWEUH1mdBl7]g)j*/i_t5Grn%2x^U75u.^,+%aebil:>N2(L6ALKRI(ufd'N,aqHsQo510ZO.+<nvL`,BeS6]@_ISOa1[10BBdhLlZKHscG30pY?Jg5005J.g#[]s-4,]4E-/R/DQ,N'D=EDsJv3gL`Yn>#kqNF)*/khq3EVgLudg$cf+$r$8ARN'NDp]sS79a3jLWm)x^#=P?k>J&=5GF`ftSN'FMkV$UEOEIVH9Xs2`__*UlGjseC;;V2iJnO8$tk&P@tcO3M[72J<O&u1M'IV)->Xc'VHf$q5<0a;j:baje4brE69)SF*Ic%3bkfCZJ$P=LA>Z%h8];M3lLEsaAx_O;IR7I6X'L5=H)L5G/@;gRH8Hs9$,^t7e0,)Z*9isA=d9m8W_,)[Rhh0ZDGf$LVuL0Oi'J:?Q5N'O%Nn36,9L9a[i8&5%&73NB07IaWOoLP]_asmFw0s+wSMLoFmQ'g4GPsiL[eC4OFj$2J]wXNN-xXubWwX+Z%vthm>l0LlxxtDF.[<X2_OJ3XOv6Reqf:xx`Gs/9rrtAxgH3h&J8o<u#u#]h>wtJB$V:f`g<l&(jW-7(BqMwqJ<t9D4j);R%cRx^0(o`E$Z>lFhXoEHZWaf1l<Xnm^tV]hv5:igYm:)[8oDk)D.E_v0a%T%'H&<^'1bH)3eO:5?l&vkcpOI&b/Ha'qJ7VjGx+6SGx+Y.:Z%a&D8eDxo@jlw<e%X;gBSlb:)s5p6>eAw$T[,nmP0UtnW-HSBeQreveQ'YIf$-rNgbo>>pXms)c]1RV#U^RH.%Ew%VDnhYWBLJn9B#.OJ-KUmc%(k>9FXlFc%7V-8[Hm^@TZH/hY:knw]$*V^@b)_4&:Ujt$[?n1_YxGd%4<R0P9O@,ivs9MaQupM^MuohtLn>7=%%WGsIG6S['oDs-ksLQN/I^%6p%ecVO7^RsG6YFCM[&g%@B2H&#-J=#wvAiOx31Q:;n@i5AAq1?WwN'.7#$)nQ@kb%(0<jL-GVe7etMkMDNuLst,GhNRQXWsAI^D6/&Z#WCEbLcD/)Y^>?w,)tYUXVPe-qOLFRqtri4^%0hpc?'CV&137fs`$6fOba^0kOnG#Q;rDwb%.>@h_kLN'As[s5<iED^8^7IaAZ2v@/tc1jbSY&c%eUeJsJ_e&MaREZs^7/wsiIo?&&SIf$)UB2:#+HncG/8ZWZk._TlJ/jr3W@oDj/`IE[p'a%6Cb$X<AT(%Pj]X#3pdueV:&Zcqjtw76=greSDUMLh;6v6oaN41G(Vtg<vmaYeY`JZVtH&T=WZ*8$#j8AWa#'I)e@a=LpO7I(GAkC<8P<_XI[4/a+3N'4(pc$wknk&.TjDsC=RVs*TJqdRlEHs0SRKsx[24/8;0AVZZ[&M;G/kt&,G#uMbtW6/xUT&;+$u#[.Wh>x%1FsFA3Hs<-qMsMQjG1^3OB1;9#ft2fC:u;G9Es'YNf%U4e&MKpp[sa]<Ls+OD=#sJQ_W%*C@>,^l>%JlwqdWtKKgAxB=#up[nRtPWRs4DkHrF`(4%/fEnh,;X6fu8(TAnw<RM^IZitFoGJ&a&1fsdGoN%+p7a3'+;gt7HkHr?vmpeE4E`sJ6u>#gvxr/])(v#8s#u>gLMa%>6Q7@<;]:-5](a%:cB=#0Ppn.P2ADf-j51?gR)c<6?3W%<nrZ^9Gj6eeeZVs7iOwBr^OIsjbXYbIPTM:b]Cbt4g)Q0ep?bO1ZA?3Ah2`%B04eHN2tq-@=Wr`7QrY:pLSX%LN&2nKk_YVSQb?IqQ6p*j'kp.aVV*I,Pw9)_.FOsR0+7I42+.ud:aRRD71lORp0:?Q0pF)i2i$uA[rcsG6Db7EL]@oH)]_8sn14/C]'Fs2#jOs6-U:q3%GDsg?P^texkL9SO5l8*VFu,.831u6MHf$@cO_.7m)#tjetk3o#Eh)6)lIs^pkIslSKr$p'9isiA87M>Pg-u3.Dh5Kjx?^M@&Xs2^b'aH4/30vOH+;)Z'7IGDc-HE>D4Jm(v3J<$MJsr;tttJxm_saMfk8Brfk8)Cf]bnwlMV*_PDI'/,1MF78FOE$cat%hnGs#WqJsOXF`OvP6ctSD6ctT)NR70HCx4[W(%+u/eb2Ili[$GwngU*x6q&).jh'j<Os(vHLL0,U&U@M]$=H/[jv7tfj>9h[[.(RFf,)DY[XC'vEc%:&F.nhQXoLf3H;@X2(JsUtGO8/S1v^?mt4XUh1+V4]t7iMi&Ps:n0g(Crq;-snG%.,x2nMjWR+:G?_-6(')W?QWv*Imp1eN_8/GsDbOU%^eLp7xSVGs,DjqOuA1&UY]r<%8)b3%'^d-IEs=4&rhxIF.?LM>TIYIs'o?+SRK[qOW'VxML]UaJk.i@BXv'pL13vA%Y=l#><Sb%CdrmxBSid=CHuJb%HhxMKjiDGs55Q4B#qI1C6*3GsZL?W6+pINIIIVGsUR?Fs%Et'*GMP$cD8KI_Zr3-)fs:dlXd5+)lk`EI?x<Gs^4:w-a<sJMEwx'3=aXk^R7,2_ahGM_E6[v>I)/)ttLW1D,O,8f5G4B#5&EbrT0h`t,j1d*x&Cv-8&3jLXxBL9I3K'-,ia-IdW[U$7LUSi<`oCsAY_pf>l+Ds.NOn*P;_s-+^cER]bXWsPMCUsvNbq2axWEex4gCsXns6hg?4i*upf<-W<o>'cH6.)kZ4<-U#4b$+L7?Pb6o;-2Y2CZIbRWAd[$'tZ8Eq-F)9o8B7XfiKY(W-Nk@o8b_+Y'0U=S,/^x4_<`oCsvY_pf?uF`s:?fq)J]Q@FD6nDsbN)AFc;VR<%=310@$91'/>sq/5'*.)J=Vcs</.]%^BT'u$ir9&X,,<-9?Ll1:b210aU+_FqQ?C+wg>%+f6bp.6E14oO'RpKh=W:/O8IEFwW9SMjY4&BFop/)E_'o[S/ss?f0+2_d><Gj[TH2:n^Js-EY$FOk)3le=>^q[*JfL].+E<-`_h@-Neh@-Gosj$2]bZO?`K4n4^Th_`q(/`RoBZ5.ql1ggS+TsOS5.(&0)0tSI5B&:x>:vDcr#>aih6pEAZYsE99[bCXH-)Z1Dcs^(h8/Jm:dttJHtNUXt(M3_$TMT<#TsjvJHsboof.g&4AuZRT4MFn,D-09(@-^<)&.&cNw78+`Pg)RN4M_hGw$#73104E5.(U:(@-t#W..8#i'8I;]`tBt+^ocgbWs]@[Vs-k+:2aQIkOhfN(A/pR%+iG6H;_-hC8'VkKYp&_PMm1fVsYg#1KkaJgNT[Z>u(V_e*$bqA#C.[x-hQmIM'3^k$[+jnn;ws<-MI2u$4S2oLQv(isV#o[s?R67vo0`0#RY9@P:i[/1vAXY#';Fxt*WNH&3SEf%At<j(Qwt$/^4I$uQ/+RER92#vC<8DLLc>DbnUs20TsvCsrgd4$WqHN).(Act+?I;<*i=PpK>L/)W+[0)qD67J2GP^t0[2mNUlsZs`Bvw+5GX#$v-YZ%4V]77c%FB-qY4?-.a+?-LZ)+&MQ>b<HkpMh&QaEsHBZ[$FpS'jj2QRJ*]$4C%l#0)2XDotW+$D-v7(@-^A(@-R:/n$%:N5K6t'F@`GFgL]$GtZ_r_PM(@%NsSF-Fs%LL)0FV-+2m+CR]&k*R%]<PYsu&6Ys$O+:2-1o92_nv*;RKK6/_KJ#*Uq3t?&-**,bOgVM-=X1'd>4$M>hA%#bh(VDw:71'@o'#]?49g%sTtM0pc010ann?5:HlrLHb8%#NH#`JuL@6aR*P7IF`9D(XfDvATQ61%Tf110N6.k9R(FI)u@o6NTFc]scEfq)UE?qnGZPIU[rZ6o5]btt-i?qn.s6C@eSG%0N5Fat6#KEs,?373_#g&tmg7D&RY$Ou-@O=&oxunLeS[%+hO39.H*SN'+R<n%Sh1C#bR$h_#Djq6%v*Dsl2IE.*O].(5fha*(5Zs-7OO8M:IA#MH`4rLTwRiL?p`fs>81`.+TrXuC3+Ri$%JK>/mr`t`k:HaN#B,MSMI&MYs00M?(2utRJ6?&(uSkfteBX1&AH+E=e]6Ep'310:Ux'.:BCxLgC8D&#GPY#oDSb-Kii'e=chwMC>aNr`LAF-X1XN.3m*(h=S3eNW;F+;%'2-)eMCns;)5(.i(b8PdZ[NsV(Qq2=XOI(2hH)ke[:>#k?fQ-LNZX045GPs_=EDsl#Bp74Kf)X>l+Ds1jGtL=c5at`FY:&b^LbZcsOWsEb:^seA0101E0LT`J+F.B_hut:jrp)u9(['iRHX#KESBb#R.UsF7H[Fu,Ks-t[EUEqJYpo)C[Vs[s9[b-]xf.Lecbsm&_4.9sa$Mlx0j*xd0r.%U^Ms0kra$2kP]st?i9Dao9EsER7f$;KhI(0)RN'c6:w-sk>*;OPOAYX'%IQSu:C/eiUtl&#U<_hnM=GCCIDnoE>GsVSR:0JcFh)ZLGeUklKU;O23r;s5h5MB45GMdS4`s`@9C-wLo;%I/,K#K6#bW>l+DsCk+c-RlgERD8RN'A=q*.FZn>t/?[6fD0EGs4L;Rs%?Hp/xGmZs[jd?&(qlW/9JZtHAT`FD6*51)B_IOS%'2-)$5wouiK6?&h:5U2i>6U24Ss*@v=T1tVnZX.>)5bu.P_[-0Rh[BCEFs-]<GhL<S(MsdGII-bq4[$K2`,tR*+LYSadNfYiA;RNi%HN#2u<Q-u0W.IH]Ps_t0D0]Ad-Ib#soiatoZpl'SHsj3fHsfK#x4:D^3F2PZ?=@@ca*'Mam/0O,k(E%KEsrp]c$[R.nLQx6bs@%@#M[Mf9e:_Em)PkRwYr6e9ebdq@-Q5gk$9?/F@RTqE@KB$F@/Y/o@Ieg`tU-6eMO6UW.SVZHLG[2E-^T2E-QYV6Mvk2ns:^?X.kb;)tmW2E-)U2E-:X2E-VZlK./L2Kr+PY8&ET+&c)v,'?89PK.:=XaXpbAGs2&P,/W[Xit2ooO9^d2W@9u93I6]'l=EMW`t<ZfJ.:q8'F?IO&,j^]J.:XT^YLGdJMx[:C/iA*Ost?il*E]Q9.L&ZKpv=RAY:+'UMhe%:HN)27JPK=*tlY2YM;xO_N;CcLsqIUk=]2p'/jJEksWo]wOwBVZBf3hCcHvVrZhY4TsIx3+)Nw?4t#K6?&lH;p)[WIx%Kdo`m*+'[s$EdYsD7210bc5*6<=Zrs+h7D&plpv)1^TI;v;5>#+WN6vUQ1&f-@$$$d2eCs'@k'&2V]q3(Ukn.o7TO/=e:^s3Spvtj.Q:v2$PvOA2@Sum4pLpR=P:vM$(7v9]([Z6#S=Fu$31bXkUZFe`=)8cnV78i,U>ZS8hCM_FQqt,l+K.CTcn@<2`m&WE6es'>`EIlN310>b31'u<KF)mw31)Rl'r6pZ1-)k_1-)cBrk$lAagiIY)ZsG69[b$'@XCeC)$#QncvIm.wHL_E)<JUtYc-WF2.HKB<Ds-roJhqD67J0B>naE&N-Z0^L1NQmrpLD'2lMYAaNrB3s3kU@aTAkRYSsp3mQsUR>l$*K?MiC7CU2p<2#H*3ZJD/P33)_Oj$>QCI7PK'qPUg)>Wso5DZsZ$310U0[w#bQ,+MSqm5]>vs=0e=a^orZd);W);9J.cPTsf^&HsoGUp$JZ//udh8A&&&3o@FH+WsBo=QsoT,@.th/?d<FtlgH?Nt:@qhqZGpq'/.Isj(gJ`BOS4OuLg$<Rso'CW.`ThNspA9C-oe2m$._310j2^(IvbsJ2DZAbRuGDrtbsQ+HiUA?phPr]sPX4?-vS+?-,U>[.#et*t/l2Y02jAUQ3LW[GO6)'8iZN/i*]^Es__=?-`ptv-C1TwMr80htk,6eMf>'<MJ,0kpvWXLs4L;Rsw*CW.m?LJs.Yp$.b6r)D-`Ys.Cg@(E7j7s.io(T.KMi(tVVg$.a52^MJ-q(MN&G?M)Q2AN69<ehhhqE5q$b-I^TZVhlH6`sA$%)$bQ<F`4'J#uWk<0,TGNG#%,=L,Q`i3o;F5at^Lih)=+j^OCRW2M$I<mL`)?B&VdM=P@Ru+j2V<Gs8nAv.[EaLB/h:f6AE410PT[$nF`F`sV`Vq%7(E@=Bhu+jjRUZHb@wYs[j9_a7v59.QA6`3)ALgLIi_Esu4Fat)em5.Oci^Mrmi<dT;Gl)*P-HMx7]6MkToYM5($uY)M]>KJ-))bI:r4&Ea.1Lh]1xJPEWcs'KOV.VJI&*OVbP:fr;GsU/m52SZWm)eGk_N7jOL:=o_7%7P7jqb.,X#Rio--rQ..-rR(FiY6U`tAvsv%9g010aCJ'F5=Xb3q1eK<TqE>duV$6:A`>_L%d`xHT)bU$dJ6.(N*p^o.8Qe$S9hd)WRH>Y3iaW_>A`^O2q+sOg)WRsg`'V4hch^snl0D1[Z@`tSSVbt5.=UIRX3.(h0pVd:VQr,Se4(K>nt]t7o@hX4mL1J;j;c7@Gr^:I2Eb,*1/cQ@=CN'>9gk$[eRs-1p@;Micg$N,LNZs9V>H&Pu85^5>;YpD1MUsVQqQWl0`tP<x+CP##/OfwDaC;_:dG;M@tw;rh0*3IA<U#.+U8$)$M48<:2^t,>3H=tolIs>DX'XEZ&4n#ld-)$gO2t$vPJ&v#_(*4x/,PKD,`%#n&+;Kd$p(h@Gh^u`-5)GwnDtlN>B&c]qqmWKvb*:u]<HR-fP^B=-FHCeXa=p>CLsF@+oLmSC4Lj?okJCn/B5`?Qvt^^W#.ACRg*%FfW-7[S=h[96)F/s=L`a`-LsFb'EsbvZl)(B4hqTg]EJfMMn3GvpHH^[/.(CZ8&>&^5E4@3+*t/WW>.OL5T3mOV/)Om(H-j+Dd-eu<qr(C')M9v$JtHQ`=M/CIntmYMd-fbpOBAVRF4DbiY7(O+f(th4-)U&e_WE8*I6B^+CL@8hPKJ'T3/Fs9>p*a]$Ke/4DsrwXSR,<2-)x>2-)Lqq=#r]FJ`L)Co%VPQ^5VfZGtJ]E^-$+V'8QnwA6'X$C8]Z[ZVxckVIdx2C8x>72hmeStLWgMOsc`'Es7D1nsRrA9Z<C>7Axl2T^Ago#Mq(DUsU*.e--8Aj`?Ce3#r)G)M&F?mugXf0Uu(1-)jjtZsgPN&dIJ$.8^CxUfg)N>^k?qCsL%%)$e^aUHe]0^t8o$t)l3YH,b.o,F2s/SsMA3.(CKIQs)+R>M<JThtV^8;/.L]Js*iX[Nw%EBSK;SqL-v6101ILj:vleS:'he>H2?DvLbxlfa7ZxKGXerY?HS-MMe+:5N<Gu43)6;U#+xT8$5OL[t<:2^tDKivUM&ck8UOCUs3Q35R+cj<7OeXMt@uPJ&[m(xXSV^caQV^caAagT.+pINI=hMY$c#xCs`T[&*r7XX$g#-bsYU0%OuC;Ac8'FW-_SL'J3/&Ns]<a/MTO()lcDW1'h>d[K=['3NJ.m#Bs3Lw>@=EZQ>l+Ds`mU*Mg&OsubfLb,,X[?^8v'_$$2btaOBc05?j=Yu:u.89W1t<qxKU<q@A$`<Z#aGsq<EDsckU`$4`B-=t?$Qs&AP:&qR-C/2r%XKq5GCPA+x)X%v*DsR%2>5ECtE@UUVY#lcEn*RbB'=YTAHselk1gUfc5npsOE9*K@&GB5i*@9Eq20*9;U#tj>%p09,I?HO`[FY?>^b$BLQ=X56QC$HV].a5m-LYd/]&.n1utn7n'P19(wMa_Rj31Y2.(xZ,4AgLFLLfri*M&g+>uKCY?/9sk3D[.FhLs>ANsw62=>Lwkb)Q;MRJNRv^t#2tu)Pob<m;bg%+M0t<-quX41*3Eh^36nRsk=,ft/i?&/PKL'sXqb-6*-qBu)$SD&)BxdQ5s&=#U((7RlGW#vaa@FXC7BXdVTF#d@CQ&-;)Hl&DSplT2<6^,:`kKP^`'Ese<T(/FNIL(`kwE7']:iSC5$QsF;hLCPkxoo8FrmL#X+=&br64oE^YiqnAIGsNq-6(f`C)nu5VU6vdq$YNRv^tvhu.8VO8R3DFC<&s[WD)Zmh[+m]%=d-kO=cKcE)t'm2-)Y,fe-kpds&w9n6%'V)T.2?eCs;VNR%-9(C&U[kK518tKPhmio70G2Nrju#d.#kmCsmCnq$VkCb7?g+>uI`Kg-m;F'S^[3)SQ7[/NI?5T'I0&+;V@Ip.UP010qV>(Fr#<gr7)_(*v50l8O.qU@A6Ta>_EE$uuiAasrc:1.3Ut,McA=ILu3S)vH@T1LE;T=#6HP:v=S'1vqqIGLuk4-)X`SkO+dLs-w.dBM_?'$ngTKI(sXk$YgD=T>M7OC4I1YFDItMe-o&:1'3UFv-qUsRM>)doLFYVpLJ1M#=jJ0j(OP69%=-)%+fFmT`f3[n;OGO[9FX^ds7evZsk?0XsFHajL_BRFsnK;Rs_Jh<.53TRI`^#QB]8'.MJ0rMswo*x.YNoVsA.2Gsk9oHs:r;1''X%C/JD9r-*vZd;*0LB#G3saa3u1%Moae0^w8;HsC`M@&a/SDE,n);Tx,Y_3&rh3=7,A]sdmbZ-F=9tqXS@.LQ;?NLiwUfoX)cBM?JVR%r'D_/4p57t0eA7.L*]m*AKW)NB+oVsU,;Qa/4=Zsnq1=>Gkd-)1ncJtNN>B&[GqqmMK-1L6sxR8]#PA>/x&Q/<_dZ;5'`:-WEZ&#Bun05PkFOoj@V/)+@hNaW3@A/dH@S:0dp'M5iqEsTW$&/wWvQo]ND3Gwrb6E591.(g(VMLln<d*sYX0GumCv-1w?]-U2(QF&K'-iEE5.(f48jC1rEkXbE.@tEvK0lMwLLgG^ZGslZIq[MeG)F_M?O4&dW=,#0.W.M$5au6--i8%bQhG[4CW%/S[g8k&HK)n>2-)&d'bY,d,m)iscIDP*Z*7dn/u>,<2-)(*2Z-6uCpp7JPCLfAR`t[Dls-K5b0NO/K:HaYCp.mYm-LHbSBoBg_>XhAtD8DSfl^1+L'Jt*Ih^Z`010.lfn.LU%dsC@wx-xe&kLD^@Z(+[ewF@^n^$UlcFsdH'r$=9Ac4qVf9t%P>B&j<?ht)0:F&CIu*DKUALUuUhiUrR-/V3eFp.df9JsIt?Q:a#PWsrX4.(&._,)ahw)vCEoX7>hB:f=fZ4]hC[eVX>m?$d(4XZ0Sa6fLIDU%C#@,s%MIF)?#[csN`CH-'a4(.oQ=eWWQPTs3*V_JuC9dM.j/Z.oLT:v&l%*.i$CR8>3O2(W0*X%MU'=d[f/4Rt6oBJ+Bs6sE,F6s/ZA7s=Dd'))%KEsT-svMVQGTsi#t4o[AGe6d6x.vs>C(J$n)qrOc0rrZVt#n@x&n*/Z%E3xY#Lg;sDLL,;$3#0;pBbJY<=lB4RGWNKIe-mY_9MtND]O%H6hMlp;R:+Qo0#>Jpu#U%$c%Lx(YC.^F^%uoObC4U(mStlLaTrX^@TOS<;U_CpSVgbE+[j@&h%..-;]`9.mJ=@4$J1Dc@K6E+f%DgHuT>Ov,)[:e4v7kTId?T2tL'xi7#;?v`tfXYg`aC`8.pN^r(6qgGsce.Hssl3_$)prb)&$8@P`Y%BNrUnKco3#1cx90kbi_sNbMchSod1<T6fIOB6<XJKsU;QYsh^W>.U5xT$pnv;-rN(H-2*nA/iW^MsgG*%+FS^&4aj4Hj'&+Ds:[Wm)]icQs/_R<&6@;F.Xge#IqMLs(C6#bW,V>Tsm3mQsJrkv-rWOpLDTKA&D>UA&EF7l9`M8HsxcOlfT?=C3bS5O=#*N48'&CWQ,wF(=nwDGs&Lp3=PJcfT.O8K)#$&xFUiq/)a`X4Jc=%^&hV6HLPPp<lk2nt>PD6.(_Z$P`YZ`RssuZ$Xj2QRJZE<ltpt?I4tINZs*Q#52os4=>.S@?PG]EI)YGLnnaFR0):D;U0NM3-)BTmI;0^*1>S26=>L2Q`-;^^0>>OmDs0n.m=jt3=>_.H`-G%@k=q,RgL6`*vouQGGs7`Y0YVV]wmJ>)A.UX;%=D?UGs$;o_OJ89IC)b[p&c`E8N8>=[XDgA_/8I$^G]0t1>OdRpT0>dv*uq%9.KHa-_jZ(t%Jd?hpRdvD-rPWe*4b89.=7dwFCY`20o8(C&R$MQsCkSwB,uxmW&tHvtgXYg`h_J_Q(Fp[sp4`t_M,+fCC6nDsH'(XMXP^IC29.f;gP#WI>kwxM+jmQs2e6qL5=(:@4>g$kZZ9#6gZ*bZ/:OZs?so*D?,pL0nx?I2Mi5F`J@0-)pL^U>2*-01IvUG#Tc1=>p5E`s+vgS/Aabl)dq<9[0oip.jC110S/sB8F=g3f_M(T.JL(Vt-N332`pIds7V7`sgp>$$-RsX>R10&u<ZuLMgxa-I*3MPsZ*fEs_x8e;=a&HsA`bj)eeAnfpcjXPVuEHsJouCsZS2DscKErLY1JCWxP*c7B<I,MW;/1(p0m8Kgcvqta=@NO],</%kU(CGhOFLL@;bjLRmPqt6Y59Mo1,Q'#-VHMR$,%X3lrh';.vaE'#Zg'T3n#uXoceq1CUbtF1X9si5atP=E'l&4[ZtP3awsZKEI['q$@#MR(?)OMJ=jLkxA:-,D8DtePV*3,$M[O/DI`W,5+Ds:9-d)60ugLaPwtL16&#MDZ%?tB5eAMX46HNV_RO&)PS`tGHL1M)>nx-BDjhL.[R+NW1@mL'4T?._n%P&7L*4+S<s<:OO1H2^JX?Ib2:JsGLND)WOKqsSn?@+xn7wt*qY,)F$mk/bYGf$ku5mtHA;7S3xCC*uoR:.>nTUsRoqR'8kQI:&xhq6pS*DsWbIi)M4^;M)>O#L=pe--<)lk/@`xjOJS)OL%dr6QBlboO8>&ZMC&%%B>K8+@gBfqR+?,LNP,+gO[[2bQ[vbgh4[ItlUPhJs?4@nnU+WtmK<w4nE,OL2WaIL2@iI8-8>XQsh<#YsEGhh#+El$Gs/Qq)bixeC;Y>s-ES5s*^bn@5+%?4&S>k4qE)M[X#v.-)Am[.(U5gU.p$bw'Y0Hs.*>2rRD5u1q0;p]%e^v)*ci7k.S;IZ.5u4&uLR89&lGJ://C.c;TC6OS.,8x+vOWN'SL<@'iQtOM8PS77D@;=-WC2=-A9DeMq:[]-0*Qn*vW@.QWvC.Qi.0sUei0hOYB>oECRw:MSaI&bx-1gSgeK@O)9F2$]:7:?NX@`tmbmiLJ:m`O&TYNb-bh[O(3=2$B/J>-v[<F.;HWU-``d?'?ji^sO`>Fs(3RGreR,u,BN?.)#o.-)c(,lSCOkOA1&Il-ZGDrtA$1C&Y,Wn*-3MC'wvePL,;'XuG6gEs^Rdh0H)iC*%Mc:$W+7.(:`P[Fj-^PYG9W8F[<BkE'YniC_KDm,IM:IUo%[.mU*Uf%_TN/GVE6&J^VbX#ioGf$W0jlte%Pf$s'*ET0OO@`eYH=qV53KVTWk?I:[7)t]ODK&S7f-IXxQ*)toA=#TvXqtDg0,)_u]&tr:vI:LPPtlx-x[s1T)L%ANrnQg4MqONUYDs'Jj$QO]MK_A+*Ds-`$GpslJX#pi]X#);pEsXijotv?K)3OgI=h),0[_Pf=HRtf+TM^xe>BnwTx0ru]<Es/ZZ%^92lA%cGPO[mclOulINP8`9OJnrW&%'s`7cstC&k]dd.-JTu]O>HR(*>pk`Osc*gtG=X70T5C%K0AG%KRiVq/]ZSnL8bkP;ohkV#i[(u#.YPbsaA2qm[e'dMi9+(KAqgk/0]'l2Wj>)W=3>`R[`m[FtbV)%(eNRD`.%EEWP^KsP3=skYaiGsMo3TY=8-gmd/ZUVRW=9oteWbDk+SBf3q?Ds*N_v#PX[L'PNRt^K]@UFi6`JFbbRVs]Y5u>]U'Q1x^^51q/JHsCwIHs&P@i'iPfO%gx>HpCS-KsurY%-+kQQs]a*TsZd1:6;vlYs)adkA;6`Em8A$*ID=Gc%`/jt`'nM?V]6ddfXI3obA;(6b1QwhlQ'ubO=$c?J.mToDcmAi51&%iK;Q-`*U%EZ`[%&9^bSdRjolX9asg(f:YeU_O_q)jQ0VkKQ.x>xTLkajOoF:5Nc>AVLF78fG'SOWmFx6[bDXeEsjl2+)LjsngBYIR@_I=.)NojKliOcU;,.`0_LASDsM`Mx)X$BZsU<hO-()lXsJOH+;[vZRsw9<UI*5/dtF1qq-Ijvw+nO(.LE'Loevfa<u',F`sr..&*@J7stDPOv,T'KV:p*^)I[QQAJ&TWDskvwI(=uYTXmJC&Ux4?tO/b:F;86CC*E(6L#/<8^tIC]b,.5rG7%:gZC=*-HA^'s6/enZR%a&;*J:Of*A^<8sOU=uq$:&wCsJ7:Es&`@WsGLGe_9WsWsYl6Ks,`ZO&/2>_t2n]]t]/]htRd+^%F^ht>SpUFn$`ei%4,Cs6Oju72WpLx9YcDi%jc@UZW4Ig$0pf:$ZmR@FB+^ipAB0s^@e#]4>]V[4?R'+hc1Lc%T4'UMQLQ>#Z`x#*(g[R[`]N.:(^gb24X'u#)dWRs9Dso9LWopt)YX$0IU%VsQg3_j,.D_tTbPdf<'(Js#l8c24]0lO(8RX5Xrhff'2Ge_IQ+4UnSN%tjD(%*'Er6[CO%.:)IIq;$pKu#q&M`tVAMTfm%WWs@(96]D$Ok=Gn2u)#vJh^s=Bu5@]tns%g-O=x#Cbt;X:n:aJDotLP)KMD7<Dsg]rS%vmAX#;h-w#6>x3]KH2lXLF=mCfcC)A&7Au,L#uat=_l-9%E(Al;@Du`9hjj[J-OI(<&ZeZ_9`xoWcS(*qX>l=T-G`%YC]S[R7H=`4q(E<HO'(*N,Crj3']C]Tk2pM%8?-Gw8x6D:(Gc%G2X7b5QpoOiqqPI0u1(tBBEx+_O%HuH7agsfap_fRx9FXLOrcsQcn%uN*;$>>B&r$Tv8T@-[#NsD*5qt[qJI(vW^kA)/2.(8%Eu>)G-ntf2Ytl//Cc`DxT_OUD;otKR;otjXdfs(d$rrA[_Rsx+snOO$>Qs<L&wOV<_V$6:JbVwtD1'9XV$upsBhpXL2+(vKcXYG_%7IQ`(7INpkIs)-'>a%k$m?(J+(?,N9LaqelP'3G0Us<EN=Gn<IMqafteURBVRs(f;wtYY[:6li$N'j8&giKkA7%DQ/()+p>77X%cpsTJPg)98^bpV>rJ/j[$VD>SU[%f_b'[jVseOe&+,>WE[U=jBaqOP+j8b9qt@[GLKc%NwhQs'3Z:XV_Z2Ee^*#??=?9F@q7x_eZ?%MT&IhEFb_7.g@WPWmf6UW/OHpOOvjNG(@_4E/+Gc%x%QntwZ8&tWMSTsCkEWsukvn%Q5.(*&bPno&1X8-3SNltrx7gOM_gLY=]wxL66vLi&Z?]LX4xP]>(`0_tK+<T$5abO`()J-G_BUsK&XkO/D:lFXD^hO,OxCRaHMpI@M9Z$&?QALI<L%/Y+-+20]7_-X:,DsXI*o/p/xT$g^[WZ&2B=#+td(WFY)l(?fVkJ%tv3g>xXZgHxKEsoE(C&U'WK&77b-IDUvq$or=:$6BYYs`(A#MLtFfOPUJ]tBR+Xs9()^OP-Ubt7Dskt2,tkO.bJ]t5#)t-7x:mL;u<[$nAcRaN9jiUX4]p.k1_diW6u>#dII.(ngWltxLRcs7=veOsD7Csm&iBs.`pxt9oOn*++`qQN)c?-;'$e3^6TEs#cu^tYTi^OdK`qQCf=7sGjkv-:=8+Mp$WGstwr#lF5b-_*PP'tKt'dOQu'rQ,:%(3[O%(3c9T/]M)7uO;:BHsec:tOI]XqQEi=+M.]8+M*jhQCeg8kPc=;viHvw')_[S]tEnAv[[A,pOe'?.$dXfah&0W`sq]>o)<V?sHWpF,-co(WHNk^k,c'bGVr5.1-5R+dV%)6g,o-aX6:rH0'SjsJC<fPW-wh<(&#>@(&DqYtLgk[O&.5L[0;2`$'XEO[0(L=(&W[EKNGrGU$v+jcsaL%?PFYR0't--4%Frr.rZRM#Y_F9Es+]71'OL71'm.6Vsi07RRM:?_twGuQsxM(RsT:WGVwI8nO?nTO/<6TWU.FaehIr>R]w?Lf$bdg8NVEM)aUftk$pYriPULxP]CXZ=L4Y_9MDI$2aCKJ;M?x_=LM5kB%@6G-QD$[v>Bp$a$3+nQNE#LjBUv[CSo:XGRUAx3?S$Z*RbrE(S$$:N'Ab]$XVJfNI%fUFp>_rGsc.$x4tj=s1AhUb;#eStf)Q%rZOXm*M:Kg+gBxA[5Xk?mOE(:%FsS8_O)cC7%CS0U[2dN]t^EI+M$<l9%'t='uI80U[drI#/H<pEsa]/I$*J?bs7pRL^9;)N'ZSp3]lXMZo*uaLsvD#ft5EMX-7;Nb.Nf0DsN?e0^@;n-$;kO0156i3]G1[1_/JdVs>.XGs,B9EsmTccsl)>_/xwk'N@fn&Mmr/[s25>C/o:*P=8bR.*%Rwst&'oBJ.Qq(MG%xk&mA=_tvio?K?lXKL)[5+;',7RR#d=_tixB^sYI1akVo>Ns?Hs-$5R^@4r1,FsE`+QsN:Cjt,U#tL,=D#RkfHRR.6B]r_7(:$9e7Xlt9)fZ)*t,ZgeuPWNcjrU0-uwSl:LhO_PfnMI?H=K?=S+H2b9GHK6ZXKOv[nMl&)aOaGjqL-biLFJc#1Hd?bCK'TVuMguuf%Go.,[Vxr/ZZY-:WZ;(]UXg4DTE(coOw-NJiuFOvB'BknD0cn^I0U5TLH,+gOfWBpU&s.KXM'[bZkl$V_-8QHJPR?qOdd4-S%;n^U-CCMZ+[HF]&3W?_a+v6*OBkW_+m3TIjfXvDHEv%CxCeEA5YDvL/?3c@0mVa%]fRJL>]gtNFZ&L[Isl29wKvq`;HBbN=`5UOGj]-]G[9[V<4)@DJb:]PJn$os_Hu)Sp&YZL4mFWLgcpoJH['k,b$N$#+)*4T.C2BT4>t#KpV#o*LvK0*2qU[,uUG=P_/.A-)t-A-DQ&;/o,M.).uB`N.`i=-pvaC42Ag58@P[i1OK7asJ+v$,:OdK&t&/lL*m(1N0#J&KtiA$KB1Xcs>UFv-mlOvL0x-tLX_CH-.bpG.Ab=3D5.'2hBk,3hE+w`,iC#Q8INe9D1^w>LfGsM-[A%m-DB@nN;3X$#bS>R*A4CU@f_cXP<4CWL306BSn3HaSbi05T-Gvg,qBnU)j`#ST-G2--6OR$#b%04KuSs#KnbU^Tn&uvLGlfAKgHJKo#bU(s%nh(s^oB_tF:VGs7sa-rtB[20JL9c)$sp;.1vxB/Tl:=G*u:=G:0kdpIGF.u0;o/1OeE8VdRTkJ%v*Ds*0qc).]Yu#>K,N'5_CXPF*wCjbhCbsi)Ax$6n$:QvnL5//1h'uLVYDN+UCkf@CBHsx?dNs@R[RR)An*MlV$N'wH(2tNLrCsXVC($g_'+DP<oY-f_.F.F0ae-V)8vL`T'x==rs(t<RFv-3E2dMr1^Z.f'wnsK`Vq1f>clsHJLI1N0:^so20%M;-NbV?9C=?'NO/*hafjg#TMaO?F410PPg-MaVBSsYrYFsM7$bsGFKv)@fBeV8HSRA`i.8u;.2O4#TDeL2aKO=kqkSMs4mTsuj.4tS(qkB]Uc.ul4_5M=`SbMbNI$Kv01(AR,b@t6nVa-)&Q_A?9McM03+Uee+$h-i9rrD./e3FEU(1gR6i]GfTQ*INA&+tbi>eqHE&ps.Rdn@G^*-%SL[G%MMBvH:r0pLn6;k%WhE)&1HdA4vSOsQ'Pe%'51j5&c?7fQ^:1n&-PtDs,9L3';EG$,,#(%#14>>#G2W]+YM5D<Cr,AFB;HfUGHl:d1mc7n+(E5&D]IS@2[duP3ih+`M]+v,F^fc;RBKPJ^BdrZ6Jn1pQoO;-[(eY>L^x+`?:5GrDQ]G;r74)NbbJDWGw6At09^A=c;D/L&K:8nDXc87`$:#Y@,-vl7NDmA9^pMT=]5m];a9#lRlbv,;]*B43.uDNs^L#YvqP/h-^u,2r2u8IZ$Fvlf7^^+QN*39>Z9QSfx/QfD&U#lu^sm/avnm8SXr#G)?evYiJDZcMP=$,l4ia<*P+-MLe<H`IEaZPkb$-i*J6[#6/.e2^34wGUvJ<QWWW^t0;jB4?>0tZ?Z0'ka%3_=Oc.hUwNsajWpUk'R9Rq7+M=hL&aKU.4^j0CFk4bax,Q[>A^p6So[_0hoW=40Ol#.D0/:R]<9FeiAHvt?<iJOKwe*4TBdg'ki+nb<kqbeV[_^noUW(S&k&oU7p[qosPYr^O;vxPYLTs8FUw&kEWQidYo`oS&4CHXfAJ<C<%ou1P*qmc%QT2=D4PqoD6>,1Pr?$c%uL9W&6v?<cmuqS&&J5+;nP41u4cU_$/s=-[=PxWD:sa8MY_w(^H[uAUYi>8JYDQm8hw'g@`'q_@-M%OWr&Db%,h4j^n-atax--riE]$K[N'.?DT@@6DTv<B[jcoS&/15(fRkIeUr0,c;]#oktPQjdt(pnh%ArRhTR@.h$^0+k0+aW^,=1$J:5ZIDs37r'VL%HQ&>-N_^:GPCom$%5U?;ORXAnki%R*nFK0?#uJLWgHs])X)sJ9LP1g9A#-]WE&%AMI%>6wvV%^KsA,c.;&&eoObD>u^X#]$<`tgHZc%on2)jfY,fdKu>4_GHi^O,`DQ&tcdl76_-i9#ImO8/@$+D09PU?`',oJxx)w$M;%[sQZOoL>PCEs@)I#MEHA#McG-QsIGpEsuGHq;E(SVY^T_Ds_J1rtgU&et*hEBI=[CeOn/Gs./GUJsV$hZs=?`tO@F87G'`cX#VHdv2D@Jh,3(=i'R6VCEP;H92uHpqdmhPI:*Y$LG7Mo/1r*xZSF.EdD.EWP]Ab^T`DRen7g>QR7-`/et,w?@%<afS1MPPY#.s?ntpEqL2l80.v+UAA-q(5>#I(d[sw,'S1`b-uPh(;OJAwvO/<&pE@makoL:*TwsEnU_%M3HK%[<7Y#4Y+19PW31ujS%_OBQjdt0L=x=$[w_<_nXGM*5?UZVCK:uwb]KMjuIj1JL7:mw2,Q&FHDu,]fI%+wD@Q/B<vt,S-QbDC+9K%s(uDsG=3atOqDZ6'Y(d*dPbH2lC*Ls@I`e:3'WTf8fC`tlch=3#?5Q&QH/kt1_xKsS/E8n9.:lLI5=m'dX_U$Q&_btjkt`Of(,L^2xAVatRpm%4-aTf8c:`t*67]-L`v34fiSo*P]pk1P#WJJs/Y[47uQ]c:#id*41D$57]Cr$ipMFiPp%Fi;;#r$.wft>JNgn@L`^0ki1uDsi_%f0JQqt52rtq-B4o*M+H/4tU7qhLgp0xX07bwXE==R-f7rp.>.Oi$>Uua7P&EV6Flm_sn/ttt3I+Q&]9Fi'r[lYsAtZRs%d<ps>LM=-EP57%s+5[$Opn]t+P9lO7o-#MoFU]tN/f<uaN.uhGos20$+Qu6rMl^tes4?GAvo^A(tw5D7hm]rYrpS&r)K+2HZ802_$#9-iN$iLWC&T&a1$:;$m9X:a+aq/Sdv'vCIiR%B5e^4RBG#v_+f]Xi`7eaobL+r#w7>#]tabO$g<d2/_anqg]YxuArk;W*/Z1g20-F.'p>kMTdcN[KpsOonN2vunNBfB@69Q&_xZBUPB[>le5a$-e5t,>%/Q:v7l/wLeop[<:-<5&nrW:vGMh1vUG'9;9nvU7$lvV%i[ES,sC/-<UPqS&j/<#vGQ^2v$diA.%in>.K$aX%ig&.ouf'Dq0q[C]r9la%*X?dj)X=>#=Q#pLqZKkR6dAm]M&?lfIacLLOh#Ur:,Cs-[.J+MN^q0Mdp`]+?O:_8.]L%,Ujc=l2kKtOmtq^oW('gLMIM>9?(vR.MgS]tZ41UoFdG`,?heE(b?Nvu^ce4XLB*Sp,Wd`*K+<>#$f%wuAbNep+W*PZISkS&[AIHj<k/.(_`B+EcH&_S@d3sk%[$.0$?ob/X@G:voYRf9'3Kn'aOSM'vCP:v0H)UQwtbgV2x9>#_Nh3vDOd5LW,xpAK1LG)W*Qt1qKP:6aVS.(=';i'Ct-]Bc07e%uw=43aBi`aQ)fKcB@.77xtdb2'S0%Ov3qoDE4Gc%ig&.o9,aSZV4,;[,4?9V*`6TeCH/(-5Z5.(o_TDs'#ottI=0gOx:)&Iav/mtk]$qL/st&#3G:*]JaIc%>(./[J.['[hs<RDXoeYDRWQ#u@qJas'3amJ'[1+?rc['XVLCcsO_($u]`=OMkkcS&JpsP??bp_-2Po^fDi[^7`2=>#?#lCs%=9MsmF-f:X@477=WwR.#T(0CCjE5-,W`*7CV*E3^@HF)gcP7JWfK_,_lrI?$/sa%2s*84<VGwK(,1lO*R/Q&V*NFS/3+^bDax(-*_u^f1'/^O.pMuMn(eQXe=Vn*,_-o**s$i)3VLx+t;(S<Yto_%<N19UYq[F1vL^gkZ3>A>(Vkj=WSmp1-U&Q&og/gR&WBvcU2fOMak9Q&IZ]Z&1_[e*//'*3cB0b94769:mj_;gp:$'hJ42<H8JIpg7X2e*a<NvuBqcMjDEkxuqe2lOTh*Q&rJo_OQ+<5&ER;>#5B88vnqaUIrk19fPq6q$36t,>&2Q:vYResOG,$+qiBwW%?4g$vaw5_UZ.3:IIhP#u?h/Es%eG^X`oi/ZDu<%^w<Pa%wgHW$*LsbQTpefOa6?WB^)hdOr#Y[S*vQ[$@i8GKT%97.#JtpOrdOVL8$CQ&El:a*B^eV%[Lq06vA5M_f-TgZJ.NmfdMtpa'kRgU-L8lOGOW.(14S[tm]^_IT`%^*v?sGse5f_OixB3k<@VRsQ.=]sR:=]sFMfk8M0P(*vHo$ted'W..I+Q&bBA?7iA%%+4@:Jsj_GNDh<)'5Y,(jtWKRSs(6'F`O'pF)i2i$u@[rcsQ70D46SR=GuGKr;Vk1lOuf3kOYLf3fR()cMj9P[rHM6Q&IuLI(;g]Ye8+aRS1/oRTf&W4FC_XVdkY(kO&l:tLRbGc%.feOTaHTZ-h))GsTFs-$c*`vYfMLnOTqtuOe[TM:JA/fsx=xB-I#^EuKq2QfW?e_iE1Trt(wSE<S$x2jqpBQ&gm3-3K.N^J-NivT=nr#UvKWaJ4Eka*=hhT%xxoS_D)uDs/$>pO6j,Q&W+(J:URJCoosq*D+QH+;/K3lO@hKOfs)/d<_n[_&[S_A5&CDX-gX^9TcuGF`c5fvtrdCnUbQ4@=p&%vt.Xq$%i`R^$$qY]>g9G<DJA;ehJ)$gU`cOgORPa&b?p,E[nX`eh'tS8IGI6qOX:oq-Tp_X,%aD'Q.,6%--V);hpHd>cQkgS>.[>B=L^cR4CTogOc3nL0Fg4hOD;3s]vc^.=l2[Rcuu;Wgs7rT'9DZ%-QEs?]LJP:v;bDfOkX#G_r&+,2mDR:vHYS7vqMlZQ1]$s$IPl?kdsw'3iWAo.YY2]bwf>[0n7rV1e^2<#3#4cinhR:vp=wfLew(&t5YxSorw.Yc.u6>#Htt%v31sscmg].6AYaa%:V'?5.??.IVv#F%r)K+2@$</2_$#9-dHSgRaH$OFVge)c;vpo.ZwtuuoGOgrBkpE:Zb387CqT:vFql*v(^m,6QXUe(/jYT.>*mXhHpue+TPPY#unAi*.>Ij91]q58:?j(^Q<Q`Bh^`XBRafw]I';iO<g?#TnbWLs.71DJ/m/cI]669:(I-BXukPtULYW@=RSWDNr].nObNBF_8<<59JC^&=f)'cKbMUg%6e$wefG*Q&vEJ;T+SN+27,aaO+9>l=u<,%C*C0%fnEUi$-WvEK1^FQ&5gmt=V]MuO1cx)fr=/k$7@:(@2E%fOqs;qVilu_Fq?nn9K^[x6wLl/_]<.Y#meN19V]tD+:83+)MFmEj[9to9%/(l]xs#k0MTR'%D*?=,J+x0B'Y8U%4UoR/u2gxY_6]RjM=4Z,>dxnjUUxL'dH'%4]mAT8Llc]OBa7c7]f+n%hvHa*`7(B4gG=-v:.R/1l8At#=6pLp,SV:vYnw(MOvi:#6JP:v`Og9vb?Af1tCZAMa,<5&7VX:vojEdOjPRR*YRZ`Ovn-+mQx3ci_-6>#.WW&v=-/*O+`M&-x0LG)5v=>#h^F0vVf5(dsU=%531`e2aB:>#X.Ad%S/GoO`,^e%<#@hadG^S8,%i?%Y5's7@U+Cf/<m>BC[udOxd$@%m9)Z/Ha9$r)Mjdt/3[@%4DP19XF*CW.6Kdk:,qR%tq@Y'Ku?T.;Fc=K7(QZ%dcAmAMEZeHwAdPL_V/Gs8CG^tFcc=RlY2:6Ui6u_n=he%wvF[oe]/(3d@jLC;66Q8(wp=m6s7:-bT69ooNOG<+oK0>([8O5+GZ>_9#TFnd3+'R@^pwkWPM.1V#+.1x1)r;qe^eO.g?*Z+46N^mi0lOeFKc0woT^FgNvaIH4u=;?mY]T3tHc%R.-%KGmfhO[:c`$xv;(h?>`h?L<s>&Jj`^4MfsI(.>IU?J.YU$$M(%-[wN+<pQ&T&.Y2CZf/%%+%bgj0V+-10.-FxsT^kXYQ^:T%qsokt6TAoO%?Y.(b0tDso4qj$@os;KV**jO3hoGQYQ(&KB7:9NYOgHZ..]RsOe;9cWP`DsuXUrta4L.:S,'c;mi(Q&6sa=6kN5v$L'N)>M]a=,-iC1N?w?W&s)Y.(PY)E3j$q7?sYw8[fa%qO.-OI($rc:-H%Ho3f5H`%g*qi^jlj@hlv2r`ZK.fOqkx14<n$ctnI7Q&[8g<*&M9SrIA_Rs@X,(*<D@=,O6YFCM[&g%H_7nL*j0M%,U3:0sARX/P.uDsdkx/(OfC?ujUn`%+,Q.1M?7%FZw.Y:hQY`%QhHE0vPbYc#2I`f)x#5JR`Qe$I=xc,'&:c`8I=>#uxD%vR_+:):aO+`7tCr$;nO_-2=P:v8:$:v:R3Jf'%V<De(El]6lQ:v/=CrOU(;>SB/NpI2dk2UI(`wEtEsrO6miOsORjf1]vX)s]LV7I.:wk&EE$%+Q%/30<.tPAi=:&npnfC=9SPU&kfU.(x>%NB__(dBWXja*=Ni60L7j37hNh[,W5I(=9IsS&c5Jj%ufLdOl<x;Tq/_Z$S.,HK0Y'u#>*wrOhWT7G7Xne%qqT*]&=HQ&'(-#.jO<Lscr]_j>%1lO[S]7.K,Tet_Y8_jFS)c<)U&T&KU^FGjjge(3^tn%Rc/n^&-Je*l,CY-mx]6E5hF7I`7'sC_nGc%@ORoOk,JLO/<@Ns5V5^tgv%q*NP+F3vW1fqVcQ:vXwK9v@7N0ft2LdgLw)B4?:FkO^jX`R8@EdD=AJUFqVltO@=?3q.t@Hsdd7vt4b4cOjgweFoju]$chQeRvw9>#k7]pLOLOh`#RrIhT(>>#YXr.vY@I^#AE?D*Y^=lLm3F^OQ0@Psl%019O]c7%V<Y1'vQ(Is-@'l7v&*T%^HF/Uxrdahg#lU%tn[9B@cMx9K2V'LT_5^toDY,eEuCsO=Zrg@pEDQ&;R%cRx^0(oJ4Wk-2g#+B7]GG<+I.-bsWc>BxoLa%^g;a*4%B?-ftlit$7x2-X:4[UpLQf%K[A&FFb0DIX&JVLFle`%LdX=^'4-F]BGsII+F;d%xg*GHKVrOF^H#=M]tX,HhrCsZAYZ7XZA$UWKa9pWfK>m]kvwd,P_%`<+BFXs9SM+Rfc*cRsUPPWeO6iO^EGOFI'9oNHPFQ&Ng<f:c#snsROL_$I,rI?>?b^%Bg9,V/Rg8X5;u;d$Dv%m(vfObH:Ng%^@XueD:5sH<4O(ILdJgOe64lL5nof$Ie<<-aS&n$^dU^T.I;BT+G;--.####u4T;-4:eM0pvK'#(5>##*$?tL(g=L#m?Y>#-<)mL>4pfLe@6##FvX?-345dM_VV8&;54GD]BTT93c>A+4iZlEwYAeGx]`f1)>MMF`E<;$Fklxu>TJ8RWO$##dB_O;PjlB=GJMe$H&>uuQoRfL7nR`Ec0S.#AroF-DwchL_R6##08P>#8&krL]RQ>#gNb&#tAJ>H*=6p/0g^D4<(O88%]g3bvrIfLI-HIP-Fl(N]TC`N-9x%FcWJ.#xw51F)Ym*NA7$##wLYS.+GY##AA081Cke%#k`[@#c)#/&IpchL/k20C'B(;?F4Me$wVml&:t+/(Ucsx+nHel/0/V`3kF,290LD>#sF.5J5AvV@>R1L,a%m._>[3>djY^-66%MS.3cCK2TDP`<Mjb3=.L@VQvIF&#4D4B#2dkuGSCI2Lg?Ne$a)FqDe1dER5oLS.&Cg+Mb[F)#X+^*#HbFoLt'B3M0(^+ixOO&#YN,W-,.OX(Wdbe$.;$v#cWn7R5)fl^T78F.fn;'f5g53#5(A>-;NYO-E<dD-S6v%.6%AnL`-'P#rYGLMH))TNJThlLeC_l8uNhA#LsJp&@1D'Sq2[`*_fg,.r*9SMBb?1MtT320'#-v?8c5,a=,]'8(u@J1aVTc;TMHL>^hfL>M;&3:riF>#GQb3=<fR)#x4n0#:(02#RqG3#kd`4#-Wx5#EJ:7#^=R8#v0k9#8$-;#PmD<#jixX#+Su>#CF7@#[9OA#t,hB#6v)D#NiAE#g[YF#)OrG#AB4I#Y5LJ#r(eK#4r&M#Le>N#eWVO#'KoP#?>1R#W1IS#p$bT#2n#V#`4G>#LF?5.u;NJM'M`PM#5;PMQFq0M#1,GMY[n2Lx+G>#'2*Y(r?L&#m[jV7/(lA#:Gg;-rHg;-t^U[-ipX_&5@l-6L9)UMD-1SMJuBKM7XFRMfj&3M`GVG)vjvf;d@/s7ZD:&55KK/)E1T;.7Kkm'&2>>#bVU_&L2P:voo_+VXQIQ0u%G>#G[N_&GqPTMG&*(vF4)=-=tcW-:>:4kr$p34NA,LMw(C0Mubj.L$cx.iBb(^#>G@&,-iF]ulfooSuE=Mqv:+Au$mQfr7^,g)4DBJ`VUeQKsp@>#Sr;V?S%+GMJv6A4$o<X(9DBL,G3be$81Sk='1oQaXI/2'+Jju5#[c984I>A+v3FV?Nu%8@OZ8g2-'8L#tBu@XQmoG3J*<L#5w=5&e#q%4mYbQjil`oI+6qx4?uPi^?oIA4A+OY58;;)3a6@>#fpWoRDb<t-gPrfLM.x`EckB`N19/[%-a;W#cSSX#&JlY#=:.[#U-F]#nv^^#0jv_#H]8a#aOPb##Cic#;6+e#S)Cf#lrZg#.fsh#FX5j#_KMk#w>fl#92(n#Q%@o#jnWp#,bpq#DT2s#]GJt#vC(;$7.%w#Ow<x#hjT#$*^m$$BP/&$ZCG'$s6`($5*x)$Ms9+$ffQ,$(Yj-$@L,/$X?D0$q2]1$3&u2$Ko64$dbN5$&Ug6$>H)8$V;A9$p7uU$1xq;$Ik3=$b^K>$$Qd?$<D&A$XDaJ%X=7[#0hG<->Hg;-]Gg;-LGg;-`q`=-8scW-=iRX(f7`e$nBPX(U,Z_&qYce$C'be$[1KR*v8__&PNbe$I8_e$Wc_e$H5_e$1Fae$i@`e$vR<l=ieW_&:vj'8sAu=lGd9SI&%Re$'#;Yl-n<Ac)lkA#<e%Y-d]U_&[#9F.mW<F.LBbe$^7KR*TX/:2B#_e$<g^e$;d^e$PJUe$Uq+`MRQB_MA[Wk#B=dD-:lG<-?Tx>-lmG<-qnG<-L:)t->(ixL1[sMMnI8bMD-UKMOp?TMSVEUMiUY*$LJA/./.GwLDo#u#<Cg;-qO,W-?+`q;0gU_&D)_e$FxNX(c-DVZbJ7;6AQ4@0t]Pe$+MOR*OO&FI1QH'oaqOX(PnG_AT(W_&POee$(*^e$7oFR*,$x1^(['a+;:]PBHY`D+^F7qremaw9W&8VMY)3c#oF0t7Vwxc3PNKVe)4Z;%3:tiC^`6#62,=2_p.$@0a#6v6BJTe?K`M_&QX]_MY2eTM6SC[MQI-LM-YAFM@35ciXn_;%b9UGEhkflgI1tY->0W8&6TgJ)8gG,*D(9v-E1T;._<<Db.>H;@KD^VIdV><-_mG<-30A>-xFg;-3#L&8(@/s70OvV%L/2_]Qme3OFh>TM2?BW$KBLqV84u4f#h_pBSWK_Mt/3c#_<k(NV2ZX$N2-E>'.,GMV7D`Niq18.m3io.qKIP/ud*20TFKOp&KK88UvZP'9mTc;l.6D<C?C?+@dNjL/rf(NBT8SRXrh.Ufha(WpH#AX-,Kl]CI%G`TQ9]bnw:ci+>lERneH?#CL@@#BV&E#WuSE#[+gE#T`6K#u>]P#1^4Q#6jFQ#;&cQ#B>1R#Ro$S#Z1IS#cInS#iU*T#rtWT#w*kT#&=0U#5t,V#A6QV#INvV#MZ2W#QgDW#k.GY#9UR[#c,q^#1,E`#`Bic#<Zbe#mesh#MKMk#$pXm#b[?(#'2G>#7192#^_kgLTb6lLZ0nlLaTNmLg#0nLmGgnLslGoL#;)pL)``pL/.AqL5RxqL;wXrLAE:sLv8J0#%,>>#/th;-PRPkLqV(8*IpKSIq=bo72=(AOJ#p4Sc_a(W%ERrZ=+Df_Ug5YcnL'Mg03o@kHo`4oaTQ(s#5lY#;kSM'SPEA+l675/.s()3FXpr6_>bf:w$SY>9aDMBQF6AFj,(5J,io(NDNarQ]4RfUupCYY7V5M^O<'Abhxn4f*_`(jBDQrmZ*Cfqsf4Yu*8>>#f5Ch$%2j^oG-5>>qa;,<P?*j1v%?<-Exe7(ZSFL,c.`e$F/_e$0YT-=WMU[-h`W-=%q//1h@N;7HmgX-`FOR*e4`e$.vM@K2>YI:`/JT&&2>>#**3b$@1>R*.%/@:pZP8/mJ<;RVej/Mw+G>#$JV_&./Q/:hO[A,rV[Z-u%G>#6YUe$HwYTM1^)aM-i^H:.]PR*wxH'?(P,W-v@*44ugfe$gvmA#m]?:(;OQL,v75kD.rJfLcu+%&hw>A+-'8L#o_a+VS)P)4M29L#nJnIqU;1a4J*<L#3@=D#9i1$#HV&E#I;WD#mVq/#o*lQ#pQ/a#=vm(#Dv;%$n=;mLPoQ>#KOg2#hiGN#l6>##P97I-<5T;-B5T;-H5T;-XG%n&)W$@'$Y,i$;@hr6-#w4A5(rr$EWCG)^=5;-v#'/10+Y&#vnde$3Mde$_#ce$&&de$%#de$8VQe$1DOcM47P`N9R1AODorw'N`8GMcKpGN?'IYPm/I&#k)I&#m/I&#o5I&#sG[&#ndE'Sd+BK<dTkd854l3bxhH_2&&wX.Ni)`MU(Vp.56c=Lchp0,92%@'rYhi0E<VY,pE(&+Wls.C2.35&S,387E@YY,]H-87,[VW%(a:D35wJ_&SjQ]4<E#)3'A/;6(THG)*1ux+T,YD4S#>)4;wdw'3Q,F%K,l-$Epk-$Gvk-$Fsk-$kC*:2V0UDt`i-5JxP7F%ucSY,Q)PW1ihvr$AuBM9Bnil/*=3F%K,l-$Gvk-$cp(x'PPc##e86&M24ItLj?W$#7x.nLcJH)MxqJfLamH+#7IhhL1x.qLt'd.#$IonL^G/8#Kqj1#a@+gLU8RtLJ&7tLbk>.#_]O.#u[AN-4@Rm/`i<9#xa%-#<YcD1'tx=#-i/*#aZS=#N.r5/^@r$#xq$YMbw`^#Qc/*#VfZ(#Z3dr#7lJE#4(,'$mo]a#^5T;-;dQX.Uufa#6?:@-Jp8Z.l2FA#k2u41<MsD#weUv#VPu>#4bCH-P@Rm/>D6C#88OA#e97I-p`oJ.FNHC#coq5/Mx;`#VW5lL]<*mLBMO/M4/o`*JW0Vml<>5Ajm[D=%+$g;QA2#Z)4_E[)8<;?qi,F%M+$v,7ncuY3QDMB[*$/Cb53?Qp[?20xVADE7S1kX_:.wu5Sv;#7_>pM#Y_P8J51&=@#B;I%rv2(?DgrQ,0V/$7a#3#G+GwL*5Qt7BIPF%NPc##8YlS.^S(vume1p.W-M$#bwwJNMC?##52a.$cqe%#r_7:.1?*29T(RML8q-k:SRklAf9i=u)YZ/$*gQ(#hG%+MACp?PG(_=ue,k-$sF_=uBwr-$)]XD*oM#KNw(`^#)P#dM%Kx0#oIi9.=V8a#MFP8/3f3W7AE$,M4PU2#L$iH->@9gLf_d^Sw'59#Yi/*#PMa+M%*TJ1<a0j(M(:I%O/ll/cO?_/Gda-?-deIq'1UY,f?R:vHC]:dq%CDbfZx4pa-EVnC'0;e>OR]c0&+2_3/f5^fDMY5p]`Ee`pEM9YCi)4P;:5&l*DAlfxO-QWt5R*ZYl-$5X=G2qg&/1/H&F.LM/;6jXfS8*3QV[dHhZ-/ww(<p<k4o:qb;7R9XG%k*jl/%LLk+=?*58iHfQaUa[QsbkJGNs&-)OWMD2Ck^;8SvPIF%=7YcMA<_a#k<-C#X3SoSKvH+#6qF6#%sLG%V?*29=7gr6In?W-9/j&H&.BJLQC?5/:VVQ/?MQ_#]U'B#ZHwM1EO,_fMVcCj7k`Y#gi`QjiZL7#EQ6(#-1x%#G+ixL*ecgLkZc9#rJP##B3_'#Nhn#Mc2$)MY*elL5phx$RS(vuku=:v/3/HX^7vf(EM:<-Ut%'.eZu)MtZWo$,GuG-/7T;--<+,NON15SZap`33uYRE^WNp7@%FW8kJ?.%5sc9DYm&;Q9c:.$1K,F%Gwn-$;i(;QLY1F%)qj-$vX$##;ao-$x]p-$8In-$bol-$27n-$f%m-$*vp-$h+m-$qGp-$dvo-$ShMF.=r2F%1=9/D91MMUXwJGNJ'I21:4*F7pMW^#OK&a#:R'DMpq+9#qhY29]doQaK]>M9N$U4fP;:5&0cEG)PvMk+7^wf;w&0W-PJq92BCJ_&5ivr$^*/F%I'o-$a&a#$4BN/M4W-2T*RTs7uKk4o>fPk4@M;5&U?^w'`gEM9mF>M9DjVG<?h./Vv&WG<nOBk=WmMuLU8RtLliv)M44v.#0w3$M)qT(McGm6#<NEjL9V]F-'Z`=-hmWN04->>#=*F]#vWajLC3(E#4p]a#DYe[#^p^^#aAFV.e/O]#+cPhL0bf7nkn]W7(A;JUYsRM9cO]88,SQF%2lP%t/TauPJg%9/Y4ffLo>UiqAB<)=@WZT8gWwY#w%iM'Wm&g26W*n^Vc@ipcBR>#e7XA+uuMcs-<1q'so('#ZW_TMf4Y9#,Bq-%jqd=u3f-j0eZxf1s>5a4&E7RNWR,^#1TRwT)I;_8v_$##t'*<-&sEn//5YY#%(gE#cYU).aLOgLJPvu#-B;=-[bK`$ADH&Mj;(sL:/fiLb^_sL=w(hL,6%&M,)doLGDS;%aH,kbPwLk+q:hiU<a0j(;E@&G@'kEI6x88@=<_W7o2B8%[q.2Tlr)pfQlRfLOINv'iZ&<-c+O$%qoG9rux,.64]s)#ocBK-l],5M*LLm8RC1^#Fxsb.JdK^#f`CH-6UEr$-Z(G%aT:T84?/p.xKhl^.&?2Lik+T8C*729S1VG%en?M96)IG)99MM%07#kkYE6F%WMZ20x1rvu0BbxuL+ww'C.;/:xxGv?IX[F%)8d39#?8H<5C:58@sK?7bjXCP4h4onZvb39TV*x'd3AvPALoV%U1%X-d;vE@(b'3DE9mI)7ivr$OgnFi15hT[kR)$-1<-/()6)fqUlrR/Vh`i0Gx55/:mt;-R5a_*FgO2('FQ8/RPwpKMU]v$4/7mSX3t_&54iAOG>sFreh<Sn^AcF%?b%##NBs-$Co(##Rj6R*,TC_&<Vq-$-(n-$-uKB#adv_#X?gkL/JhkLcVP8.PC'&+'`'B#(4&cN9lL%MV$#d2&<7VZlb4;6R775&(q85&N=m-$x>__&&1;GD_Ev+DP#?@daA?/(<PO%t?]ADN(+U]OW%gY,7aK;@]K-Au354m^4hs:mivt1qhrOpS6M_lS+,l-$DC>GM#Zk]>`e5^#HM#<-;6T;-S]Gw.Ju;D3[Uaw';CGG)*/22'sx.;692/873#x_s(;iu>+KM8]w:&,Mud)/#ud2<#1vx=#.H+.#gXj)#pxhH-sYlS.M$,>#ue^01(ul+#_Q`,#Rq`8vNh'S-<).m/*8g*#l`r,#sYlS.vN:7#/BpV-l-B-doAp-$*5JG)3lEG)V*GG)4t9=O]2)##"
-- File: 'Cantarell-Regular.otf' (68340 bytes)
cantarellRegular = "7])########WnGr'/###ZE7+>)322'Ql#v#RxMT9$w10c2U(##-k%##>VmT9r1)%S9U*##Sj*##v5:t8qjjcDOA'##wvW30B:,h<DnYjlAB[w'P_4R3lO(e=<<ee<nw]w'pG+I-iSte=pe_L9H@*##K'^w'7vA0FZ/'kcn7*##`i'##GtBUC;r:gq&HOk+^HfD4AJr9.N^Qv5_(iJ)Z?dW.;h^`I2x,&9HfWds,SY#u0iR/G-d#[T)$vx4HT3w$qmnUCCw;_tP&1LVgn*sm@C=GH1*#)3c/qH2]qk>-VdJe$JbGw-qiWaAeI1=#G<5)M)Z<ig=8[QN7]&;6LPuxkFf`w'OMYY#0]Wh#cJf$$nNK:#&/G:v/n#?$JB'C-$]lo.f6%##QhSe$UGuY#@6B2#*5YY#D1O$Mt.BrM7@RxkW$eY#/55##nOSq)ph2KVfoWo72&M)M@Zh]4<lc)>.[6;-UGb(jkV+##gswo.0$0PS/(v]lQk:;-(U7p&BG;d*RG%xK0@n._/(1B#,:gxX01L^#Du)Ab1:h#$nkpY,2C-?$N9e`E3LHZ$)M`fU0=?v$ZADPg7q`s%7x(Z#:6]p&qcv]4;?x5'$kp`W<H=Q'vZ_DNMoVh)>&^M^'5>>#0>###RMZ9V.(1B#wJFSR<UL^#;Nw4]1:h#$BJ[rd2C-?$;'</:3LHZ$nXNMK0=?v$6QquZ7q`s%'C&;m:6]p&]AmJ(;?x5'v7(g:<H=Q'YlL&=^$>j)37=)W+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%Rm>G2WMhA5)p4L#Vrd'&YJ7A4>36R*A=@_/2O/F%A[u1BE;Qq2e+Be6m%L`E@x&?-/`?VH?qTJD<[6^GK.75&W*?X1:*G_&VR?M9I^MDFZkk>-W*f'&5ef'&)=Z'8:si+M5If>-cFII-8)m<-fQqw-pm-qLI4urL6#/qLIwXrLIQ-5Nh0n+#;1SnL$NpnL:*8qLGWdD-lIe2Mw6;PMw'crLNwtRMM`7(#-Us-$-o^%O7juG-g&l?-CbDE-$^mL-QMYdM]mrpL$SxqLxT`/#(TC5BE9Q@0#8ujtT.Pk+a:p^f?_n-$>N_w'_j;MB`]iQj+O;_8K.R9`HHO-Z-pl%=/mC5BWV6^5rw4R*C9g'&G-QY5+v4L#vSWiBT1PcDlE`>Hn2iKY@5scE<<i`FBt9/D6pjG<=;tjtYBDP8DX=gG&>.FHMeZ<0+9IL2>*e-3<6i41f&@UCVpIKF&6FVC^x2s7:8QhFsl<6&h=r*HhxtLF%g9fFM>4sLX2oiL8H%oD#SI+H-6eYH#g1eGvRb-631(O;iG3VCd6u?-BdiM1+sDSC7;ZhFgLqk1T+IU;Yg>[947V.G'fC90rxuhFH-B5B8tDU)2?ijE2MD5B&?^kEdjeUCCt7FH-ESE-rGnC-=;G;&:4//G/3`$H(Av-GWPX$HAm@bF&B8I<a_%##C^'=-VK%'2vgc+#E<x-#ZZO.#$mWrLx?Y6D>LlpLjLRx-k+7;8ZnF`8';_g24gBJ14S#WoMX(d-hIGd=%&2lMR4kn/H/^'59Beh2l9BN-ZHJrNXX0,N02$##3:j9.,9q'#SjS,3?^oW_NprAHYWhk1>g8+4]c&F-or&F-doX$/tm@-#9OUv[j?2/#3sarL3RxqL+Od.#w5^l8+b%F-g*S+H(BKKF>q^JDTQ^`&_j;MBcMFX(dGMn303%I6wuo+DxX4j`l_WWB,JqoDQT5fG9ri>n,;*n85oIvn>+3(8g-+Wo=Lg?;O%g2`+1eQ8>`;ml#p;A-qx8;-%AT;-JKjb$;/Z3#-.MT.FVCv#ICLV%dDq.L0v?S@wo?MKGWarQxG<S[BVMonqfOuubC,v,6Se]4HD`uc`J^;$HZC,)Yis]+va*m/3&vc2J0hPAY3fVHZrqiT%3%vYA%mi^TKBAbV0ZcrB99#$:0bY-Zxrl09uMM:p_hlBT0[fM5@FSSM-](t+GO2(=e`D+Ns9v-e_bJ2(<s]5:Y-p8[0<>Z0mdf`EWBv-eR4j1Qj>^#'5Fm'9:?g)JN4^,tZmD4f.:pA'L'?$hIJm0]R*<.*$Gp]2T_2_>GW,aFxoDb`g&Tfs3ZZ?tLo<%#8P:v9L:A-SgIYPW13GVD'^xbR[b.q9Qv`*rm8/1sO;^cVmE##;-f3k@LI5/1pYG2i`o)38MbE$.eYJ$cp@L$/pkM$Gc-O$g6BQ$wo%u,ltYZ,LgF^,k(@`,K?dc,$doe,*-9VM9t;L-T9dL/86f=-YDOJMx6R@-KmvxQ8R,8N`/;hLpR^COU$lB.hElR-]>3l%Xuf=#Zu(Yl@Yb4]xT9`W=:'GMjjSrHCNYr?q+1G;1qdr-'qg@X'GW+MoGClJ]tQxFO.uCEfmn_jVf1iTtvEuGQ@L%F?/sIC7TZ1Bw[Q%=ec9c;p..57Kb$)27&RS-okHG(XMol%*>mFqlvwOn]qY:lP=^=kJoa@jDDI(i.q8le&@wRdii/``@d[x<.v-xseaeOnG@V+L[%Lf'G^Vo$?'$;#*DmbqNc7(ibSs_`UW1:u6xuR?[=54It+XRHnV@:Gh8`XF^?0(D$skX4M,w0SqNBZ55V-<-8cX.hWFE5&K)sA#*+V2&_8YY#*P:;$.iqr$2+RS%6C35&:[jl&>tJM'B6,/(FNcf(JgCG)N)%)*RA[`*VY<A+Zrsx+_4TY,cL5;-gelr-k'MS.o?.5/sWel/wpEM0%3'/1)K^f1-d>G21&v(35>V`39V7A4=onx4A1OY5EI0;6Ibgr6M$HS7Q<)58UT`l8Ym@M9^/x.:bGXf:f`9G;jxp(<n:Q`<rR2A=vkix=$.JY>(F+;?,_br?0wBS@49$5A-B&##-fJcM4=c%OK&p4SbUEcVgka(Wl*'DWqQ>]XvgYxX$0VuY(Br:Z,an7[380P]5DKl]:Yg1^B4)J_FR%G`:_ixF>vViB3E<]t9&d+VP%PcDQax:HX28v,BmOlS^s&>GkklV-Sw@VHR5@)*-8QiTW6i(EFR/_J45d4#[#R0#IvK+$.%#'$XO.%#brdg#+j7-#';w0#xG7@#+98t#f`ot#iMSt#(<L3$jW_R#hlUv#3S1v#hU8&$]d]=#?Xft#rxx=#0fa1#0lj1#9x&2#A.92#CF^2#1.vE6PqG3#Xk>3#=nHK#kv0J#w(eK#rV-K#(5wK#b4S>-.VjfLw0#GM3Vh*%4%UB#+GG##8$lf(8Rj/:ogZp.'2>>#%M;4JDUHK#A&x@t_4-%+#hYftu&nxk+ZYf$V?$)*Y;Ke$U_+/(?]nA,-@Ke$PJ#lL1V7P-so66M=(n##HR@%#eQk&#,jH63DDW)#`C,+##7D,#Jgb.#Kx>tL#xWuLtnNSTk9#AX05Kl]It<`anX^.h7a0YlPIxLpx=L;$?-5/(dhUS.-p()3Um*/:m7Z`<-nKS@Hit(EbQfrH[a=3B84KM#HLpM#l&8P#6&cQ#[=[S#u6'U#:0HV#PmMW#cSSX#'PuY#AF@[#_W0^#s&h^#5&<`#NoSa#&b@d#ETXe#aS-g#$GEh#<:^i#dj%l#1vbm#Nu6o#hhNp#$CBq#:6Zr#U5/t#p1c:$.fLv#ZW9#$'Wd$$O1,'$&bI)$CTb*$hxm,$1xA.$KkY/$`Q`0$vDx1$<DL3$XCw4$uBK6$;Bv7$WAJ9$uI:V$:@I<$V?t=$s>H?$9>s@$U=GB$r<rC$76=E$P/_F$m.3H$3.^I$O-2K$o>xL$>PhN$_haP$1*ZR$M)/T$j(YU$1+.W$L'XX$k2?Z$7>&]$WIc^$tH7`$@mBb$clmc$)lAe$Eklf$l2oh$22Cj$N1nk$k0Bm$,h>n$Cgio$`f=q$'o-8%Be<t$_dgu$%d;w$Acfx$^b:$%$be%%@a9'%]`d(%#`8*%?_c+%[^7-%x]b.%>]60%Z[a1%wZ53%=Z`4%YY46%wb$S%<X39%XW^:%uV2<%;V]=%WU1?%tT[@%:T0B%VSZC%sR/E%9RYF%UQ.H%rPXI%8P-K%TOWL%qN,N%7NVO%SM+Q%pLUR%7O*T%RKTU%oJ)W%5JSX%QI(Z%nHR[%4H'^%PGQ_%mF&a%3FPb%OE%d%lDOe%2D$g%NCNh%kB#j%1BMk%MAxl%j@Ln%1Cwo%L?Kq%i>vr%/>Jt%K=uu%h<Iw%.<tx%J;H$&g:s%&-:G'&I9r(&f8F*&,8q+&H7E-&e6p.&+6D0&G5o1&d4C3&+=3P&F3B6&c2m7&)2A9&E1l:&b0@<&(0k=&D/??&a.j@&'.>B&C-iC&`,=E&&,hF&B+<H&_*gI&%*;K&A)fL&^(:N&%1*l&@'9Q&]&dR&#&8T&?%cU&[$7W&x#bX&>#6Z&Zx`[&ww4^&=w__&Yv3a&vu^b&<u2d&Xt]e&us1g&;s[h&Tfti&mX6k&9t/m&VpYn&so.p&9oXq&Un-s&rmWt&8m,v&TlVw&qk+#'7kU$'Sj*&'piT''6i))'RhS*'og(,'5gR-'Qf'/'neQ0'5nAM'PdP3'mc%5'3cO6'Ob$8'laN9'2a#;'N`M<'k_x='1_L?'M^w@'j]KB'0]vC'L[JE'iZuF'/ZIH'KYtI'hXHK'/b8i'JWGN'gVrO'-VFQ'IUqR'fTET',TpU'HSDW'eRoX'+RCZ'DE[['`D0^'&DZ_'BC/a'_BYb'%B.d'AAXe'^@-g'$@Wh'AB,j']>Vk'#>+m'<1Cn'W0no'x;Tq';)dr'T(8t'oqOu'93Iw'ZD9#(,iD%(H[]&(igC((/gn)(NrT+(p3N-(?H>/(gc@1(-ck2(Ib?4(faj5(,a>7(H`i8(e_=:(+_h;(EW3=(`PT>(&P)@(BOSA(_N(C(%NRD(AM'F(1I(_(FoamH[5KL2vc-+%hC%+%>wehMWkmhMw?ju7sPudG=nhmMH?4TB,ZkVC52%Q/UxGhFoHD=Bn$GT8'+OGHvCae$_N)nD1A;2F)`*_ID%ON0Y_nFH[6iTCGQwjNJHbpB.O)E-0Hg;-gGg;-7)`5/W@ViF73iQMi,gjMSD4nMi#KNMS;oQMlGcgN#`0kNm,gjMhD4nMi#KNMb#OvL$_:-Oju^0Oo/^NM#G+RMnSugN#lBkN6;TMFvK3.3WY5W-a2N15?HlC&SeF<B.5n-$qrooDnj<nDl3_M:6TvfDn6_M:;fsfDl3_M:xmufDn6_M:-%1N:6)uq:6M8,EclX$K3b3iMT&$JEsp%UC#BKKFKgkQ;'+OGH)`ae$)@K88i[oS8d^jU-9Hg;-v#jE-56T;-=kF?-jQC[->xIX1SsZ.<^>NDF?n'7B@C=GH3p0SDN0W7DXS6O<Quo`FtmVG<Qxo`F)dxH<,mX7D/o;2F0%OGHJ2Q<-)0sE-TdSF-jd11.gcmOMI4:SMvxuOMZ9CSM%PR.O0jv1ObfHrBnG^kE@g&5N)IsM-.oef$XG8(>,%H>H%ZX&>#i3GH$j0B>'wI:C2%be$&<xB]D30+%&?4_]B$be$$5^oDGj<8M(oEfOP1jiO;&ix7`maYH&a0#?./G;I0)hY?PJ#sI12-v?jWE8J'#-v?np/<-A].;'FmKNM:T=S9d%@B5&sOhFLZ[7Mv%m4MAEUSM$67oDQxcg3,RgS86lh;-Js<_$DB=iMk3EiM^9NiMfjAjMu/'W$P5UjMp&^jM=oxF-&#>c-01LU)?w[hMkL0`$A-ohMEu+G-'v+G-'v+G-'v+G-'v+G-'v+G-'v+G-'v+G-/iZx/Vs1qB*SvLFC&^GM`-gjMC-gjME5gN2#LlP9f7,dM54pjM54pjMF/D-4Y.?LFplqaH<ndjN)*u89>RXMCx5/H<-p(*H:g><-TJp,MPqvh2kTN,3j%Gc-[Sa3X,7@LMNuvh20Oo>-jMp;-Ztx/.PTBNM^bQLME`8+4B#/>B'B#hF+g+CAQlm--4N*.3'wI:CTmww'UuuG3r_A@'AL[H3d,OhFm'ZWB4GEjMfBIe-8jRtL,47LMsw)i2EExG30jt*.$$u5C$e`TCTf,mNjfdhMYfdhMYfdhMX]HLM-nmhM[+E.3v*wG3N/K_8q/v'G9aGW-qXow'0Heh2^&B,3M?LkF-77LMStmL2sv&d3eL2d3U^Da-igHb@8;>C5i7j?^^Hs?^^Hs?^CIjq8l%BbIE[JR9]#0g2TPp;-f7,dMoxBo-(rVkF:$4d3rV@m-(rVkF2`h;-FaQi$b8P)Yi_;u7'-5d3jkIU;fk$T^Z)3i2xLD=-ku+G-:op=9r&,d3QCT18^%,d3QCT18duxc3qnd;-/*%^$0LehM0hdhMCbD:8F.XkF7ne;-K($a$0LehM8Sda$1RnhM1nmhM1nmhMllmhM1nmhM.b?i$X8@Q:[8jI3.Re;-lu+G-lu+G-lu+G-lu+G-1o'S-AG'`$lwVkF2p>kk2p>kkm$WkFm$WkFm$WkFJL.W-ri/K<i_;u7wuxc3ma&d3ma&d3ma&d3ma&d3ma&d3ma&d3ma&d3vD5*4K(:oDCg<i2NEUkFn'WkFn'WkF3s>kkVq.W-,(WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFn'WkFP_.W-uV/@Bp-WkFdhJ@'p&#a4s>cA56N0g-of-+%+fVA5+fVA5S5_A588ZA588ZA588ZA588ZA5a+.'mke;u7>uWB-OxWB-OxWB-3$Y?-DdkgM]lAjM_tAN2:wK88DxFe+kkV:8B6L883`N883`N88PaL88QjhS8C?hS8C?hS8-e=<Jm-S79M&,d3(%/>-Mts49M&,d3.gkL9Lvxc3^)g;-rVYd$7[;<Jm-S79Lvxc3^)g;-rVYd$7[;<Jm'8r8JQf;-&q(P-&q(P-pvVE-oqSN-pvVE-bFQa$'PEkb'PEkb4Yh;-Ha?i$CjgjM5/gjMFs+w7[fF59p%J59p%J59vCbsfm-S79N',d3Nop=9Mwxc3`6/W-=[WkFoAtJW$C[E5LPnn2E>)@0t`e?TcC/s7ZdCkFlkfS8pt+p8L9CkFvEcP9[s&g2]s&g2_,K,3cU`X-hf-+%Xo-+%jQ<g2tw]k=Nw]k=2XnLMuVxb4i6=kOD%ZK32WbG3%/_G3&8$d3Pb%d3Pb%d3O`(d3O`(d3_6&d3_6&d3Pb%d3Pb%d3Pb%d3Qk@)4ol>)4ol>)4`?A)4`?A)43hE)43hE)4%=E)4'LjD4DMZh-lf-+%'H^D4'H^D4DI[D4DI[D4DI[D4DI[D4L$OE4EJCeG-ueBI*,h#?'+OGH4+be$r;3nD)DM*HTigPN1sVE-8#.A-)uUH-*uUH-*uUH-*uUH-*uUH-xDiP-2NC@-3$Y?-3$Y?-3$Y?-3$Y?-%JSZ$@jdv.vW]v7=?/s7HB1s7Y(d;-%JSZ$1nm?g1nm?g1nm?g1nm?gthLUDPeX88RL/j-xf-+%%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88%5N88&>jS8A;nS8A;nS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8&>jS8'G/p8BD3p8BD3p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p8'G/p80+>69K(:oDfO$k2NEUkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF(XWkF?n7LM+T,k2c#/>BR/'TME*DeM'4pjM'4pjM'4pjM'4pjM%x83MkkZL2=+B?.<<eh2fgh*%Vi-+%Wl-+%Xo-+%Yr-+%Zu-+%[x-+%Ic4U2PW1s7Iv(_]s*gS8pt+p8Ud/g2aha/1Hu>LF;JM*Hu%vLF>A2=-foTW0jc(_Im800F16wnMqOau.TX_^HE*RX(qIGXCx5en*GWNI3Ws[6D'%=GH%&DEHlMcdG>i2mE=jNSM2>5/GCg*^G7-RnM***hFI-w9)Cj2=BogeqCJ$8kE1J@fG%?+vBCr;2Fsl.gD?o6XC3m/+4t*tC5pZ3nDi5'oD%a>LF9iHpD(3]6Dn>n<U8,^F4`YBe6ECmHG*dYLF=4BF%61M*HEmcs-:w:qLw4:SMvW#%.?FnhMedd5.Eb*MMq_D:8h[oS8qFe201^I@HsN76DDX1@'@Q0NM;u`:8b%Z<-qw.>-#NZh-OeFU2C`KN24?;U8VWg@Jop7UCq;fuB8$<:)Z[?k2HLRLM4AxR9/o2a4/'<O+DcTj2fRS883=qo-$-E_ADS^b4xQuP9kRj3=Q+j*.SgA,3fD^G3X##d3m97mAxHAmrA@v<-Ss,;?:fTJD8q7G-`O^66HJ8DN:^v1BBDo+D(N(GVcMi+MYdD]O%e3PSR=]%XEVDcVJ-m%O,/r1K/TbuGq.JcM?*[uP:#HfUce&DWMhPrZ&<r:Z,T7VZ^j)AO5Jg1^4;0P]<x(J_<lGi^wk2MTGb[(aFR%G`Kh@c`Yp%>PTEX%bTQ9]b1X/JU/hg7eaD2Vdg]Mrd+M#;QpR'MgoCFlfw*?fhwt^.hK8@]X,krCj+[;ci0qV(jV5t7R9No@k9ZOxkS2d(W?ukxOA-IYPEE*;QI^arQMvASRQ8#5SUPYlSYi:MT^+r.UbCRfUf[3GVjtj(Wn6K`WrN,AXvgcxX$*DYY(B%;Z,Z[rZ0s<S[45t4]8MTl]<f5M^@(m._D@Mf_HX.G`t7Hc`N'+DaR?b%bVWB]bZp#>c_2ZuccJ;Vdgcr7eBHWrQk%Soeo=4PfsUk1gwnKig%1-Jh)Id+i-bDci8fBYP?P#Dj5<]%k9T=]k=mt=lA/UulEG6VmwM>`a?Dm7nMxMonQ:/PoURf1pYkFip^-(JqbE_+rf^?crjvvCsn8W%trP8]t=r7Ycxu4Yu&2>##%6g:m*DlY#8i4JC0ihV$4+I8%8C*p%<[aP&@tA2'D6#j'HNYJ(Lg:,)P)rc)TARD*XY3&+]rj]+a4K>,eL,v,iecV-m'D8.q?%p.uW[P/#q<20'3ti0+KTJ1/d5,23&mc27>MD3;V.&4?oe]4C1F>5GI'v5*oF`N'ANfL/x+DN)`f(NKb^V6O$?87S<vo7WTVP8[m729`/oi9dGOJ:h`0,;lxgc;p:HD<tR)&=xk`]=&.A>>*Fxu>._XV?2w98@69qo@:QQPA>j22BB,jiBFDJJCJ]+,DNubcDR7CDEVO$&FZhZ]F_*<>GcBsuGgZSVHks48Io5loIsMLPJwf-2K%)eiK)AEJL-Y&,M1r]cM54>DN9Lu%O=eU]OA'7>PE?nuPIWNVQMp/8RQ2goRUJGPSYc(2T^%`iTb=@JUfUw+VjnWcVn09DWrHp%XvaP]X$$2>Y(<iuY,TIVZ0m*8[4/bo[8GBP]<`#2^@xYi^D:;J_HRr+`LkRc`P-4DaTEk%bX^K]b]v,>ca8ducePDVdii%8em+]oeqC=Pfu[t1g#uTig'76Jh+Om+i/hMci3*/Dj7Bf%k;ZF]k?s'>lC5_ulGM?VmKfv7nO(WonS@8PoWXo1p[qOip`31JqdKh+rhdHcrl&*Dsp>a%ttVA]txox=u&2Yuu*>Y>#.V:v#2oqV$61R8%:I3p%>bjP&B$K2'F<,j'JTcJ(NmC,)R/%d)VG[D*Z`<&+_xs]+c:T>,gR5v,kklV-o-M8.sE.p.w^eP/%wE20)9'j0-Q^J11j>,25,vc29DVD3=]7&4Aun]4E7O>5IO0v5MhgV6Q*H87UB)p7YZ`P8^s@29b5xi9fMXJ:jf9,;n(qc;r@QD<vX2&=$ri]=(4J>>,L+v>0ebV?4'C8@8?$p@<WZPA@p;2BD2siBHJSJCLc4,DP%lcDT=LDEXU-&F]nd]Fa0E>GeH&vGia]VHm#>8Iq;uoIuSUPJ#m62K'/niK+GNJL/`/,M3xfcM7:GDN;R(&O?k_]OC-@>PGEwuPK^WVQOv88RS8poRWPPPS[i12T`+iiTdCIJUh[*,VltacVp6BDWtN#&XxgY]X#jF]FXntxXm/TS%W:PcDga]rHZt)>GgsXoIJI9>Y*BruY>H3DE@CPVZ8[YiB4)OS[8A05]tRm1T>f,2^B(di^F@DJ_JX%,`Nq[c`67w(aT?X`aXW9Ab]ppxba2QYceJ2;dicirdm%JSeq=+5fuUblf#oBMg'1$/h+IZfh/b;Gi3$s(j7<S`j;T4Ak?mkxkC/LYlGG-;mhB7##GKb&#Fhc+#O_hR#EN,j#9P&a#U+um#3$=x#:cJ&$a>[qL3w:QnLXjfUNcpJ:`n)Q/bl^p.w0t;?8ti;QFY*-).uD9%`/bj9b?fvGbUJdVjr3TemS0Zum-[T.pL@B=:ur;mMpH-)D4K?5T1hdD;L_aN=OSaapuGw#5jcK1>PPEE$hCBXROBNpD8rZ>9eM?P`#)$ccZ%*s2sqH23Y%wl^]&F*a>#L:-/<nJkL3kTL/dq%7R^3KkvK*a#I8I;a?[[,BtD_Os/htH#su$G.07CXDE7x5xI,+NW^f$u4>aRJrilwu40'V.aa1rI:D87o>nqkp0PX1L&l1of*B_l0.&j7Jh'JcEHx-S]=x2&#tlcl9_;(>QAHBfi00>8/#H2;I/UNihrUC)+SYTPBcu^ofvV[SJ[e(5pZ*5#HVi[]l>'XMhCV/K2a#,aOAtePgQ8S8o%pYp8loQvQoB;po#8[j:9Q&EXN6-t%vI6HNG6OmgYCpg2T8^sedd/-N2;=Eb`Kl?$0)6t7f,PEOshX^lL1lTJJ']TfFZ>[-nB[EXUZ;b=SP,bXbKu$$oIQqA.snHa?wab+FC2OL*B)O_WX/bt5,6=78Zb'YWD`X.gDAC>tNBU]ea$]$TK2+=>[PUSjYZkhCq3f*r(l[??$,4hQ8.Y.GMS@H<f,(c4KBrA)+1(ljCk70`9sOLKkP]$bwxbtd#j+=hI7`Yk<,ctOCfr8F8RS9`Bql:CAB]mXk;Dc=4%Q(&3B5L)>NPhnu.^-dRu]H)cOJjC-_DPF+HW&o&*N;Jhc>R%dqVfErpv%f*>W8>>)NM3e^a,LZia#(@BQCaQt>enTUT9(C0BZ02>w%q$`^H.5*9gjJ2e+Ug(qB_9=Bd_3Q6:cQ'$eijrN;Q>jW]HOw6(Ua(UB:bF*Y?lLX&R2a0Eb-ZEuPv2ODViV6qP#GO2+CMbGj*Eha86XO2d5MUBg$YhN]Ae$[cd.LjkZ4r'l7rh3cd^[@Z%37LSp6CZRe>Rhi$e@%XgN:00x91E2,#xRvt17_gj%1jsX>:^9.uC-Yp+rTPa)G,<Z.Y8`4W7LNxa%7o'3l`QM=+u1qc%774]1WGwKM*GuUi<*?EcPP@KufgGpr0rAmx@A4<SU?WKia[4TSC9x`oUg2Kfk2gxo:*?acP;X5j*AFSPVP8'jE&a@>f'*Yv&BNM&7d.W;Ku1.&nG(Tj**luMEEr$ZS2k'E?1/h>Sgd3mi<)>T::,>aQ/<J,uUAd#JNI/w&9gdsK,+`v]n_H-#X`,<^V>4Ns3:'k3Jaw&[OLuK+N2M?J-8)-l(cW33WvUt'tT^Kb$XK$JW+p*6TeZ9haDXqC/3Nwf).PL4m4$@]-k2(7vxd*mSS%]&WmKIG(8^eYCG&V(ZIe_RH@]el=.xU1rR4xJJ?rtp8x:rCX;)o`@dh%&@f0]AAX@%]=#NY'f;_.G]5?r_-1*itu?Xo;%ga1XCS=8)F])DRs%c7r9v%,?QQBY^^49v'<m2/>K-O]]9hJfu%(jY9e$^]SjsQ`nGLtV1C<eVLA,:;h;Y.^/5+^DI00f]f_5=g5#aJ2XeUGW(^bqAA82=pVmp?)nNbBW11]a,H`dkA].A>vp]a`m3F'`#KmSQv^6lCsqkl^d6=W=^fYEvp2,j&6WP6M63Ln<E[L*V63Yv:<_g`,e6qF93bw_._8':;-d2ng9;#/sW_jxw*%^=(I?'rpNbkMt05Rh[-Z=MIF.3Zw<Ui]%i#D0Y[9D>FXU4/^'o.+JC8Www-Z%C%Y(J-e_J*sO_of6S@BO]VXh5_Bx9uF^RaqrGi5@Q)cR7j<.m,&Po3x@)VMn[W=hh3L`/t,:fZp`.iuDUs+7pS'AKCL1V`O8a4kYu=ilee6cnqW/]p%?c:r12[4t=%T.vZP:8*Fulo30I)2>wJScIn-w7W):t=h36coNx*BYhlgMJHa(N]g#7K/-h@82Pr_<m+?Q%dRn]l25R?C5t/'cDfc7jm+Oi[vCPv'w(8NPaAD4e#L_Tn8aOw0H[q?D9<N[LZ_8lk/vTE%6ka%LBTD0$$h@r+3u?anE/;FZ9<U;xdR7f#OGYF0e[`7H0m8QNb/p0UtDhpa9a;/Y[1OU=tsahIc`WDmw`HQNbsc.L/u^<P6u:XLC*DxwC*MrvwbF9GdLs-7QIoQ3h0'`uA)THVGsV/Bnf2J$u2:ch<d`swh$&u'k)A9_8&l)Xps]mKJ#e(*skSO*u>[(lDs92a8&&5nGVbp77h&FFZs9LrCs+:ik8@7>I:w]=_t661:8/%T772OjJsxRkkiQHdk81bD<%q<^std7.jM-<#`689HT8o#&#uUAs9)s_T77tMF5tik`[%Y.B7dYX'8$Z9aqHV7V;>>*`oO.DY)JVsEU<=K3rO^fHjcb>B.d'h1b%M(3jBe>>g?a3YU$mxm8%9:FqBGASx0W?GsFf<.fK1_V.?#$IfOE]PxR;HUvGOx^0IYXqXNWjRJhZ(q`j(J9qOdL9EsMoidBPVmAgOEjq?QfLs(fW@@4ZK7I$$*sw5O`:vsh6j8&kETqtdD9v);Ss9)qii<tw@&9&:v]=GKc*ohc/Dx74D-R]j<nI8Abj_hUNjI1VI/9&[mtSLu4&2tZqT3pBYM[sjIv<ZO+)Ca,BbBd8:3_%Z*-/Fw7qkt.lbwm3lu]Or5K:`hT9h%_^j(2[/2`*J#DC*J>Fiad,4L#PU7IsG?eD_#wSFnm%bfa#HkZ6de*Gsg5]4=K<nME^78-c&>,^bN-,>anD,d,k$YFM,&T_OGU^5chIIR7$32mA(aM,5Th2v8&KlP'k6kMiG)f3%q^R^tn6gCIRbc7$SOm0TMdQU68*[Qgxme,;f3[ctOG)`3.+ZeOAQhstKioC*ZFoj$a[s)<%gWRs+%-.6T(DmLcgJSs(a#Z%JMbJsOT-+)9Tjb$qjt;d(&pktj.7i0,,cd3k8;sd]arZsA=9:6Q(n[%JiTI:s&'@OsZ^0gw07=QdY(dO)AFatilf6;t?Fdt+(k>;50#@NUGDtOl`%Hs;fgid`$hm$i<OaCN:t)sNH$U#eA[6$vrd-qd-[ktq@)@Ov(IZsWm5=h(cf$OUeOReaR+CNTVQI(.YGFskL89&JU.3M?HLXsB&KXsoXiJsWd)C/O&XQsE<#Ys6l21'd<XjL;r3^G52'K#BH57$Ot6+;d3*LuQp^Rsu`;d$``3'fsG;T#-xMne%)Xg1?0wl)='^ctTC#ft1]^:6.Arw4$5:Js_0;;94r<u5=sWu,OCLKC`$.10xcA#MQ:uDsSk?o.*`Bp/<VEj08W3'O'PS7%<?s<Y$`D5Uw]=_t<75o=)+WqO,jF(<'EsgsOM9(fr^2lO#_b?Kss6(fi);T#1m[7$u@ae)3N;2^WpD%h6c(icv4abOcCNbtRA0f%ufCte.=UDsT37=`O=JvO3#Z-j7`q@0u2Ur:*71kbDDl0TM-L)f(7fCkZi+UnS*Pq),V>:$qvmx,ScAa<g+Qe%<v97YcB[Llf'rMiVSoC8r^j-6OJSg16vkrOoUqdA+#TG=.M>T:A2$UnegX4KAYLq8sG;2:[_8CB:Vfh=j';6`;iCuLqm/lUN=bveB]'K#[?Z7$LkObMh]QU?2]^]t$-YhO:RZuO#90HkwW+19?%uxt,t*Fs?uR_ORCF<q;9_Ys`Zfn@n^KW-$BHVm0Qs0h3VUe[QmIc%ZM#g4an_R1n]rI?1<bf%$]<kF<:IkFYAk&4n3dJrZS%M'k?;igEU2.vm)$,nr`4:$m7vLg,dV:v^fQW%^ct,ivka4od5-L^Y'wrtL+d0G.DHe_+KY@fFRgHk3'>usqiP:vg(PnLT5w:tWdL+rVwX:vHrCh>rAH>+wqZS%LY:>#xI>2v>cX(p3LY&8[&4GM>6XId'(d5Wn1d4cIVbBB;WEc%Wj9cti02gtj[Y77d7xw+S<C=,KR4Gk^(Lt:t&0t'gGGiT7)[wuIo0cNC_lnAOUii0bb7>#$9tvu_NKV2aNUR%i;xat`@7H54MoYQ2RhHQ_=ahfnSg%OFYS:vOfb+v&qNOPd/ZUVhx,peud69*fj^F)pv%V?&<WKs+rSCN3tI3kU.`$kT:&Vkm:AOJQ&gC)/H0)3g+RY#bXdtL7;8ZVad98.amP:vi::pLnP[l1AORV6(VD)j$(4%`gr30MEPEJi9NR:v<bh8vCk:)sWBI#MARrIhS<4vu=TY7k<c6>4(6%2.Z3=lLi^*d(]-I],r'058b)3X:l1PqehsXS/Sg=N1PS'-M:`D^qP1[W%&@'$vL-Sw0U>uIsn=0`j'Nw,)B9r:QYlS:v7H>'vJ9KuXX]sr3hbmE2;`dV%qCtK99-,+)Dc6.(jUas-`O`]Zv5#I8*kIJ1ReP:v/>_%v:ZV;&_L^%O;^T:vg)$+M2,2m;=A;igjq8>#8wK&MOHm&:+3wm^Ibav5I^_;8>#EDMpa4/*t^;>#OSguu&Zlb/Y?csgBoY]4R#FN'J@hYslVd*`>8DUk(7cuYSqQY#+pmj)?luYWT:%Vm`;*O=>SE$v@Wd=/J'^M[S/n/:ZwOI(vY%Tlx[,AOI@pgu[i_V$*+,7_N',##P^<$g^#>%MOm^.C,[2]b6^Nt:=Jub>s2bv0/i)M-09qj%/kOL7H?#:VmcRfO#G4dY@hc_$6O0LI3`]DsqFTU6_9pt5epvctv55^ti>U.(_aSO&JbEnEExu(5)82/3*Z:>#:;p9vhPc<sCBk]#;qP^t.@71'=;9Wo]6]O&ghH#umu@9&GQlusbQN49pn;Gsc.(V%hApwF?m]$uOl=hO;gdct9&Ktt5skIsJkO^$@UeqH/ct0hG]s$O2$w'Ef6C(Eba+(&gN.P`>x8<$%G^3oEd,4ot+].6ZR&4AIZ*N'3rl#t_.fEsXQH'lc`YC)vaq3tQC4cOb^*+Gp/i^$%9G`T=p>tOpSV(8lHhHHaW6EI=JdLFOZ)BJFZ8uBu_Ju:H+(^OLtrc]KvnjZq:%'UC=loO2F:7%#U+S%amZ1BTKvS-t`RR7INGZsTWJ7%2+OPsYE>h_X&-Ym-r3[s8s6_k9XKUs%_Au,3Sww+Pl2r`*O0wVl3YibIx[C]>w'/eSF3uOZZVRsQ^<LseUvmOJ7qktTb+dt9PJ<9@=h73@4XTsC>eKsAQ<rOEbcAV#DXm$;:kVKX,u]tOmPFsbG]Psg4fHs7i.T%uq'%+Eq6%Fw5N6KEeF9L#j8CJ5Y&;KY@0Gs5GR,MLn7kpea>`B*$b-6E(pH3IU.f1'iTs)g/vtjp.qoO%q'`KA#NL%1lj?J8>DT.p.-:-<Ge-IH^cvstT7`sI_J9&fF]*r$ZQN'3.IZsG78CEu&`XkdFgqG[PR$tk_qs)`SkHroSS#*HxwKs5D-bs>O4U%AgQN'5odvs52(Ab4Gp<l#*,:&$?4`O'1.Bh2smwss92Ds#x=.2l%hj)xXG3BL6Ok+C;r@*t+kT@w]`Mh>tA8Mv;_<.dl;+3tkVN(@j%4Jjwt<M`>>7.L0L2hEmUF3X'6s..t;&lq'0KIUqXcsTvY1181Lk)luP^tbH(2t%YiX-EsCX(bn=X(5$A9iFe$K#PaCtL_rw9)?,RN'M%AjL3Z'5Wm?N_/vUTHkE5cs4YIe:5Gu#lL,WU%OAuQlL,P;XMbYob-pHr-?jB:U)jTqU)VhTU)C;RN'8&:W-V%L*R[?#u>'[e>u0O_;&#NaE[/JJZsIp6M^CmLqkS9RosO4i;&^KpF)FL.U;[i&M5`tmU$U^[_ONTIIFD?;iiB'Hr5QQkb?(GFc%.%eIsV^OIsA83+)&mu$4bh(_tP1l_N)(D_t-gG<-rG&W60Z(_trQh)-Z?<WX:i6pnVwUC1;PbjdicXImvme'/8ne'/dU80UAC6&l7aE$M8Q06*-CN>h<MRN'E*D]02WA_aPFs<Y)5NmLOta-IG1'U#-e_7$f0Lk)t5=Hr'+P4&PW=<kq5]'/tSRq)*C`ZYUr=,MOX,CN=H2wO9%UI:7QM4Al8mOAvB+N'?J0f-NYRN'7'Z<-x(m@.SM&nJ$#<GsH.;x.boe<&6x2?7-mx#M^8L2:p3dXPRv(<t=%lEj[WfRICb][sa5Kn)8]Anf?0HUZ@duH2:oiRIu..N'+P5+;)f[SsL6ji-9KS3O+X(uOlp87In<B?.k-[/5?Ae`O]EUDtm=lA8[*GGseZE[9dG=o.UE-e2[Tx3JM'I4t*W0l8/u1IA0h++)7EL(*_R)N'[&#U#$%C780dnN%kxHgsuuUG#Ak4'$I9[[FDfRN']++^D#;5%fu`X&)rH-:Ht2kWs@RXj)]lSnJu8YU$9e64?_&xH`Sm-tHbK.E3#1+ZsHesNg&oiNl.c)+2+t(fS*:F=&K7U=&8Ic:=JiW=&]U0'fHr3T#d;2Ds]Rhb<vHM/`&SmQks;S5T8:,oLb;u=&;46>#PgR*Mb>(>&$X1'fc0vKP9q(qko,@b7t'Mn[tw&*3WfD@>b`;.LkS'x4ScBweW@Tk+cq[I1o+S'AZ:Cde/RxusEsKEI:)S^.;R:bjY.Y^%'i0-)0Ob7e7s8>#qhK(v$>-AZIT8'FQonFi'2Ic%0*1etg6*#-YCfstg-w],:16>#[kco)KccNB$S,bnPM=Wk1mEqD9[cX?9^Ufrl?axH+oI=#HIH=#p3GI22Mv<cZq0-)L)8j)Fh9s.*bZ&gMcXe-YFH=#%SLe-C*je-J7gFMWISN'Bus#.TK5sL#qWigGlsq@.CcJiA.+l/.Y&HsoK<7AqHr6R%iVQK_&5WkblM[ssx(*1%s]f)]YwH`V(`KC8AE2M<:/wsn9A#*Z5`0_&WqHiw.ugLtRfR%7jcTkv.qT`DUYq)pe@osFuv?&rTfRI1&6L,Hcd&M<%*l%0S.D)C2TlS`CXY#qRAg)>b;no?E5>#@lqwulQr)8JxRN'CB-u7B]Y#>i:SZL#jNS7nD1.v$w>hmxF`NT$<ml/2Q=>#&jqc%tPIAEY1c[F%?P:v1BQ(v>XcWC(EN8v8E1q,A3FA#Q1f:d_%9>#;9x-vZ=+<,-wT4/GU,A'Nu-T.5vP^t7jv&3QMo<d++/%4iE1-)RJ1-)U9h--S^-HFFS<UkNr]7$`vIFEJ^v,Eh8l?tfi(*Mj[.EF0Ja@&7ZeZgm7/7IUE8Vk;DhC)FTiGsJOj@&'+w@&iG,A&9ve<C:.RDIwmGjsq=+cOC0'M'Hxu3X>kWL'w%CI:^/iuO7s?OA-AtrRYD/&G+seA#xcQfrM>=BGe;lat$K_[F%_^A,QVk^GLXIbOTX<3fwH+@'fst<1bc@ftQ[fR%l>;2g'w&SgMgO.sKd*^O?%3n6<`vJUtFWkUoH]RseHMO%Q.O4a9M%nYH.0uh9v;gLiCZ;[f0Ne%BU+T.R0ZcO_Zo/1K5N0<Ri@b%gs9`LjDNx9Vc=r-;p?Gs[/C-1:kPo)46HXtmlP^tkIT8/g>8+F5Rl_f`[a.SP7@a<T1uqOiYG)McarS&PGEpSD_#_$=tZDB`pmS%3n7c7Xi5tEJ[tF?@]$<6ObKd;u_$n22j)_96w7Zh8hRL'*4+Ls==B]hkC>wdb9$_shE@uOsUcmkhdOg$*if6<D9ieO:YacO;j-Q3T'W8eM@5;`j2*pOT`GO-jqB']pWs#u0>tLq,-7xRblrBQUvV*ihtIf$SBw/u@MOf$9mQl)v(ZA&jt?:$usGLIuvpZst_#/hVa[_ODSG<4X5#b%N2qXs/j1mP_#u`TkJ@l$XG4oM'1r9MNlg+.h$irO.-3l%lD6ldUoE1Y=5Db[eJ#kc82T?C[@Yc%xmTetGUS.(C.baOW;?N':Y_YschatP@QJX>Ps+0fK1akJDk)Wsl2U)f,r+M%se,]TAO:V`pU*VWZ>l`TGG+oO*Wd=MMX*O=<2^vCM&rkt7wgI<oU+IHQ]h@BEvuO:H47H%DJQX>o?8vfntZmgH;E6$7ZhwXKJ:lFH]ja%+U;1<gKfPJh76iOr9f_RRCf`%YK7><1Sr`Wu,tKY7ZK1YV`0e%vG/Pd1U'jT1g?xLFr%HYq-VmW2R?@<gfq]$0eA(R]In>PLh:__75a:B42juAmnib^xSlP'M6GPsZw&Td47-K#JW27$+i`3o3dX`Oo'P'slE(]4^VL(3>mXbOk'u'sLC1lOe?4`OW&9+Mi9op%8G3X$PuAEs*@Dr-/dPv$_4O=t;OxCj0%f<tWPe4&a3<9%/iDx)XFfwsdYhWHHA[wkl]A8mdwY8$Ir%c))*x_]8-)b%Cp];?X@=A9mMm@9+GRBIel^hOtBb<TrgOMF^cghOkETpUg?#a%'E6*K(tPtMiggWMh4mHIQE`4=W,VbOT+2#S=Nq;HX:-1Ioa/sO+Tq*Ts73;W(0'ic*R@NX.1&oXTuw_]-I[B[9Dl2Bk7wEAsF7aA>.1pOqb8-eq(lF)VSX_O2Rr#Ut+9@T)kqb%(<#sdEkRiOj:cSMncovK5&',I+&PdI/v80H[s_mO7qP^tskfXs3nAXsH*I=#%(jss',^A&L^^XHBTAe_*;0TdUnZ+pIY:1fOc2vsHkh%tcwq%*J;tO/B7'iBIpwR.F%+lAFann.A`[kAF#OO/>o<LBHgF_t_AG^t4k8g1]s/EsPpkIsWa&Es4YclLw?CV&[#Z=5eBb0Njq=D:orToORQ4DTkG7l$o:L5NjQ*?5NuG_i#TT6-'^2:NGw;gUCr+=TgY/rL#4?$&#97f()Sk_N'pD6lq)TR#RMXO&hK%+2_ag'bUP,)-GQ2L5T%a0buUK1Yc7he%oe#qOKPU_$KwQK7A[1`AF%Kb%%6(sZ:kiuU8>7kt1mD]Jt#*g[9M/8]lpgcHTRItC&IsGs_MOj)re,i9rnL5/VJ.]+1ek*Md*V]t_4gA&((6O]W>f*`gJ,Yspb.gsB)e2h90tA=65[p.i`-TaGuNMmfmoR#km`U$7/8M^'IL`sbZhs)ZE)2q#EgF2H2Ue$j[%Hsow.hrX5T_,D@5f(Ga)[Kp]Dii2Ujh'bKRe$L3A*j2)1[,6EUe`UN%d,j(e_WCu`1%L?EqO$T-W$Xm#qWsxPmAG%ahF/Q9;@(5w]X%Xo+-l34jg^^:T#?Qk2$V`dd)YvP^t[B%Mb?5rR#:)]R%>J$4A,tIFE/^04EA?CMZq*YlYmb.f,jhVI;wXTld5AXld,Juk;?^`b,XG5Hf4=BT#c5I6$I4=%+8*)gtp]ER@GB5ZsM&N>f%U'4Aq(d3u$0fgsq;<N'l6HwtSE:hd&ct(f(,$f1'e)3Yb$Q:`UqwiOvZZ4DbB9_%x%g=#KvQkSY'wrt6PMDalXZrOtFYq>K1rI?P,cZBZpP^tD*Dtc0'9XsQKeEs;ofDd0h*F`&MFa<DhDd8H?*YC0dMa%wTF;ZL#_PXe=3WW%eN3E2ZgiL,nd,)j?@wMn$PXKB-jiOq3xvSUjV`$6J&CLto>tOOAn[g4+uVU*u1^X9`SnOhvuq:4eoHs.i4'$xp`[FtHTN'18X#Et)-T%m.6FM?%cjdPOv?uVc)7IJV8`[Gb9x^j;/<`bB<UIx<2rOYEN,6QO7]+L$`N?:%A3FYI]7EeK=,J5>+oO%#0LT_x%ws1wZ3gIBlFkm+dC)g77<tI,Y7.nE^et',1U[Oc,qnD4mENB_HYkRBSO&-t,=t[mP^t'_)WsWF4]sBDkn.?H$u?&JK19sY6R#qov3$7;xbDE;@X(T+4+)BLH7t>T81?s+tkt0Q7hP:?:`=igP^tJA3i_9e4R#,LWX53*n$=2jUtmwjDPnQgJI3,E]L24@A8-N8:s)=8/K=AMm,>gh;6caLA9bpHsGs2KOj)F0`[+9':+MrXouOjL^h9+kdh9BdWRsUhYhL]Gm%N%@;Es^]eikk't/If4c8f9Nd5$np(h):`j&VU71Lfp=aA,dow20GCUk)$lR'jN=*(=sLuXe=DV)::e^>%Wu<_t436N'qK:(f(8`Ysvfi$92lD&Mq0eg)<W_$9=:d$9*Wf$9RuT$96BLJsE-t(TFU:pO11NIIG-%P=V';9Ce1Q98*aM]-3u;XaH?XImA3Xr^voefO?:=?JHGq?b/NIJsm/QI(U<o>cx^bEs<ofDdmGkA)SvAb`C,XkguU.?@9/.>8c0xlBF&Zm/vAV%`mU?2EG`D^%sm``$NuBI81mnGVfbkBBl)lXVQx8x^(8rnnlMmHLSpRI:4`mF;g-?Ds*FGg)NV`f4fb_.f+Dph5eD=i)$x*<%D`L:H@]O]q+L4Fq6LwC)OxYntm9.uOA?@VXuF0n$(e#xJf-,dO4R/uh7TX8WBE4<VfR]4YSBA?U]B2c].>vbeH)x]OV)NtBW'RmD2cEZJ``ThO<g$S%S#XR%HuSLB[tVTHC)p$&&/nt>^+[Ks3bp0KhOQL:G._JuQ/i[I7=pWV8MgGMr;e9MBu]+MGm#B&oIj(*[`kk:GQ=Is/YX'a8ELRJMQ9Buj`HE4$#ejcWvdxcAW-5$:&MILb;oDsXWYERX9)^sG().18ud8.qGFOS:+w8.lDkOSEb5Vf:#$S#rv-Omt<[3o7S34KaRY,*e.1(*bJLu1YV#F`;6/(*)hJZsho:`s=Li%t:1Lk)jFU(*ML01LOjcqtw&FOA9RNs-RiK$McHnctUEfjOr$fvSbsU]KTQue$t&Z9Nd,dpNj;MmO40FE^lV'ic'hXsT:ZX.vY4S<t(Vix-V65>#e/-%vlMk2&2(fPB0cPW-m8g'&=?B*d2O4xg9$xf%q$R2BSG2T;<SB%4OsAEso+cXnYZt$4fWvbeq0g`%YiqPA>mCO5=08gOl;C%4:ik,2abgXS8(:GD-qP:v)Q:,v>aY(00YJCi&BP:v3@x3vumU)4JBq]O1w0kEMHS+-GU:B44vUG#l96Ss+o@UHhOQL:n]>NubrCF=39ae-^rTe-4IMe-rS0^tFSX[P+%[n(U`nPs@<qEssf@i)O=$Un^7=uY%`kfim&Ab.bNE=#[g0,)/oYq7?4q<13tjOSJ<Sx.xeNZspHfSs))eC)5''FRJlJJ/C3iF=ikm--Sthk8JG+I-jQXoLCs#B&.8.`30*/G.&Ke0L^BiI:RPL/))tS>dq,FEO+^d)MJ#UPshp,xN8):d3Q+$fQ_r_k6HbKHs*-IZsGY5FMoe,10'CtM0`^JLLfq9^s=Z%O=S3d1iMXNS#agm2dF1sI]?S348/4knJjCdv=@j]=JYNoVsr<MUkj:bk8Ic]7$F>+Xh#fTG=WOwML?m^Dh;awf;QJ1j(_Oq`=hX6WI./,^tL0>?-e9.:0XPkXr5O(%,83sQjAlk`4Vf/5^u3RDbNftERG6Oq;SZxER-W@HP.dHYsms1=/5T[+i5NY)MmbB%88/3;nT4hH3[`^qsGneLaDaL(*AEcb)'Keb)Hf;L)KBMR>@a__*D#.`*Jlr3+pZ#N'Hi3T%SdLs(8BJOJ9#KHs=i3'*$lBOJ^S&VMROleMa*CY?B8%a$3BPC&WeWO=,QwMhIkCfhN4>0u:XZ7$Aj<0uCor&=*sxn8BoWGs=?t;fCWR50dL6WI0DuYueZf>-Ux8?.5:%]_D),;nMfCs-'6#9O)^d)M>h><kgrZT-gjNB-V<<6..4u<M7xUp$ooCk($mek8IbeC)p#7bMn1w@)::j(*B`RN'B5GPsiiu3S#JZ9I]?P[sdGM`si+qc)?(+cknV9`t'dR$5@KL[ss6gu$&oiXs(DH`tRRse)tS%gmb.2Bk@[A]t1K&ktp1mZGQ/i'IgA9')IqcYkhJ&Pk%0EXPSW[_O9Z0=>[<?aOE7+N=IvO(A5_Dd%6:6)WQva`e6gl]O#P4xg,(_bt[0qemeY4_W[dmS%O/;j.Ql'd4_[9/)[+FOk.5^Gi-/<?aZW&c,5W6)O:4?N'kD0979e$p(7$$Ssf1aC)?^?,tOww<&Noug)3vsEaI2PkK[cUW-hbCc5lwor/PnGTKJ:DJs$?151^r4f(4oA.)HB0-).97A-tH7A->nko2PfNuDFxuIslx8n)v/qO/$lt35arX(U2M]c4M;fn@.W]C)A'^'ak=>COsKIu#Jp^h7flcPK0c1d-'o$GIabH=#$cg&G@G`Zs,SiBJwD04/,4Z_O2J61*:G?VHi]I%+3QoBL4w*pJ@A'_-4uF]9JCQhnbM2[%6D0Omhk_C);]YU-t`o$P]FY,*S.?ft)H`C&@n8:O+$gma($JGawsj^-12p[nkm,g`H@l1k:6`7$/)sn7sooDs^]Yg)c;MUm[tQ[PiS:btw&FOAH3Kp.;$u3$$/D3D6ELZ's89>#cRZo$kBLv%3S_V$Mq8>#t;i%vD?Q12raK9nr4WP&gDTvGHs,9Mo-LeOpOZ(d1F31'Xv)u#3n%c[(bua%G8uS@dJ:d@ep?bO_gokt/#U:vb^H#vRol`Ye>+XrCOViKwqS:vV$0W%<PuD2c$5YY1&+tAg7lk%P#mt>V<`LSY^A&M;vU.tOww<&un1._Kl?ZP8/wYsPd#@0t6&@0rS0^tcDJWR*`Zn(71OQs<4hC)?J9E8=*[nT+@rwPo'dTQ)8)oIFBgX>@^&$&abH=#u-@WI@G`ZsPl;R3ld(*#em/qH=5fhtT0IA-K:IA-O.IA-xMbr$s.nt>MAfk8k3GI2Clh-/Ug$k1]F]c,GZkV.r-<dtnBxY-Z4Ge-5w1-)kxBbtZKq8/>jjOs<d@3MDFPGMAV=Z-?jT+.SI]9VZ3E=#`ZKRscP>IsYV7'&7)9Yaj>nW%N%;'f4J1md00;EIbNP[sB;2DsK<(FsQ>W]s;v0.vjc.3pf0b.Bo)?PJEpQ:vI<Y9vt&4cH2gHS@X2=>##/YOEs4g1Tq'R:v>-B^$KV`$sWhDA+I^T:v9$P'vM#BL=L+96$HTd`*N@4NBq55>#9i45vX;nEbP^[PB=-T1p93iu60OF1v:@A[4#8wCW^HV:v.bF:ZB2UcD5-:>#[O9rL9#%Ph)s#PfGo#F7rHr7vs['[?G><e)a-ST%pI,5H%AIEA%.&Y,R5Fx+k.We/jGFcsO9?@+],)D5jI4]-+Xjwjc$x7-'&NT%,(Z(UX'5WkG;fn@EJgC)h^3_j]jlnJ0,cCL%YVp)F+?bWA.1@'iHd&4(vUG#i[lVs/2c7$J=_[F-A?H;gr>5)`dG[$3j#po8AkxL52N*MEm#B&wH7c;EK%j:]aN2U3IYvLuHF8tvN>B&vqZXl[%gl^*+?/`^SZ3Xg;hC)q^q&NUGCA;=3'#1abH=#bT`WR@G`Zs?*`7$W&oVo/wU:uZqEX%min[sh5nvjrSnCs,[qv#Krgb;w%pDs*D`h)4dp=8=SOit2/v<-6+_j%*<als(nTEIsNP[sh)e$PRG^x)TC(11f/=8RI4Ljt#;xD&gjd;^h.Y,)B$3-)xhHD-9LOZs4E8VkaI9Wfw<qEsJkPo)4b7[Y(_d7.nT1-)5Cc$'piZY1CFhk847(@-v4(@-bUX;.(XM7RPa%j:@_hAGsrM9MY5>5tD@q8MSvO1u-#`w-6SRfL2/xNsH*I=#NR.+*g`^g*cPs?Y.2q-MSB<LFmEMxL8Q;*%6TRB#L9dk8kiG]M(5Xotd&r+?g%&?5]X(K#n50FVQ4<[X2OEfO7&8kW=mML%$aldSc_]Ds+TIe32tkbtGieOA[s8[uXgs6[RcaC[_Bo0,GANZs4;pEs:?pk&kfolB(igg>0FGeU.Q'S%$bqA#e^S/.43h=Os,c$Oa/_q;$:n3qoN@F2r[0Ds=Q1%*nmKO/moJ[Ifj^D&Wf_&)s17Ps*8^C)KmP4&EXg`tC#]s9:62(AHDW'A(Xm6[+O]9t?N=E&3%D+`;.9;[G3*ZH^3FqLsDNeL_,#=1VdvU67Kr`tFUKXGkV;T%Q4V*iqCXR.AiT_ODHnqfiZu]t_Yt?.(a?KuRZWCfc3NhTwvvX>ebfk4(4pWKcY5iOh%tdY@i'ic2CcgQMSxMbM.`hGu27iGWJInOC,&)tKaS9&GG:1TvQ(nU%ooT%K:cEheqqDL:kOp)&Y[RsU9/.(Jd7c)ev#P=,mDa%jU2&X1GL6bmOM1Y$Z`4&Sp9bt8^]7.0XMALjSb-Vb(1,)P0P:v.eua$%6I-ESb3hP?cwL>,HtX%Y>(RX8dGF2'-HA5N13-?XLOw9uMKQ2`?+,%vbck8^%wGtP<#B&q'4'*OtnQ%M#mt><Ubeg3`NGs>F<rL2aYAu`s6.O1*7F#L43]stefX#8ELRJ:amFM_r+k:R,6(MTSln/dUQK*oU8stFHq=OHdHYs^es>.ThC=#^N_)t33h>&QeHxF1>ireM@:/`$xOh,%hEpsUA+v-i&f;O/.xVsEq/$0J.enSwJfXuBb<#.OJT-Oj(ZqZRc$0)mfTBu2AMsA'';DbG&t&l7Rx<YU0Z7$_ql$90du_aglOp@q4(<-PTQ]IJb`QlG`rnZ'oues]@;p),G;_X.e*VHQU0-)@CtN&Kl,>&DcR(-o83'f84vq6xblcp8a3H2C?v9Zu?DU[E`[Z^[*((asHViF4`Fc%dfx,llr_:Y+POZ,#Fse)Xx)w$h*j:TKbW^%15Q>opj<#-qd0&UDOw,)v4FecFOg'a6O9(fhxf[pE#Z%0kuGf$k#j#5l=H$lw?Pn[j=hk/0p::I%_hutV`1%*Fl,=&Vf_&)3o*Qs@(hC)]OGQ8;J?/V%J^<J:IC[%+_Ok=d.p6[(_U5^/-KRS'Q:pAg>Ll=u9Ok=k@p6[B.d%.ux=)M#h5f(-iem='1I=#^KKLflG*Ds)^hs)9<E1BVBkJ:e;greX'70`%$I=#%<2DsQRg@Mv$n^tjmpw%>=<1TLPuVB?K,U;a8+7$woAe_;7Eo<)oSWKbS,iO_GLi)n_c;67#;7.GZ'e%o=iZsDQeBh>E7CEpA)9u[NB*<rDmD-`Y(1&:.&epglvD+w`h?Kb[6i95^hYs/>Jh5OOI+%gJ./QhhTvGHm^WLd':eO:S/6AII1Gs(qLDsP?Htt<'s;7?PtR.ee-`2QQbrReoE(Sj*(HHhG8ZKYemZ8:>QqVe]M2i_,LXsg,w*&0&Aq)m=$Un`J^p74#JP^g;Ce=J'ZqZ0l,pSTHa2MWxWhBg2uU])<#Ab;`%=YLDM`srd@i)q?`rt)HcUA.J'Oh3dT-`8Lx<Y_(i6f#+phBI*datH/r%*v&S>&t@aE&I(i&Oq/l+fdLD8oCEr<MZdp*`'8pDs&lH+Q=RK/f^kB#QqVmSM+>JnnhU6sI`/7h??B0T.^tmCs&g`&.W$D5M$QN'Q21)^s<60H5&Xg4f2PmYsLp`x)?Z:/uXmkE&i(&F&o-8Y_--OTse8.R)W@9IC&WZiLM=n29)>pDsQIs$QrJNZs(w7B.&4%Cqw.vcW59A_/DZf@F^P8s.dpl20<->F#L*xXsi[;b@?6b8.SKkb3*IVgLXLWwG^BiI:X<INk/vB7%R>MRJbOZh0Tp_X?U(39.ffPQI;4KT%KK*u)>QU(*+Vg]tm5)7u(,o<ld:6=lak8RbnkD<5c'9u$vG=&>g&Hw$t`lcp-.Qw$F/h'amN;uSU,,qcGI=DEVe67d4wQ_</4knJfESl)/bCX%GF3W@Vb6Rd'='W7m]j--+LSl)'$#H4q`QnJj)+c;m7]qJ0p::IZGDrts;:EO(@f>-Zw^8/74GI2oSKdM10BnL8bYW/Pim3KgpeF;[3cGsU4Zw)N&0$.gucAO*@f>-U@f>-U(B?.V=InnLtxlB9XJ_8kuFgdO'%K#O-EWk:U7i0*WGF2CK[(tPOwI:,Q<c7X(av-P#`*M$ZaU6+oI=#hSlQd$HYHjs>+RE%nckT.5P>uEvkHr9B+%+&*Fd%1``(uBOD&.$HJt9X-IpgW_>+DMoAe?iwH=#1O?5.W$D5MF,PGOYlEig$AVvs[GL<huC<eLu+&2t+8E$l'mA[k#JRbV[gLC4X=>.umVl:&bJ-ctBoVbD7divo>N2^s?4eC)Aw4usFUBs0p8gFM]w0-):(BFM:F=2CI;1gC?^<Nhp,aEs88)otIHTc.kf@i)&4t+.g3mjL^fQ^t5YG,MZkFrL33T3Mfib%tPhXv-gH]vLX9E?YTdkt>c@XO59O'#brOPk],YOE&sAqbVjBw?ueCp,)-[A['A2RN'8W4kL=;%a$qLO4$C5(=1`A]1tHE-?&CTn<Mqo'B#^gZfhOFZ$u=s27IT)25*Oq.rHqK@4SaTR=GeUt*DRIG,D$Y3NhUNV3g9]D%4h1?^>ANPUIjkMd3$#J@5m[_,MYlL%MueH1MXtXHtL<6T/JJk'*#n)b3'wJ^ciJ9SI;nXRZwrF;IfqA2C$_Sb7;-OTsb1^;tRm8kgKeU@)r^Q79l-Q&G<%WJMJ-J=hjUit>W8E$ls'aaaFvDkfv'6I-Zrhb`&iEb.x*jt>@T*B-a>]>-#Y=v-9tM+N`4c$O^A(FVN(kHsG)(v#Bq#LgCN/^t_TBHM+=cVLZ1SvLE$`KI[2w$j4]<GsHS=v-%ak8NYseh%,A==t_<41u2mQEZM-BnOfG*u,aQastSvZRsqmhNr#+tL0cW8_jb7obMW;qj%mxih'@aj0T4Cn.O0<``ODJB:$^8Xl6O0h*VoBskt;-RG;ZYmE_wGdc$^,fPie;vXU69nc%GFD,M<%V=LhK9Esd:e8.HvUG#P?`=.qSEXkb=EHtP<#B&MCbLBx1;E<23&F.j%5Wka4IZRw<qEsEF<rLSGJtd,+3e)Lb7[Yn-Itdcs(R<=0[,M)BEdaFR8qVE/?l)Di%+i*f?R<<%tcs(tKEI:]H^c#[rBk6&3FMViq/)%<[I(qW/v?*>8,EjP5KVSQb?Iia@nLWa?Ysa'@tUv8).L,`1^t%TDfO>i.jLSMtOsnPFtU6O_qZVo$0)*P,3uoR6L-Lwc4%h3JXGs%eUY]TnNk%io<te/a8&kkG:-E+%=1>6L$K`GV$KuvxatH8f_*vNg`jc8E$lMK+Dk-a*+DZFjqIp?#8E7e(n<g0da[:ZIc%M`KKe5#QU?FoMO:aAT_,l8pmB<:u,)@K`S>-^Z+;h)wns@S;no&%/O[1R<rO_^Z%C&,*>CJV7#ul>aEGN(_P'6`e:f2X>&8]kDGsvUa3F5uf6e[roM%J%IO<_x$MG;(w:MUqj=M@YBPP9Rl8b4L)GsP<W<>-6^`=x1x2=]PfrLV<cpo&^PHSFXG)j7.-&-+mdvsdkH/fb$=FqFfKZkNndFs<R1%*naX7.M+JPDr>1h$Fw:T#Nj)TsI8`7$BnI4&iad8/GwN.+rB9C-n]5@.XYO]qVYvP//-KRS?%T;6E-/dMjEJ>Mv8,Ts1+p<:/IOnnqp^GN=/px9aplt>$eP[sF_w/N39pQkfcGb`@KPUIe,>at+K;F%m4Fftpc?L-Zk?x-CwGYM<es2M$3@/tr,7x-Ihg-Okcj9do?@gL=%(SkF>s**AmJe4i<P.<($vft[d'btm1'MsU3SHsGfersApsh^Y@Zi3L-X_3'tp[sAwt(--Y2bLV?]YsBRrn.9NIq$gtT[s4:<@5ddQn[T_0-)0:)oI0CVq'N@Rxu@pDobtmi=cjLR:vh_A(vY?j.[2]w(:=*O(j<A7>#c%g'vv1$&Z5htlT=fSxXT(Gc%PB#V/(hC/)OO_ak4q/_,i?v:TIx9>#_`%1vWqclpb3;-*&SgY%LPt[%G[;>#`[v9vIIs7CE;bg3jW,]k_G8>#/?@sOWnh#W;7X?nueGr-Li<.)tfSN'6[v8@D_Y-jFVrSkwfSAtP<#B&ob&f)OG$HDF-kNhVWrNg?]thJ.[gh(SaUB$`@C]VP*v$/%:b=EvWsDlW'i$Fj@R'lD[@Xs/:2DswR(4TqIU5gQpK<&'/bta3I;&.s-+CM;9s0C5CEOJtH[&>b+;OBVl@=Tt_t_$,2x<Ys@MI)Z*0.LC,3-)/`apu>^C)0MlXn(0:)otiRD&.%32v8x5r%cnf88SroccW9)>DbHx)4jR<oVs'*]VkG*-Hbl1V9oANPUI1J(ZuNK7<&8HvNs+af#M@Y<Uk.`r&H5a&Hs6[1P/CI;4uPp21F(4ST]E[>qe#lw<YUg-F.n.8'Qsn]st+Qu5PESZn(rs4Ns6k2(M+Hov9]5I2hWn/iKj#@at;GR_E?m^DhPcRGs'?Q(MlaLmthkA-1]^q-)_C,29Kgtuu<F6t0U44,MxlXfC9%=>#tt8cO>3H_[a`EUH$X5hORj.xgrv^vOmkB0JM^GvYN7;cY%:BcOg5oktWFqkt8wjUHkl,pO)'^4=n'x`O'1JDYJb&EENj4^%5Velh=e->kS]#&4E<Q:vIA[(vhe@r`.QOb`,BP:v49C'vBv13[Y84$5vXE@Xf/#%fYaW&)42sn.YRhC)3otitE4vR-m]iI0Kh<q$+^=>#^1b$'nU'VaPmfLrgqef1OY?0lS%&Y85qx$4bmChOtY7Xa9QjRa#JkVUn.Mhd;TVd@fP8]0wO?hOtXdF;hTOrOX-T.?pKUeOQ?GiWV$UvGPb7+1+5J'v%P]=<%?2]HQEB6pEA7>#0M+&v)jE&%gpq[Z`X(JU*]ZiIktgwO9iV*-ER/3F29$w$;U`e:cu568q5I2hJvl+)?;:<-n1t88gRg5UL4UNI([IFEd6ijt@?<LKrZ9T.w&1Ds@f5Y1W;#L:l<<>#I]etOJ%*`s68M=hC'7lOe3RjOV$Y:vo8#S/@K[7nRaNt7Yw5,EHPQ8A6.tm$/;V*I<8//IYr$sAdjOu[#65>#=St6vCM1:8UQ:@cE1Pg1-2I%v+AkxB,_1ZYM$L,dFrq-HQLGc%Zg:,]68HVs)4Hu,kR%ctIQvgjuM;gLYF%&ci%8>#,ME%v2dYAGqcqv[oCE%tc@3vup@@B-aW-fnT_Ut3`>cls^IRXsF&14/^BiI:=;pHs>LYd$)`Kx+wUYR8'QJ^4HvUG#;igwa%+&9t_YOE&i_/fLh$TN'Y*YGs;r&:Q#wUT%QlVkJ39,`3>wTbt*s=[bt0trt1(.Ss4N<N'1v.$gm1;XsTMLo%H-eIZ3oo/QdM;^s@Z1c2JVhLlmA2Z>KgR(*w#Ii?xqVi4W8,qc^gGfhd%)Yst*:Rk<[7)t?UGB&guOr)$QZp%U]Lj(V;^5MdI-LkI/fCsup-#M/B@bW1'wctXQj@&49fNF3xc<-aIHL%0gG&MK7oVslIa7$aV$-tjA5Au`DQ`-b2,O=mxOn[P@MI)%lH4&xs1-)Yu&2uaH@U&ARj;-;d>@.5C``^W%v;n/-KRS'YR=c?oISf.ikDFvr29Mu&#ps2d%jL<5hxtZ*q$.g]/%M-Dj[a.VZ(MT#WkB_l45p=oMl=G_6qV3p^$0f*Z9raNkO&^$7gLSaV/u9o&(3Xe$p(A'xXs(?fk8I&VU.U9a<AUAEcuauV6Msu8Vk'tmt.S-mh(U&b?@O2,1:0_bAY;50rQeL830x'Pgd;<(<tA<cKc4YvIi;``KcqE`]tjOl_fq.i^WJf8*%?Y;1mMI&as'@R.:-%uY/M>e@+u4cs,D<K(u:k>x4M=^Espw3nO$#]NPI:8JGc/j^Jwt&GcxqkT@Yv,^Fbc#&mo;kC)u]/_IF,n,)k(07Iu-Bu$:N6F&.Fi?CqDK`QH>2wGrRTOh_qpCscww1$qQ=%4ffK#uL;949Af%I%s8DAPRovG*vk9L,sK.h)n9a%]H/dl0Me.HsIp,Ikg&/O]uq.0)e86uYZa+laGT=Z-.I(F7F0DUMHFFB0q06+7:nI=#E4;Gsh8`UPcoVb34lfeC%s#0)K$r?uMqNBH)D4+bk?qCsAj4'$^`*o7c]K#uMw/n)M4O:%(FgS83`NGs#F<rLocGF`VM+#HeH1N0KoF>#LPF=#fDK%Mb`h>&)99,Ot'8>--@4;.to`x)*kuP97F_L5L*ae:/c(2Msb?:tZSFE&(3T=>2F8L,#P#1,j=^qZEexlB'5(L5r@OiO^v%Zh]u*U#gaZ7$=Vg't+h=t7YY]CEkKfJso.0mtQ=7N'Ifp*M]si>hVcu=l7:DGsO/:F&rO^v)9-kT@,G@vsQWDRIt&h)3'$[l)@-g0PcW.QJ<&uSNx+onO17#%`rK#+DL'cst>7APsB;f4/H^DjB*9ab,0eG9MBbs9H)OMS]ELGJiVv>Z%6qNL0Csx,jNheb]?Y0oOiTp8NB.Tl$1eo_R:>DT.%X'S%cuWN;ws->MiHdc,2oap.tjdh9A%D').=:=G6EfC)?p2@tD;LF&CvZF&i=fF&ZCDrHoOE['=Y724:_fKsRse^$Z:XThX5PUHT'-.MlVaNO+#v+v9hIds>w)VlU8%Vmo>W:v9wE#vr&:ej(+]*)QRqHi=*&4n[(1,)R1R:v0d]wuX<)LFj9/je'8%>%Y$,T%]am#mWvA$-UYs%=6=R:v['ruuj#feo/sK95QWii0LM<>#PlM1vS#`NXgQi-*k9hc)0#4I$rF*lG+:p02,cGn]iWqHiY*iI:M,VN'jx)<t'*a+i0M,AkU2i%tgeMx)NV<*EbG7N0O86FMKOmB)R9HQOJ>d[Hp?p6<uIqC*XJ`]AD4Gc%[Yerj8Xw75%/Yp.Bn=t,$;WCU_[w,)b3VN'%8K=hVq)n?KBJds>1&4Jm_,At]CoZ&bsq7u9cZT%%SYxO]gFZs;^Tq2V>C')DS?R3r'u<Y&(-l8drqp.21Or?bsP44W92'f[d8(f.h-W=AZ`e:QV@6%JA>lLn[Gh2t5$$t,uJA&MBPqtER*Fs[?gY$Zm++B]/G31+^ea$vmp6u6aXj)2[t-;T1^?&C7$r=e24_jE:L6hmBT8M3sPWkViMLK:Zp8.AxS@5n>s9/+>%Zsrjpe1+oI=#DXmp/c4MM0v9$bsp;gK'+bV19hQ_hL;Xa2M=J.tfc^t63;%Os(rX>C<q?>#-@.nd3sN:7AM`Zwbu1*30m3K[s?XFbW<HVnNx`a.Coob*.t3IxIj,%uLiPbJMZIj$#5r[e?dO3k=ovV,<%m8kL90[]-#,NL5(=NdKriuj(P86FM4RBHM3ov##NNCL5?_YL5b6*]tB`Fr)MjI[>M31-)W8B3EsW*jh^npCs`FAm/J.enSd+a`u69oj)=[`e:u*fW-$.<X1PrL_tfF+k)U71gL(IlC&A*'0)($]=>YXAr%ZJJAG3cuGMxdi<d,Q4Z-h(aF5*Z]#M4LNUk&aOn%^-PGs(6eK<L)JP^UX:/`Yp,B[oKp?.sO+S7P7w/:Y/:kFB7MdMZ?>]ue6t_&9n+Q`waG[..F&4uCvCQ(30)^s41`&)*GPVsGKMn[BOQo['wr$#][qnRxs1-)99:ftx/fI%lEo;-x>N/%0L(,ja&Sn2T^po.:gAGs8vgC)-G64&F27L51rE-?rdYL5=(re7Z8h8.@-u@&U)2_?j$0$.cu^lM8)hPsPviwKiEOEt.0U8M0^pht)jiH-l6e]-$[f<LPmek82IR*.LJs/Mj-d0LUZ(vW*(CXs@LnE.hINf.GAeGsV)fi)8GnE.N8c_au4_ca<-8XLfbt<YtN[*.HnZ6Ml0d0LN2GCa9Qt&$1uVJs9FqtL;)0@t2YJtLGM3o@-Nt&$0oMJs9@UXLhdjO/mOVj(PHnR@u(?/<9Srn.B?7uebNP[s9D2Ds7RXj)ZJ9@4XpiwYo:768wW_52;)#d$<qjb`rOIt-AUq?@*OAds3TFE&f.Fo72?>=-nX_H%t$`XkrEXSsxf=MAbgp/)BAU=>6I&X-pdUM3h&,'@,i#0)jV/&tm$/'.D'Y)M/i-?&`X_,MU@K,&fD10)>74(sPV`B-DOT#%o_h3t(qn<&]XeX-9`T6(UQ(IVq4)9g@(0W9[E<Gs<FBs$)on790MGHNQacILQU0-)R`ZM&ijYx7YYMS]uSR,2^#s5_Jb_b;ANPUI)#wqdN%=h1Ye$p(F1w[s=ghC)x:]d:CJ7a+;2fGGX/'$&]]C>be`622`';FKcMEga3BeCs%9E>PB3'0)3r7dtRtU1*2bA<-c^<B-nLaj2hF2UauM<<8hk_C)_FSwb34U$9bi:$u-AtEaE@0-)^t3=&Hl&:38h@I>@BtR/4s6(s2WQI;TTV4W<S(%Mnq/+28S)`3pkBaslhf3/BR*7IN<v[]ktD&&TLWt12C5[sR40Jsi8r63XX7:H.me5^4oA.)vl?=('r.<-qWaY$HW-O4MDdC)WTtOM]vkwtY0C.).Z4asV<YwP5@s;-3A9n$IKPC&h7[C&Wrp,M&*eTkMD$<]Uk=Gs9Z8Z0p.h:$(AhtQ*`6OCrR0$-d<E4E@>B%SS0.9Ss;Fltkf6P`5UuD3G31484I#=P,YOE&RQB78A=wO&icdseHr3T#9'Ysa#0J>-HLF;.N.w$4hw(gL8Y$4IXvJ')c;gbBH)/Ss)f0s.guRRe2M.+Pq#.61_-'4fZ5pU>xM;Rssj'W.M+xx)$Oit%OSJ,#]U2E%L_Is-Vaax@GWP^?aX)*%CZ^5/Xb]auOJjV9wW?T.Wxdjc-.nBbZZ@M@OQ4ecR3xq%?1:Nt37pA&,nA17>[knJNk0G&kti;-j&c418DY-`Yct.AMExdc+'Rx-&hW?M/D14L(sOwLR?Q$cHrrx&mKAvJxG.PfDM9mtIQd;B8Jc#[ZbL19aH%+;9E$=YuZ>/tvN>B&=Lit-C/X0NT-ZqZhXot(iL9T#im-#MLCJnnfLSX(]FH=#:XrGs1Urt-1.`PMtWuqamUAfq6#Q4$v4kR1/;Ko1#g:Ys0bMlfd(q?b8rIYMK6&#M2AOl]l)Cs-;p-#MqDV97l]lt>UZik8MO=3)uO>F<jgYcaOACs-0`2'MSeNG#coak8.p][FiV/EN)Z,oLOF@&MSjQ5NMT6F#=RlZgP2kE$/=2O4/aV`tgY]F-^$jqLPEX.f:LMGsJLX7.^I3:IKZ7*n9$*jLeBJnnhTt(M%7_S-W@65.h&vfLh<v<-dGNU-]HD=-+xHp%P%X)tl$l(WRPvtLSLouMBYLhn%;DHa.Idi^RrOgLE:qo-E>?embKcAQ&[7Vs+$`L.gRvlSqX&?Z2Dt(EC8QtL#el)SU`oCs`j<VhGXUk]-ug#5(*TgF3@X2^_d0lOb%kIeE8iF[H^@jT(Uof.^wC=#LFXn-oi+Uio+EUiWogWJYK+&u^u%vL1_=iaPi:l)K(^at<S#>cpxNltH4_8Ms)3Y$L61r?&1kfI&@pt(V#/48u2SD=lFwM0636T#<-m6[j4Kp7ek0H2,LU(U@.P:v9revuWeOEeHqSi[X=ru5ZtH,)aMRV6bTvX>-o_f:Oo/.v76EV7N#T,2Mj8vu>VR<Lh9P:v/ZKCCQCe2LqJ[7nclkv-.$(&N7L#WSO8>9m(OU:vY_E6Wmt:%atqU:vf.=L,3++6M#PQTmoh:F.o&[,Magu$M/f?8%Ur5ZMRd,2vM[HlL&$HJ(.l.T%LQI2LZlOJ(-KF,vJAgW7[C-)*Hll+vQh65Lm#m#uMi8kLu8G(-v*H]tYw4:I<1eaLt.als/weEsO,he1r#bssUuC=?r-$4-xwjEhVY;ji^n1/uU2qe1d^pqd.YVQPKOK>fAs0lXRGkd%<SK2K0Pl[Kc&vK=u9]j-/1?W%Z:V^OhiX<iPMwT#<QL[sqDM`saChk/7heVs$_0btiW%S.&>S+@J.^b%VZt0K^Z:B8X07:v+OuN%O9AcS#`]Ds-<MF-=OHit.DI*33fj9v<L2*/(k4'$*'vT01_>pu%cfwsh^KDhS&-N'4fHZs`a`nI>S0%MPh%ML[rd-(guHbO,JT)NJOu`so%*J(.Z)%+b5[U-/NW.(Tg-o@l;C%4.`MW@dm+c2Y%#d*<NCI;)+LB#rlkxkEKTXH4/Git#HI%+ZLdt6FXZ6jRML=h+VIZsevmFID8nFkh)Q[s<xa_+670%MF&`4)UI3Y,HR(^O:w>.6%GriFD?%jN?]+mf$E`*]AxVeS6u#r$p]P8LQ#m6e[N%P%;3IQso*X_38*ZU-,Um8fYsA`tCw#0%#[$sZP$NXG6#Nu0Rck5hW[Ns(F[8(*FQQ<[QWWL0BV,FsUPwI:^7[s-/w$BR0:qx$epT(*7R9Es44GPslaR5q?#RTk`/tpsTLJ/j24m<emdDjYqbA(]_@3F[+Qc`R(<G^%GgL[sS:VRs<EG/8+J@EAM6@l=I]RjF))#$c$C^p.CxKXGtI]Vhe+D$lsMik8-T=7&dr*o7#w1-)q4>@kZr3-)Ui-[K?ca-IfwH_/aF_Xk7`$Ksi'rH-D7eW%<LmDs8p_q[lK`]Ls+$9IeQuCs_CX2$DLv*`+]1^t;RHd)cN3^-9)@<Bkhhk/kiH>5m(D+t.%QI:U^]=ubd1>51x;OJ)bK[sPZVAffce`*%1N<-_)pK%](1Xk_DE7$))^Ku>*)9u$2RA-e1gw't9:M8No6i:^**$%X'h4.`LL78Qtv5/'v(`3YS_5heCH')IS6VkG%j[Np`R?V0]?1KARs6JAef$X&aX?M:%LE%(4Sfs2/ShtDrN?%L-82FCH[JO=ASPs&$n<cPOo,)OGSpt;w^Vaqa'rrW#TdMOiG:&,72r7c^9T7)?`]st;Eb`BcR-)OF3hswPEH&k45O]kXgaWj1,CW<]E;h9HUEk`i+Un_N[b;_wNp?=DQe%f'S0q4>$Un3?Gh%&QMds%Li%tF/Lk)>jiX-Zr;R*ovr6[66gG)7Q&&t?N=E&#[e7%*2t&-A3B$l<0+wm^g;48X<.:[#pVk[3/k50$`dS:'v-'5NVIVkR8%c)u;r%u8C1B-^*5Ys+@<UI[N%P%7ET.;,<t33m4?h-?GL.;aqNNL?m^DhjmlwsKNbb*Pc$t-[6m<M*=1@-b-US-^D#`/PWTHkwnD1'3SBv$&xM$-SV$:(Y2c;-wE$UTU`Oo$lD.FM)OJ#M*275bBh%NfDt$mm9:Rjm8FO[sgJgG)xgdMLidaU$J+5IZ;gIc%aekj`9rctGRa?(1Mj]7E^hpb%$7x;%1=S_RL(Xj0b./ft=cpMs#)#9-GhVfR36`AkiM$1U<R-ATbWqn%gd_:-mGMJ<od15Kv`4DJeUx.*d2+ON0-u]t&A%Ys.18GjcXkv,*YfVNb_Ra*EVd9.QmI=hD<Gm/vt;Oks8tU$)gd.%m&UfsB47'&oH@<Z2_WtYQC1PI_EP[swDM`slNx#MK&2i8?XcdNbsEOkm(D+tCn/k$MN`UMi%Mp.)S7N'c5T[0fB^CM$BxjLMnI?tUwxF-HKdIP8--N':>=k%u*BX8soZNUw]=_t1Wgn7[Yjk8*B<Gsg/[x-&+WfLHOUWjL?jM-`Nq12Z[E%=9DGR]CURXl_`VN'#%-gLqQ(]$Hj,1_>4rMMIcGKhwbg#5ORR0$kP%i)C[TasZlVHBG*WFh;PPHKhA#d0mBJOJqsWss_5wb*?I.u6E6:i'o`T%umBwt)X,Olt(Tu^t'Z`fOxH^Ms5s]kLc(oft^&_bt8MdI:^BG^t?^7o70c?s$?cEaub86N'U5:#BZIt87&b&s>>KcTk:Rg_*V4:7.%IVGs@h#WdTE1=t1>d(%SXJ%4H'Y1'ukq<ep.``%)R5`GG+0_G)/XDs[^K(*Ldw$$ACOI(ER)(V-v?Ym8`;pI@`Bj(kPoI;UQl,2E:_Yss$RhT7r(qkp+b7$9]^[F<89r:0CkjtRJ.dt_&%iK<,i.jf#:@4dSkjnB59dVaW`ut02IeO_^%QDmD`]dch0#h.9n2b3%eOAi44Op+a'60rc-Y#Z/S_mlh:PgO72Dg,^Jc%Zn5(f`1[YsBC_6fbo-+ksN4bsv]_0pu0w^I,//Ks/B:&bj]5)-'W&f)q+#c_Q#WuA.G'm0t:tigBM'FsaqpmlVi6k@oFUd%%V4&Udc)fZ%b@jaKE8`tvqV)%]o4MV?5%ue?U+hc7^8bstv&I&b0lC*5'4weC$a&)^+PQk6xmbLddM2kJ_st$X]nC*OcaA%8?:hs[>>^tia$S%k5Ac,rV+8h99Yus)9TnJ4E,lJWJPoO@uIh%PTb8I.+hI;u.E^4eXa-IPpGZsa#UEI<`0XkGhvBjh@4-)+F4-)7rVN'A=0'fkR[YswaeEs>hxHk3-'Ca)bo*aPeZGaJ2EuLD0RDI)F^Gs%9(2gEBacar[+Vf_w+Wk+r=5P5a&HstHR&*W3Y0h4,c7%REo>-kFPG-eQ_`.-&<e)[;jY0j`WEEhk(Ooef1EMA%G`s+_@i),ngws?&JZ4d$g=#g*Qa,-3fMg]O7>VdhhPPNo]ZM1T^?Nd@ggiFL57$?6qErW*7'j&l/>%f.51^blf0^oK81u5:8lO1Slh0PL*rO_sxnLl<.%fCc'K#Mgn-UnGd[+c*K_b$af?nt#<'8Cg;Gs5:1@-Glra/]iLMkfl6N'mOa)3pOmE(L&fwBt0dIk2uv1*r))Hs&XW.:W(($%M1=0(B=<[bh7FPs,cF4&*VGDIdZc[s4p3IU6Gp<lgZ)Ir8rK`t2>@Z.GEa:D#wee%NF>sZYt:;`Zcs[=ZM(Ck/GkS[&))']v]fOb@l:^_%WXrO<CKbDbK<$Dk>p/?YCArD;5ja%0P)ctaboWTb%(hOk(_(HE]<^@Q9e44t_=,8$GefIJR?qO]<]GS*wu]t]20u-?,#_sa*b'r-OD+[1nua%c+>dD=ZE*@lpP^tqRQI'qEilO@,V=I4BZ[s9LJ<h1GY[Fuel0h7Ub,)8f)%436_bti=3c4uF/gLOFXr/mqcMVNLgSgn6)K#xU8CEl8?@+.@k$c.In$=T-2(3LB+WkBdL[sNLi%tGBDp)0$Cbtv/,1Ms]>4Mk*$2t3D9Es_'c?-jPxjLTnI?t,f$a.;m,bs[o`'PR>a,)h._7%3N7(fc:[YsWOuCsg.rw=OjCT.MHTv)xWkR@j&>#uFC_?%9g]Usu&NRs5mub/-6*O:l1WN'hnq@-pciE/QL-Vks9^sL[hP7I#qrD%C4RIU>7tGsg5>J&qW7?PkV+DsSj`a-l=kw95GOKLB3%ued$PT#P:N2$GZLq)=kQI1m%fAD#;5%f7:D)L%%tZ3A5:XcqsWss-RXj)WLG_Fm&=x)78aHs./p,)3++Y,Lk57.<0p;0L$WGssDAvt1s&Y,F/ZrJ$oXs6N`WOs&j9t60Knw=?-rtevBjR?w,G0)Dh9^s0=9x=@HNa3=,5Q/#?(S%#c#ga+jva%6?dHFP3gq1s^*j^2<a@a*2&T[[x@%%b^Dd=(OctbnolxcLFR'&o%w0K1Ehrevh_X%Z*VFMaN3/IH,#QdVw,K#XaXhKm16[bXZb$lfuSO/RfqiO8Ii2h#]tgO$=6oC5?@:-N@=Ppqc&4;4#;UkH.`G`YB9lX-xVCfFPH+;c;:>9%h-Y%/P$<-V<Lt3pV8Us#'q?bo.RUI6+gLBafVN'L=[`%Daj7$Y<Pq)M[hYW89f2K._gO1J]jwMslWDsD&wX>l5B>b,Hg@Kh[JX%VZ,;/v;gF2H$MO/;]e6Mcce`*idwa*E/-)OjC=V,R'?%+BrxV%'/JgO^mOZs%;+%+[:Ms(N)[eC,3dIk]'-x+0UKSk)YOf$::9h19[b,)#AIf$Z3NI_Rt_29&DN1)Ai5NsJ=;_X[9X'*QR9EsI%`A8VbTj(hgn-UD8K,aEv0Ck:BkPK^%9>C>;N7@cP-7@3`W*an+N[s,KnH%:ffttAUg_-n)xxf2%Y7'V,us-uYboLxQ(Xs&TkDs(mPo)Hob<mh@8#*,4Y0hA9pK%JBiB#ej)Ts'pb7$0$a'/Cq.^tvLLba=xcv5]_EippU0DsJHR&*>NDI1WiU[G<NiiO@,V=IXTq>GH+#YkklcIs$_/f)TO5Fs_)R/52KI=P0RA(u+gX#%Jv/uhu4RZso%QQI*WqEk>Ei7$B7nt>^l%Ms68v`,3R/.(ZP`st6TNV/kLiJsp)FTsQW04/)pA7%)3XTso&+Zk*gM6/tqI#-@6l+%uF@W8PsJue0&)A?aYX'a$Ph*jI'7'6ZG@&-HN`w$5A>g)[`aM:/pf&4g=U?%;mfUsfSev5:Hxi1-8V[4i)*op8+C<hv4IZsH1(AbTq-/l7=Vcsw$ZJ&C,gj)hU.$pdqC=6=9$tL$;Em/aKP[soDM`s`uq_%A+rDsAECUeQWkatapm?&Hle-I)1e*Lau'IVh<_k)?OZ+;J)HR@VX],))&IBUJNIc%lB()%%O&FHv%r]tDZ(g$-vQ7@xH+N'w=clsEp[h5=*3`s(_S`t+=*`=(1NGs$S'hL5R[/Z+A8nOi4:KJk[oF@^%2[%kba20BjQ[s5,&sf;liI+s+a,)[LLL0c<Z,)5HOatjCHpg2`T3gW%,LM:4k9dN=?_tLjLMkoCVkJ-.u0MU6GIs;Ru3Sig6Yk%&Cb`n*jb`Y9sWs&RN.:vEKnefdI`t[C.N'j[a-I/L]YsW.d+i9T7Ss?0L<.AW>C<)Y;&5n&i`t@?TsL32#l(lU=0gYAKF;w]=_t>aoI(Cxrq-`rx,)GZAJAwPY:M?7@uLN;Y>%a&vlO.RhpOLUJe@P#DO5-/=o.;,0`*wJg^%3;2Zsn'%[s$Pu]ti54Xl]@=kKvZKstrXcqtbCV8ROgI=hN[fD<AKBOrkHX;j`H'.^O*eNZFA+O=WC+EO:#<gLw9BnE=VkCAHX3.=N9Ar-dS>b%k45O]6WCR@&Zwa3<s=B)NPC@*ie,(%cV42@rH4Y%WVFO3[SO2Bfq(v3w()tV?YRBUZ,?QXEg2a3Mj-]JU4'$A)I,0N-1H_`@EJ&aNn48&7HWqQlw`IBW/i^sEe^R8=;QI@3phu9;r3ZpH%'c%lTHN%,fGZ$Kr?QkuX'u#2Ijs-_sUgLWncb#,-XhOZ'.'5CD^P'VBi$F24PseH&?tf:hxHk:BE7.ucS_Od.3X<q*S0q=>$UnO3fb?<Dmo;#MkCAp6`d%H^^S[MKiNb%IxU-Z.'w-d;Mmb7aHV=9pTj((R5_suFods>7$o8QxV[4v+xI([kFt.8=u55OS9gWW%n.8606Z$uZAL*,_ZtP[IGT/.%Unffl(M%Ni@m@5sPUa#Kn7Y;@V/+*xI,5n+N[ssV>mUaf@0%0mSkLi1YFhNU9';S*;F;HJN0nT$k*V`dHU&*pb29qI[LshqaM_+m?w-`c;W<YAm;%vee3b00J<=WI>:$;1jZsLmfRN80Dp@vC^clT_K6b3.kq?G_;ppcV6N'+Ws^%)%`XkPChk/NKoeKJ8.$t81Lk)olf7U/Yj,)UN7P%LvHst6if,)&(ML0Fp],)]9i9vc4Z:;U6?k(Mgn-UY0o37K3DF;^Nv0)csVwtlUdBtjOKN%E1kk4E,L@Me/?l$*Clwf4+D(tF,$v&dtZ`OrJpk&2L$.:mQ=r-1mISsG1XOQ87lTX['2;07K-e2t]Z6BHr3T#efaU$wqE_N%g1Q/LOK1RULQES%SYa*H('60@dRa1_G#b%xktU@W[Sj0_VV*Iek(K#cF'7$]G,7I[Tt&ur<odse,XRs7B'lO^aGtO#<uQsN$>f$UqXGs/WHtu_w5K1+;2Ds)0[t)s12+V;/bTs]>$M';ASPs,)pktsn=qtKpW_1pgkiteg._OuJ3XCcG-Ae+ZEUDENgk).dP:?C-0Ms^,Cl&b(egsD`mOOd[q*u&^'hLb,lvMdeCfsHpL`s]s,%>U]gMsA18Ps]%pktUd,nt+]+@1mTOit3ps1u>=_Rs<%,Ys?0#>W`&rL0noJ8R@pfG;IrVcsc9mZ%KqA$*Uu[1'=bck8Zb;bO#1dI:un>I:jDJO85&<r6k]ruOiCBL9n_gL9n/OB-(Qh`$Q3HTkSb+uOFv_#t-b$Un(Ybk%MbX,)Khh9v0DG3%B?5jtW+E;]3FvFsJ6>%=L*<4qs'krf*DJi,RCKR7cT]Ys<Q7e`]J2OsN91Ek;iNn]fId9m:I-'5,ZE#Pm?+.BhPv,)ca&+TY2=UI07k,)Tc6UDh0mA8D%j1)^tke1/=8*%3.d:Dd&_Y6^xf6-G2c`?*IpII2mQ[sa;2Dsc/Lk)+VTHkCf8vYcc2/=BdtYJ3[Ra*GG+rI>Pl(d.%5d&GjK/f)?`]st]`otV:Eb`*F)$#EKs*`B)3-)>5n,uqPEH&/gNQs#x6N'UQ[gL<'^qHI>JN:pkBas5*YDMr,`+C/Sv-`%JB^`6_D%a]s;W^blOq*Hvt;-r?GZI4/?T1`oF>#E:C=#K+(v#vI__IP_@4&piS_mTY#@&ebH=#?qw-Kkd.E3N?W[5ENFes=[%D&<6IQs'25@5ksmqW6Ep$5dFPlWQJ5@5w&SfGo:'lWX_=`tPiAf)H+BD*i-*'IZ6X.+[P^$&QT0i:8fXMaAA^m(FH9S+qj=GNDjHYs^D*48(cUqo^K-O]>7WXH2J61*'R9@kBN6Os6cYL3P^kf(tGuNsH*I=#^[.+*gA(=ct=7T.CZHstRM6P&6%I<-Rjm.3kQrw=-3=OkEumCs)]=7&YE%08FEZ0)ZI[6uLPEH&9)v;8L>He6ZmiOshdK@N;d14'$GdIH;7k6u@?ld&%R/<-Z3cc-a+xKY]C]IB*w)csEL:`.?Ev;uRvNN&@nUH&xYwp=(8@Mh`(8;[slI,EeL]*72gpqsY?>Q/v)@ICp(r*aY+&9.HR9EskF(2tLs%3fUXrqcrhxUkNndFs0R1%*jH47.c[_q[lJi,2qaZ3g)XPn[tJnn/>bI4&QYh/)n+i*MY.ntNY$U)M&mh[MbQNUk`1/0OT&=1'ctNnL9CBC-oB$t.to/11&,>N)sXJstPMAk=Amdvs/a0c<QEumDj%[YsjgcTkV+?D-.mUH-)36D-e#jNVYsx>:r;FnW>F'aM7[O;lkKAH8eIu%l%]8[+E6E']pR^RQB.c;RN33@=$=,HsZ-^A&>_e&*2N@w>v[nxcG+8JrQktGslo/Ds%0bD8gieAc&psH&kOU1&;b<j([L$X.Zf2bsbg]_6qY5rH+vxxt+VTi@cD*4q%g1:6r[0DsIQ1%*0<MUmde$7]J4_,M?IG,Mc%(&tA'A>-ix7>-w5@A-B,Xf-:i]wBgS94/,aTW-P`0c7Ce(^#:c3GspSxYH?ZcEnJfJd6@`(I4Xe$p(OBdk8MO=3)_M4MtO<#B&2D`OJ2,)da[lI1BZo/=1f+I=1:5(aN(eB(M,4a`?_&LwKqhYOR:5BpS^bZO&shoGs]ihs)GhGV'RAh<.<YS@EV-t8A#I-FsIL^w%j[M5IoHg$cs4niNUMhw->%%_M;%gJj%Y$x-qT:2OOE@qnX62n6A(p$(6h<Q8OH(USxF4WkW]x=Y*38%#>'J1GVPOQsjJb_=BDbIDd[sj3`/(XsQ>KDjE=MI)l>h?Ksq0-)=SHctUg]9&POIu*hEOW-wB]w'BpJ1CwD-XLZ=H=#u30FVtfZ9MjMTv)Wd8RJ/kf=Yc-me;jHWt*CX46/@9I=h*90'MF)Rxk6YY-H+,^7$5To0GhKtAueQdW%HZAC%(N>DIB890`/*.SsDCeC)+4OkMfH6qt7AZw)euo3K7@KN0L0SN'x--i9q_)BM9'&b-^vHwBkxJwBu;4i9CN/^trD'5OXNH9/B0i'I?,i#EqS-NqjG`Uk/EJh^nH)kb7nUOsfv`E-E7aE-c:A'.0Dj@NIDiUs>-9_AE1Di)puKOf7SaCAmlIAi&^'3Uj6)LkMX..1^(r/)mC`2i6Taf`^vr(k.,*fDYO4l9SRx5'<@4+3x&vS&lbH=#-^wkRlG*Ds+)@#MtT[ntg(x1EJ(v8f>>MUkU*U>V<=7pJu9tQWCvJ:QD<V-2ZDY-`<3Qn[Z(i6f;XI4&@Lp`t(Qje)@U?>)qL-i9#i15It/LZs0(UxkkHVGsj-]CkrJ8]t?qJ$0aw>[t/&RN's<ks7W9hB#;hRXs.Mb7$a`Xb.=0wCsZjuoLfR#atLV'x+5mt`b_@$[MVp@d)<FKt:#lmt:FQht:g+>Wk]55)K7cM*M8eOZ-V5Pq;pYPq;[XaJsx'#GM.^.Vs]07RRu`6v6@f)B5f/]bi^g=#d765<I)`k)FbgDbN^CYe-$X1fYf':7A]2]C8rq`&)Ejrotp_r<:MXG4K0p::IN*+/Kl;>-mwX*p<cSNDF@sI/;TJDA.DLc's%q4jL6VCxL?-s0CWC_211[6H>EQ(MsK&%e-a:H_//]kkfV5aeM%qBrepVVV[P=tAPVQMc[1h'W.-=3Dsg%GbA8WZ90Qf%4Ap8_n@9s::6#=a8.Ajd[5XgE>&G8)<-4?Q[sT,220RnhMkWaG@4<pckTlJ^mte=nEj[P[-`T91@-`hZi$WPb?In0K=O.A-i9*_l`t/Y3(N9bRj%ieO8M2]]Ks@Zp0>&Sk[+PS]0>:io3fe)Q)MLO0CMolTLVHL>1N>_XjL<RFjLuVucM//8j6pk4gj+XF(0a/Digw<qEsd/]b/f-ItdcK)uPqi&W&R:<(P(],lMrC8#M,FeFPn4d%.o#1XM?pk*EMA$1KmX2J'<c1tes9?xLc+7Ysxna7$5?Ei)8*X488/i6W7iacsUN[9rf.Pn[h55IM*Wj*.=pT_Ij'*V;A&*KOxnsZseH5Tk'SAn.r<2Ds;XAn.rM<4]p@3%A)#Ra&NAnmgq^H=#(<.RfB#tguP7Ivu;6men_0tP=Mb/_kA'8kp`H2&(NP7bn`Eps-;s:*MJ*.]MsWv*;9Qrb*Ab`p7+ZVdag:b'cEYLbNBP6t.`X@RInv9Bo<MO;0l=H$l1qPn[YCxBAeC)$#FA*$%r=wHL#0*YP6-p2Torx2fDYfF-#8[A-;J]r1?-,:tn5pA&b;+]t1xN$MIkv3BUGus1=MD@&,_M6E)/_mttbXkA_(%'l4$Qn[165IMdaI1MUM0a[@w[BM-b'h$A_-XC=WAth[Bo$0,K`ws.?oQ-f3ZT%&ICFhsRQO&PFs<YfP%UM=`IL$<0A$&hbH=#$_LI^PEI#M/:?msg-=,3dm`CEgwSN'C'@Ksd?gvsR74AOt@-i96c<GsVC3NMJmcG%<->I-mW4IsihJK3`>clsu)$[sQst3J%WCEkda2R[d8u/)v'1i6AAVW-(U)F.%XI=#jZOv-de@nL7$j<d_*[l))&YKL6f'gLZ:9$.5/nYM*_4IDexA[tTSHkOB0Yp.bgDbNfkCF.]D:VsM:B$.BR,FMFA`EsAirotJL&=Q4;Bi)vb3IDD=w*V=P^21<3m$9K>g*.a'e*.MGge-rpw+i]6ucsWF(2t>j;g1^iak8S>qFtwvw<&u:o9JO&1^>B(uwL2EW*i,::L,(&Yh)Pu*glQGNG#QS/L,'nW$M[m#B&d2iLBBkq(k>fhY?-OJh,gwLh,ZLE6pj;nCs1T[+imPE`s'v$u%>i^X6F^q'/u,0(/m]1L*Qa74]k`&u%[17k(:pE=#l<GI2ObOvROHBPu$I-92n*kB-+Wob-h/W$9P*nDsjbW[GM)+E3(->F#KBu<Y3-cUtGN>B&+B*h)%Nqs-2LcDM-Id2tG@FV..P0h)D5x4:PJEH$>U-i9CN/^t5OnbM%b's.TX<3fH*/*%CH+v-eQ/0ML_VCEh8l?tH8mNscTMRs`34(M>1Xb35upe:->ds-`h6;8CBd&4VnVHBv3ojgBjQ[sfcg0_D6ItuEUvb$ul7uFF%d44E%OdO'7SCRNhX#G>A#`K<._pOPZNh#]aprO`jVRs`d7=3vE:7%>kC8[C`O%+Z`]b4_[9/)U+FOk.5^Gi4ci]s[ROgO0]qE8?SSHs/T.%4qjE_NlG*Ds?;YK.d<dh9-kw,MX$X.fptGw$CCbVjP.?`aV.cTs*Z=O1H/DnsiI`C&TZpC&j,[:@+@Y`kXT<I&$ZPOah9JNe)F]Tt0'[G&h9Uo78b0u-T$n$M#g57.'4`C)()u2t)>)K&AOT@M=`&spx'7m%xm&+;,d$p(D-u<YtN=3)[E*Pt$>#B&lW]LT4kiOB<USCQS6+Ws7^e05dL`kIe&_LsnNC*k93ems*ug(*@Zajtdc`[$S6w4_8N5FsBTleUon=.)kT,=&4Og2;$`*)#=Gw#M;r*7/^/Zl/r;Y_OLAkJ-6,2m2f4EH=8Vrn&7-sx)'B4hqo]X0QbGi34(HsNOoRmEROB^C)_4a8t[b/v.c0Hw)>gq?KaOo?K.8F6N_L=g7V&QUoesW_3v^1GeLj0Ftd([G&L@Q10CY5&l,;=vMO.#BeUkWJsk_n&*^s4f(2e>.)40?3t;KX9;Mt?a.D48PJW]LqReovnc:MeEsf=ONsbZ6A)NEi?trLjnJ2aa<#=wIwL'QW7A2u5I6@U]C)c2_'aVS=CO_DDLpVG5HMHA&Z7b=LGa0<<C8cJ0Ohp,aEsH8)ot-f0,)5XxTt)X&$0CNIu,C>wt?vi%W,bmd-6KL`kIc9/$?e&v9kwcjCsV<ZX$CejI1k0,l7p.n.1IY$<Q;,E.)Owk>&'53,s.-/88:'JUfo<nt>U?xHswPTMs&TkDs+2`J8BRMs%_@]=?PDixl^4+s[4bbh5f,_C)F^Uwb%Q*,Q5K<h)VBWg=5&KSsMC2K&C,&PfPG;/r(o@4T7^#WMr__sLwTx<&xq]et0#NtLe/cZM4J<mLtNx<&&K6kZ0S*=G0ABW$1baA)c^E$MJ1sxLQn4ltaIxE.he1%);/Cs-p5jWMpkqsLJl)K&UBI`Z7YGL8Bx[5Bp3^?8=RV8&v(q;-K98I-;NtG%dAt>RR7dj)P#XdtF%Q&'oIu6fjk%Z7%wsEa^'kC&'SdW-_X8?%7;@>8neRD$=;ksui<V#R6;(,f=,l;-YI'd%Y%Bu?v5vAQFo.6Mt^rDh*SIZs&/l`*EX0K1*Qvt?,n,Nse:G:&Y@_vn1pU[40(>se^''(rY<#TkYZjvMF2-esNd0>&4WVp)<KrZ>knDGs`%3U;9j];ewkiSt0'[G&g)Ro71d#3j;bVb;)Z5@.nY-/]RelVR2q2F.M$']=TIEcb_Gs%)f.?*dQ=6A)x36?t?UGB&_BXIU*(j4=PoL_/Lcx[Em7tLDgIg=#AM&7[t41^tjICs)t#-bsa0EkX+)aIL@-S)bfFaMs<%404FN^+A%`rq%nqNUd#w1-)Hcq-.KdNqD.5=uYGEM5^NZBqLi)*qkb)aY$USdC)l:]eC+x3O4RrC$uBeoF-oqoF-s9L%/;Mt+Dle-U;k$`)NYv(UsFgGAkUdb/)S8U*IY=0-)09.vLdN,[lGncG-B;cG-&LL@-Yv=W1+8Cnov(f'sJGTdD_>Y.HsJc-H<.J/H*<pwM+4'Fe(2/?-_<MXZ&&s>-(06dn]@.u*`[s5/;k3bswaefL;o)K&s8/(j3dv(tihg%%Dw4>>b??P.Wp>PJ/tF$'8BR/a[`INsbZ6A)Z;7eq0ag8.Vrte=]PN&#]BEO4Lcx[EtmP,2&'h?u)*%<thTrC&=t+iK@Gs%ugt_d-D^P_JEnP9Mi<kg&J3&+;ixNat-f0,)+(/TtsO_`.2w<]uheK]*Y$5R3jv^FLKJ)]4Y<#TkGNpOBE)NcsrfQj0UY=>&8'8q)5Bhr?m,cs-u/o$Mbj[DegTKI(w-HXZvw*ECK+4(4#J@n;CN=v-&=o8Ma]O%tV@]>-L:]>-A:]>-ssxV%-jDZs@7eC)fa1_td=Jf.Otg/tmTWjMw5.%+C>`m/h/=;-96mQsZ8L<.*U87I]T#QB]Q&.MjhWn%<eP[sgtmCsMCM`sT%S)Ox0C=6[`PD%GFW?dj&6peWI@Ip>E3ZkbaX,%Zjmq6[@['&Emdvs_l&+;^=,U;S/MYsA=9C-g?-5.a@73O?6[9M&cVb;(T,@.M;,2e^JfEnEE#SI%`EW-vd?[@FriBbBu%=Y/d,9Kv9$bs03&#*QkV3pB$Mg)*4'fD.NAcl.&cvMp5eTkdw*M?_T*V$-B(gMxXnn3A=bn3&TR%+Om8HMJjvt0/9UZ@BfpZk'?mt5(+:N:i]G5n09BF-o$jE-Y+(`.peeb*^_MqLJGVio*)@vC)9pwMh6'Fet<md.,o+$*Dhn2.^BLUSU$p]aTfe2.Uu46MeW%iL,1sxLBH#atxZ6?]TlnM.exdjcbPS`kdKlG2dxEC+:d&It*UGB&V$-K<RfARMlvdTk1t$A-,3w=.H<JLTE48xg$u`s-I,FkMrut[=cnQ_<xE6bscm:]$N'i=,C>wt?'$tk)^HLk4$@rhS)*Uk4@A3O4;Dv7tq,$L-fr?]-ek/O4PYDn/w?Wdt4BuVss7@`%/D*Ls<qnJhRdm0UUH-o7bS0^tl>Y$*>(4XZaRa6f^KsqHj4e$'v7e$'cqtXB;bfKsm&Ae6)jGOnDJ`SkcHm0Utec[Fw<o0)CiS]t,Y$G&[?Uk)xk$A-(CWu.:'YKLG$&JHM1nHH)w+IHC*8Q%Po7hX`]7VsKsu-HP5U-HpuN$Bip8l/JZHGsCPaEnS/MYsa1Yc->,6*nX%HZPn=$LGj1wdm:_Oemj1wdm>wtemDj4%)L8248`Yx0G6+[0G4x4-)TR`[bP;bf`3m<DkiN65^r0s8.ieeCh9u?0VdXa-tMTrC&5Ji2MR@+g7aETSfmS(d-bxO*Iv-)kO.r/3M#$eTk29#C8t'9_J1^jCs7q-#Mk;+UeKuIu#M$G>Z0%%e-s5GwKIkDp7Z#kWq=FD=#d4NwK&gVF)lG_kT4Gj'N#2t(k2tAPp%,t(k0nAPpW^'6U;_fKsYT8R.M6Y.qd<bVe3dv-6/f>TQeh@+IoG:eH)suHH3JVeHp)$9I&EH[sOFU`.i92Ds>OJ70bI`RsnWI<&44v*.>j#T%[@H=#r65IMU8=F.fZZft)I0(*=mO[5_8bt?;r]g%jYPOa%QU5BWlk6<lQ2o7*#cvP?9x6<?jkt:[:Rk(46(x+?*jC)gK*5t[tKs.3o1Y#Y0Wq;(-Kq;iCMq;<;K<hGL,OhJt_+iW1^Ess'2.^v62.1=-/WIZL`+5TU=S&v>vM0a=evRKOmB)h=A(MGaVm0dwQkgJ&+@VjSIKY?w;B%@4S8fgSLI(e?>Gsm%v[.P]#=P%JZ@.aI9WfO'4a4Im+R<@YYA>nY^C-&W^C-N4tnL4Om-.mi8aMREZ`MN0g6ebn%S<RP:j(E`daMUjpvLpn)K&dK=i'PuA/i$=Z%MZtm0d6Kj=W=@1t./4knJ)>=(fU5.C/vvfV@Wm6,E_6T$6.E@ws&UrC&V$&$*ve$Q%tRwH`gM,C-[V:@MYh.r%MHH[s(tmCsj<2I0e+:k)Gsi9dGTQqMXRwp.9hRXsWek9MxGPhT2(mlTEH$)tKj^k.kC3-)'-]i*HFCE3ixe^-=;pHs:XXj)Rqh<dPnEu),o&01HvUG#h4bk8]ud,tYkK8/m6W[GTgnv97W<.b)T/SsdXgc.F8LVs`6e222)3`sYMrCsO+(v##ew_<eXlSS_X.f;DZJHsY7eEs%>:Ee[H2R[MN:ZZo8vJ]lFs[KCwCB#17^5$H*g?KM%qDse>b4O6-,qc)<uCsG+9Uk]H1DsL.Jq)q>uIuF;eMMcv'7doeg--Yj%7[#t3;n^r8Z.PEVU6DTC&4[FU^t76S+2pIU^tNWa1'W?OY'(7%i#9k*TsjYJc`H,Yc`oED78dUpN%m*#u(#/Wcs]#d<-p7d<-N+)X-EB>x'?&6uQ4qwL0I]8FDt-wn%w-jnI%`WN'/h=AYj67#mSd3LhNCtY-]84=(vMmw'W>FSN[):sNLR&+2(x)/NmJ=0M-o-mL#la^-#^a_84R=[9OULd2N4eIe^lHs(]sL*:sUvYsF99v)?oXkO,3-IMYxJ4RQ&1dOImd2R?-T.(/HjKsZOXq)qBdbrCg'N'h]'Lelu*+72c6Bdj8pqstlJb.XNZ,)FY'dNa+-Z%<F(J6%S/,.s>tWQR1<2q9&UhL-6%Un9>m*Nb?[tLH4^(o$*WIm8W]#mr8]'of-HeM+@4gMDv^hLRvpb%k0alt>sw,rnZ8=>sV&as[2@nn-o#FsceT^s][Dq.qOY^tTib/MoXP3/V4fP'`KQQsE<#YsF[ih#+El$GdWPq)br=+D=luS.-U#XL;P$>UZppBh6fLB)mrJkfV80u-SP7;qJa)rZ=bPgL4=g<tw@&9&7YW%++vQ<-^(WrVUfJ$tLc*ohd5Mx7)5eI8Abj_hf2jUQVI/9&H.p/1?/[U:HRSI>dk[+fZMv7b(F4c2TwDUHIV)<E[4lTsf6Vh)-*9baewP^tcri=-.9ou-K<;#N$Bt:i2V-ntAEc_/^T+D/w^+jL_(Z[0u>>[0&^Y[0Ztp%uHPs:/#Thw]#QSxLs'FcOJ?,1PK?pkOsB$c%;Z:qtO78g$s8jQs),?.QX#D.QguE?TE(]&FUg=,-:2dc]+3.DsSKOj)ASx+/=2R_Eihe$'x:8rIPo=atw61_$kZ_WqAW1r%u7RhKc2qo6jY^tsv*xi)4l:ps2-If$77R2uu&NotTnP$c)qh<dKRo*Mg5eM5)HgnLL8-ZZ:Zt$4h[[Ys^e+Uno%Nq)cr7kYQsIqE@+3mEq^uHI<T[7tsbDRsw`*UM74[qMLVJO84utKi6,-pe3WEh$wsYhZUoSt*Eh@?56`>a3%02^Ot9;NVU^t?IFNO*tf*8L&E?G['cMC')AGYO&=O.(asUmc%dn<7I#^>NuJ9$f1P'Af1:K75%lwDJRAOw,))(22Z4,ZtOq;^27uR<(RPQZpLW.42_t53:?+kNYs:fuCsZBM`s-1HFE#0D-Gv`rbO$L9+&.i.T%:WA4%jJHo^C#9lo6s9>#uj:a%mB'Tn81<uumu(-%4stF`fh?8%@*j'&(oOtLsa>rdbpZS%QkNe$lT,0H;Ud%FPG82'gYc'&HBQfL4u`9L?O3a4.s?b7`)5MhY:Fg*t^<>#w23$vLI&;Y]/W%?PMLV?f=C4k'U<,Zw1`xL9`s[CO?5kOK%Xkl)C.vR':W:v$*G(v$)[)=$2McY,CP:v&07,;^mUj;ncrQN+_JwuNYNf,ap6#Q]iQq2JW7;MPp4_jwhj'/:^X:vkbM*I8.pE#OqYW.SBP:v[sggL3J;k)f5O7/N70'v1$DvLhfphXtoo=Y5Qki%ID5TP-6Z@^4'=g%=Ib-I3r:KoEI8XYEg-_s+g&FsU5c4&2L-&LO&Gf%n9#9u/rck81I3;U:#v^%##mJs#hcq;no?YJH,Rw;LlHkt:+3qttL)d$#UCrb_AFN'=5GPsp5_Me3R5U#a3&4J,M.FM*#mb<(u+2%%V9]/X3rhtx&s6R3J/Op5)rI1+PadtgGqNiO]rS%f_<Gk^,lh'TQNt$1&WDsIqOJp]toI(UJ)Cj)'t$4aIO7$_-Vv)2HZ>GQoqsC;.,sK:j>SoF[D>WO8*bUZEs+SGO$MQecYf%ZsJe8vMkZ0);P`OSrKu#D3in>PWLxBoZ_P>XkvpO2p6YV)Hi0g3lB(HD?VX%xbobeM&prV'o^`S+;onO,0rLG<.nk&n7@Q#CQbWsM0]b;)wQ_<,j&Fs60.pt($xttU:(7@,0A_tGx/=Gv2]4/-LwZs<@r[FCvZRs:nAi5(fZIs=utgLIQ0ogc;RU#Q+uh0)/;vs.3oktCHY.(wA7[%?$tJsLJ4^=99H%d^_uem^S^)j*C/.(XOost_b0hL)'Ka#cWe2;e))gOf]glOb2b=5_Nqn%*[TvO9lXDs^TWDs0DNdtgm]]tMJ;a,eMqTL71D`^Cu`Q#/;N`s$N_v#Xd-T%s`$P&mlgUH0=#x+BV%4AZGn_o)lni%1mFv5HEp:1PNl@9Zo`i%i-a$bV1Ig$j_<e?=7WbtpAYE$-+*hAm,r]t^.tLs`*26l1H?wO#aFTsG;p+VQ2+Fsn4TB^.^gMsBkGeOr-pF;4.L_&].jpt7X$Z$JGDW-3d1Ds0Ue&*$7UIU6;cEBk6BOAs96Xf*Qdb;qTgOA;Xl'/b?YcsEYwq05?J@Xx=)$AoI$`<G`n`Obt5D-#rcW-_iA:;+e<w)*1h*V*^`;^ch-mL]sqdOg^L`tgvim&J;&N'xeHZs]WJR@OlIrkJ-`8$JeOq)mpfpY[,6vjHQ_Rsb,l8O0*u(K<&ntt7@sbOIm*fFn#V^$PxB]WpObX#fiwaO2EENON<63=S@(W;,n9o.Qj(`3GqkH9Bw)Gs4i(h)`KsJF?dav5d7pZs^:RXs=X/rO1r$=Efl3j=O8AN'47n;t@KrCs$>_k)>i>(EZFDr;%.6lO1%tO8Xh.77P1kn7/d(N'V_JGhjmlws#Z:AbuK&Ck'WF7%ZP.=t'dB/%<0^1'3%:1h1'G:tN'J7Reio9ZHME:ZnEvC8qe5lOWn6bOB>]*iC5]*i,oHf$HIGhgKxO:$I3W$uApXtc6&Ct'SUXFM[B@F;@)BF;OE3u#S@i&C^GBd]ck8<^DIcWBexIH`b'(LgfL.C6f$5-_@L]kl[=;0trQ;mt+mgb$1+aWsVrf1jgFn*C[];qkSGLD)Xid_sb:RO&B1ne(^cpPqNQA`trq(3<lAs,)iumh@bmEc%@K_>.CY(Spi%?%^uMmi%0B4J8Y`Cc%D:cPss?qF_Pk=TB*+lc<SVTZ;A`K,f_t?(M4g+nE^eK@OZ$%u^jV#A_aG>sO&qDVE`G`pCTIFc%ZwHkt2DG_sMMvxif&2Ds:):k)wgpujNif$O88%4A6ixoO70s_^#=V:V-kUb%_'cDE&U(pEloe:;j`vaO%s%x++0sktC),nDQY']K9lLxKFXEVM#UQc%.4m`W-&2F[lC_>mei/Esd.XV$Nl21'>AlXQ')N,sqqX/SC_q-$eOpCs`%Jq)B4n`W$ILiZ3<O4Xc-.jXo2#a[o/N7a?+<g%W;7sH%6XnDl0#SEApj3G7KRQF6*S+@Z#L_%);e`W0<NiO>5EnV7HL=TYcgY%M*%_s%6/(*H`fX#OH&4^o[^h9aQast@_=Xsws:i>8m*uPugmJs-FIgtY0x3MovobOcuO^$IsXXsg0)uL/*$N'ga_*7pIavsBbC(EKXBi54BL4AFaAc)a]mb)Y6rxtB,C(E#m5(%;cn+s+#aaOhi:_tmu:_tb1ip.n)AgOlH'L5e+ghLE+.2h6V:7%H;b-_*PP'tMt'dOQu'rQ,:%(3[O%(3c9T/]?3S>-%=vl0&Hx-iCQ<LsT[uot/cJ`tHlto9X,IH`mo#L]fdG$ju:_U$:+8k7,aZS[BtT;N;g#lhX7,U$TJx$F0iw-%YBCdHbT5;%P.,TV5]w-%HW'tV^H5;%Sr>-IO08j)l&S0qO8+4%+$m'&9K#KN#'SUNv_SbM4ijcsd[BHMY?VhL:@xQMID%MN.GF09vYZfr+u19.wc^4&s3kMq$,^oiXiq@-#&sY2BI?EjDgl0^It]-qxxa%t@CPf%/$qktl)GQso>umsH8WGVxOAnO5iD=,<6TWU],Qu#+^w0%dgp8NaD^;d`q-m$vo@/Q`?Q,`8=_@K/>uWL84Dbc:H8vL<](]K>EwA%=3PHQ:xJd;8kt_$.i?6N;0s8@_2=%TuR'dR_A*><^wcERf4'`S%':N'n@Kk]lvc-h]2q_*20EbsUlbeht*d29qEl`OY55-&c,$N'cRqt5@xC')`#F=5_?RVsB';u5ohst5EKc$G8Y=>%RG;)M(wSSs:[bQ#M@A2)>[9tO-,0L^6k/[or[9`s-HC_tro%ptQ4I#Mnx`-IS:gp]GG/+*()0L^(b&g1xkRKs@Ut2$Y6@w)GRo*MeQkw=a:F_No9(%4XmbZ-SnHO=@?,O=iOP$tYg=?-wxRu/F.__ONI:1^=eUd-%hKn<EmAasK;8+MP@ta%7,E6J'ITI:#^u9Qw]=_tf(L^s-:KvbRVpMscdpMsK^#]4s4,FsY(YQscXqjt9IgsL1^)<[)W2F`GDcke_jh5$MoW'sulS@g[do8_[vmdO0]@PC0+9?AhVe-5g6Vv>-9Js^pdM<gv/:^O=OtD_s]JagFSKc%`dH7/@Fk,>)jdx@?;?aOR0.cbs]T+lGvfXqc]qpb$4]__4l>n%5u[GlN8U.bjk@aO__P[L>]gtNFZ&L[Isl29wKvq`q':e`=`5UOGj]-]G[9[V<4)@DJb:]P*X]ts_Hu)Sp&YZL4mFWLgcpoJH['k,b$N$#+)*4T.C2BT4>t#KpV#o*LvK0*8qU[,uUG=P_/.A-)t-A-DQ&;/o,M.).uB`N.`i=-pvaC42Ag58@P[i1U^7asJ+v$,@tDL&t&/lL*m(1N0#J&KtiA$KB1Xcs>UFv-mlOvL0x-tLX_CH-.bpG.Ab=3D;eu+jHK%-jE+w`,iC#Q8INe9D1^w>LfGsM-[A%m-DB@nN;3X$#bS>R*A4CU@f_cXP<4CWL306BSn3HaSbi05T-Gvg,qBnU)j`#ST-G2--6OR$#b%04KuSs#KnbU^Tn&uvL68fAK;n_^siY)D#f:@F4,M5Fsx9%S%:nVR%JAlln2$&X%<a,S%,@Kk1(mt?0Tl:=G*u:=G:0kdpIGF.u-vr20nriVVx]u9Q5SGtllL+%5]EV4%(JdVsMDcF#Dwkr)[_eC3W?RSs4Gs-$XwfC3m#Kf$8Y<GsnO2m0xGI+DOk_]t:5.SsIMHh,'K`-IP.(K#M*<C<XZ3psA@*I-d*u*MIb1dMKN]RR;%t(tBb4Z-kec*.%2]=%,/r?9>@2lO@L&N'vurc@B,5OSHQ:br`3^[>)`wA*gixjKFM[p.b2,^s53]&)V@LXG$HYHjEWlq?P#%u?ERd$C08q>&vLM7IrALn3'5gZLt7alshK&+;ljO8M53BNkv80F`hK6?&WOun[aZRb.TQ;7Qb()TNZIj$#U&Ze?@j.qMjJS8#:[a/)_$)FRrUC:Qvf-mL1FAOt?A8F-[jMqL:Hb.&o#YV)2`JLLk0l]SQ'OaSU+91T?ID8&k5(2'**P6&F_f/hiv[1PX71n&MDO.'+NU`3IHUn#7'(,)7+gr6vK^o@$=;VQ,MCf_hL#Jh`&f=u-$X`<]g^lJYCj(WjVX>#[*8/1x?tr?m@9AO?*cucb2=Yul#uc2V:QSR?6LVd9d.^+_i:&=f%0&ObLCGiO<5a3VE@5]eXJg(7BZ5A$;?,`0e[,;12pP]tEw`jjTo/1ic@sdR=oPo??hg(e*UmAO,PpR,g/T[[t730i]^g:oF,BO]87Wdga;dr[of^+2aPK1npOWH%JMd`@v#?lcrsa*oU*$>8[v#P4MCN^1br,ii,dE32kgW?Oj$L(tnc?,b;K0:cnvaEc(@3Tpr[WdhDTZuM/-b<3knWQc2M?cY1_w,i.rQSF4.k^tt]k'ohSw>9-FtQv:X9eM,&+*/<n3B]GF*siuq*<Eqd'OP6gU%'Ddh:bUOeVO`r<mkkQ=-1nut?5YfkK;f$@u-qjU.pGbR8.Q(xGXPFRf%wO40AaI7ArU<4Tlsge`Xi;@lK=ZW6Q*wfY;V%YKeq]`O$U@u5RIpTs.#Rg$S5oQFuhonhkh0SosK'9-:v71t,Q51u0VC_$gOqh&g^`reUt6o,UcL:E=s4PE?)O+Zh9ZLZwi%-D9[%+--;5HI<C50G4HxuBRs8d$pA[4d@2@m]o;=e,'937XA`l1X-c7JGb=TOGMN6^t-TK5s2%)9f9r)Q&K>T[kr5Kf$whAhE@BI%+Jm77.--><Ef6930tQj=#WLMGs#8'404l'A/cfcUXm6OwB=U>&4,>9`tI9RKst3tDs8F]Xs4-WRs*4?2?7G<EEA`0i#e;]%%@n@:f9@INc1C9as^k@=%(hgstT_I`tHlf@+3XkS&$?A:$@V`n@vD+V$LU'iBp?<Luv;9asaNVIPTotjL(1qSgnDbAunrBehL'cst@/`vYWLq6VlO[aODlbit[2_btCaoPsEAgEsB^^X#K%XQY8iX'aYqnJs([EA%5YI#JJ%$e3f0H]s'FYLitE7C<hv7%g#1B`%*g25'Z:hXkx7;Q&D]s*%JhJ1KkC[vA$+?hO1mHYT7:,_$'j6.Jq_]Dst3OYs7BcnIl80.vPsOXNu45>#W%`Ps#H<4o<uEps#m=Qs'hHf$Ca64vebtab^I:;?g>$gLd)'u,dSlusiR1_%([[P%IZ2Y,DRp'EmV41uSJ8lOhva7%p^X.ubJ]lsXAm92Y']wk$goxt01X,M-3>cO3H9:u[*Mo$o,*U-.8YO/0Z(_tkhSj*@4w<-v23blD,`@4bMY^t$)uDsI`3rt<3&rQ_J7HsggX#%n_Oi]i21V%cLMGs2iYv$NS8jtx?IK:Q,kS&E/6r?ri65oO<StOktmk&b_-Y,U>+sMGQLu$eO/r/G8sitRoedFc5+?/rjEciTkuc*e0Y#79'#WFc^FQ&+2U/uPKn9vt0qN%P+suf[spw40n*f*I;SV%bOH[F.CTuO;BKnnL,qnnDrw-CtM0bO,.`[kBe;[ko/<r6f=*?6aF.Q&89@5(fbvkt+422KkjmZ$8W8_j9vjX#P&@p86g8Qjf8B$JSNnktQw5685x,#uConrO8aglORLFl/pY%ds?(/l$4+'NsoHB3_pNvAkA__4&kp9bt8^]7.g(uIku?')35C0.v.?_a@&c@kT9%+,2B<:>#F'/_%A'1,)P0P:vHQJadrIUWLE;nW%$E+1SE(Dul#fT:vSnj3vcd#egf74c0j/s8@uZM9kRBM7sNPPY#3kf-5Q8EM%^Djqe]QXV-jC%gLr9RH3H0`:m[W7>#ln#6vvaJ>Ahx4^?,^]Ds?9g>'/nnFi[_0.vYY=dDHQ<?kxU'Senf+L5>[OqLat#,2#g5>#hV++vuZtqg/t_vY&;ml/rBo?9Ik)1&gCFrdZGW'8?>=#Y^bkgLt=0`jWk6>#:%0X%M()O)I229,HlR3'GcmE[69i&#T0iwL8wVUSO`*2((C0<M$O%]kcUOrOC`F-59q9uu]eji$h&EmHWNx>-M%Xv10N8>#VBFxueaQ7NvUH%+S)`<-+I]+/kPibhc0a9`bEgKK_r9j%Z&g=#=%xslaU#o%hupo.GI4.vJRA[[u)Ln@mVii08FW:vYwmn%A/Uef0E>V<*J6^tokw,?vY%uOtWIrUYZH^X+3)M+Vtgws'CN.DM0JT&n]H8^C[Kb%*+/pE5G[<?P2QP/]W6>#+-;g%B:M5,h0+bFa>ii:*h0^L(Vjo;j(s)e]nKc%-)i)hKBEcsV.7gL:Vp<;hCK+_MOG6srE6(v/9rU0)$=U&dcL+rE`S:vO^Q^OkheDX2SRfL4x)t.G@1).<TT%M?nCWh2&@'lDqU90^=DQ&<m5Im#9<X('I6(vkYQH/GASHWA-<5&qV`?T_ErvOkO2uDC:57e56%P%X&vi.cU'SexBBuLdfYlpVc*Z-RZ5<-2ZKb%&SK?%4udS%lw_CuAu(?Yi[xOYk'J1F:AH1FX?v1-(MPPjOn<Q&wign*Jf&U%jcS$`iKiR%J6=Q%$@Te>W]8iBF;p1T^cm]k9<[l`5Z'btkMvkt%J8Xsw*6=/cnn)vqW,YBv#&>cc.,Q&f/`c]P;H:5inLj9NndL)U<n;WQL:5PJC1.vASHwbNaI+i4-ST%E%O%vMBBK.[N+k01iIJ12j:>#&G#*v#`b)[(%F-V_2QP/73,G7Lk9d2I]ejO?)78#7gW4o2WS:v#`?['-OG9#*UwRnOI6>#ZhP5veJ.:@UN(%c:5qCa;*Y+@/.6H?qpdpI;M3lOVZ(uOx=#B?0o3fOxj$fO>EsnsgMja*l4=T%#Hee5o4HL0rIPL0oc]7prmN.1QhjI1O>sL/pnjS&-aCr/V8[r/p?g'rR6kbqMJP:v)oqwu#k9Sk3USLu2I8lO(Y2rR:55>#Z)t8v)I[>G>^D,WOQlIq[K9>#gI<q8cEa9DZUoKsg3n],KiwstQO?k%OL<c(0xP<GONb7ePKV:v]L1`%Q3Mn$<*T0PO?reOTi`D?f+D>dK,`&Mqj;GsnBHnX5EJqOL5vXU)hqb%I'm_$2AR2I2Urk&uF9qO*^^@oJJka*s@vb*X1]q.S8Ycl#6'fD%3YU&w0;rOV*R/5M+vC*W'VDH;[%2&Q4uDs`RacmZ3pas/Dl#uD7_RsYv6j4epC$uog?mNm'Kas`*^@'YkO+)KYGg*-=oq./M8o7QQwR8':x;6WCQ10i<R10UaobOS(P:QL]LikI'H7t@`IK:eXl]tQDM^Oo[._OwkH=Y<+kpst8vj$4m^DIi_uHI_m-Q%._d#YiOS4Ym9oLF:MmLFW6m1-6Yl^t<:s-$bRvktso?Ks(wh3=vK2N%e/F/2<Gm;-PgPGI?JdWi7;Gc-d@lXQr%?mSlFE-t2d51ufUC_$DX@`tBwj>o1IEQ^lR+KhS[n+T2[b[R>VM6M]@CxKDR@^KB,fqEXVV(8OARUKj/_%MV=a/RL7Z=Uccs;UU+,pV)WIc%8sB)IwMnSVXvb<V,R[-Ijm;?>fG2:blQgta>_AG>TM]c,QQgdOdO(J:/Y'u#6VgwF?[iOAH@1lOBC.rO+mhRs00TgLd/^qHAOBuLrv[eOODvKp[ue'N[=srt`m]t:*>u&#o5i$O[UM')kQlne0X/Q&'hK[s*W5`,Y&MhIDxs]tM$P^$;,^AfC?IQ&dL8T%JPweO(G4hXW7Xxsmfbi?-T6`8Y7+%pAb>]eVhKl$.RO^:6XpktoUT+)3o6F%]Vfu2HY.NBOWE?]Y-e)aK(MVh9$8gO^$eJ2*CvV%afQ6/]vg4hiX82:cmsAHiUUp7uDM^65.EDF$k_+8?:O^,6#)H>9)4;MYXK$-pY?bT9T7vub<P[;bL*#H(55>#rW'#vqJtV[A'XGOoB@rm2o7>#o+]w*X<Pk9$(f,;QgX+`P&6.v/6]7Bwew]*m=0`j`VP:v*b'(vH6JF(o>t',V`Boe/q8>#Vqi-vjENOC'x#P=,mDa%jU2&X1GL6b*,@HDcuvo;d^lT%d0UefasSvlsxf%-xg$:WBS,5W24FGHaI>LH`DdjB$WWjG>Vt3JDG(mSoC_hOh=-??V`aS&5<1DK?=t]t*:Pf$&W>eZW6J/q*3Ct,XPTGKhVqg%:c,Q&'e+sT$8R.1@ANaOxBe:;r0pCB]H%q_:t6j$`nH7`@*^RsZceCr(=vV%fckcFT]Lg%1'VGVga)<gu;3r`FEPi%N>3pIu5AuB<giIsbwhoA]/G31+^ea$<`cF;e?iVs)#Mvu7/>J-/j'LhD;8:-G<]v&#+XOWQd62:7YtS&Q]@k0)m(UkO4vf_pw'a]Q9Qe2.4x:K5l,jpcRsrtEYjr/aR^T9OL&s(lXD)%8U$m0:wI_Occpo0N#wt,=:1%g'1(Gs]BMvt64;l/e-:sFGg`U0]4-Y#VlGi,uZAF%f-R:vxcN8v5MCs[2NwM/7osOo6lX:vdP%6vs.#<G6JP:vDe#+ve*#uBLF1,'fd4/(ghT:v6+@sO$Y0T*g$[`O?vbi=1fR+iRh;>#DxO2v1/L3hr%<p^iVd`*Fh=>#i(.1vV%4ksR<c$c:(1,)pO9>#)VQm%BZN1C`Y6XfXP#p8>.jGsDPW+)+3b^6xCA('cg5ND5L$k%C>fqC:cFc%u#j]toYvdt7?pE<gn'[,NZK(u]Cw_<uSS_<,YY3n,8>csX6s/QK#mnb=ILTgBZd^$_0,&V0.&S*jZSO&p5A%-Rng$%H:e66FfOR.A&wCsU?<c4Q;K_,K/X^Hm5oDWM[X)S?v0sOwu/a>G<6+FI5hS&.gGa*D3WW%LdGF2O=nS&`#3:Lr>oDWaLo,RxVMmOB*<UNdRl4D6.,>DM45f^ej*3W7uSvldb/Po2SM.0&wZit5@Bx$Vg[ha4Jka*^WNb*gV`T%bT%L]&GxGf9Pu`OY,/+ibng95+K$J:W3XI(,C;1up8Of$5ZWRswEal$ka9xIO$wiO0_]GQP9H_$,mr:N1*YwO8#PuiMOLnsU7pkt.3ka$8?_@1p#5Q&6-tMG^n[XfkSntf+Wg5%h1DK=RF:o.ark-8;4#<6GAL#`cd^RsqxQqtA9>dOPNB`IvP@_$Cv[ZW'''sO+0_.6DEa0E1F/H;Ad6Q&1Kt0ls56aOxrL43K'7.O/h:cJ]2[Qi/?).1;pYYs@FwAku?jI;&PsS&q&@M(8;u55t?a_93nc/d$H7.v6`VVBO;Mj916(.v=da6m8aN9[xFH`EnX2vu[SM&i,xrxFbsuuuG3X)S6wUS_`%;YPINW:vU@11vBK;sP>tZ1>c?3f%]6[Vde3Opi.$J^4IgYFsO<vNsEsYFsrDn*-'-V`G'8FQ&b[V7I'^FIs9QvAkrX@8n;mqia:w[AkDeYX,)F&#Z[J1Q,ZOuDs`23r?iZRVD7E?h%iieNHV%Gc%/(L-%tNxBK2Xb+ATZlIJ:Jqi3pbZiLvDoea,+P]`WgFQ&6?F]_&cVCf>9vI(7-S+@+pMa%sEF;Z&WJ<`a6U=_cW@fOt?mG6Y4%@%-C1xR&6$O_gF2$gY,2uhRNhj%J8;6`r'GQ&w6?O%d+Kwt04^[kTx/7I=VbXYK$`RsIPja*&@7.Mds[1*'SjbP(_fDa#Kn7Y@_5^t5s27IXncftI)S,5dYaDFE8-f;'14^c'Pf.-l*7C/lX-^OWwla6]oJq,(1vfhG0n#7a`e&-^x9HMn+CL9H[atX`bJ7&P1uDsfMW]sQ.Ph2k+m%-JTmpLQaV,Vd8N(TH@1pO[=p$/nj.T%C`bgtr,_Dh]+<5&Z8R:vx1nj%$Re6g%X7>#vNN-%toXU$VeNoRqsX:vOJG$vu7##M5*A2P=9hhO%eO@SPTD`$@5A$MF<BgL-#LM%v>kT&q<=5p[sR_Or]h6pRi^7.PH+7Is%>o.+<iC*;WiS%9)7hKR&CQ&v84v8@f)bOb(F*nIV?@b_3I[a>ZA1lP.RtS[dCZ[Hd6GaKB@d,d<&<-d6't+j'px*&(hS9#I/s7tv8<-KST5<l$NvuUJ9p;#mul9&h;@]W0/]&m@SkYJ11`KY#WGRN,_XV:wv3W>ZDJFpAP^%J-aC[)tIIGYe]`OIIU2Xj-pJG1.ba%D$4&XPd4@UGbHIRUD,f%Xp`=Djf3FJnNnuH3]HQN53gkOp<$c%?dvU6h8xWs$8Q.QX#;iP9-#H2+qmc%NBbAu),$os;UU_$BALW$)4k#Kkk%<-/(Y_$adU^T.I;BT+G;--/,>>#/:jl&J_>w-O_ZY#'5>>#,-o-$k&:MTnVPiT[]f--<F-L,G)###GkcA#;X((&]4Vf:)Hxu#Ner*>jP0$Jv$WY,)>MMFOk;;$@Xlxu4O:&OWO$##dB_O;PjlB=GJMe$H&>uuQoRfL-nR`Ec0S.#1g2E-DwchL_R6##08P>#8&krL^UQ>#gNb&#<EFV.v*^*#TfuG-bLuG-.@1pMIKH##8r)XCGh?_#%m>PE`QdOEfrFG)P,a&#R?3L#O`qr$_rBX:pv;A+ZCtr6[mMAO:TZq)OAYQ'2),##%ILpL$980#9`($#Uww%#?c)b20^Q(#HPj)#aC,+#0mRd#:Hg;-6TGs-T0uoLqV54ML3_xX8hD>#?@7Ac._X]YLH^Ve7I]-?t1LS.G=vJ2'(i9;GuIY>+.glAGE6R*.L@VQ'=)w$+kZ4].dG_&>R.AF[a?>QY?<p&Ia;@-v#'/18`nx4PE`l8FNh+M^G;pLGPP,M3xGf_xOO&#XmG<-f0#dMB+73#5),##`;)=-&Ig;-_N,W-vAY_&)h;L,#C*1#rlRfLM?+jLQptjLJVNmLVC#OMO%,gNMQKvLg4$##(Gg;-v@g;-C_Xv-ZGLpL,`d##P3hp&<,058XoB>#A1<JUB_cxu-.:B#P+/5#w@g;-v5)=-*@xu-b4YwLb'e##@oA*#r-DG#[LY&84c?>Q85+^#@lF^#rDfnL?(='Mn,?>:N;PlSgwA`W)^3S[AC%G`Y)m:dre^.h4KOxkL1Aloem2`s'ML;$?-5/(Wi&#,pNnl/25``3JqPS7cVBG;%=4;?=#&/CU_mxFnD_lJ0+P`NHgASRaL3GV#3%;Z;ol._ST^xbl:Olf.w@`jF]2Sn_B$Grwx=##9X&m&Q>n`*j$`S.,aPG2DFB;6+.BB,$,>>#jJ^e$,7ae$tb`e$BvTe$NWRNOQB?1OcR9MBp@7#6.rbxu%C]`X>HIAGg/x34#Qd.O:,b]+2po`=RQaJ2_kdumX2YD4@Yw],:1P&#MR-iM1_IIM]1ZDO5eWUM=QrhLfCH>#NvX?-A)`5/lb[%#3^M:MG=JcV-XrS&T5/FIU20xtQe./1xOO&#r#1LMl,$Yuck->m#YkA#gSYdMdH'9v*),##ta`=-LIg;-OHg;-T`.u-JD@bM=W@IM`I^VMJuBKM5L4RM(RcGMX%9)vt2G>#Y&uoLP?7I-9(>G-<0A>-kRx>-:Gg;-X&r@-@R[Q/sU4A+5h4/()lkA#GHg;-?Gg;-Rx_5/:L7%#N8^kLHhJ(#g.`$#>2<)#w[&*#2`R%#pnl+#F$),#RqB'#O<#s-gviuLx[7(#b<#s-)P1xL$iI(#.OYS.(a39#dN^Y%lYd7nf)>5&iG2>5sQRP/Ik587K_KV6YmIM9nHclArD*58L0(XL&8JA4L9%298;;)3lW@>#fpWoR?/.k0nYfYP;>LG`k^r:Q)ld^%du]a#ihub#+[7d#CNOe#[Ahf#t4*h#6(Bi#NqYj#gdrk#)W4m#AJLn#Y=eo#r0'q#4$?r#LmVs#e`ot#(V1v#?FIw#W9bx#p,$$$ZO?k%ef,s6cJtf:%1fY>=mVMBURHAFn8:5J0u+)NHZsrQa@efU#'VYY;cGM^SH9Abl.+5f.kr(jFPdrm_6UfqwrFYu9LW5&Q2I)*jn:s-,T,g1D:tY5]veM9u[VA=7BH5AO(:)Ehd+sHOMB>#Y]Xl]19kM(:$2)F^`6#6CusY-Iv&vH@CP&#RmG<-f8uZ-3&Z_&ufce$>nae$I6Xe$]El`MYU?LM6Q7IM=&xIMvxuOMRO6LM_DZ`MXtmLMEfp(OQTU1p^,F>#aht4ff3d>$)lkA#5nG<-7_`=-pnG<-?lG<-DjG<-#Jg;-S``=-CF:@--Gg;-@Gg;-3Gg;-#E:@-<Ig;-c[Gs-K0IqL(55GMc8H`MoD*UMi])aMj1jaMbVv`M:r*%$<.:w-nGAvLL-b^M;LXJM[>wTM&B=-$)m@u-<jErLIp?TM[]8)$IXuk-Ub4R*Bj4u#K$)t-eV0%M-7mWMn@GGM71x.M$2b]+Qh9R*LXGR*Bm>MTXpsJ2nN+:2AqNe$+MOR*X=Wk=Zk/:2>`NX(@dHX(0k6&G8o;s@16d-6.aU_&UB@L,wDFDE:[Qv$ieI_&^7KR*3qo(aNr:5KMw1FI(OX_&bqp-6%u5qrBHY_&8)V_&UY/WSl=B>,Ol:<-_nG<-&kSO&bN%dMVodLM2xDi-:n&FIg/VX(RTbe$lJce$svHR*'nDXC%Z5LG%w]e$G&RX(=?h4o2ueD+lid9i@AV_&xm]e$Td8F.oTfe$/4TX(`IW_&qjw(b@h9/D/kR5'w,^oo45vqrp5t1^$)>uuY%?8JDgYiqaJL,b;peIM(3eTM#:Mf#t`nI-YlG<-[Sx>-cH>k-fuXw9.(3X_kiKdF@OE?Qiq18.m3io.qKIP/ud*20#'bi0'?BJ1+W#,2/pYc25>V`39V7A4^I47oT0t`sSc/*#WoA*#[%T*#`1g*#hI5+#lUG+#pbY+#tnl+#x$),#&1;,#*=M,#.I`,#+G31#4fa1#HLg2#Qe53#`9v3#l^V4#u&/5#8j=6#C>(7#Tih7#eb39#$C0:#GBZ;#wnC?#VjBB#*ddC#O]/E#UoJE#Y%^E#wsRH#of?K#u>]P#1^4Q#6jFQ#;&cQ#J]_R#Vu-S#_7RS#gOwS#mhET#u$bT##1tT#,UTU#=0HV#EHmV#KT)W#Oa;W#W/sW#%>lu#LX[[##3$_#?2N`#*Irc#Nake#5l&i#fQVk#9)(3$W/5##TE<L#^$###+5T;-T5T;-Z5T;-a5T;-g5T;-m5T;-s5T;-#6T;-)6T;-/6T;-56T;-;6T;-GmL5/M*,##&?5od1I]l#EIU/#5+M$#'I5+#cK;4#%?S5#=2l6#U%.8#nnE9#0b^:#HTv;#aG8=#$>P>#;.i?#Sw*A#ljBB#.^ZC#FPsD#_C5F#w6MG#9*fH#Qs'J#jf?K#,YWL#DLpM#]?2O#u2JP#7&cQ#Oo$S#hb<T#*UTU#BHmV#Z;/X#t7cu#5x_Z#Mkw[#f^9^#(QQ_#@Dj`#X7,b#q*Dc#3t[d#43G>#l7?f:B.B;Is*/X-0=OX(4RNq06'0[:<WlA#GQx>-SGg;-C_uH&BJ7@-]cA4(^#Ok2w$deuw4G>#IbKe$6Wu>-05Cw-c)kZM-Jo12px%44g<fe$B)2Z-v64X8DY>eu`4bZ%82#P]C=)R:_GYL:5ts$6vR'583@#&+xE'8@#Lc(NPdS,37E8L#grLlSRv4d3Fs8L#wKu@XT2lD4`i9L#Y#Alf-@tx4GYd7nOVnIqfUs?6:UWP&2985/5(,87ZO`S%3`8E#XxJ*#ssRH#v(gE#n]$0#a>2O#cDGb#=vm(#Pv;%$&kXS2(8P>#KOg2#hiGN#l6>##tc&V-<5T;-B5T;-H5T;-D&&(')W$@'$Y,i$3@hr6/5WlA5(rr$EWCG)tuCT.&5YY#H#Su--?)UMBEUSMi*ZWMh$QWM8Y1%M[*w>#1YWL#7lsL#ibDuL_n)?#Y1QtL_JntL:/1M#?cS(9jR^'fxhH_2tFtN.&)PX1Q87mgb&sK#,$8>-W+5t6ICaD#2'q^#G#=]#*<=e#O'%w#7sI-#FuTB#&BnqL$Ji^#aT7d#cHjD#SJ-X.@qm(##1r5/FYe[#j2TkL$A2pLnMpnL_H<mLCPFjLh5,0Nd6wlL_0nlLVtmLM3MN>.bTXc2#/SGE;9N%$Dp:PoRV_]=FtZ`EGe38I#*CYc8mG,*/3kM(1G^f`^i@6gwj`=ui<s1T-/<5AfN/sntCqc;mwl%loo.Dt^tb#-P_Quut,8)=r9Y59*]/kXTF,>Y%nPPAY.NSf3`SGEOT&g2a%@'54[di9,<DMBb;,F%C1Jrmp?Ww0*s';QZpo=lw&ti0Uau9)RY-F%+13v#Tf6>>wCV_&YIv.:='UY5;v^:mH^K_&;S(/:Va[i9pGk-$Ndsjte3w.:EklA#%ch51w[ZC#NYe[#tLsD#r#iH-;S]F-G7T;-a<eM0A%3D##7$C#`87#M6?VhL2ZrB#4####xI?C#JM#D/?JPb#%1(pL?BL*#jp1c#t<fnLpAb%$u33U-qgI>/*)q^#9-vlL<=O`#>bEJ/D6ND#:'niLt$dI#2BaD#`vIj1D:gi#oU8a#L)gE#v/(pL$m&-#GMWU-3,Tv.G`v(3SFm-$:1x(3:L5Q9-#65&;@?$$HGI[#)-N`#bee+%)cb&#YUXgL:0C*#D2`*M9;99$*pJ)8x%/Dtdjh.$9Vi.U0Fi9.pPYb#XT&g2^iiE+xg[P/NKo=l5([/$O;TkL1MR;#[w*4P-%.]kUV5]k8l-F%Z[r-$2;.m&<1#KNYh?lL5lP8.GT6g#?j0N(Cv7AO+43YlrHM21VC9F%SfTwK1sLG%n:kA#psDH%f%3>>+W>G2NN/g2SjK,*-.C#$W`pf`k&Qk49M@H%4.Vw9QI4onkTZY,Nacf(Wcc=l*X05gj):MqZLL]lk2Uiq[Uhxl8oYcaB%>Y[k_CJ:KP'/:%&2>>P]RY5hC:uu;v^:mk,_w'@UA-m:c$,;T]FM9iwTk+/:4>>k0C2:DqcF%&KLpLXpn;#1_P+#?_A(M0(g%#&G;T.6(q^#k)/>-+QYO-S#xrPq`#vG6'-,M.^8)=QXtfDvPIF%V-ZcM9bk`#FZZC#d]hqS24f(#CP=.#%sLG%?tw+;u1fr6In?W-W9q&H'Nlc2c>A,M4D*#5(F/VmIASG%Tc/;6AcEJ/v^DW#Q#=cM^h?lLiV05#;:=&#m,,>#U%`xLV-<$#aHmtLChn&Mtk9=#4#l.#d'=$Mu1N*M5phx$Hs=:vNk,7v'3/HXNZ2v#cfUW&+SMpL?$F8v@e#7vPZ6B8H,GRE`Dx-#hM-(#5;4%8W,d&6biE?%<+L,M+Z4C.H]jr6^Y6#6`#wuQ0=9/Dd_F59O<@60s)LV?Znl=P:CR]c?p&vH*]@5B;Ke]G<T*#H>hjud7'MDF#t5;[i7-/VNLjfMx0Q`k3ls-$/^tF.3`98Sf(7#6:4*F76X2ZHJ:CM99<^p.;kC?#@8TppF=(x2wv4>>e-pLphC:uu];DG)7*Mk+U695&(60F%VOr-$lk')*#(3F%,0v9)3pP`<<k/>>=3IDkdeIk=gj_7#ZBM,#[p^w0e5Ok41]JG))?1R3-MxW/?(i%MrV>&#sL_/#k]5lLfE`x.kO)/1t/G_&d]Sk+/5DJ1]s0>>MfH_&Q*95&lP,F%vt$REE)XY,5tJ_&@2hl/,#55/:/?G2BjIP8hXt^f/Coo%X3=G2'T88.N?jl/QNu9)vRkA#VO#<-,vgK-YN#<-.#jE-vKx>-_4`T.C4#F#Eq8Z.a?.@#b%jE-?gG<-sG*b.[(gE#)vqh.j<G'$_2_W.>FI[#LA;=-A[lS.cGt]#aO#<-'8v5M7K5s-'C$.MM*BO2vR?(#=.3)#7eg:#;H;8$sJWU-.u&$.&:$IM@ReuL1fWM0HTvGEbCgY,+1(Ft;Vi`3_nOPA'a3`s'Of7nLa=R<Q=KG)w?wr$p(`c2Pu08.[Iw(3oa*sI&<BSo:$`Gj7:I8%IjL5gej?877h?'-SC_kL_]8+Mm_#<-NSG-M)+B-#,@De0@=ic#-+^*#Osk4M-s$Ak*]M_&1;_68FSRK<.@Z=M(UlDNI&$-.YkS(M@i5xNg8Za&Ku0FnM)XY,bBvu,Ik')*D5)dtB[P)NU4dJ(3:-#HpqtcEP<Im0KB729S1VG%Fw(B#*o%S8da(5g7O#kk(<PF%O)hp.i>JxtG/2x'f^oc;[%Nv6Nh[F%)8d39H7t#-'?9/1E,L?7h4k?%'YkxuK3`6(56A*N88m9%tG8'-<:OO'_SX*vCWR_8CZqK*[5n+#fw>7v#n?'(YRS32-0,]#xl=u#^02'#O;q'#O#eiLl)9nLuQ489j7XWSDe`=-f2T>-X2C59l5Y?.@.s+VW*XC&sm`(;Be(G%@<&=#eNd;#,.;T.q####s[lS.w6YY#qX`=-<fG<-<7T;-BJCAO4i8;6Z7<;?egGk47ZwE7#Vb&#p+aFN:X-29siK.$#_Z]+][rS%Lur4#gNe8#;?h'#'VM4#9-2,#U'x%#s2B2#ia''#tg0'#s_$0#<)ffLmP&+M+:(2#rS*rLR=6>#?@_hLefC%M%OQ6#+a*9#n7`$#0U+oL+tZ+#J.;T.sP/a#ULx>-hr.>-2ju8.cHjD#mPaB#o[lb#um;%$&cP[.B_''#v[b?/A0Uf#_bqpL6_ORMQj#6#$]s-$-D32'l9SP&(Nhr?[q$##;bOiK>QO`<L.@mKU=0DN=M?v?.*Y-?K%N]=p)=kFqbOfLn_ojCk3)]t)fQ`<_%w>6H?v.C$_'^YsPh`3$^=*=tW$&O;_9AX<c9At-,1eg"
