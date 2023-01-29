script_name('GAdmin')
script_version("1.0")

local mem = require('memory')
local encoding = require 'encoding'
local imgui = require 'mimgui'
local wm = require("windows.message")
local vkeys = require("vkeys")
local rkeys = require 'gadmin/rkeys_modif'
local samp = require 'lib.samp.events'
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local cjson = require "cjson"

encoding.default = 'cp1251'
local u8 = encoding.UTF8

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
        chats = {

        },
        hotkeys = {
            gadm = {77},
            acceptForm = {73},
            spectateCursor = {66},
            specReload = {85}
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
        gg_msg = "Приятной игры!",
        adm_pass = "",
        game_pass = "",
        car_spec = false,
        autoEnter = false,
        aloginOnEnter = false
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
cfg = get_config()
alogin = false
sendFormCommand = ""
checkSendFormCommand = false
local players_platform = {}
local _showSpectateCursor = true
local popupId, popupNickname = 0, ""
local selectedTab = 1
local changeTheme = {}
-- для информации в спеке --
local in_sp = false
changePosition = -1
checking_stats = false
last_checking_stats = 0
last_speed_check = 0
spectate_id = -1
info_about = -1
spec_textdraw = -1
player_data = {}
intWindows = {"actionFrame", "playerStatsFrame", "playersNearby"}
infoMode = tonumber(cfg.windowsSettings.playerStatsFrame.mode)
infoData = {
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
sizeX, sizeY = getScreenResolution()
session_online = 0
short_cmds = {
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
local show_online_menu = new.bool(true)
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
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(width / 2 - calc.x / 2)
    imgui.Text(text)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()

    font_12 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).."\\trebucbd.ttf", 17.0, nil, glyph_ranges)
    font_15 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).."\\trebucbd.ttf", 20.0, nil, glyph_ranges)
    font_20 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).."\\trebucbd.ttf", 25.0, nil, glyph_ranges)

    imgui.GetIO().IniFilename = nil
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

local playersNearbyFrame = imgui.OnFrame(
    function() return playersNearby[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.playersNearby.x, cfg.windowsPosition.playersNearby.y))
        imgui.SetNextWindowSize(imgui.ImVec2(250, 287))

        imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.07, 0.07, 0.07, cfg.windowsSettings.playersNearby.alpha))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.07, 0.07, 0.07, 0.30))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.07, 0.07, 0.07, cfg.windowsSettings.playersNearby.alpha))

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

        imgui.PopStyleVar()
        imgui.PopStyleColor(3)
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
                imgui.Text("Форма от "..formStarter.." | Выполнить форму - клавиша \""..string.char(cfg.hotkeys.acceptForm[1]).."\"")
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
        if imgui.Checkbox("Информация о машинах в спеке", car_spec) then
            cfg.car_spec = car_spec[0]
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
        -- imgui.SetNextWindowSizeX
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

        local adminPanelSize = 37 * #cfg.specAdminPanel.items + 7
        local sortedTable = sortedTableByPosition()


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
            {"ImVec4", "ButtonActive", change = hexToImVec4("444751"), reset = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)}
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
        imgui.PushFont(font_20)
            imgui.Begin("specAdminPanel", specAdminPanel, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
                for k, v in pairs(cfg.specAdminPanel.items) do
                    imgui.BeginGroup()
                    math.randomseed(os.clock())
                        imgui.PushStyleColor(imgui.Col.Button, hexToImVec4(k == selectedButton and "303238" or "444751"))
                        imgui.PushStyleColor(imgui.Col.ButtonHovered, hexToImVec4(k == selectedButton and "444751" or "303238"))
                        imgui.PushStyleColor(imgui.Col.ButtonActive, hexToImVec4(k == selectedButton and "303238" or "444751"))
                            imgui.Button("##"..v.name..math.random(1, 1000000), imgui.ImVec2(186, 30))
                        imgui.PopStyleColor(2)

                        imgui.SameLine(imgui.GetCursorPos().x + 93 - imgui.CalcTextSize(v.name).x / 2 - 5)
                        imgui.BeginGroup()
                            imgui.SetCursorPosY(imgui.GetCursorPos().y - imgui.CalcTextSize(v.name).y / 10)
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

local _newMainFrame = imgui.OnFrame(
    function() return newMainFrame[0] end,
    function(self)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(800, 450))

        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local nickname = sampGetPlayerNickname(id)

        local newMainFrameChange = {
            {"ImVec2", "WindowPadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "FramePadding", change = {0, 0}, reset = {5, 5}},
            {"ImVec2", "ItemSpacing", change = {0, 0}, reset = {5, 5}},
            {"Int", "ChildRounding", change = 0, reset = 5},
            {"Int", "FrameBorderSize", change = 0, reset = 1},
            {"Int", "ChildBorderSize", change = 0, reset = 1},
            {"Int", "WindowRounding", change = 0, reset = 5},
            {"Int", "WindowBorderSize", change = 0, reset = 1},
            {"ImVec4", "ChildBg", change = hexToImVec4("21242A"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "WindowBg", change = hexToImVec4("171C20"), reset = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)},
            {"ImVec4", "FrameBg", change = hexToImVec4("444751"), reset = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)}
        }

        changeTheme:applySettings(newMainFrameChange)
        imgui.PushFont(font_12)

        local button = function(text, ImVec2_size, ImVec2_position, mode, font, alignX, alignY)
            local alignX = alignX or 0.5
            local alignY = alignY or 0.5
            click = false

            local _font = {
                ["font_12"] = font_12,
                ["font_15"] = font_15,
                ["font_20"] = font_20
            }

            local colors = {
                ["active"] = {"007EEA", "004C8D", "004C8D"},
                ["default"] = {"444751", "303238", "444751"}
            }

            imgui.BeginGroup()
                imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(alignX, alignY))
                imgui.PushFont(_font[font])

                imgui.PushStyleColor(imgui.Col.Button, hexToImVec4(colors[mode][1]))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, hexToImVec4(colors[mode][2]))
                imgui.PushStyleColor(imgui.Col.ButtonActive, hexToImVec4(colors[mode][3]))

                imgui.SetCursorPos(ImVec2_position)
                imgui.Button(text, ImVec2_size)
                click = imgui.IsItemClicked()

                imgui.PopStyleColor(2)
                imgui.PopFont()
                imgui.PopStyleVar()
            imgui.EndGroup()

            return click
        end

        local navbarLeftButton = function(text, ImVec2_size --[[ active ]], ImVec2_position --[[ active ]], i)
            mode = selectedTab == i and 1 or 2
            click = false

            local navbarColors = {
                {"007EEA", "004C8D", "004C8D"},
                {"21242A", "007EEA", "004C8D"}
            }

            imgui.PushStyleColor(imgui.Col.Button, hexToImVec4(navbarColors[mode][1]))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, hexToImVec4(navbarColors[mode][2]))
            imgui.PushStyleColor(imgui.Col.ButtonActive, hexToImVec4(navbarColors[mode][3]))
                imgui.SetCursorPos(ImVec2_position)
                if imgui.Button(text, ImVec2_size) then selectedTab = i end
                click = imgui.IsItemClicked()
            imgui.PopStyleColor(2)

            return click
        end

        --[[ Tables ]]--
        local changeSelectedTabButtons = {
            --[1]: string = text,
            -- [2]: integer = ImVec2_position,

            {"Главная", imgui.ImVec2(15, 11)},
            {"Быстрые клавиши", imgui.ImVec2(15, 49)},
            {"Дополнительные окна", imgui.ImVec2(15, 84)},
            {"Цвета ImGui", imgui.ImVec2(15, 118)}
        }

        --[[ Frame ]]--

        imgui.Begin("newMainFrame", newMainFrame, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
            imgui.BeginChild("topNavbar", imgui.ImVec2(0, 50), true)
                imgui.BeginGroup()  -- Title
                    imgui.PushFont(font_20)
                        imgui.SetCursorPos(imgui.ImVec2(53.31, 13))
                        imgui.Text("GAdmin")
                    imgui.PopFont()
                    imgui.SameLine()
                    imgui.SetCursorPos(imgui.ImVec2(137, 20))
                    imgui.TextColored(hexToImVec4("444751"), "v"..thisScript().version)
                imgui.EndGroup()

                imgui.BeginGroup() -- topNavbar buttons
                    button("", imgui.ImVec2(114.29, 22), imgui.ImVec2(199.43, 15), "default", "font_12")
                    button("", imgui.ImVec2(114.29, 22), imgui.ImVec2(338.86, 15), "default", "font_12")
                    button("", imgui.ImVec2(114.29, 22), imgui.ImVec2(478.29, 15), "default", "font_12")
                imgui.EndGroup()

                button("INFO", imgui.ImVec2(70, 30), imgui.ImVec2(681, 10), "default", "font_15", 0.54, 0.4)
                if button("x", imgui.ImVec2(30, 30), imgui.ImVec2(760, 10), "default", "font_20", 0.55, 0.06) then
                    newMainFrame[0] = false
                end
            imgui.EndChild()

            imgui.BeginChild("leftNavbar", imgui.ImVec2(200, 0), true)
                for i, v in ipairs(changeSelectedTabButtons) do
                    navbarLeftButton(v[1], imgui.ImVec2(173.33, 29), v[2], i)
                end
            imgui.EndChild()
            imgui.SameLine()

            imgui.BeginGroup() -- Content frame
                imgui.GetStyle().ChildRounding = 5

                if selectedTab == 1 then
                    imgui.SetCursorPos(imgui.ImVec2(220, 75))
                    imgui.BeginChild("passwordFrame", imgui.ImVec2(275, 161), true)
                    imgui.PushItemWidth(245)
                        imgui.SetCursorPos(imgui.ImVec2(15, 14))
                        imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(5, 5))
                            if imgui.InputText("##playerPasswordInput", game_pass, ffi.sizeof(game_pass)) then
                                cfg.game_pass = str(game_pass)
                                save_config()
                            elseif string.len(ffi.string(game_pass)) == 0 then
                                imgui.SetCursorPos(imgui.ImVec2(73, 17))
                                imgui.Text("Пароль от аккаунта")
                            end

                            imgui.SetCursorPos(imgui.ImVec2(15, 51))
                            if imgui.InputText("##adminPasswordInput", adm_pass, ffi.sizeof(adm_pass)) then
                                cfg.adm_pass = str(adm_pass)
                                save_config()
                            elseif string.len(ffi.string(adm_pass)) == 0 then
                                imgui.SetCursorPos(imgui.ImVec2(74, 55))
                                imgui.Text("Пароль от админки")
                            end
                        imgui.PopStyleVar()
                    imgui.PopItemWidth()
                    imgui.PushStyleVarVec2(imgui.StyleVar.FramePadding, imgui.ImVec2(5, 5))
                        imgui.SetCursorPos(imgui.ImVec2(15, 88))
                        if imgui.Checkbox(" Вводить /alogin при входе", aloginOnEnter) then
                            cfg.aloginOnEnter = aloginOnEnter[0]
                            save_config()
                        end

                        imgui.SetCursorPos(imgui.ImVec2(15, 124))
                        if imgui.Checkbox(" Автоматический вход", autologin) then
                            cfg.autoEnter = autologin[0]
                            save_config()
                        end
                    imgui.PopStyleVar()
                    imgui.EndChild()
                    imgui.SetCursorPos(imgui.ImVec2(520, 75))
                    imgui.BeginChild("onlineAndLogoutFrame", imgui.ImVec2(247, 119), true)
                    local full_online = string.format("%02d:%02d:%02d", cfg.online.total / 3600,cfg.online.total / 60 % 60, cfg.online.total % 60)
                    local temp_online = string.format("%02d:%02d:%02d", session_online / 3600, session_online / 60 % 60, session_online % 60)

                        imgui.PushFont(font_15)
                            imgui.SetCursorPos(imgui.ImVec2(247 / 2 - imgui.CalcTextSize(nickname.."["..id.."]").x / 2, 9))
                            imgui.Text(nickname.."["..id.."]")
                        imgui.PopFont()
                        imgui.SetCursorPos(imgui.ImVec2(16, 38))
                        imgui.Text(("Общий онлайн           %s\nОнлайн за сессию      %s"):format(full_online, temp_online)) -- :)
                        if button("Выйти из админки", imgui.ImVec2(227, 19), imgui.ImVec2(10, 90), "active") then
                            sampSendChat("/alogout")
                        end
                    imgui.EndChild()
                    imgui.SetCursorPos(imgui.ImVec2(220, 261))
                    imgui.BeginChild("someFrame1", imgui.ImVec2(275, 160), true)

                    imgui.EndChild()
                    imgui.SetCursorPos(imgui.ImVec2(520, 219))
                    imgui.BeginChild("someFrame2", imgui.ImVec2(247, 202), true)

                    imgui.EndChild()
                elseif selectedTab == 2 then
                    -- Some code 
                end
            imgui.EndGroup()
        imgui.End()

        imgui.PopFont()
        changeTheme:resetDefault(newMainFrameChange)
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
        sampAddChatMessage("Настройки сохранены", -1)
        showCursor(false, false)
        displayHud(true)
        displayRadar(true)
        consumeWindowMessage(true, false)

        changePosition = -1
        show_action_menu[0], show_info_menu[0], playersNearby[0] = false, false, false
        show_main_menu[0] = true
    elseif msg == wm.WM_RBUTTONUP and changePosition ~= -1 then
        sampAddChatMessage("Отменено", -1)
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
    openMainMenu =      rkeys.registerHotKey(cfg.hotkeys.gadm, 1, gadm_cmd)
    showCursorInSpec =  rkeys.registerHotKey(cfg.hotkeys.spectateCursor, 2, changeSpecCursorMode)
    acceptForm =        rkeys.registerHotKey(cfg.hotkeys.acceptForm, 1, sendFormCommand)
    _specReload =        rkeys.registerHotKey(cfg.hotkeys.specReload, 1, specReload)


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

        if cfg.specAdminPanel.show then specAdminPanel[0] = show_info_menu[0] end
        show_action_menu[0] = show_info_menu[0]
        if cfg.windowsSettings.playersNearby.use then playersNearby[0] = show_info_menu[0] end

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

        -- if cfg.aloginOnEnter and string.len(cfg.adm_pass) ~= 0 then
        --     local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)

        --     if result and sampGetPlayerScore(id) == 1 then
        --         sampSendChat("/alogin")
        --         break
        --     end
        -- end
    end
end


function samp.onUnoccupiedSync(id, data)
    players_platform[id] = "PC"
end

function samp.onPlayerSync(id, data)
    if data.keysData == 160 then
        players_platform[id] = "PC"
    end
    if data.specialAction ~= 0 and data.specialAction ~= 1 then
        players_platform[id] = "PC"
    end
    if data.leftRightKeys ~= nil then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            players_platform[id] = "Mobile"
        else
            if players_platform[id] ~= "Mobile" then
                players_platform[id] = "PC"
            end
        end
    end
    if data.upDownKeys ~= nil then
        if data.upDownKeys ~= 128 and data.upDownKeys ~= 65408 then
            players_platform[id] = "Mobile"
        else
            if players_platform[id] ~= "Mobile" then
                players_platform[id] = "PC"
            end
        end
    end
end

function samp.onVehicleSync(id, vehid, data)
    if data.leftRightKeys ~= 0 then
        if data.leftRightKeys ~= 128 and data.leftRightKeys ~= 65408 then
            players_platform[id] = "Mobile"
        end
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

function sendFormCommand()
    if not isCursorActive() and admin_form_menu[0] then
        if formCommand:find("pk %d+") then
            pk_cmd_id = formCommand:match("pk (%d+)")
            sampSendChat("/jail "..pk_cmd_id.." 20 PK`ed // "..formStarter)
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

function hexToImVec4(hex, aplha)
    alpha = alpa or 1.00
    return imgui.ImVec4(
        tonumber("0x"..hex:sub(1,2)) / 255, tonumber("0x"..hex:sub(3,4)) / 255, tonumber("0x"..hex:sub(5,6)) / 255, alpha
    )
end

-- Debug console commands

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
    colors[color.Separator]              = ImVec4(0.12, 0.12, 0.12, 1.00)
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