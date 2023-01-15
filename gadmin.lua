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
        gg_msg = "Приятной игры!",
        adm_pass = "",
        game_pass = "",
        car_spec = false

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

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(width / 2 - calc.x / 2)
    imgui.Text(text)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()

    -- newMainFrame:
    font_12 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(Exo2Font_Regular, 17.0, nil, glyph_ranges)
    font_15 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(Exo2Font_Regular, 20.0, nil, glyph_ranges)
    font_20 = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(Exo2Font_Regular, 25.0, nil, glyph_ranges)

    imgui.GetIO().IniFilename = nil
    imgui.Theme()
end)

function setChatInputEnabledWithText(text)
    sampSetChatInputEnabled(true)
    sampSetChatInputText(text)
end

--[[ buttonsPlaceholder[2] : function ]]--

local actionMenuSpawn       = function() sampSendChat("/spawn "..info_about) end
local actionMenuGetip       = function() end
local actionMenuSlap        = function() sampSendChat("/slap "..info_about) end
local actionMenuGiveHp      = function() setChatInputEnabledWithText("/sethp "..info_about.." ") end
local actionMenuRessurect   = function() sampSendChat("/aheal "..info_about) end
local actionMenuKill        = function() sampSendChat("/sethp "..info_about.." 0") end

local actionMenuAsk         = function() sampSendChat("/ans "..info_about.." Вы тут? Ответ в /b") end
local actionMenuFrisk       = function() sampSendMenuSelectRow(5) end
local actionMenuBack        = function() end
local actionMenuGetbuycar   = function() setChatInputEnabledWithText("/getbuycar ") end
local actionMenuRepair      = function() setChatInputEnabledWithText("/vrepair ") end
local actionMenuStats       = function() sampSendChat("/stats "..info_about) end
local actionMenuPame        = function() sampSendChat("/pame "..info_about) end
local actionMenuSwitch      = function() sampSendMenuSelectRow(1) end

local buttonsPlaceholder = {
    {   -- First line
        {"SPAWN", actionMenuSpawn},
        {"GETIP", actionMenuGetip},
        {"SLAP", actionMenuSlap},
        {"GIVE HP", actionMenuGiveHp},
        {"RESSURECT", actionMenuRessurect},
        {"KILL", actionMenuKill},
        {"PAME", actionMenuPame}

    },

    {   -- Second line
        {"*Вы тут?*", actionMenuAsk},
        {"AFRISK", actionMenuFrisk},
        {"КВЕНТА", actionMenuBack},
        {"GETBUYCAR", actionMenuGetbuycar},
        {"REPAIR", actionMenuRepair},
        {"STATS", actionMenuStats},
        {"SWITCH", actionMenuSwitch}
    }
}

--[[ actionMenu : show_action_menu ]]--

sampfuncsRegisterConsoleCommand("execute.cursor", function() print(_showSpectateCursor) end)
sampfuncsRegisterConsoleCommand("execute.newMenu", function() newMainFrame[0] = not newMainFrame[0] end)

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
                for index = 1, #buttonsPlaceholder[1] do
                    if imgui.Button(buttonsPlaceholder[1][index][1], imgui.ImVec2(100, 35)) then
                        buttonsPlaceholder[1][index][2]()
                        if not _showSpectateCursor then _showSpectateCursor = true end
                    end

                    if index ~= 7 then imgui.SameLine() end
                end
                imgui.BeginGroup() -- New line content
                    for index = 1, #buttonsPlaceholder[2] do
                        if imgui.Button(buttonsPlaceholder[2][index][1], imgui.ImVec2(100, 35)) then
                            buttonsPlaceholder[2][index][2]()
                            if not _showSpectateCursor and index ~= 1 then _showSpectateCursor = true end
                        end
                    
                        if index ~= 7 then imgui.SameLine() end
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
                                print(_showSpectateCursor)
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
                    imgui.SetCursorPos(imgui.ImVec2(132, 20))
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
                        imgui.Checkbox(" Вводить /alogin при входе", aloginOnEnter)

                        imgui.SetCursorPos(imgui.ImVec2(15, 124))
                        imgui.Checkbox(" Автоматический вход", autologin)
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
                        imgui.Text(("Общий онлайн                    %s\nОнлайн за сессию             %s"):format(full_online, temp_online)) -- :)
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
                    imgui.BeginChild()
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
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    -- инициализируем все команды
    sampRegisterChatCommand("gadm", gadm_cmd)
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

    sampAddChatMessage("GAdmin успешно запущен", -1)

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

        show_action_menu[0] = show_info_menu[0]
        if show_action_menu[0] and cfg.windowsSettings.playersNearby.use then playersNearby[0] = true else playersNearby[0] = false end

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

-- function samp.onShowMenu()
    -- if show_info_menu[0] then return false end
-- end

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
    "pk %d+"
}

function samp.onSendCommand(text)
    for k, v in ipairs(formCommands) do
        if text:find("/"..v..".*") then
            checkSendFormCommand = true
            sendFormCommand = text
        end
    end
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
end

function samp.onShowDialog(dialogId, style, title, button1, button2, text)
    -- TODO: тут надо просто в самом начале text button1 button2 и title в utf8 перевести
    if style == 3 and text:find(u8:decode"Для продолжения игры, Вам необходимо авторизоваться") and #cfg.game_pass > 3 then
        sampSendDialogResponse(dialogId, 1, 0, cfg.game_pass)
        return false
    end
    if style == 3 and button1 == u8:decode"Далее" and button2 == u8:decode"Отмена" and text:find(u8:decode"{4a86b6}Авторизация") and text:find(u8:decode"{FFFFFF}Введите пароль:") and #cfg.adm_pass > 3 then
        sampSendDialogResponse(dialogId, 1, 0, cfg.adm_pass)
        return false
    end

    if text:find(u8:decode("Информация о игроке")) and checking_stats then
        print("i have checked stats")
        text = u8(text)
        text = text:gsub("{......}", "")
        player_data["nick"], info_about = text:match("Информация о игроке (.+)%[(%d+)]")
        player_data["money"], player_data["bank"] = text:match("Деньги%: (%$[%-]?%d+)\nБанк%: (%$[%-]?%d+)\n")
        player_data["fraction"] = text:match("Фракция: (.-)\n")
        player_data["transport"] = text:match("Транспорт: (.-)\n")
        player_data["house"] = text:match("Дом: (.-)\n")
        player_data["vip"] = text:match("Премиум аккаунт: (.-)\n")
        player_data["reg_date"] = text:match("Дата регистрации: (.-)\n")

        res, player_data["ped"] = sampGetCharHandleBySampPlayerId(info_about)
        if not res then player_data["ped"] = PLAYER_PED end

        if isCharInAnyCar(player_data["ped"]) then
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

sampfuncsRegisterConsoleCommand("execute.form", function ()
    admin_form_menu[0], formStarter, formCommand = true, "DEBUG_EXECUTE_FORM", "me DEBUG_EXECUTE_FORM"
    form_secondsToHide = os.clock()
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
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
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
--
-- Compressed fonts / images
-- Exa2Font_Regular
--#region
Exo2Font_Regular = "7])#######'%0aW'/###I),##aq0hLr*pA$Y69t82`bh+IeA>#L*+##Y'-h<.a[5Tk&C>#@S$##sa,e=JDo]4O_B>#LQ*##U.ue=@tYk4Xo?>#YZn?9W2^+>o&ulIoWZY#o&_w'e,A0F]I63Rtwg--Yap92lhx<BKW8R*5k1_ATb3F%;%HkE8kPagI&$##0G###A)@UCcqdE*a4B>#YTi--f'TqLs]2K(]pE>#Tacw'E3n0FA-Ya8m.j--CBA$^O9shFd,'El$s+##KS'##^LS=B(i-a*,$cw'UTp92N4^=BVB;HY3YE>#_x###@eHiFt?>x3DjF>#f)?50WbDfGhv'(%,5i--?Vw<(h]:;$/H&##>Qw4]-l68%=wfi'2]:S(Qj</M*h6g)0-k-$WpcB#vK@lJ$j>]=$iB^#RVkkMqu(BuV%%I65S/&v66O]#SZpY%r7$##n[C+*XeRs$`r29/ND#G4mE/[#m&l]#tB:a#h=S_#iq]PD?DMb?.JwM0Y@B>.I07^58U*2M:ht`#J2)_KftBkMx`-(-k<MO;fj5#-lB`k;EQ?&#:R@%#psZiL'TGgL5rg[1wQ->%K4_Y,*55>YPKxBSDL2[,E#Vp9(Yv`4Fb,&uoA*AOCYx8%KsaI3vT]?TfoFc4:Rlj1q:Rv$@Tsv6x*Z68X1_C4n,]x5dN$;6;DDJ8@Ys20o7M?-%xOw$.'2a#x#s>7ujsL3Z8>>>+UTU%BODo2q$aZ#+6eW&$,:kFtYaFr'a5DaFpQ^$1rJd)'cK+*u;Tv-qII`,l(TF4>U^:/p?Z)4tB:a#dH'b%DcCE4S7IG;?EZk0o-gC#VvEK=Z>Wx$8$lA-(h%g)CZM<LG2i:%[lF,4/I#<%xd0DaEJS51Tb/<$m[sT9h*G9%u]1Z#&_K:/-AD0*cuV11f4Mv#$vu##IQk&#cIs`#8tC$#UxMd%%nZ)*>EL:%^r29/@,oL(:V3D#I;JK(+W[d@L518/CU.(q:Rw4]_Ane)ioA,3a4uWM]K/G`MfR3krJYxk2TV;.s1Y<%+(%],^YVO'NIXn-VtmTi9ZIl1L%u/Mu4TE#']p[kqMTWAf/i-2XnkdEHZx9A7Rag*vX4`4S3an'IC@[#9W#1%mWph;hT,%7Sn%k9@BW;7(JMc+7SuY#rnml//rA98u@qV$o@w%4s/0-3(@n5/&^g88[bPm:0I>1%m]B.*Wcvc%AE.&4CIR>#RTNU0;l@Q0:5oT0@Uqx51sOP(p*x[-k1A?$M7qN2F$e2(7cfQ::USX-6nk(au-Ka#GooYIs.b*63iuK3%=H2(xE_02RA:nBBW)&77T,4M7vDs;?),##8J2e.e^x5#S4ad%vU`v#q5xF4N&MB#Z4h:%rE@Jb7`YYu/2w4]_-a?uH8$S'>b#+#lF#296ZVA+ZB78.2#N59''d^,Tg'u$vjZeMRa_=%6h*iMIM.IM^HQa$4H7l1A5i^oJK3FN_U39/AC1E>QZlk0c/XL)l0k#AN54+3DXd&4'3@C>JO9#.u*W^6q@b4':A,C5vqqX6;A_M)343G`/GB32mb]?$Tk4I<fxf=/f'wG42AA['hC)q8F5F61wi?%'vQuj1k:#`4w4iC,xp@.*<?<I3V3-l1s2jhL)>R]4gsvCsn7[`3dH]Z%],WI3u#t;-HLji-kHw--GW8f3O,NG)])bn'/*n9:lvUX%[.[w-/B8k(^Pff3/SAe%Jue[-j1A?$L4hN2^[b50i6HL.(.aEHw/<>$tZnY#Gko(@4ntG+MPO.3rjp30,Ks*4p0Y$8gK_(#/`($#6A=e#>B%%#*fR^01n3:.D1NT/>PBp7Z:Ha3J[eX-vIVw&sI`O@=67<$P7IW$j9^7$sqKqu2(/E'?DXe#<s75'Yk2?u@0ta&C-NS;t5bV0vg4u#h6l6#$s-V8-Dd;%mXH2&91Wu75SsAF+EsI3x?7f3`GUv-$l2Q/&C1K(:NZ]4ASCb4n`S51exGD>b`O**hLx=7+`6E5MZ7%6(Ph)5G(`M)4ZZ2;8rRf_xX4n:-8[8%k7L0<JYCv#*4:,)N`:`5+oJE#r&r02krcY#rJY>#O9onL<U-##WNft#ON:7#3PvH.r`Q_#dcus-hRZ29UZ9T71Li<7FiPZ,QxZT8WfE,<(o_V0L1Fv8iUV+4`tQO$$=,'$-^I:JOnYm3'0ns&?KeWM4GG*#'3V(v$^7d#:%jE-63(I(t#a,MLcxF4l)fh;13$E,1BWq:@/s:/6,i;8@3(9.63T62P_],?^-Hh.rMW9C'#KZ$ts*v#MlbnD),R>#&JEp%f$7a#usR:v.-EP]Yu8>,S1h1340_:%,m@d)<]WF3.>k_$J^VN(_XmV-cVg?3t36@$JXZA,vDic)t?gTC0<rE#MH,D#%F,j#xZ>29v$Z+DX96'$IJKd4b^JY7u[-nLo=*,#JAr*M`4N$#:pVE-D88'.f:ZLM*i/,jBs=91HV9S.q&9e4$ksLT1XiY#X=M;.5bk]4sYF.h2On?9*#bFrm*/DanHel/d`cW-tNEdXuAY1']i#:.._/@#%Mj#7R3E;7R'Qi;pa&88LY:d4EC$:7[W1:B]&pK#a,)U%G#Cp%uvW;$;m-)G>q1N4P=9C4)(xf;eP+xT2Z<puf/M@#;5>##L@@I-vbch%[]:S(nphc)RbTfLgQdM?u5wR[s%+d#$a(c#]:f`;ekZ.M+&<FM+bi7[A`BR3HMlb.K),##:WfX#4er=-dvAW4rkh8.d1NT/Jv8+4%A#29aH9Z-B]gkL#&.xkrW9s$_feb#tQII-9&wX.FXI%#U@KY%c1Rs$lXB+*tJ_#$+fXI)].B+*,%1N(NkY)4&h?/&d]E**WFfmrINr4%7pLv>2^=tU[tP-)UJsa*ODwS#Z,]Ni[s&&,IJ8+M)*i*:owFg.$3YY#R@v)/]A0+*N:X2iD)+P(cx&)t3ug_8q(oanjOr>-d1if:hG#1MoHh*#xG<jLp8xiLut&i)23I=.sDp;.==M8.==9C4(g^I*,xiI.OS>c4WSMj9J[2B,D`AOTcs>(-HFlb*giC8..>,KLOgLg(jUoJLS)x4]g=$g#WExY,>d]Xupwk(/^n/N*ZG7i1Tcuk,&9cu>:C$)EK*xM(I(C@/DXI5/lY4jL$3x9.[qV0GP17LG.[v)4n10(.KIkt$4^Ku$:Q:;?(Fb$'PH7'+BocY#eE.CGdUi?#iM&i)'*0@u3#auL'.;S.MTE`+hmrFr6VO'#VH]t#CUC7#a,D^Q_&`]$u,R90WC94;[BBA,cwu3;]EBA,]7bt8YoaG<pC[20],Da=XBjKO)TZF%N=1uIPnYm3Px'4E()[Y#srwv-V$;;-89_E#'Ri8.Gq[P/XO&r8NA0Tp[I[r8+eU60Fq(h;GRsv#5=v.3wqLx54RGp)=;s/<B+o+`Q>5G>]@]8%f%*D#<xc(5&5mY#tPc>#<M)Q/e]er6g3PPAn,?a+Y==EGgaV.0$f^F*H1NT/#hqS-XX6p-CI^EniFU#6]oo+<MU0NMfAus8YoN,<x:9Bu*J/T&:#<A--+)5tRd<3tD*'/1.Xr<%pYRD*U%<9/gG+jLjqVu7q;T;.GBw;6HQkT1_#AO(UU-Q8MdH01podD6K;(]3#%Vx5OEKW$Pp'uA[$-L.K^r1;[xh;$^WX+jEllA#0x/)*O8#c4mk*w7gDhB#Ol&cr9;q(a[x<qMKrH[%x3_F*,eWR%xs`a4rX@79S[lS/S#Tp@xH:a#*=ELDF;dKD%]Nx-lQS'PWtd%5G+F)FI%95:;5-]6>Tb^,Vl/d+p9k(axkTT7@KU,)00IP1oZ?RAwMAX/1%-q7i>$I2iv&I*kT$7As5Ww.15YY#mJ0I$kgJG;9N$(#To0N(Z_G)4w*cG#3hm/9hGA-<s,>>#j_bFrmn?_/AsIK<$Ri8.rZv)4lYg0:udZp.Y8xN2d^],Gkt<2:XQhB--DVu>q'Jc4XZAYYpP]'?e=po:F%?X:HfqKG`e2X:Qe39B$RZa$&$a,b]Jc`<m`cn&I(ow#N=%i$RTKY$XIcwLN(4@&MI`Z#VXcC)?'07/3BE/M]K>&#>GAvLMLfbO?Fu<%5h7vPbaxF4fFPZ5/jt1)KMu.$`ti<'S.hF$H'O=$G%C+$+D7qLB,W(AH#r;$KqeU.[h14'gjl%0GpCZ#Iuq;$Q<Hc%'(#k'G=I8%/c+.)VvE@tXd,R&M[E7n:UhF*aVg=u^)m3'f/cO07qvK)f>Q6W5R-iLY2BnL=]+d;K58N0H13:.n$U/)`pxw#<kY)42`XpbG0vluEkl*B2<US7AVxlus*vN#`qThNhQP-9[4emL1GZY#>C^$.p*U-M_x_#$02Sa3ln0N(6I)^<]SC)&GLw8%UukoNlU>[.$-@ouVvB`0rg8@#g:_fuSf&0M4?UkL4(*N9_'#t7.<^Z-:%xC#-av5/`dCrQ]2tpus]3pupPFI#Q+-,;#>q6;q/5##OWfX#I8s<#SGCU8fe)P(ud)*4nGUv-@Tsv6J'x8%Yrse)+]k_$S0cO'<]d8/=/9f3mD``3dIIT8D9n^5RoSY%9+wLWM_d&,(sYl9i3930Jk#n0h-#[7$nno8r3t:Ef>?U/v9Y#%;)Zi7hgW#-K'Ig)j/4T'L0Ax,PAlC5Ep:]0gNft#;B(7#HvSKM<RI>%nII`,GMBH'sCpg)[/*E*p^/@#=Nql)U'b,+@`df*@-sI3hIDG+mBgq/j:6Z,;xI/$2B5>>mE:2O%NM^-F39q%s=%w#28[:9XeBm0xk/m0.;D3-*oMZuXgj%X$),##OEJX#&x4e:+`Y8/TUcH&&UL6_6;?`,lLdf*^*+I+3ag],65sH2LIep.a;NoC;u5I#.ksp%+aO;-S.H-=Mf_;$RW6*3lmf,Glp1'odo+XCI?:'o8:el/o%Fl;g>,vC>7:f3q?DN(PtUN(1[v)4-n3:Av.w3:mY,f*[VGB,_:FW%IQ]Y@C?*G#`#vp%0DP>#*C^(4Wov+<$WeC-UEr=6)NDwKAZ9[dm3?A%HgR$,=u(TN?A6)M;cgs7#A;-*M3H)475^+4aJ^w.6#Y/*.P##5E7dV#`^J@#cO.]6-l-*5+nls%6BP*,<s&12w`H$=?Km<8nOfq/#o90<J+AW$xh3t$0eTvA8YC9rZq/bIOhYoeFZCG)Up^,*b+'tq4:^L(m#fF4QheX-=7eY#WJX1);)VU/kDfVS9=Yd#MU:v#^;DBu^A;m1YTri8g2###Ps^#vKR$iLlGW$#^3=&#aXoC)=ZLv[gc8f393#9%kBBu$_Qb,%#Ah8.UD.&4sA>a4n0Ag:?mt?0q7WT/kWwF42_@@@r0`2<<(h)3,];D5'Pm(53^DE.b7[n&Q;HE9BvY*?eXRf*h/]>6U$e_+skm&6rOt4'9qS2-4`+gL6GlC-o$^794V1-4VV1s7-UPR0-O>70vF9?5/kXj'?`g>,;_`D5_ee9.&>/m0/DxP'@*XY-8.#6':9N)+iD3a*K$(O1L/5##s,>>#2E(7#lS.^$:[w9.mj9-%3n5V/[nn8%+[FU%FC^SMASFN1NPX>56/eV$2HDG#0?&SR%E(u.3<7p0W:4l-,fVZuLYaNMEC6YY4e%v#&R$&%4a'i)=pp;.9/9f3:Eh%7DNSE+%=ZruJ>[ifiY8iLsqJfL?75xu1o_xL<C*$#7hJ]=TeRs$irxF41hvI66&rO0RTa`+pd*fMnQkQ/6T1r.jwAC#_E'C-GlRQ-g1:u:<:Z;%.e+h)(lgF*R.=V/xGd&'ki9ITsw4gLVaW%CE5B'M3i)[$AnxOGtg(-&BlhV$1'<W#5Bipu_tqC,8GbCXW.i7IK=@>#k$$`s'Ti?B(WeKYul/+*qN7UTU]+P(brs>-1MLW-u.Mu7UvL7eT36B$SxuA6HT-GMY&mV-(=4/(-%qT/Apn/3-[w9.6v5X$e:>Z$8V[w'^2B.*W),d3Bjhh$+c#G4G30W8og_50xmcr/ln^duZm(?>b$];8nW49/#'280o'$I#G&)au:kFS1I6+B,u9mq&jVO(N[.cQ8#ueU.X?4U.NLM=-YhQQ%WEsP'#G:p7DJZ;%L15B#>+?D-x>Ts-qTBp7fRn219K@h2$,3X:scaFrGv/X:_Ha&d352M'K-0a<<nZ),5Be31@S+SC6Q9h=ud*D+_4Ix6AFtD#nZb%ATZghMcs5_-R%-h<Ql&gLNkZ'v@`bgLgA[f;x*R[B2_`[Ihl*$%rSt-FRZbA#Xr,u/AMht@w.w3:m],f*c[sp/t:L^+jlA,&1JY>#LOJW-IsKgFg70G3Xx),<#ja@.rL@D,+CMKCYF:,'tk)AP<GqKlm8%Mpf7o>-v4V-OjV_:%gd0WfZ,E.3_4g0%A@:f3</gF*^Ndd3diMB#l.-A6)M[H+'G]I28g,X7-6[U&IJa</h_5+3?*9G>7ONp%%lDp%&=lY%3>G>#;ZF_?N[D&5Nt97J4sx#8e.$>u/VcG396K&ZKp$tLx]Q##0hJ]=>e*N(or<wpK/'J3rwu>>&F$$,?2o>%PThC#E*e6%=`v>-b+A(#VSZ$v<PwS#t(BkL(HB.*(@n5/CSwv$ABjn8WdDb5I(WT/)U0T%mEK2:iHGg1f?Ee3fh%^Pto0X@*ge'7^rT%6'+sG+%D`%0;O('>xOHs$lZ3v#d?[x,4i(<-;heA6,(X5&p=N5&YA=jL0RVW-IVU`5X:pc07WfX#UM_/#r-LhLt4Zl$hd/[#oNv)4,heX-w:so,V%40(jbcW6bwnI_QG_fu`8tr7uX#m8G.iUQ,@$gL-_?'v[mMW#FeEB-w*B?.O^D.3Me4T%jTAX-P.WT/ORZS.V6kF5`Fwh4:Zm'9sne7nw?+:/-9[P1GL7AFQ$Ws'LMB>#5Y###Ev8X:]nub30'CN$?pE=&EC$K@d%b9%N*k9%Ct8O2r<^Q&UiEpu$#*L)$-T@#gL>w.<o###i7h9;QQIY%TJ-/$E/'u&70iC$?IR<$-'D($E,tt&uK5J?C)iv#B77<$?[u3';uew#7LXV.A7Rs$%M(M5&q1k'9A(4)B097/L)8*'K@M?#Hd1w(4'Oh#V^st&MCDZux5q/)n^A@#&Tmh-j7bHZha6kXw/?T%4UW:.eanG*V9>V/@kY)4MA3TW]vciuL:T*A$4JA+cEq.p6N(EM]_NJ8h/5##i]dC#hvHm1Mqn%#vxhM'5bCE4JX@lL3>Y3).SB+*B$s8.@G.$$H(c+'BJbQ1eXq2)Z0t9%D'q`LL#[D*uGMK(ljk7n)n;v6[5*#54]G_5&0B@#2/g#(GEes&.`)BMGE_kL9H@&MZM?##cRXgLA[oZ&%I2du<#p.Uwms1T0&i(WsXiO#Q_g(W%?vWU2M^CseW8G`DqCP83o$-303Gg1'>usov:e;%sd1=%=cq@Rlrf+4.W8f3UGT58;4PvG-t$E-bB:6&]TIk(;QF)+qBi%O#s_M4'cc@5/6ow/H[)_?)4V;0t[?g3:=hH#->7j:5DD9/_JNv%AWX8%h5G>#uGR12qxhg*Ms8F4?%Bk1v8'i),1_K<>2@s$CND5:]0>muutwu6mfI;6Nd1JU>lN',Pa.JhWlmi'T74.F;*`e&^2B.*TJ[U%cOBk1lCLP2SoG;76d_*3+ilJCAE-,,ehi@FDehR#4(8^--Jgq#9XB^-sd4d(wuIfLe*LA=WvKK)nBIP/sCXQ1_Geu%-1eX-;N)[KPs8CO6*x9.5:J6/3X^02k81PMggaY5AP8H#hTnH+8.'O0hkpr6>e*D+b`u[PV4Qh8PeM8$nP[H3-7o`3N@5vm`->01B$=xuT'?r#V*V$#7aBK-`mUM''0<.3FU2r70Sg;.0E'toGhB5'VK#<81Z:m9+&%b4_7=:/eZQAQU*(90j-nY#:jXF`JF'A$I)XG4pWNM0Li;..LE-)MN3$##i3H^#&C?&MT@5&#cxmU(:6X<-X`Pd$d0v-30aZ#8O,:m9FV-QqbNI%Fx1m<-#0@J(;8^l8ou$GV8AuKGLaY53x@XI)<>Uv-tKpJ1'.vN'rfVk'sG(Z'PIj$''x9'#j@#29>2HfUb(;j('.fO:&?2x-OG#G4J0-4'oQsm/Fwn@#Th'L5;w6D4Au1w,(IM]5CSP:v]WsKGM;l._/Pd'&:,058oO#29iX4R*eg#L>1e_R*9uFR*ia?,MLtt)#,PY##nKU[-i2`-6UN2^#@p8gL;o$>#&3GY>a;RuYmr^V$8c###mbw9.1p1`Pmo1+&k@?O(g%k**KGxB#ocfIh,O<&hSFZ1MM#Xl(x^c</,$###n79<NR9(:%<Vo-)&(uS]Ye4B4utI,*_)&_#[JlJ]]F$CuLNF8&-G)20uS.Pf4T%#,OR$##6+Jw#VNfnLwRsO'<]d8/#RU&$(dHW-nn>;-T;vA#1F?03g`.Z$(5C[6?TE_.af`^#,-vN''H9I$d.u`4m>B+4R:]_#lkfA$+LRG;n%Md4WVmngSId1Mf8R20M=dl/Hqg4fK7OXLH=nJ)obb;.dFuG-R3'8%kStuP&eD;$6U4OFIb64O?V#K3tdnI-IEmD-AtBt5`,rR1s^CP:qv^C63LL,3^cLv#s=[s$k9aG8eT@F4su+/:J9KM'&&:K*XiWI)/J>s6oe+D#+-_B@Co^W&XiR-$nrHhibb@JI7_?=ni*<)MsT5;-1VC,3hkXm/cS'f)lk2Q/x?7f3$o2*Oa9mC&<>#w?*3sb3#'@LnrQ_;IowCui/s-A-]>EY.F,###ObQ]/=n?g)Ya`I3g]b;/)$fF43-tiC5nL*Q:bZG*oZ)5(TG[$5@8N>5lB1L5w.8S@%lJL56iC.*_8ov$'EsI3=ALlLc0+m^:bmc*58Gk'T<SY,nQxu*7H^w#+Pw(#R;6$vA(Ox#%HW/M<QRv$js9u$PTk]#v#EQ.B4e5/jhp8/(r-lL@eei$kd^:/),ZW.QTk6/Y8<@.$($c*`lvJ;.u3V/_?dK2lx+$,8fZd1K1C#,<c-##ma'U%:sf^+xtmw6P`oF-[`oF-K.lC..iC+*FKp,*`t.[#,Ksv$=/TF4Loh_%_FS_#=U^:/QpQ2;+Y>c*/RI9.]nKu.+5dW.LBFq.aYUV$vWM$d@OYgL3YL'+m$+,2c#[A43)KQ.(OF9%JTKT]P1KfLVO_*#&b6K#r++,M)HH)4m31lfoN]v7@$`'#E16M^&>uu#D*'n)BV]P^^GIR*O<2^#_%I=.m%Oo7wUm3+_U[+OED3#5&b:4+/swIqE`g(j5Y###Cp0KM/rCu$0N&i)h@h8.N]`?#lFB[%SJmK'h<l+39VG?,re#D4k5V3XsvGon:d7MgCOI-3r``O'4bCE4[,ZgNMJJ/PXT3Mglg2^#F*.e-[VVwK(DkYLSSdHR]ar@BU`&2GtlIfL%AGG2I2@kFr8k(]^6hY(8*J$Pj3sFQvJEY0j@#29IYd+V-8'29rAq/)TZGn&:oq;-+mnA-]I*^-scRe603_MC>JIG[P<8H[h<_lFN:-##od0'#8G[8#'hJ]=`W^:%rN;`1Ee3hVl2'8],Mt])BfRQ-jKx>-%/@W%2C3Q/&^clVErcZKv=U])vj3H]%/5##-4D,#$'D$#Z:4gLo0x9.x2k-$gII#7quCZu#('Mu_h&gLZ<5xu%jVs#[Tkg23*<8.eNvrul*j%O7Kp1'_84RE'<BSo;2p`=L-5QBIhXaubL+v-X;:pLs%QWMRwK]=kvRPT#N.&uTen#M%A+D#'7^i#@nf2Bp7o`=IAuKY,Lv;%_arhL-2uat[Vvg;[=rB%'K[P&MhoQ(cR<P]5dKSJ34$qV%^jO's[R@-K4;;$)O#GMH1b9Mp>W]+i(p5`9kue)hFq8./aS+4qi@a3'^B.*[hRs$l9Q)47O7lLI%*Y$L:NT/wL>c4BS'f)4m1T/Eh@<$faAs$puhg1J*[(+P:,:&mcZ.2+H:6&U-L,+`n^D3h5Z&4?a2H&/pUc+/G659f`cW$eZ/W$7]jfLT;=I-oL#D4[gsRcdQ%ZPtDo(#gnl+#spao7i[Rh-7mG3b-;)K)f:_clXw)iMaEvDO/M8f3XMu@MKDEU-8h:/Vj[==&Gfn2.l/FZM5E$p-he>Rs<Fg@$+G(v#cNa;$pcliTm79+itGe`4Y%I`,RFiK&^DJ]%^1%W$jRa5&g1@8%p`5P9@RhF*ukE*,I)>>#3*78#`gfA$pnA*#70TK1*H`,#<<%@#C)V$#b3:k;In1@2Qnlq&%.Ug2osob%WSMX.kI>M97VbxOc7a/1Vki&PlZ3Z#0l%:#8q7Y-2t(4+M8###xq.>-Fc1p.)J&Z5tqhb.+nsQNbA###mCBAO[Wkl&*c68%''fxF%QrR*v6qR*;2vCa_r#sIwPI#Q971S[f27,E%,TSS5HUYZB1aSAxYe>Q7c8YY*Y12U(;^8Su8n7[-t$j:$sjVRL]d:2OooR*O#;PJ5X&:2u56_#'+BsNHl6N#<4il-S6w0#Xv[d#OMb&#sjml$;%Lp@`p_,D=O'>.7i(?#3cS&$>q(a4h3kX$Bt=jN2H+;-7^(#vLjFv:cx34'f.fP'815H#?(vd3j&bIhGw*A#%Qik##hcM9(I7`EZKZB$I3pC##_At%aW/@uUH]B-pL)Zu?^[3DmT.##[*TZ6Dj6)*dX4kXtQT9V5CDYP.`+cr-8[Jr-5-2Ts,2aOU6](ad[72LwPI#QI<Ei^FUxlB#d*ZQWb-M^s8%#Q(veBPNd]+`<H$)*&p;5A)ols-`;hm9usS,3hh$&IlN5E=MeA<9BN$bu7O68BYa:B#d>SC#xl2+,^f5#?I>:v?`S0K-&j]n.taX.#TJ7+NAJSs$H>'##O?eaHA7&,V>]U2(,/xuQ+=SVe5h]`Xr&)aOl8e%OrUPoNCD:2#*BDuNo^ZlNDJC2#'nYtNA4FjNrC9vLCo`=-i:xU.)Tq/#pR:@-W:xU.(1@8#Q/xU.c.rZ#E;xU.W/^*#UP:@-.;xU.k*]-#V;X7/WH]t#bNvtLFE%IMYF:2#6tctN_8NmN>,u1#nNVmMf'_kNX4M2#fD17#d=W`uG`d_#J<r$#>2<)#ePpWAlcfF4]QA.*w$3e$%h?M1<SV?#h-np.R>.l'r^sW'i2/s&ZL&M10/BB+f.O+3;)t@tI?4jL+J<,#DtINM,ae*Nk/80#<=G##FX`=-?c'-%`wfi'rog;-Ylb;&.$tLuLweG#EIj8.4/TqJO'T9.XcGxk-BjJ`9Ui5/qM3'#iDp.vv7b$MNVF)#@-Xx#))Au-=^t,M<uZ=lZ9d8/FUpR*2eDo[O4Uw9jV<R*6TB>G)D#TS4DKl]mYA?$%2G>#,]oR*76]1^1Is92+G=R*R<0&=xfWVRcsAR*sr<R*,B#vGr);&Phx/^mx7M'#hoa;Nfhv>#?Cjo7eZb&#mQsjN[PL2#2wfd8(?Zv$cg6)N2P`c)X+f+MCTPxuAhZ,$T_NjLBrJfL,(;2#3*c6#(*;cuSR&a#=<r$#mvK'#htYI)&o<Y-c=TW&[U^.C;x<)uAm<suLjv40_>ru5g0KloEiJ-Z4`f+M1Fl1#CTL7#$t(cu.d:aMM#=;R?u0&=EZ2w$?]d8/H*CD3/^NAGjQ+<-=eYx'@m[.CMib?KibdDNT;exkLxV4oIq00b^63$#(pao79/9f3O=%ZP*`bI+7R)D+Y,*>0,5o@5TV(,+kd%VD[3CG)^bWiqAmI#$/:Es-S1$@P+o(^u)PB%9xbO%H0qpHOY*tV$ao9+$CAQxL8/88%V]1MTxGrR*'LqR*r^Q+r&DM3b8DA.q.stKG60U`3,w8=-F*2U-;Zm#8NkkA#m0h`*45-=-_l+@,gl*#QeYIAPUge/`&9cu>/ti?^vL$##:['u$ME-wfLXj=.[-(qUrq/P:e6<l((8s@.6)X`sZpGN'MvQA.9R0:%DA2S&:JuY#l*^l8x+Rs$TCMq'u]YC)^DI.2SC10C/?5-3LN*D+YR+SnMUSZ6xc;5A)Ra?Thr###ig[rQkuY(a'>55Tqvu`OGi/S*dUpR*R>r1KjJJ,M/RHlNuUTvLB;UsN$f9kNDJC2#4u8sN4;%iNrC9vL[o`=-Z:xU.CF^2#bR:@-?@2i1KLg2#:7>##)9no#J_l)MfjJ%#5_of$[blj`np,5*dT#_um1YaCuouPp3]Ra)BEFwJmvfZ0%#]d#[Mb&#`X+NDJLbA@f'ae$W[(Z$T8x*3)$fF4E3kX$%;Xa4UbdG*T]cMC/aG<.ZBJx,(qGV/Z.4T%l?ii2mtg$$fv8Z-iCH>#s?gTCj,ip9hvRdu4@WL%2k:?%3W%uIQnYm3$Sk87'LqDN#/fdD_j-3:IY:m5=I)c:,.<%?cV[V6Ani5/@%$##b'H]ODX[(aZ,P$?Q,eV6HPif(He,87G5mq.?[C+*2.hC.uonf,5?4?@gE)KCrk^mCZ7KeC0@;KE6kK&$/<Xj.dUr,#G)xU.PEJX#YHqS-'_Q5.fnYtN^v-tLi0xU.R8p*#E/xU..5cu#P;xU.IbG/vS(l0MbMJR0RD,+#615##xgCEM20df(*c=Q1;<:M148Tj2d6vfC=MPg3_R,+DZV7$$*0?.q]Vx4]JUa,*@(xlbQRw;->uV*/K%^]4nKBDJ0SvC<u*:1<oHU*Q@)tuPoXpu,*c68%XTo%=bEPfLmcp.CqOO5;.6fX-TN@@BZlg:Q`f.#/pv?.3phQ:;]bw[#sAM:;r]-JUqG*^#e)l;-jtt8.P)JwB5ajd=f3a#,ZV'9AT_v#/p4/N0Ar2g*sNlB$&Xp8MPsJfLr4*(veNY'$6`nI-ndsB/iAT2#FnYtN'C`pN=&l1#gs`=-h:xU..a-0#^R:@-X:xU.7g60#Bm`=-M:xU.4)[0#?m`=-4l`=-;SH2OV^ZlN@2u1#O[>tNJ0oqNHi$3#SauG-1m`=-C'LhM*l1^#S*BsNIiq2#_=r*MXK>&#@YxVM0]'gMH;2,)rKWR*3?XR*4DFMB8H4wprD7#Q(7&FI^ZYMCL6SR*:Ixl&aM7_ATD###2-DDNVqpV.+me&#b0TsNs[YoN=&l1#5s`=-^:xU.S>#+#SR:@-C:xU.XVG+#/Z`=-Vj`a-X)7kXLaD_AsxDcVAfUR*X^p92vc*ZQ0A,M^+StEIq8`AP]v@M9Gbw]cuZjlSJvY]YnV/$$*xm(#_88#G>lv$$6C%%#Uqn%#0pm(#]`)(GY?q/)*IMH*EcZ0CZFhB#T(+=$lHbj$T*s%&ocZ/(VN9fUT$%o+9TLC,h`x.MQ7MC,D9W)+.j:^#Z)m>u3a`XG(mZ_u?oPZ&VJPU;b2kS7BNc',i4FJ2C+%Q/d=&21HKOY-vIO&#s+9;-ogEr$]j?ed3Ub&#8+,##QNft#wTC7#;>#29rZv)4)%x[-,5Rv$PpF3&;&IO*Wt2.N40KE#_X&53$(>G#Vu#&28>gl8+tUb,6_wE5TM4V&Z@pX/f;Ok1;pQoBk2Bj<m&<j;./1j<QJ+s%.V*k'?92_K`UFnLit:D3M)'Dj/;l5/^q-eQ8e[rQxGP:vp<IYm@-3<%I/l1T9n`=-sX_w-(o``NbrQtN0P5H7.=58]tGR>Qn/?x0&>=r)Y6jg#(S12UxljVR^f=r)KW;r).aAA%ad7Q0V$_+rT`4sR.'oW_';u^]&UYA4?cPP/gC.>>H.sM0g@h8.4gE.3s*bLDCmVwAaH8[#/5N7/d[C+*/A6gDChQ_#Z$sH#L%a^uOEIE+Mm$LO02XW@V'&o8Ag`4DF.0tBMOP)3G&Vb,/-lo94-mv.[X9N4TS]lDYIqB#96iR1CBep0TI70DE?3OWM:*=.g&QW.[.Np.2-*'6x8%FdW[Q:vcp+5&3f]+rxTel/$@D<%DE<VQ_IOR*WM`xbV4tR*gNs7R#IlR*X/aR*3I`uPRu4r)SUsX1xoHfUp-lR**0uX1jkK>%oCr&58$xuG*<Zq)dq[-H0(6V#Scf=#l_=R*6l2G`G70Z-/E9(6-v_)3ZlR;HPYdv$?]d8/nv#U.%TiOfp^1E->'Bo2DvmwA#o6##O?AX#38@8#(?$(#vsA`,g`T,Mv*E.3LGu;-kK<7%H__+4:US8%8I3Q/ND=@A*ar-2FgFlEbAZe+p(A;%K#Ah2KLFs8tjft-x[Pu/5+:VeWQh3$c&3EQ0?P4<+77W:?x)w,5PSL(pCG@?Pk2U:v6.u/QTQX/(9co7*N&Wn/;l5/An2?@Ouk=&r<IYm@-3<%QxDcV9n`=-rOC[-4FtJW7jEs#@s.u-0xD%OVU%qN@9Y5=3bM=-Ms.u-G60aN:mtrNHQL2#T*4GMDLOD#5]<$OJr6N#6R)bN+wYwNai$>:;$+r./)N`#_w&XUkFkEe?:@2M&WM=-me'hM:qFl=T8l?-BVB40h;K2#s05##/,HX1XDG##WEX&#.Q?(#rpao7QFW9.hGv;%=sY+E.ilM(#+E<-D-('7o_+I<%'7#6Lf([%D,Y:vO.>>#6lT'%w2h'#+V(?#Xa`4#m6>##*,>>#d2O$MaKs$#9LQa$<t%i)VCfU.*W<T#OdN#(>'Bo2&e3@SSFuG-h9L%/lGV4%FurEI:e[rQ9LP:vQN4eHA4Srmnjl`O6UiX-@2[q)4q:Ses>7#Q?5V'8b2[q)'Ji(a%2gSShKSq)rFa-?Kq)5]tGR>QhE]q)9?^w0B);JUwfaVR<QM=-ma.u-.)mtNRJ2oaWp/C/_#U'#`]E;N4;DB#q^5##UCODo@v>P0Rp)D#.D_N$O&BkLbid##KQJ=#34lxusAreMFW$lLc_v>#qWH'#uH>buXvis#9Hm2,.l*>-)>gW&I$H.,r,m=(RHJ:1X`&c0NWfX#Ke'/%R8^kLX8*?#Z*,##J15##an`W#@LJJ.F6cu>HMvEEb4+2_jn,^#Q%9B=:>s(td?/^&?0[G<u^%N1@cwwK,up:#7@.FM]Y`=-04I*.EPrC=$8P(JoG8B+7R)D+nPlc-alS:TBW2.P/o,D-.n,D-eec1%IjXj)S1$@Pbm(^u7@m=:tR=`G@,&,Pn0(H/s,>>#a8X$M0'J(#*Pu>#KbE`NpP2AN-YX_$a]uu#a(A.qj^_+rV.PV-F9W_?xXP9'G$t;-D42Y&We9Rrg-JG(aLUa>PC<m&:Vx+jaf<BP3?>>#N+3D3#Va&,<CDmL2@(u$:U5E=@?Xs6]77<.dN1K(LZfI*[DHVH1kAs&x,_6&4(4p/3+qC>l*LcFH$EhuSNrE#g5ZA4/s;#19TG]uTn0#=WIKfLG;4%vrCcY#3X0A8*+3vQs(5r)l]*r)1(H]ORBd%OV_auNM:3;;NG(@-Gs.u-6r;%O:mtrN:eSS<0bM=-&jiX-Ww@r)GK;r)6/B*$8aBSo'20<R9Quu#f1uL^RYgJ2?2?0)F7$##N%RP/qnLa*^gb&FqqJsRR'Ri/,pV.*:L21)$wa[#eW4,+<v-0rv$Y+rQiou,aJt+;?,5d3/.i*>Q<--3f.c)[Jw-E.Ar29/+t'N0ZeRs$'EsI3$[5BGW%lA#u,@l$#oTg1vg*D+_+.]6@@kD#a*Uq1r&abG?7A88uP>L0.T@;6>Gmf*;K6;/o5o)*SRomS+9mK3kT&KFxW&e4445Z.iJ:?-YkR1k.-a'%e%Wrm12R]4)Yqr$u07[&I1p2:=&`iKiH]j(^Ilr-5H>:.0bw9.Cr;<-4S8k&qw'`7u)lH(#E0l<_&BC/`,>>#axbwNdAS`&;qeU.LKSX#/(hK-JV`E/bmj1#A5QaNT@7&Me*xU.>.8;29weU.PMwS#-t.u-OnR$O[&vlM3O^r2,/5##:1=(M.0df((X+QhM*WJ:USP8/UP@Z-h,41uI.%+mXF91((,/7r9B>xuF6*h#VS1L.Upao7.sLm/Omqc)&lgF*G:Im/u;Tv-iVp.*,4[)%*/698V;u`4ft]T%Qp0N(I*K8%si4c4.:J7CSsGW.Sj=u-EqJ8/=0tb5tgc[$+cRS/B(2[,K/@N1n.%W.#5_D5_*q@>PM_7L-Tp1gnL)c+Hixh(1CmC+17CR'&?/B5)f[8%jAP>#+edG*2?(-2enW9/AP=I)DX;%,R<ZL2-d3v,+Chp&A>`a#&5>##.$sW#UM_/#V?O&#^f;7)v#PSLvw(h&B0HdF23A],k^+q7^`28]^SVq.>s`]+iC;eHk1m5/.MQkMop(Se)FKfLm``=-Hmls-@BbL:TTiG#Xa*b.V2-on8;I&/a5IL2ej*8E=:;p&QWE;I=rgv$s:xOs<^1T.<B(7#?,3X%e0am8>Qv;%.Ab=I/8kM(XEs;6NuBx.LhF1D3u8L;hSgI*fU3t./T)11VW,v#tT<e$SDNmN>FFC,HIce)x=/q91?LZ-'(.[d;_L(,4nG('tk)AP.MNfL.`?'v]vis#H_.'0^####hB^M>C_M=-BT<49b?uR*tatX1%tm$%f?w(b%2gSSfx4r)A9;r)X52.O1oIqNCZqM>P_V`bp#;&PXq7(8E?%rMeX,DN<+,G-BPC[-9<[wTp:LxtmSuX1k;%#5(,o>/?>uu#PR/(Mo0nlL5'*?#6*b9#It%>GOb0^#w)Au-_6lDOZw/vNCD:2#$[^`NX/CsNDJC2#sbR+MqT8wu/#4cMd=*mLWfv>#/O['AIoY'A9kd;%cle>%KuY'A1,/#Qk22mMG22mM&aNJ6UqMg2GhKoeS[S;7e`%aO%0LqV:Z6;[w`TR*jEw:Q1gR3Og=9Gj@$ev$;r*=%jl>H3QWYA4E8[q)=@)@9qiNp#dNOgLgg:]$TDl5/'LYR*YR/2')JI@[>m<>P=Q?D*DqCP8sg%##ukDj9K&e,?x?5t(?bbp.KaeEXNA$EIg*ef=5Z$$$r]Y#/`a%HQxP0M^MSsh1UMQ$vS6QV#=a''#3Z-a=0i,g)n:;W-<&A].x>FAFRKG]6:Jk[t[IaW-]CCd6eVK/DDn<w&M,&6:1G]i1Ts?:9=`A;%woUQ&+b'AAx<((#*A7j43ef7n8q?P(uw&>.D=$Q8TGxI*<+xC#b4Nd)KK^U%Ot).]We$s$3isx$0`FH)Fp)a*EDrkoRN<]$xLj7npMP)#q$r+;rA%)NM+W`30iZrHrl1T/'UuSJo6,H3+87<.Rqf8.C5v[-PuS<.:J7&4%8o]47jvS&DkBipX2FZ%@+YU06T&^5-3n,3[),u/0Ja+3bIeY#$'f)>].Lp&C$F5Cqo7K.JQ]A,dv,]#O^7bur*DR/`k+V/>0Vo0Rsug15E-XAc((T79U82']tsf>Ur=w.&HoT$wdDD+=:v?,<G:;$[*I>#.pp(aEQ(,)6R$291>*:.J:B_4omc]'V-A.*Ynn8%&f^F*U%<9/[8Lv-@;^F4:+R1M&Lu>%ck+D#mXjE6@NG#7g*YPC<,U04:d=%?nKfi3gx9b4EM8p&1dUP0j>71(8bW?#vEGA#4GQs./W&B+Cj>XN:=*mLAvjcueuE87pLU+4:ghe$Te<&-;a_>$K;eh(62Jn&U2MG)nE8@#D/,##bAiu5#i;p%3L^Eeq[tEew2/T@MocG*%R?nJiMu`4j1?*(]f6=;x7Ic4Jnv3;#Dn(529T42N%)<-Amx'5em;M2a%8v$Q<pn9r0M^>nCNf>Mh6GGl=3J>Lb-GG%_@rAr2.4MG2[F%5S?+%_tQ>#X?+^69YM;$9CSj02pV:B+G'C>98PaG*q%C>92>EGEgiKc#i9;6[vs._l6.5/*8h;-$[Q&mx0m,*(`B+*/A#G4P2'J34o0N(m_G)4<`$]#1>7R&tW-.2O%Zv&UMMj9/<r;&.$`_$=IeW$**r$%fah67MPhn#:CmIUfRtbrX'tl&;')/C,D6ajgAmN';)d_)$s_lJ6%[Y#aOar?f,8]t-l68%8p]87.q^#$]7h+;c_/E#Ev9Z73lRH#q->>#vGB8%nUci9EhP&#AB#`/oh_+;Aj9Z7=ucj1I^+G`u?d_8jee@#20Z]4R]qIU7,eQM&PiB#G$mX3v7XI3/P<-vw-HS7,=J2'K6@gLhgXIDngK/)Eq6C#KQ%_mdD%L(fsP3'2AD(&<;0TS0tmk(6+rP/L0(L(,*vN'/*=m'd1H-.6dxvL1x98OZjUDNg4Hmu]%[J7&8jNb7BB*4Mon7e%M$s$dlP=4hT&r.$?[ou$B,bu#tA19)ik&Ze-]'/2Y_'/w0*(/eO9d)RFes./HJvL4<TnLn<27[u/6)Os`;:15CNh#F<=&#2^Q(#X`iJsP7CF*`pxw#xD*&+4Z630WtAo<a8'A?2qW78-c.:/Zqj$7Eoox.rANtIWT<d*UnAr.%uF/(0HtR8e`-_u?[t7.Y@To7:K:7#^m5A4k%-abLUuu,1=UZ>JcM9/ND#G4BR:a4,o2M-ZV>W-O)u,mmNxC6CaYP9,keb4l0_#?5v9U1#a><''qh@.hgI8'gGno@u%/?5Flrc<#^*`-hMV>53et'G-Ss43UuWqMx%Vu>1c=RNW05##^5YY#?N:7#XjXp8fvlG*bn@X$f5R.)LCn8%9%x[-pYoF4TXI5/(19:%Si8;6,K??..&Hs.8E*m1E*B2'=b@X-]g9^u]DM>$*,N+3ff:Yur?h(atkcM9TqIJ19%=G2a^,]#*a>I+tOeY#.R-6']'r(5KuKS.>klQ9:^52'Ij_c)ATW78*eHZ$Plvs.76N`#8Xswn*R60(KW:K(H-cI?w'Df:aj*$Mm+#5]$i5P]K'+40.ChN(nEHxO$LYV6gEMCGo5N$Bwrj5vAGxl#Psn%#([dl.vBo8%nb9`$0^/J3+jt1)/K2H;.IIM94I>6'vsTq/+OZ;-qZF6/PCQQ8Y2%a3ODMgE=T6O$MLCR#3%&B-Y$Nb14`D;$bQ#31fC6X7Yung8g/###d@j%vf1Xx#sx05%G<RJPR.'FGdUZ>#R<3jLGTAG;8.j(,f%L%6]u1E%70V9&TYmpB'9X=IQ#@m0k#IVMg8GkMpuPF`$p(Y>]F;qMjmJ<-9a31/jF'dk<m(8I=Rk8/p`P(PjbKfLRnP&#`9dr#LAO&#Y5tKP%rW>-w>[:Mgu:DNh$Ch(4N%'+8?d'$F`GM&[nR[#0L;>u-Zd%b*?28]oU&v-Zme1M&H?##rp3J-DlL=18pm(#Jpao7U@h8.BL`P%XCn8%mI8o8)@YD4i:Ze'1^#9702:W-RJ%7PU<VKC]<e`EGd-d)ItZDEU6;0C(bvxOMgCs$IqnS%Rq+g([9:h(Goh8%He@s$vjaI$(g)8e]1S490Ym3b/*mx4Gdur?_vi<%#E>G2(,(k)RbTfL^/sv/BTStud(S5@vL#E=_XJ`a2U(60[ap%4fe6,;tToJspY_:%pliG<*qP,*f5)?[nA::%w:GjL5j%H#e$3@.5M%60Mgr/<o0U*-fcRr%;sllC)B0uI2LvLK2biYuCTJI&#'X;$hcwr6eX[OO.i-s$.M73'VVVDI:2>iKUKMh5b;G##75YY#^=u6#`9F&#2Crd*tJ=b*7a'<-,$pNM<LU58Z[kA#c/3bPvtd@3wqLx5io_6/kc-E?B(->u,H$)Eeb0i:XY`d*b:.A65imL:egGLM$QLk3Z>uu#7h'JL#=Q;-/,E=g9K]6%vQ1b<*-H0)]52T/.&E%$NLxKsUFOR:>gLb,49$;/k(Xo&MKS.4;VLb4v%^]7>86X1RM.f;x_W/2vn0f;>`Q/;Q@1f;VlZ_#'c@-#c@j%vku<x#1.58JrI=KN/V+.)l2dF<2Y2T/v^(t8K0&ab$i4iB7tZg;@#j]+ICIWf#,`V(@n8T.GuEb3r`Kc$@bLhLZL/h;ZQRL<&uA5)t<O#7r0BD#ujQ,6.IQcu8#bd;sav+FhQot#:gbm#L#ffLE`ZY#9<u6#rpB'#sP9h&F]R_#jB1&$mACQ/XCn8%=0T8%e+>Z>t`uS/U&g[@kI#p:J_@&6>mNA+wEk0*bwhF*UUfn98JG$,J$C1;ZpV[$TxgY#c`n/=SI'_#nL,299>'f3(/H>#t/X;$,MY>u$M]Pu7no(#+p/kLeeG3Fk5_#$RgwiLiY_:%X*$gL/8[]4Y$0K#erU5/K0dXlS8rEMSh`S(DBNq4`'Nc4pi/(#lgIH#tVC7#5oA*#=_^)*Cmj,MF%m]#.>#G41cNT/]Ve]4a(@l3GVOjLXTcGMDIr8.vZ%1,'G9f3u.r.$o_LYZeR=f2v(ji:jFVs-<l<T/N=@5/@wYO1_Q=3-9]Av$62X22OAZA#`Se+W<3Cm&:8:<-f66K1FQ<[?g2+[6+L4q(=&p^5pu(v#q'ga#.c$s$Rur50?%m78C;tu5rIK58iC8U),nM%,1:l9@eAlf4w>]k(NF.'5wit1))GY##8rdg#xn8*#nt;*%A*#,2[Z1N;lxuS/9#[[$-KPF%)kZMj)Unl/7xu/MwrDW/p<su=@<-DWi7@&u#+XB#n&k#?Qh=/4t_$G4,5@m/*<=981-2</P@[20mhgx.jXp)=ABB[0r'-#/XJZ.4`GQ_/l7:]?[>uu#$?p+2Z'[kV56vkKpA^;.LO.f$=bw9.B>l-$hOjr?l-^v$xhH/*&m@c639^Am,9NL%k^/W$qa?<&5Z'KF9,&fLL3Ox=(.)##WA?$vomub#/=:L0fKb&#Dc/*#.AKxg]+Iu':+;8.6,Cp(@Aim&H,.p98IaB6usH#5i*.k(RrZs.B0p30,qq48OPB@27gg],2e's.gtU3(SmIh,U24`#[^5p:qWqQ0lBX$@7v088Hb=E,a5X70$i#5]/=uZ?:Ci;0:.,R:N;`(,+_,T8#RWmL13#&#EM7m-B<dFeQHViBSQ<s.L+8P^/Z=D<ehrW-X?CW/+A@N';`6E5,?t%,p$0;8R0ev,2-h#.lhZY#o9A`as?/DaOV8>,Tlgb*fa=9.[/K>.Z`Q>6S?MX.Q^+u-.:$K)3361.)j0gMim9>.c'7g)<k<:../M'#jLGM97VbxO9BXs$ire(Np+b]+Q2s-E%5YY#oD>5&K2RPAcEAJ1[#:g)kp(%.#A-.4K)'J3sU^J3pjAV.qEG<%(l'^HM$),*R:K(45Gcv,uR/21d(A_#((r%mv<Ip*#LXG2dkKDNhd-)*wXBf)69k6/w_=M(r739/#_Nb.i`1?#xLn*.xgveM77(u$uw7W-Vx['7?sLEk.D*m9L+,R:^@pQ071K601oQXAr3,g;dH0.4fIqj2fU?03wdA]=s?w(<(rsp.D)M^6]'`K3Xb?uuZrm(#'s[d#(wUv#8exvL(gPA#M('q#tdu>#0XfvL=LFD#<i'f#t)m<-t/m<--?:@-6AMt-1R]vL^D4jL0X%g#IKwA-4;S>-p3S>-EV<^-HL@R<j$^w',VF_A&csw'xen92%S)5SEH')X:'hS8Sv)dEVFaw'8N&.-m-^w'ST,:2)lsw'#vA(sx/PfUP<T9VrlnFMI=5&#l<-B#IH4gL&?)=-8(LS-WbXv-FXKcM=@=%v&d7H#3Mx>-#B)=-d^Xv-`ZfvL_h%:Nb[-lL3`tD#n5)=-)B)=-l4)=-8Z]F-*B)=-(dq@-2Rx>-+B)=-._Xv-[s4wLP*J:NoTNmL5YrPMNkV=Maevu#I@$##wL#5]2']5'k)[m14X'B#4o0N(wQ->%q-MP8VeM<%qlWI3B4G)4k(;a44AQf*lfMT%$xQgueXA`aWEca#jv4WHG]UU8mlxmK]3GhUFYjP$RiM60AY:?-gpcG2tkcl$_bBiB'i/-)NkXn0Mw[301K[T03Fru5fqEt$x]7d+W7rV$e`P##CL7_SABK_S+5pu,K9t@Ts#[)*>EL:%qaVa4O]#b[a3ZcMLdlD#Seb8NXWr4J=7M?#s7J@+$QegY)*nxK:Hg3&3hi8.7IPbu%'mm8*;i'5bK7;Q5h%v#;1KV6_so-HS3%YSh6(u?=l<^,=4$u@'sCT/%R:a#Z/)U%kw[cRHDLbRhk&`=7Ud-39Dpl8cKD@.=1S60SEm6'pNWc>DwEQ/%,;g*8'Ua#$%Pg.l5D>5vmo/.D+WdM_OZZ$:mSB5i2Z&4'3R>%^-nY#-0R0).USJ1[h-x,n&,]#aW/W$gxW(fAD#29fFxIqBIrr$5BT:Bko7d)eZGonpVtI<,ph(W:UTD*xj)w8(#-S7e/5##=KL@-vm,+=cUbA#P+_H<$=$GD$VpO](@x63-87U2gm@eun,1l10a.-#]en[#A5>##cRXgLptf@#/2LLM5+=p+jU;A#TA>F#%KYb#_K1G)Y]L3=p2X^,xngxO7/Ik457N]=6a><.(/_Lrw8sc%t;wj#iIrtZfZF9#m*^*##>[S#C`R%#BC3#$g5]+4D@*Q/Lp:9/28m8/DScQ+-v#f*.Ps<%x?d`4c-w_+$sV,)RZ.H#^6S[#FKI>6tq=/(EfIa+hxuF+jS&0;maR>#lhu']&7Jp.nC0N(WSa-Z>pso7,+<Z7MC@Z7`pnL^GHLfLa8f(#UJmV#VkPlL,W:a#_R(f)-<Tv-pwkj1q:Rv$]WD.34AQf*$w/<-sBxY-hsHT0(ZqV%_Iw8%O@9D45;KO;NuGD>Y-0R/&GjT/-3qv-KBn$,t,`L;HZUC69=Fr.D3)'>R-Qn*w-Y(-jAER:)i7t7LpkB,';1Y&^QMI3bdIm0x&ObNkvAW4YG&a#NCZ;#N_R%#IhJ]=<]WF3rQv(N:cv)4FZnO('4p+MO5gI*t00T%9IVN(<BEX.V^5A#c99P:;N`W/#MLK:?`<-):wFO03YI$$qmN+`.Im`4S+*1-,0kV7ag.Huo^,;Z2LZ%,8.s20&.&@#@*,##NNft#@ZL7#%t=W1+uI8%$3Tv-tPYx6X->t]w=Rv$wmdeMM>aJ4OHN/MQ&GZ/,%Y`4TilD>k%mY#HXDL3>XNg*kLU)5tV7'$S)NM2g$Q2(,FQU7he0Daunf$RrZiE@k7CE>empC6wMff3GXYQ'2IGk:%3LqBrV]A8R/6c%vA,SRIsw4].D###X+U/)(0fX-NN6&4nTDuP`+3AOADg5Yu>dau0K3w9D@3L#'nwu#9Y$MTA=*Xf<4co74t@X-C=5s.gV]_#Yitbr>o[@uJpV4uU<_-MCBa/:#je34cu###E64i:sDo`=qa:Z-YhH1M[5g8>h>o=uspMW>$h1A+ACJ99w%tWU>l(8.CJ[rd<o###_WY,m3>:K*vqh8._r29/<mE.3TXI5/=We$5Tbbv.v])@$hRc&+h$JW$Vm:#$:Ps`#/ceV69Hb=GVXeY#aacj19hJW8s/QD-2'b+.#esw;v%W<%KsaI3nStv6IQ)e&A$F:.2kK'J_'Uq)97$G4np8wJC#,K3#<oHDTBKD3HUu&>&;^x.P%*bt#^kM(A9w%5VHw$;1VChEKl;v#/[Cd<LH9aHe3LAAAVF[.l<O;$Q2F::G7FnLk7Wf:Ti9##mIfFuadZ)4oh_+;t5HE#Nmjv%x&L-Zhl:[0'/2#$Eg1$#l#'s$^f)T/JR=F3U-4]u>@YjBLWE<:=eS9$1j<e%abgquVZ?(#Dh%nLUu)?#QaR%#ZJ%n&D]R_#h;+t&o6Sr8;i]q)rJ3^4gmM>7Q]X.)%kW_5KhI&6L:>@5:S?@-R*.C#KSj**MH-)*fBYD#;1ip.i&a*4:'?U)[fG>#qQjiMr`ID*`nchLu_.iLon/d#0CP##2i9j%F[eX-3tBu$TukV-t.DB#<q>%bV51Q&D21;H.3`Z#m&2&/-(0M>ra/[u9.<A)5F1p06p`Fr^R.Da=wfi'BT%B=I+7s$UXUa41mGx#t*320k>%,r.,cq$&;1?#KU.n#826g%7?vc&6jN]%4#9Y&(_otu%Sc##U6Xc2UaTM'Y)'v#8=3M*a46%34F(Dj3qw/M5,M^#T9`c#wQ1_%-$:u$?]d8/iKhx$*)TF4$f[$$BvRL2e'9/1nuN.3qaQ0%u+Mv-YOi8.MkX-?WsPG2rgm.hAN9h4P%r8.wwbF3*EkxP%qViL&o+k.J>Y#?iWqv-X3Grd7:#@B<NOJ4ed5N'DVp.*Bhp:/R/jg2je./1)wK30qZd`**e=p%p;=$6rM-C#3d)4'jLm-.RKEjLbffc9d@(<-:QDMLOZ7JM>%H'/5PLmKvQN`<mx^c;;TTP&:i###IN.A.P7dDO@G%&42CZc*T@lF*qZ+]#@=Pf*ELJqD)Rvo7jgHVZ`aQ&#^f/V/DYD`+]EDVZd%(gL?.M^#A>cY#7OK@%l8YP,LM)3RE&NfLY&o_#nBEh#6+(p$O`9La,.d-78@mf(&xT^#Eh$4,/XjfL#o0a#0.Mc#F3J31E;gX-VklbuE+1I7x34V.u#U'#5DIU0TWt7IMCn8%NI?lL&mu8/BM#G4m'hR/Gep02n2dv.jZ4K1x[4`4:J/l'vPEA+k'i=6&a/m0NCGB#xwni'[B@XJ-d6i$U'IdGFHh1p^^ahLi&f_#5V6g#;diR87Z3j18,,D%T^6R*LnHg)-23w$vw9g2Ao'/)4XJR/GA)j'M4V;$x4h%6^_(D+b3I],BQT%#Cww%#6@7[#T$M$#,n,D-[p&c$j`H+<*IDH*qc4c4gSH+<'vHC#B47-+$L;B>rC(tupu$8RIMd9%-%(a*E>-t-m+5a*Q@fN0A$=xu^`>j#ck@D=v(-f;SVlA#$'[*l>5(iuh0Xoe$e#q,p5SY,_q#Mg.xvo%mie4;q#_Sg)SQ`EJ5TuumNBA4gI>?,'M$##_.ED#OsB+$40/s7$X,F>=k9a#8Mm5VK,FG4>Cst7d#RWISOa3TM1gm$9teu--ZP<.UF]?$H0tV$Oi$w-`*Ag#5IFW%#cON+M_2@,ppgD3sAj9D9.GPA5/:s$;it9D^wm/==EnB(-j4c43aiCG3l/QAirxF4=MGa,I5)B#4xAx.VvnD*hFkb3IWp;.ffZ#-.of,3G;d=$:39s$7Wsa4hv#E3%*I>%`63v#*t-k(1;[C#1Ri<-qNtc22JYY#Ni&crnx18Ie-el/$jXj)4uK[%o)2isS_8u.HcjT%*Ob]ut&la,&PLM)g:DW-T#*SC9H4O<&bjV.ZkxN0*JV>7o4.'-M%H-=1Wi>54k'(GvcZR2j^*b&x5k,3^i/p7m-d50bfv_J5x,c*8&DT.XkC+*,C,w$/]im9Er9POA.wb`w9bS,>Vl1^o#Op&eBbBS(](`+1l<ufp>&f3CN$]1aNft#2b2<#p&U'#m.B6UtR4I)m<xZTDRaW-pToW_$dIH3xLHx6J[w..x3DA5xq*a,=HwQ'1W1V8)BW,FReL@8Qn$MK/0,W8[<JJ-(fhW-1pmp,`-mh2+`PC5U[V+GO/UL=V38@#Y%S49]u=*t[Wkl&*c68%1->PJu/DR*WQ7d#P2hF$vxWT#.wkm#&Xr]lCh_@tJZ]Ym^[fk4J5YY#vFZaNZ#&^N.f%Y-ihtR*#MBS*ifsR*>s<JCk2<#v6KX*$aFX7/uuap#g67#MniUU#IbN$O.0.A-Xd4`PwJO;P,c=$O$^k;Pe>5?e?H:Po^xBi^T`KwK,*BsNWY+@OHt'sN@97;#Qlsq-:1pR*6xxc)L+Uw9:0,5&%BSVQJ;uQ'J.HP/%D;,2,%F-d%,';ZF9=$?d;>2T5CV5/**n--njT^#f/r5/f5^i#<&F$M6TW(v+[7d#4s).-,Tk(jA^qk4Nx=S*M)G5/-smMC.dgR<uL`lS6,LAcQi(R<g.t(*RoRJL#dw1g@74Vd[&-/(C'r#$?J^2#Ag0s.]+N%$c6cR*>a[iB5vMR*^GIk46(Kk4'vdM'SG.l4jH9JU9=N&5pQm--Aa+;n]Q2#v:b8m&Zfcrn=F(B#b06aN(SOvOf/fo[(<gSoq/)Se2PW49f._#$Q%6]M;ncOMZ5wtNMI(U#naMt*gN/<-o(Au-)(gb*[1MW-u0lR*L(2AFwAnQa)?>Pp?LL#$toaE,<u-3#c:Au*A/(<-Znt8p02(2#[r`=-?@=r.hnxc)8_s92A)1G;uI#5]M]?0)*c68%$*R>,6FI#?'f=S*70G`a:XL#v*.>>#LFlwLaQ7IMg)F8v[LU3v_htgLSI2V$W9xU.E.k9#?%&'.Ks>s*CR39.#lm%#'*[J;*[d`k:bsX1;:1&+%1V:vCCX'A45RPJj1F/iA9]+`T[VB>v4(Z#WWW5/K'(L5dK_c)8;tKPH'D(vKb:aM?%]:.KQTfUpxc)46S>M^*sF/2o.,#H6bd`k>o):2Fhl1Bl.cw9ae$XhI#cP/6>1#?Tu#)bX/H)+Xu#)b=[:'#=o9+$^q''#<eq#$=J8=#q4NQ.De$5]k@0,j^)::2),a%$(hEVMN3#,2j90_-Rxv:2ropf::kOZ6xc;5A(bVw9rF_-Q_Ku1K7hV:vlBl1BiHF3LwP@PfZiBi^&IGcM@bUU##R.A-NX_1MqUU%O_JO;P4=1%O)]k;P1*fqNHj*<#GXC9M,A3uNL,O<#q:a=-69vhLaT.Da5'a]l<W)lXAErR*]#Qrm(F%v#QmC0rG;o.hYC18.OR$##VP4WSR2qR/386J*L^d`*5eYo/Oaaj19^OM0dUDX00_+l=8vDL+Ve]Q057oZ$UVvxuZcl[0Ani5/Yp*##Cmd`*[68<-.5)UNI7(p7ieZJVpbR:2HrRR&k[kfLM0kB-qG)#OGRHlNc@1q#1Xk,%Fa;5AOD>K*)_Uq#>H^<N+2#*$0w%Y-ns7o8BPuR*'MtR*%V45A^S19.x=?c`[APW-al0x9gK8ppuU+$O/+L<PaEgvN.i+CNcM<,#f_J&$5`pO0@####oa)<#HH>I83-*Z6+^rR*#&';ZiX)<-BxE$NNXUq#ZU0O.ED$g#5bd`kLC*:2vl&crxiJ]t#8'@%=<s<#2BYvI^a9m&/,IJrefwR*3PsjN3(,T#-sb2vZu2%v(cV78<=q#$7)B.v?mnbNH8.$$wv@-dNZ@(#%'D(v=b?g#;*V$#QhJ]=c%@(Fg@H0)Et]s$'Sf_4@H:+<o[uS/,/DA&*8fk.^@1a-_/QL.&6nWSVDS'&X,bC5LcH>#5#$/4#pT#,QeKD=Ip0)5<lFQ#74/'-wU#r#+Xu`uMu3F'Fi:v#4mP%7[pRU&$9tV$#5jw.$/-##@CAd*2%?r7H@8'fWrCs-;$%/P?6Ir#+U;r7+c+:]pb5;-*c68%m9u`*7hV:v?XQw9n5s%O?3.;#8Y:@-`33:/43?;#Tt[fLqiTt#p*X9#o[lc*3MrR84xaIDFY$j:WKRa*t+@=-J3GD%I8Qvd9Ui5/RSAeZRncV6YUh?Kk@0,jmWdeZ7CX78i2tudJch=N9W1]M-)Vl-h/4x9F2$j0h/n:&=u^qrKG?/17dc5&aMsR*g8r.Lrjg)&:wMbNN8b<#b@X7/05YY#/3uoLX]tJM*k+T#PvhxL]iqp7(0PR*XYkxOr19:2OUS:2(`Ul]u>Ar7v*(m9=R:B#d+2,#5m`=-N:xU.[>#+#2Z`=-Ws%'.bHI#MYc'KM4=Rb:_=>H3M)'Djb>7R*Xw5R*5V%;m1<6X11d$>>m/5Da#dw1gYD>8%$7g+Mq0av##[6,vIl>APbU38?wC_q)wsJ:;Ua=:;&n$j:sEeum:IC^#A`1eN,9mP7g-OVegapSfhV'v#`WkJ)jIU44<;<44w]u=l1,WE-xs.u-&NkgNqAo>Osin`*(`)9.#o%6&?o1wpkG[BN'+av#1tm6O.CQuuhueMhq:B%t-82wgASVuN6R:U#lvcpMV$<?#KT/(M?V;'#M)-$$)tZ,vxk_v#Bc]=#dO&;/[*DG#PmR'L0i/,jRVx9D:t)GDtnc`kw6YR*Nx`5&+)Y5/u*3R<2]Aa#dr:T.f5^i#P5c(.Z?L28-]L&lRF?5/E&o--`&xYHccBkFui&crnj]J1[?#9.`3Qw%481#?,41QC=>k<#[1Rx-X&ZTMC<>xu7,eYO<^DANsYBX#8g9hNV&8#OFsa8$'`M=-%niX-^==r)JIo6&,oijO5FEYlk'RkFmtDkFx=tCN+1av#UQ+2vFnxe%U,sR*lnuCsnif9Vkf3(A_60lMgpM=-'niX-@h3x0&8d#:fPRh%YM19`Thv>#*1/aN'IM9Ni0av#,bp6v6<X7/`iJE#`2O$M:Vi'#-i_v#,][bMKfZ'vFk9o/F.v/vr+,##Hg`m0_DZ;#$hJ]=f/*_X21j8.#.PuY2oJDtD2V2K2X;<%0Rw:Hhmh?B:r4R*RuTGD@$ev$Ob?H'1Xbw9=A@T.vn8#([JTc.'8fl#`x<J--23Y.'Yex*(OM=-ox(t-3RB`N,i(U#0^x9v^3H;#;bn[#c.Q11WM`,#,),##tfd(#hQZL-u2/IGpk:V*bG:C,&=Zru-,cIDk@P'AT_4'o#22G`iqAT.,;-$v4T9o/089q#`l''#/K:t1ZG?C#L&>uuSJH$v`XKHOU*.V#JKJR0wN@)$?mk6%TG,1MSSl(j@<QR*ieFDtEi,9;Y0av#V5l6#bjZp-(22:2+44:2f%lsMZ).A4$t@M^'@,GM76#,2gD(FI6TlEI5bd`k:c):2#daFrnQE20.mU`3*(ix$`'__$ZpY]4(BS>#oMtP/CLY(sU=bcMo*av#eorUMq2oiLYk-AO<^DANs]Tt#KKkgNX8oYO#6GgN$Ao>OG61Po#$KSoS%sd%/7HaNCI`^<gMf-?(Ku1q:7mQWkG[BN'+av#C2TsNpNdY#:NX7/YjO2vH%ffLkkTt#>Rb&#e5KJD+IFq(W8Jb'T)Oa*ina=-x6hH%mcpS+a%)4)0+4%v-`'hiC$ni9*c68%UJL5&h;3U-tcPpN;'jB%_g[v$;5HlMF=nmLEBT?.W^=2v1DB,MGY-tNa:lT#Y*8QaQiQ.87ka/i#5(v#Qun+MQV)v#iTf_%uB##848>r)#/+r)uhQ>#Q;hp.JQw:QFgn_8ktq_8P/7ji3>3#5)^UiqQ]D)+.53GsAEss%NPViKXr[q)-u$##n?9Pou<oJjM,[TMQ1F7/^O9:#4>r*Mxm8NMkL*>N2Fav#b5l6#+,Y:v)]bI#5bd`k5W,:2rfA(s:s&j9-o;&5qK0/rknn?96AL>?,v?JrhhiX-qp(r)t*CSepDP-mxi?Y>rxTgL<Pr(EA%Eh$7OC^#.%TgMAC@5/>1=0O.<5xu-DO*$YtFf%94+5J&Se?Kc5v:?*Xn,M`L4RM7l@iL8YOh#udqw-dKA_MUW6'v]vis#%[`=-rvCl-'%Aj4LAEG#lC@j44FEYlA<]'S?_AX1%Jt(N+1av#XdF2vD_xrL%'x%FrNR5/hQP</_[gq#+OK`Nm2Z@N]xTgMh*88%VShP&F['LO%[4v-bf7RNovuxPxV`D&d+U+$KXtGP+)POQ;=lT#RFkcM`e&V-j0Fj.Mif=#Cq%Y-Ff#3)<n@_<mCE/rx(xiB)ZCMq-1F7/i]dC#V9.#MKnX)#-i_v#1Vp2#p?<NMDbf7nk@0,jG[c?g8LL#$<9xU.FLM0vJYU[-aK_R*7w<SR0:Mw%JT;r)mLJD#&;Lg2GlNoec2Q;71Cm.j9-D(sC,sx+Q9,)WZ1jf(xMu(3f?%##qt-c*8%op.n3H)4fJ,iC.5F.D8;$Z$m4dw&lh`DB^fHp%'3x=-u3_`N2`R1K3C/iCUgcSJ@f0oiZ&L^#KUkT.'U_t%%eW[,hCJ/LgQhcuO4ol'&8D?#JI6^$YU:v#+)Kc*t>FV-b;)^#2'<Q1`4hj(:g&##Grnm-'HR?gS%c?gHq-W?D;Ulk[>mRa3t+?'K^r]u)#'AkogPW7fg^2'4>Z@Gpn:oab?YW7xA^t-)xs7MbI5xu2^hn#S#M$#uRUCB8Zu_F^(tY-A,#b*7g1X-SiK.D>YD8A9TL['I_tj0:=7^$AvV]+qS+&FV`3Z-.o$cE-A$Z$['O>-b68*&nlSmA_od5&&3x=-u6_`Nf/sR[e*R38pq#0)XtEX$<LCr(@Xla*s:Nh1Nok.#%(9q)XS$u#W*Y6#S^''#7<<W-I1'C4*^B.*M(=vGuU:jXFb=?.brdo%jM^J4ce0iD<OxW0l%3a6RY&X/bM,2=nw1f)wa%r#`N2lS3k@v#w-1h/ZiBK<_%M;$pdeY#)j3i2'>%h*QiFC0$->>#vd+6#Fo>$&ie,g)GuEb3_0Z?R6d0S.:>8b#xZ5m8Ho-xk.K15:#)>>#cJx$$@._^#G$###bmj1#i7b$M$6=r.hBp*#s'cOK(UDt.JN0ogG8(q1SlwFMQ)jr?*R<P]o14W6*5:VS9D>6#=K$)*$_eoRBPec)Yu8>,D1$##)Tmc%q;Rv$CO[8%i1f]4qkF%$RqJu.>I9]$/5i^#p*x(/WbS2'J>1_,QYVc+`*=[7Zn/a#$>Nh#?uNZ#$a(c#n&dp8+FZwA#`upbZhuDuL]Z*8>q@mUt7lg.v2YY#u^39`[)+P(]XmV-bMK$3.viQa$M?&,uDic)t?gTCxo[6:VIRW_a:Q:v6C2629Ui5/MG'##ig[rQJjX(aIqtiCG?e$$Ph($#/CP##E>uu#>5w.1pVH(#N1g*#]pao7w/-9.rfeD*ERM8.xB:a#GW1#$H`+Q'8<Nv6mS@l1e]ic)NIce)0E-<%>;gF41[v)4W;6Q8/cA8@TIo217?x#6aTNH*P:q02bw320#'kH*ApT40b(WB#?B`k10%sR/.nYV/$i*X.2PSfLVO0T%7&O]%9-.sZ^8)9.E8;(6Rl_;$Ebl.F)(=j=i2@e<#'nJEi2=q0)]+x7EtC#.gdZ<.EGig45:=q98Q)lK_W4atY&9A,)7kBMcL$##IZ9#v`jVs#Ve,d$$=?7A#'g*%<<Tv-q)Ya?T9Z)4v)[`'DHb<>'vQx67;$UA<5'S:8fRaFG(/d+,Mo@HpAv++B+vC5'OGg1SPH*Rw;Y5&#N>p%(&9+4%mcN)<HEI3/V^P8DMtKP-1>,#.gId#BZI%#C5#:.+M>c4YCn8%6l*F3Unn8%OS>c4-UrG>44e8%d-hOf-IxY#NjG7&^]x4]i'qCs0f+.)`+`r$:dYi'3o4.)V,O%t#)>>#/]#%$p-_^#P$###e$$;#Fwj$Ot_PSNcf^rQwCZ(a(?cu>=@crZJ`ur$ps]f1gQ&O3DR:a4+RsJQHp7(>eQ.:/cR1+*lhF`#=YG[6>v[%R7:2x7j4^N2j1E^#8c/q/x^)tS8w3b0p`Gv..Opm0ZRg+M7Q$##i%#5]a_LS.ed3QLg>W.3^NOf*8=1U%TWXU.#19Y..C9U/1Em,,FA0N2=npq/vQ%5%7pLv>uc%5]F&QF51lC6(x`/&5UMYf*'JMp7Y$@B5Ani5/o;``*'&.6//cCvu3fYLMuwRiLqj_k)(36N'=I.[#/sxF4)>x]4&6oO(*f?5/J`5T%dcRL('W`s/9Nwk(X^pQ&h=/3K*1$5]5;78Lm@b50wvI<&jbBc3qcg7;q:onLE>?>#:6Y?KdP?##'6YY#PWld2_WZ`*2.ZnM?o-b#.7>##5f1$#Ul#:.(^FIDd.s<[tG;kuvX%L?$KtC<i%a6:&:e;-Rq,L/X<u6#2u/ZHDP*j1QlaQ*(^E,-NLra*V;VX-np;+NjVPd*RqRJ16<<a*x&i7/:ORwusYWjL)Ls$#t@Vo%;>.[#'s19/uh=+3&UCa#+l'+*o/Y:.@G.$$n?;_(jdrN(Cm$7&sp3d*BYQmSW:i+%tejZ>__oGV$M0%t*X>%$3+.<$R0(11PDZA#R`9;(HXo@#3+P:vTNa&$p-_^#_$###e$$;#%RJ=#YYd$v]RuY#wB%%#.9J=@<65%PK8Ld2$-2K(RkY)4sw(*4X0cKOp'v&>U3WKOntl&>rxFOD)@@Y695FOD-Reu6]]D;$`1S'AWS=i,.mTf=j^g],+p#G>CGji:Yr@>8T]cL)TSM]7Yl(i)_g2[uJ$YZK9fIa)6E`&0?5YY##]x5#/RY3+^@]S^bRZ-]8H-v`Qg`Q#h(G1L]NR>6)XbD+xh)N(s'O:IGKtG4,%/[#oNv)44*x9.M3kf1]Q_p92w`<@7jA4;2hjoLuH>C37Yp+*YuFm'1cc]+3oX'8OBcu>xK.8R#&[j0P3]uGFax9.]BF:.L=fI*?O#x>rCBloJgJr%rL]Pu0QL3M4uNvUqH:;$%*&##f;U>KPhX/%)%eX-.EC_&IJ>b>3ooc#rkYN#H`'AImL4AuN&kB-_4%I-N9@e-9Jg@9X=:wgUdnENAX<Z3@A2T/l1*p70]G>#q3LcVj<Iv%t+jX:ip6AuoJ^sMGXW'QBDS8%g`5J*e#NhL3Y/,;9*W;6)&5YuN)Gj`3AZt$a:`'S^(D'SdYK8.%RtD+HK@db&P4@(,?n,2th[rB#:Mm;ocE</bP,2=o-V+*jG+(;BGaB0&0L%@OYCv#.Fqc)VfL@6J%0)*sR9'#=[ewuc]p<NjN[JVK00i)V1vCj5$s)=`ikE*-JiqDs)kP2u'wpEd(inL5*doLQGt<Y;DuM(s/g;i?Wi0?9drNkcH$)*gS1/UTAMa+'8NY5>uh;-%JEj$AmUZ['PNj$@TcW-Npt6L1tlb#K]uA,Jg1k'3m$.2WSFa*8vnH)FFIW$?2&Elp_krB$@Vm;l]E</_5BP<n$;f)tN`q#ea`v-N^j8:rXR`,?)lm/BCxr8a,Vv7PGDE/=whW@a7K#8QPM-*V`1%66'=;$UW)eZFL8E,^`gs7CCcA#$1/^&.l8^Q(ai+=j//#HsL<.*q<2qu(CcuPrfjxO>23'0(0.j'Q1g`*=nRVnsxls-<Wd`*?5&a/WNft#QN:7#%QAW%3_6d)SSo71jlnr%/BD80V(s;.NlP)>.X?$?(w:N4jp0N#%')k#KQ39%qSuY#NlbnD1lJs$nO239fSo<U<&tT#k8YY#BkR-HAl).HK43685auS/<h(k$+$4Q/$Chc))Y9ED+K9uIP(iV0>))A75M*B#5J*V9.u.`,mbMu7?b[-H91DT&(?9W$OXL_#v^L?%XKD.hYl8*##?mF@7Bd<g(')8e3(Lo[qfQM4`l###FH19^%I?c*iXas-t)W5Kqa0^#HRQ&%FS2)3F[I81Z*Ys8-R?$?;/gG#E_MW#$=SbuIV;'46c5G*X]+m'ka(c#s<A+#*9`(v'/od#KB%%#nIPc*[,;=-'Zr].<kY)4@o#T'JdFD<5<-E,5^AR;'bB),3(UduDD`Y,1eQ+8OA@/;pV<%.F,^N<2h4l=PI8bIlhg*:T[6uI4q`m*J-5<-)+$P.D<u6#3dCW--n/aY&11+*blgI*-G]fLCZx8%iQ:a#3KDqqOF&e%nEd.<WP4e)TD?C59]F%5ESR2'P%Ln1fhG<6>+RZ,4Uff1YAc6BbF'd#=e_;$0[QD*ND1[68eI>#=t;TfTAWH*cZb,2HFwB?v6'XUN>uu#6Dt[tRX7Wf<L$29<Q><-k6fT%<^B.*qYVO'9r*F36;2]-[cJi%D;LE+*_%#6_w<Q/`wY/2]2h88&cFU?YRxc)3UL#,xqI&6sOKf)VYfP'8U,v8+6Du$u9@kFF?71<QE8:&jq6,;pKCA+d[lr-a&rj;P9wHH)PF,M>8,,Moc]J5AL66'OAF.=)RPHj2'7n0@Y6O?`.Nh%E-XN9O5AX%$Z4P/tQ8Z7%/5##A4YG-aN'D2/Q?(#.osA$`-J5/7%x[-[Fh<%6Jq_,91Fj1>FrKGuhH:.OM>c4^IR8%.%f;%C=wX7o3#5&Es:;?JRwo%NCs]7`#xV@(3e-3FxQ>#WCbc2L$%L2Y^=$e^'<VKsmc=$PDed)a)H7&1BmD*+$hg>S;NB-wqOQ'9R`6/Qj+p825<PSXX-;;DC-$$btHP/NZ=oL:w5/Co%8mKUfhv*>oWr.=,vs8(<J.DGPtD#4V###o7M`aE4$##I&NT/-L(+*mx5x6Xmit6hIM.;s`;<%U@h8.vJSCO,Qj%$R^oYGDOt/2oDV4'>h*=$fLWjT^%ta*<pIT%(P,(+nv0S,uwrZ#iKI>#:>PCj>cYY#+;###Em<P]#4S'JFHk]8dJ`]$C,MfUj$xY%`mxW7?A[O=A<_^##(AY>`,wE7@IEM0:$hW/#C7f3JbhZ%bcxF4$F1x$R>P]S`GJ]%Ju,O(*p'I*GGC_,,h0#.XuCo2-rVC,uW:,P>.CB$`j:#?]?Iv%+BfN<E9nQ'J3[U7ht1x5s+jvJ=Z)v>[t?<%O$`(E+-C_-(/Q&#HJa)#u$),#leH:.R$F:.bDE.FIf9?L?o<?#N`=W/=QHw7dohuYhd=-4Hxpo.$[b4ob&k5/QS'##eBDYP7j0F%PEcu>Un;>GDS_s-l;lt7-+s3r`]=cQTUlp%h<JGN`M<S.rx2a<Na*31^b$q1M&VwKPOGsS)CuM(SAC=o5;7&4.'2K(E#:`je)5<-pYr]0Ho4&%PPA^+^38G=NbX4OI/Ns<*4UB#?<xmU$m$MKcmat%>h;AF0X%v#i9el/Ojab.7I7g)k1o7&V[3:.,[0mraNgV._h7Z7_O3nN#w73'PFc>$gn;AcD1Xs7ZF3]-nI>B#)/9q#sk=+.m^ZhW*aQ##>^te#E.BC/5f1$#2@)78Pjat&Pg30Zi`wYu$:LcVr'SfUhUaR%B8Q:R7RW%$%*&##'f>P]A9GJ(8c###U$fF4:xmm%pf*F38A2]-W_K*:R?)h5AF%?-VRu]%<Dmc2[DY&d_&_Pu`E7O;t;G##/nn)$&X`E/`9F&#_&up8&*6s.1$&F@xnoE@tWBYc$p*61@M[M1'8h%6Heb+FB;5K3[bv#@._cG#q<d1BY)=.751i7Bd7D:'f=:Z9O>C_dVB;::EYnv7lUK@%:pd'=.<q^#Tcni64enD?G7Dp7.LfC6TR-##XW+:$-[L7#eT0EYALYV&CWLD3Qwf/:(Xx#e;8Uv-`L+T%Zk&,;jxcv6p@wqA?M+f2iM#f*m0rr0er@V%OZb#7`)051g'=$@2W[LOWpLS<4qDd#dJv/GW'Y(,Y.?u98gp9AV6'u:.TV>5#2uQBwR^WKvQCa@/CKR2gZV9M[Y[Y#,E2gD+NO-X5it-=)?::%xV5l9d0?HNl^3Z#KQ39%^j+^)2o:nUq<G##K'/1=+n.T&I[QpKQEHH3g(-I4TtJcV7q#39]%^]4H*c6:3k?wU2P*@.NC6##,vK=Q]QL'J(dm_#q6B58Iffs7:%xC#G4M=QH7:B#/qZK#=r);VmJ2,),fj+VXwM=QVX6Z$IaxjkAntF,hg&%#&pao7`J_#$hBQ;&(YPQU4f]V6gG=a*$iSp.XB;7X>#Y42&u@%b>q@mUrBP##Rf9+$TQwF'NwVQ(TNZ)42C3Q/DVSfLxf9>G9Qw<?]T(U6knuwtH9*Wo=>[6:O#Sk#g=A+#b;MY5;Mk]Gig'6/cWt7I#o-lLX,=a*^Yn20+4GH3ePsI3H[Tq)/S#==P5.,2]ECT92tDw?Xgv_#jeMkYv'C(<8on[u29HU&Z+%-+j-3]F5eXg6'fQ]/a8MY5>g2&+MAC@BAWI@B6I9e?Yxa3hC_eS1]Q_p94-&X@Bao:JB(TUp*^=L#FBDaIt>I&#:>h;-`/+v/W1C.*(o0N(7C'%'1:bp<Rw%b[XTqp91tV<@EDgG#w<Sbu@LFgL%Z-G*WVfP',NWb$OBcu>l4=DN7'Os-IB+59gpB#$8)b^#:>7M6p+=DAA2(W-#=d>CcSUV$r'1;Zm(%)3CK_%.e3Cx$kHL,3hj6i;H%Zg)5WLD3C$LZ$:mb;->XS-;C[Y#>3Vk4;L#^p.`Og41]2Ak;@TxG*[s$v.]owV%>Jaw.^_fb+jWRL<=U2B>IRUf<RdK.*U-g?7ATC(@9ep[#xWLZ%s-2nU:$iO=v<)6;';n&#W,OJ-nE0,.4V5lLaKr8.<5*,S,1vR$[SAtY2Q/gUDwXeWAT-##($###5^x5#qL4_$)m8+lJ7Q:vUBBp.qOh5/KH*F.5>)>l(^*`sF-]#?OG^P/-&Fx-QX$##3L:a#h=S_#'EsI3x1f]4^>Cp.Ug'u$bh#_H0AH`,P?S@#<=ej)IFHO2P:s<7AO(u?WRx21`,Sc=eeSeET?;&%5iLv#C$j`3>#P`>Emj61gfEp9kE?$$SZW_?Y5&E7;O>d$O-*H*_]RfLLKQuu8Y^sL)dZ##hQk&#6$r;?H]LB#ceP[6N&#C?o-IYo5cW?+L?cu>LUrrK_Is$>X+`*4'.5I):I(*4LA^+4?A2m$_x<)-*Cs%6w&F9'?$0rm-Yc]+5,OA?c.Lp7g3g(#uPTW$sm'Ra`kJM'*a(4bj0tm/?9$>2=;TduWd+W%5&6W-]Tkk=7J)T.i]te#*[ru&b#G:.a$s8.3hNTBxWnm%Y'aacuG$<6@x1I(6Dt?%c5gauU4JR/oh:J:ZB]VHJa7p/5AQ/)m3vc-=pAxL(A1n)qEv,-T?7a*17DM1-.<5&4c+/CqOh5/p5?^QuU3MKgktR*I]oR**J]G)Y<CcMVR=5A:EXs$:.fVL#%,cM13*6Ni?E/#s+,##DNft#cTC7#@>#29rZv)4vcMD3k=S)=)(#H3ep?i;bh;61+<<T'6s>+<Z/WL1as2,).U_*4iomw71/F+3_9e)4=ve)*E<6^G+C+;7-H$4CmV9n1$qU(4fbqj2*$'gF#GiV$jn%t-S1b(N7SMGD#Zn1g3TY;e.w)P]x1^,MPG]0#+V(?#krD#M$O*Y$6i=R*8i)T.=_Q(#NQG)12^oX#_^x5#K6cu>gi8T/VCccM]'7<.cs<H*xNL,3e?S@#JWBW$$ETs$h.W3;7Kh-2>3ax5p`Ba>ph_0(TVYlSkhE4oL-hLEKnn_%$`9T70](Z#J3ug;b%1>,OhK)3^a]V.h?bZ@_uEf%D05gX8`h2#4SuQW6nD,MERW6Nh39VMFXk%vQc-QMg3T7N.`XjLYH?##lt[:.<UC7#%6Z<.Sm`Crm9BV.+UlD#'oR$,bb,FI1A]fi$c]>-Gjw50s.:v#*(IJV7:lA#`8=r.3g4u#l`3wp07`9i,t4A=8H4wp:X_#$pt&[OZ?>.%xYLp.l1&5A1QpEI..%###?D_AhaQ_AUxC$#&R1P/8TXI#MQR#MU_d##VtXs%2-3FlVHQuY,?Ya*P*Oj9aa0^#:/De&+$4#?jO8Gsr5olTW8ulK7rGW%Ehtc)HE=r&[+TY,Ze2/4K;T+4o`0i)&UV>PDB7&4R&$53+)nF/]k<4FT@SfUT5Xp/XT[S16<h]=DPf]uIU=mLr1#xugV/a#;lUL.^3=&#t,V)3T-70)%R0#$]q.[#<<UD3$7LhL'*nC#YhSH+3m:t[DW,<7f7TC4(LqObRt3v`QWh+8N_*&-rx&E7)4iI_UwCo:9l$*5UeCJCBl+U]Xhll8VF%##84i$#]TYm:_dX&#s?&UDR#XJM@XcO-V(L[/*AK)Ble*lf/_>W[R#$>YcbokNfw,`-%4'O=1E.;6u(Y>#wvf;-]4;T1E#0i)TuLs-OxB=@ip(9/OM>c4Q%C`$bRED3>-2=%ah$,4&fl@5t/vi4/L[u6/<=]/=(uH=,0491vk)d4pBSf_$@,'$LBdL22N0493/X.3#c7<$$G@<$+U)e==2@s$QrK0<D5YY#w^&A=_D#kk/r-5/QDkPAY,@#6New'&Ef-Mh+(^m&koe-)t8.WgmJUQ&S9KTV/T0&?B(Eg*ecmO9J+U#$oc;.Vn.pA#OKMHeN)Nvum.Js9qV5&#ChJ]=@EL:%SL?&%92@R/&o0N(H-W-ACZnS@e>L^#bVCmCx<g7/*<M,#$FEtA#/=x>^:T,31jaC$(q3Q/BA4gL')60)$G)?#H9fW0w6dU0=F_t%[kji4nK[(+Y-E%IZ2,98kT^uocrBd*xM=21(?:&lK;G##jtmg#.goV%`o###ZOeM&pM3I)QuMp.$?+P(,@UKac_w[bNw.[&HRHGDh>)01uh.`;(mUv#*b&p.%aDE-WZU9&=uJfLTP5`%6VR7/Mt:7X#':M:2lC2:==jJ:Juq^#P+#`sKX^+rWwZ((-kob%g9uhU-E[p.U2&=/$sl>#v#m#H-DfD=YF0SnZfDT/Bg:b,+qFS92$QZ.bavhUNgO)#m'p&vw[1Z#/#L'#Ipao7RIR8%@4[s$LG5x63_PL%mO=j1#.@x6HZU&$>*;a'od@cifs2i24ZXC5Jo_;$G;j&+Z<,4:#0g5B?.*P2t*3q.Qh$)4X>=J6wtq=60VMG+Utw=lA0?7&wf)b3opT7/-HO^,wog->;E$a,8pl/45UuA7R*96&tcrI/2p&0<Jgqt8IATiLF.e'viA8X#AM6(#trdT%Mb;78x`T;.]4ws-_X_58-U3T@4RM_?Nq]r8srar9Zmq>.N*iU:+L?%5vBMc0gFG%5Lrug3DR1&5UAoF#=;Sf3?RNv#,f9/3u1)v#gEI>#KC=/2[NjW-1D&p&gl<87/f$s$$Lf7n$),##pVY8.rPm;#4Pu?52r.I6;l>&,DbGon.G?),0gPN#c]f(#1oRR3AwI5%<'W<#+V(?#BF^2#tv^DMMTMn#pRZd&g.ec%IQL:%Ag3_>,pu(j?kWf4TofW&hY0v#,:C>,kQZ?Q)#K5#E88>,f((p.%)H3(O8[`*`C5;-fH&<-T>+?)%,eJ(/BAfhjo/W$1%sm9>al=$_Kq.amsfS%$imS%c*0&=52('68kKl3FCQ'8[._u,'vJs8'TH)SKrw&$/4=%vH)b+.kMNjLR<B.*xkh8.^d3d*Z8JV%#?PCFQE>]6doG8%:Q?A4FlM,+<Wdr/o5o)*t<L`=JA;RB%1B.V]CuxuqRd-H9FV4%@?&=#*Pu>#gX4$#7XM=-YrN+.;+ncX06Hk,40Ed*qra)WdY3t*nEl/Ux4'u*kDAgLVO$##JEX&#pA8X#$v^b?gAsm$G^UD3(H=*EYEHZ$si4c4m^t<-eRcX66,F_+UJ:_,^;>^,n6XM*dr?[-[Dl>-<:++)Uk5R*%gq;.oYkw,^lq$-UpS&,B:)/:@uj8%R?JnLYMZZ$j3i7nGH6V/BS1v#AsMJ<pa4J4xdUc3ntt0;x1i,+pC1/3Rdoh,VG4q097:#eb+<h)#25XZ#p2h)bO`XQ<tq'#Ms^#v.E:R#A;q'#_ukjVwOJG&<=/T..S39/UB0v*PisT%C5@uALUsu7,uc5;AW2=%xcdk:+_m12kGBh2jMff3fF/;%75Aip/89f3irqV$ac>(54`Tp7w%@21[e:t6og[A,m6J<$xP^W$Mm<H<v]/]tokun;#+M8.A6QT%TA0]tvAcY#>V'ase$fY#HNgq%Y?Zru;K86(,rCw,gTn#M;;Y$M.[2[,&F,+#R(4GMfx.DaKoX%t)Yqr$^D[w8kR5DkC'.C#qw4$#vWc'v/v]a#XIU-+As#u9`#s7[Ec5;/GlFVV2'@=9(Is>7=rJa]wJE=9C8w*0XEZ;#cWt&#]hqW&sU/;gXVg88V8(<-.$F:.R/mG(YCFj1dLst.$rFX?=atu-pqg,3hG3no_IVS%#KNgI)d>n9D<Gx#ggfR/eDJ12&f>m'TL0l:'BH115bQ0).`cod`HL^-Ixpt#8/_^#U2KppGbw3#0/5##3p4Y#<AbJ-BpLd%)NK8%b_2Q/.QYx6uL#G4iax9.ivLK]hk.W$Yd5n&en0t%$9::%Kt<9%Poc]61Vh7n%&]21q1j;.Xiko7h:4M(Tp#w7Y$5`u>s[>/jnA*#O[:xLHJ=jL.D$A%IEp;.@G.$$*Vg/)EaE.3^^i`$kuxF4,q%J3xO0g)i%BnJ2RQ68m%*mJS:`O)e_=k'H.w5&Fwa5&pxIgLuB9?-Xa(AX?V7k'@Q5>>EDVuc_FMZuRwBj(kN/@#Z=vu#sg%##lRrEIi[WT.>_G)4p_Pd0$sgo@p2qr?9:GDMF$[.8ZO$IZR/5##QH]t#q5s<#BWXP9=5?v$=L*W-YBrU@7p6C#'j'U1^Dg+>HM%OC8f8xG/.qeVnQx?TWFN@TCn.eQAdk-$D1;W-IrD<>t0SY>M`*(NNeTg-sZ'_S$`fx4M_%_SpgqeVk3Xm/t$1N(38O2<bCuM26nP,2FnmH3Q4JU/,EIu%&(4_Z9fCv#&*;G#m^N_9nL?>#Po&crAYIwKJSl;-r`&3%CXh@%]*uS&oU#v,lIZf*^*+I+3dg],7;8e2J:@T.a;NoC:r5I#.ksp%rEMCXh,/E+J-HlfOi1W-59gxepTPA>sw_+;NCsM0ZL%##9IIwu,m[+M+X/%#bZRA%Yh_a42P,G45wnafqrd$v*gj:.FBX/4Kx1g**Yta*nXS/LunHe$ek_@,[tw<$f5?VuImiI3dNF9%w6l/(IWwc*x?>X-tnVeH&6<1%SVc##,cUv#>J;*#^r2%vL&mj#D*V$#r%_c$YxLW-Wr>K3nV%d)V#[T%rY<oM;=WkF<BUA6x+'VB,-XK=,nqQ0a(<v#$HY>#nWX%AUl>.3ja],GfB(d<xY*`-x=/q9Q'QJ(Ya@c;HOE?*oQe-ieV6d*0^8c$U@NP&P4T&#8&_n+@Z]jSV)fHRDaL;VgMDN#88i7nYu*5'<jwE7HNl7nw<Js-CH$+<V$Wm/u;Tv-*.4]-I20_O5_#e<Z-$`GsTlD#DUh7n,'52(P*)f)bePput[8;/x^l'vY3c98214m'Qc+B4ruK8.*nE:.Bd7G#q'CJ#terx==P`p7sct]u`?VE#bi_p0lGG)SwN3D<QjIfhQFI)4;-V%%FjRc#p,G>#O&t(Exbw2MUD>,M@0XA+MFwt9(U33MxKIR=pa5fL)GoGE+_C]Q]x8OMIwGd.%U.H#aR)E/lQ/@#J`XjLYR#x#oCKdW+b08@oAJX#(:PG#q.YY%9(9^,+AJ6jBXc'v>b0I90r^X8Pm<P(<mRg1RLT].aR:N2$MtS&YLts/U)%.2L=$e=XSBS8JUJH+j%XS7Z*W6/HO13(LIY+MSavu#8Jt[tV4k?B(v8>,Nm*Ec(308%>29f3p?Z)4V1^<.:?(B#rJBA.-lGtCfX9p&ZR990*dGt7$TF(Z#pWVDvLLgMEx9*#^IZEeqv-kXRKXJM`3uH=MKG@7r(BT/x5'[6Dv@^#YsbsDggG&,>$:GsMpPd*wiQ]4BF*9.9=Rs$YN0W-P.@BZKZ3r7@DDs'OD#n%n[l*Tce7s$RT#R&lv:=%)pQn&L_ws$JDa9=M6'A.]l&90uFkS&%jV</luD11Ttk7nwI>`4VD-f*vZdY%JP%i1PQTSB(_7l_Q'xx6-8)v#hHI>#(229/feX)#OHxnL(*u48*K5s.#O^o/:o0N(@kY)4HV>W-ff)[KYWc[7Ek=A-8A3?8fmVhLb`2B<N(uW#.T1/1Nh@A6rcPnE,4sQ/3&lv6``<F.mGLM`-7L'#XQT`3<F9SeXf$krhsgC0Ic'U-+;/v$aDEO1a)$<.Pb7P1G2?iC`PJ(4HSZx6%dNCX2Es&5Bwl1g'>#9KV)3R'R0cT%Li5g)Pk?B5j$=Q/lqJV8-f?E5#uFW%&.;A?R%FhD,hd_u8J46%oQ3v#u1jT9B`Dv#M*:H2gT/KFj)r)#&^jjLN2eXN$2I6%OM;d%bY%U%F1eX-CeYPD@>2F?-:ls%UO;`55w&88Pa`W/EKqE#RJ*T#dKb@A(<&u%qdW;$s.jT9BSvY#EESJh&(LfLYwQ+#&=ol#fb,+*/Z6A7o`+xYm>U#$0on34Rt)5]5_fi'AlG3)&&n^**@C`Qo#(q.$q*A#0#Rq^XL6##ufd(#MGII-THj%C)rCV*bG:C,[j*D+*38_87dlP&T-j?&]wl^#IB(7#wN6.MT3p/3usDs@&*r;?irxF4QZ'u$vaw9.p0eX-m,JrML%,70G`9Z588n;$<f7/([GbrQ>8:'sfMq;.bc%C#K+#S-,`MZuf&._U>x$##x^l'vW9QV#(7i$#Qe[%#8pao7qo;Q3VWv)4GnjV$:$gG*5.PU%>Z<o7MJ&M1;&W:BBE@(>UC/isc5Wj3#%i=6=7Ad+s(X+r#k)q:O&Xk1J)3UB,];ZubE,9.X3]&Qu(N99[x&d<uSw_-M=dl/J-Hlf8MPP/NO$##*]C+*tRIm/@]WF3@mQv$>-,(&U@S_#Q&l2B+-oE5rds&FW:9606BhP&_gC>.(4$??GTcS/O59.*PQhE#p%Elol4'p7*uA02k*(E#kOH*Rb'&[#3[hA5stSu.W)ax+`,+##At3xuoRR[#JN7%#dEX&#X:_I*dcbXZ@%#d3OZWB%[uvQ/?1lO0RTa`+alC=-9cUsf8+lo74k$$$#as[tnQp6r('u89`MU+?2xJL(>aZ&4+l65/cL]s.,4TR9$@NN9h$?0)(&*b9-okr?EjDe2d0i97NwrC<N^pV5_5YY#Zj/I$6Ik7n+^>G2*`&)7fj,V/7Q,<-X9cJ%v+]T%FUh,)FAtA+6Y):8&Z)3'$aT/'I;uJ_>U':/2K2d,+eLo0%'Dc#WK5V/KtVqQ@W*^?<I&@#N(+-)X^gq%Ds4/(nu;&7O67q&Ow0EWOb7P'OL,5;$vt1#7<jEctYc&#hf-A-BTxgus8kEcJvrm$$c2g*..,9.m`.='r9c$+UjeI3$),##/>Po.:0j<#.VYCEUOb)<Rc6<.U%`v#0-5)kD9rrZ`Yi8%DFV;$7)F&%@dxa+V-S<$rQ3>-c0K/(G:D?#9C<A'dTGN'hIqo.'8a4'i_/E#SZ+]u'<D$#NS@+Mr?vQ#E^mP.Frk+D/6I#$=[J9.OT9-OG8HT.V)>D#QvPl&L/5##LQQC#K_W#.GsXT8BbvU7bRK/),/MW-;@jtKd0FM_^uW[.vo=&,72/W(B,:E+5,Q988EJX@/<<22UFH^?.O#^=uJ<Du8)ad2CO4^6Mh(A5N&2L1s(tkD5r78%a,t=G-mHq9dki='F71f)=Zo-D)#gRLB+mV-MTwJ5a8_LNocbd=dpVFPCl6##ST.H#%vM<#XP?(#hl7gLm()Z1f9K:%bts%=^?IZ$erg4oZ)%9/xWc'vOIJs7JC^v-,gYc2RDlp7=d'xR.4D8.R2#v%4$A0-WMDa<[LG&#4Hk;-Dbfr%4EqF,:]oL(/k1`-CR.236^HW.<^R[u=8TC/(,>>#v:j8==tbSN?`4I)_@#c*tm_s-i[A)=39_VeF?[pN`QL%XU9c/1CaW%F9]tu5DI<;$r+TV-MN.S1EUjO=]VrT/;HC^#]_@A,Nh%M3K3eJ=Rju8/I&56%uPb&>fNT`iqgjO=Y`TZdmPUV$8`u=GI1OR:$ZLn)]grhL:k)/:4E5s.,=q^#N0coIfOuUZlQNp70*tXAbk?##u5YY#HQm;#-Mc##>&$X$-1eX-.Ui,bW.44>sa.uu8$H]H5UXn,o(Ji;[H7&c[Ok+9s+_>$@)#K2+644)mMG&#?5pOj6Cpk$?Lj;-9m]?&p+iS(HY6',BlRN:B2URBULD13/5(sT)I$B4up'$5qpHs8d&'s7IM13CE`Dp;.L[>M=CpV-Y:[j)hLvt7Mhl)4DA2T/Q@1%/+p.K5e-,+@`e6ENPx-##Ta+u#)>&=#Dpao7uiWI)2r-x6OUre$T^Y,;OP(IlveXI)2'2T%)E#G4YXr39@nVv/`e#n0u%rZ->.b50?NiK(2uM7Bf@=K;:W#/4^&:pK$Gvp:3#:]@@n%`4QK$%7N'FZ@6Xtp%E?5o/rOk99#YGqCUtQ:0H3WPDS/5##aT.H#28s<#8^Fp8gdV'6'ogwLTbxF4gd'q.EIt>5B61rI8*R^5=Epo8=c71_?MHZ$i@)MpXUf7/;IIwuRa%08#r>Fu@sF:.R$F:.j4O]>qFKl8`j+aI2hOm/[4g4A+]9vRguFg.o.W`#9JwA-%TLk-<HntnL89aQJhw8%)Q4WQA[h7n$0:Yc=R*407x$m/iu_4J$):20#D+wOe1qb*vrVU.P_G)4&9?%.xUl&SD%6%5aPUV$Uas=GCTFkkhK(,)F]EEG8Ic`'fCYNB?:js-s2=d'O5V&=jjW-?r<<]FKDh,O#+n])ls2cutW+?#W+x29(m-DW@2R,2wYZ6:@K%k#5-2*#_vP]4qg`;%MA-T.Uqn%#7+o/(f6+T.R$F:.c7Jn&/*(#>#PcI5N*C1(.fZs-#h/A=fFRKuE[EN(lWcJ(ufht'<bO[QVP,I#Pf2'MoIgnL4d0a#7o7^.@R@%#3xPx%?Qo_OMmlS/RBF8%]:;2MW-=UMASFN1NPX>56/eV$s5hx7C/uPp=O,N#&(TL_nl6$vrQ>+#wr=u#A[Y##29(C&J,Y:vVCWD#/Kex%I/'J3AV9+*:2Cv-i]5J*ot,c*wX_U%c#u.>KMVnBD$sH#j;fLgo7JV%m=Gd3s?qJ)&.m,42<#p8*L#=%Z$LCG*8n72M/8Q:#'mD#L&f`*@>/X-/TrQNUn1RN$=Xc23]h;-]$%e-mVhOPnYw>5:c2iQK6AlY-aNp*'fv;-cn)a%Vow>pJ7Q:vT;.T%a5<1%CQA=#-i_v#*]*9#k5>##%[7H#SEZ;#kpB'#YImN<3;[&4,35<-e*aA&DS'f)sPsI3*2Xs6OtLF=%c/u.KMA8:h#902O@fkCtA*&%D(+++-YuA$C5^^51J158B16O2/Fb20GFgo:A?J.WD^FQqmgPL8pNrQNvTs=G_1tQNUDWlAs`uH3DR:a4<nE:.a35N'#707/jw4@6.I`]?nVGp87bhf?<EF-vC6u(Zo6<*%-1eX-CaP[J<i*F3nJH&%CBDf<./$/*.ZMU%2q;D>YA8Z5h<,D#:I:;$d[*kb%G<kbHJY-M/xCN(]-VrZL%Z;/DQwBN5^Wr90l<%:[R??$vlt=G3EA?@fsJ%#N`4JCeq5Z>'NLB#kJW@8^OXk>k;Yp8YsPj#*X<n'H/5##[]mL-^emL-;ROV(.ROY-Pu7t_M<Qt?mtLwg;-lY-GHpN*p<+Ab?Wh1p)Yqr$QZ$s9B>JP^9@(B#&;UfLB4f$vR(*D##]Y##_+<PAfg>Ga``m5/S^Uv8QiIfLOFj:mn12o%5gfF4ZBF:.wujI)^Z**cQ2`GFKU-C#P#sH#aAnf(b5p@#X^ps$Xok>/#*hp9()Uq1h$KB=Gp;=8xkFR0v'te(i6QB#n>q/%mw.nLm2av#-Hv7v38Y`%rQ3EG2T&;Q&HMR*i]x_s=n&:2mDr*M(iv>#WsJ+MxXPxun)@S#0Zt&#wZ7gLA(Sa$[#b1)[GEU%P7eo8Q&+E*RNeD4W9)/<Q&%[uW5Wd$8q0G)RjG330jjQ$#.g&$4_H>6g-W)53Tbl9_Y?_uaa:^>?e3T1AJQs-r(F*AG?aVR0:lg.t,>>#b4$L-a7$L-3ueU.QH]t#Y-LS-:-+r.r;(v#GBUq);nU+r<v#0)F7$##SE6X$f5lL:KH:5M]MWG#_P7xP*+;&lP&3,)DPm=-1-&ZMhLII-$C/(%ugm,=C`TX#La`=-(5$L-P-Yg.iPQC#6xQ4@)_tA#?.@r)W:Fs?@btA#4o?r)'A=r).WJX&9Gf&#no#]M+%VdMSfH1M5gQ'vC$R?;a4B;IVn.dDl1@#mX;#v%IJdT%x#t;-KLB<&#=)H<MiefL9R3j(1c5<%OG1MT*5SB.*/s1Bb'a[8:5k61*a'b.C+wnE#Jhi9T]PN1:x'R1ltq%OSXL_umvx(#9C@wu^4QV#uH.%#KH459w2b)<g<_=%m]WI):OLa4F2`:%-a0i)Gs*(5&H`W/$@;Z1vSih123p=W@&gYUtkdr3BCa=.x`>j38#4#@G?Ov6kea4u18C:m::<;$AM%8@n]d$$;qfi'6]###%`G)4er?Y'roNpuG#UJ@8[`)+X?;a:qNhB#S4#`s5SEipq@Pw9F:a<-68s=%R)-<-I`Fr&k[Q^,iiB^+]8:%6Xh'o0t=Vb4?1-O22RGg1__Sw@U[@a53M^H#dhgp7SxF?,5]S5'=gAt-=;rY$wV,9%817x6orqV$RPP(5:5YY#2<'A=a=r;-`YQT%6xd<-m`N;&+E-;.O$jL3p37&>Fts=-l?J?&])>>#=&<D#cok6%`id(##)>>#?>uu#X0,)MiBNMM[1m)%VuUv#4u0O+QRY'vm7r?#p7>##q,_'#(Lv1)Mc_U8$)sR8SZn62#7hF*V5_b%WsYm^Q[kbailEgVYp7Y,LgO)dmLZuuL51kDlg<$#GF.%#'SX.3+K+P(4NVO'9r2]-wM(C&FMP(55gR`4w6ui'qCV%:W<h^u*e=J4a24)80Tm7nd8Eq-EZDq0SR?##LEX&#ww>L/ej`a4.XX4:=g_^#*O`p7kK&R1TP(pR+:vs8&?SK=jUQ:vb`r(*&&EipR9Zj`Pdg+I;Z#l0YH]t#[5<1%+/5##GS)-*B8]Y,j*bw'/&nw'bb]w'X5q(a.7_>$eVGd3YX/PoQK%Z$Tq>W.aD%v5RT@v$eVGd3OMYxk3RZ;%s*p88u@qV$eAxV%W6;T/[rl=lE?<s%xQ(696ZVA+or7_A6;nw'<jwE7D)2:2PD###b^g5/N:i$#[-d;@2X@KWiPL-O#l&E#<tU@8V;DZ7.a8HF6U-P1hm%F4kTq41hp7b44ZvwHEI#Q3E8JqC'dqq'jQ+^6d/Ek'lW=#7ROW$#DsC*MR9't#tTW%&TsKT?'LT''3K%@uQ:<x'lilt7wj:l-3J1I$/W,_So,x`=A1Am/nJvA4*Z0i)1JME/'R:a#r/%<I;Li/:2E/23(0hSSAgdCb=iQ5&C(BI*=4st.+-ZV/#(i)5,oo$5YO*'6hVpY#$mSH)_LFG3NO)D+=@w8%,P@<$$),##RN%H#O$>G-hC9('62ZCFG=^G33A6x&f<H,:[N+$6ExdY#6w4VA`I1a4Z?Y[7dADCGNR<h)xC]C4JpD@.]lNc#xnm&6%Th<$-M2qB=J;N9kY.v5>Sn%-tY@m0E_G6'$nqZ%./5##p[Hg#*DN)#B:r$#S^jhhq.[p.>dVj']u2d?k:28/#RX$ip/]V6*Ole)ioA,3tD*E_^>:JU@T0wg(88S@=?oV$erOw9v>d;%IkPl$L3<d*Z.Ua*mn?T%Z?B@#vXj[t,4F8C4RuE=x,qK4&#wc,[d^@#dWl*=ZYJh(1LeG;d)j203U1-<KH-n&F>1<-@tZ-3NuCv#Kw%@#`U?]/]EJX#+Q:7#O`LN3+[7j)aDo)*hIoi1J6u9%15^b4ZJNF3/?8+4P=(a4'g/0<'=cE=4_E52DFV;AH2$Q&*em`*.^JT:_Deo/e%[=7IA)t.u`^.*.9F13UJr;.wni&IQZTiLW[YxuNk-o#LDsa*q<3U%^xtb*bf#R?QT39%?B/Z#fIt.)84L;-Ld=-;&5>##TKSX#2E(7#(jd(#/KB>@&9d;%rr<_$)`d5/>;gF4>.4,Y.9ot-]]WI)WTf%&lXOT%&w.&4O/DB#Sq?o1?AZ<.O%ph(MaO?@CmRI2W3R0)K>`=8]UT5'AU.&6Il1w,G8Y(5d28J3Lc*8&*x2G`/;tm1mkxZ$Tk4I<M2XQ1fI2207BwI<`u$W$@EDk1U-B[u_#KG3r+m++r30U/-%W?#x*:o0OS*o&cL8m0pl###[r2%vd+Qr#ExUIN'a/[#a%NT/XWLD3(kr%%u9Ss$<acO-ZRs*gSDkG4t=^E>g6wu6&T-l9=L*Y-7];:8&da&+I2g+4$^v*3-0je3O7u`4#NEN;r%Kd#$6'7Lx)Zr;;cgp7J@>6svb`+?x-of*Ip`O1dWp30-T8F4^o2E6gWq(#mhCJ:=VgS.D^Fs$.`u##//<PA8rKd24[x5#3rC$#jRhX-8uv9.+M>c45LO`#3dIH#*HoY#(`C#;xgEGD?ZE8.?cN'4#P;X:Q/*L5s+i(ajAj>$F+m<-#=dD-2K)a-51fw'bme--85#5]A*Iv$2O.U.&Oft#:72X-?Ifw'*h^w'um2F79X-IM4?:@-PBoY-FXfw'6f^CsY42G`fYb8&UM:@-cMU[-4rew'w9<kF(-ZJ(J3a]FY:TdEv]/]t9faedSVWedIaftuA4.d#saPaW;QrA#<A#5&F)>>#Yp-A-`60_-uOK^-P]sG#f92X-H#fw'C82SI1i]V6L37#H6be6//U.H#B7xfLK8(s1TgE-dfO._S)aM5*2Gq>?00R%t_u0vHiO.U.^Tot#=>.2.)]],MWDN(vZ)=cM;u_,-)Xtc41705A38q8%s_(##u#S:vP`5f_H+%&=xcPiTn4%B5I#=DEA_lA#(#x6/d[=Q#]'loL5IM9NOD4jL3O`J#`%kB-(B)=-VND&.4FonL)n.:NlB3mL3M`PM/u7:NY+:kLD0^NM=$A:NpZWmL+ulI#Qdq@-,B)=-o4)=-Yjq@-Md:U7]6R'#^x2D#7$x)$oT?.MCw)7U.7)Xe*W##-dF<u7*)#03qUkJ2/dvN'&.S/1vmp<A$(Zp:0;:b4`[G;9Qh%&6_lJfLC]4?.V$/;H2:jl&4V###bt]s$`Y0i)$^c8/_6x9.Taxb8Y(^m&MDiZ+^g-)*pS>##^cQE3nW7e*3sbQ#pN@>#%sU9V51r=uD1$##*0(Q990Hv$JcOA%`%hH4i7WT/3)Gc4ZGAS['_Sr8$#:)5Lsa-*?;#/*%=a?#'_K:/AFwo%i@QoB#YxC4+XuV/g,-a3c$IX-0>*s%5O82'jBPfLsC3mLgsS)$F_`QLa(#o$b2lj9buIo:7ZReM:ZQ.4$4x=l)7l2($t%E+2s?r%=/(?-8EPo/>-*H*PQ_o0@bM=6B(Eg*K'L&$2l$W$cCaP&QImc4dKTR/B+t8&HM29/Mxkq0UwU#?Ab3p1iPG%0eG=I#kvx=#[run%E)V:%==9C40S3T/l1NO'Zp:HFPqkrd9w'G)n/TM#++k9%`>uu#QV1q`jJY;$h<*20;/)X8%h37%vLns-%2=a*u#qs-?$D#?N8r*45/Zw3`3ox,og<V7uAGmL>.<*,Iu%W._jmh2?H9Z-J_7t-8]8p&aaH)*)L6-3jV7v5k5TI*PSl$6aaK)3K6IXn:pKV.IZ+B,sqMT+1,jo&1Eb:._reQ-V]Me.2KP##:wpgHrSfx]kc.^$DO6gLYI&J3[MIi$mUt-&-*GX$DK/A,q9OT%[;#++EExt-&p/#,R`uG4>4V%6`Kpn/G&P^%9XkG2UL$t-p_*>7j$#n0(AT+*&EOv6MXp>.5:>7:gnj$#K6mLg?67;-AjTP&);hg*'H:<62XD`+SKX`<TW*D+vuP:vHn2`jgGE>,,-gx=bL$MM'PsR#C5>##E;gX-pWUnu`xir74-uZ-b[2@0G*&##(j]w'M_IP/Kgq7eW@x4AYkm9;o2w4A-5YY#*$JP/U/r7e6U/2'8=3M*Hk_a4cx-+%DpItV2Lo,m+.UB#?nXtdt5Ym,$MF&#O_$W%FZ95p=BLk4lj_c)foh;0=tmV-xP_:%9H7F:B&Z`s]xA8:bKicuS%FYuM2<P]ZG>(F:8.mgPtIc4:KCe*bM@;69Tpl&U]W]+].G$$KsHd)$GO.)(QC*q(xSfL^jn`*/m>I2Vg*>uo)w4]%wP-)UJsa*kuZBrRbwAM_VH##/WfX#OmJ$&U]BqD>S'f)-<Tv-Gq[P/W,m]#dj](%2EdJ(r27d)7kp+MUOdM&+6Kb%ZlZW.leU<-.Wq:%)vd]#lZhG#/_FQ#6NJ87-fBb,qdgY#vN>F#F4Sd<mgx*+r4qC<cI0k8uRBG;#`k&#8$cf(TeYN:X6rr-tgEM0eSU9.i9l`#PPQ#n7qT&$`dUtLG2LB#xW`v/fxe$.o2Hx#*+J`,bwhF*V_+4:8MG$,K$C1;hbiS$_tk`*sir5/p.XS7s@-f*$Af6/CQS(#2DpkL>:#]#@N7%#Y'+&#<2Wf%=<Tv-9bU:@FiYs.0I9]$5jcG*Mu.T%A@'XAtfM&7l6ScEsBVf)Mt;GDiSZC#Krl:?IZ3t$$a/u#=qoO;L_^$$d5N=6,aBi)lp'NMPU<V$rXI7nKIQ:v;f=igdKIJ:vR#29LB;ig:B$)*-AEip5h%v#f_8E#8I>ip.(tE#ol4Qu&?&=#o1Z-3&oIPJ]<,,)$sQ]4=qIKCt<Sj0;n?g)^a`I3I/9f3T9Ss$,F9a#]CYI)&vMF3xu.&4ARFD69k2O1XKp]66JYi;*o2Q/6>vS/m&`G)tJ988f0?D4.QY]#lk+?-Ug']6,<]p._`MW%MruV$Z6W;$?]Z402:'U/%>ew-&t7'f,l$##-o2DaaCOcMBp@^#rF[w'%Qx4]3fiG*::]H*rP_#$ei?<.t>S%$pt9C48%eX-RqH<&NQYs]<7.W$:`OU]JpU5&?9^Rn4e`>u#nWG)3eugLDd:1p-j,$&K;.R:&5>##U/W`#j0,)Ml$K%#IhJ]=PaS491'd<.rZv)4Uqw8%0JSfLG*]tb@$V*4'FBC0F]BR1nurB4Yc;q8U,?5&hf@L$bA?v$=B+:.4]e7n.n+Y.5$&iVvduJ%p]dRVw(eK#?,E=(-i]=%E;^*+P%(/#A*FxuJ?<h#MrBH%EtUhL-^Jw#<w9a#<d<Z%AQo$P'VbU(mRJCui<.G*(VOF3l-i+*:X30*uHS<$*($G*aLG(+^8Ef2s-S@-(53'0(aX@?kUMw,]Tfg:>wL3(rNgu.Fe$G*R26iTYCXF3Hmw+41(<R9O;G##(?uu#l^x5#r2h'#D>N)#g^fUR/#.Z$,vko$-W8f3>@(^>XP)B4qQ.0);.=`#XidV'uNik%RO7[#ID7a=w`]Jh`;;0(rqCJ:_[[^?aeRB?PL75/*8@W.o9uv*qWoV%4S2x@%0h[@9&(J3d5=.31oA_uDMP)#l*#b#7Sr0$K@%%#jBf8/h%Q:A_^,g)'L2E3hkh8.QY`?#pW/30E?>3'FtI[#JR?U7h]9.*Q_Au.6Ksl(35YY#:hl]+eIFfq-l68%sw(<%#55jLHQ&,;bxU@6*(>`#qku0#1QxQExX7.+-GL8+%1Y'A</H]MJwK]=>fQ>dTX@1MpH7u/lwn%#Tl;<#Agh-/iL0+*DI^VgVYx5+H's@,KHOh#46-l-SxR21Uvf],&if34rwf346(944q77<.I.k_=B.r*4_rAa-SPCC,RK3)+TjInNpf6[-vB&iLA@0<7IHl.LsL:-vsmHA.MdE'8<$=0#>31<79ek.L%<DR*3gRR*iV0sJwbAxXn2Q%X;TTP&:i###^g,F%?rWP*2:6c*bHg;-q]g*%YOHuu``8&vH,rxLPiwA-@UKe$(EI1gB<DrZSF4XL]c`:%i;*IaXo708E2KfL@GMf#Nd-o#Te80%^66s.,C$_uAbHC/P6A/NT?E+1f+&#MF1TG0$i(p.f]DVd]x]E[p/n<.Cx3l_Q-Hb%GOXh#O-*P%A0]'/qi^'/oq2(/uj`a4.6Pi*H88k0p(I(W%jnLgB,mi'kQ4oA#Seb4^^D.3:[T$$A&fh2dtsi0lG*edV:6Yukdf/.?iwxEQQfS8enQp7moO@PZhx)XVmAA,k:OJ2Co(9.FBa)+w[0^#/_f34<49fL0N_:dO.FD*'/Ug*jhUa3Km:9/28m8/c8F.hNA_;.;TTR/Pe+O4*q%/0.x[)v/F)4#l1mx3&r`:8YD?GVL7%##Yl2`#%B35$)`Ll/N29f3XbCE4Hc.T%vn[M-@(k8&%j9*+.igiB-kD%,'%uq&H5#',#Yd##4c=fC[i9i^c#Lv[QIMK*PrXjL'I0qFP[$LFrg)Grdi^$1;%*XC*qAi#kEUn#C=Ab-%'H3bc;E.3^$x8%nGUv-`G7'1h1^N2l=j#$BsN.3DSo=%tu(Z-]_7T./k_-6Vj[d#=AMk#<$:hL5%Qw-?;Kf3X5Du$0N&i)vkh8.s;D?#[atx#MW#n&bD63'mYl++.Efa+#NU6&]=:w$TYCiTN$SS%)TwS/H*Wf3.pOU$c=gV6;3:E#sKI&4aKaZ6Y@Qt0An[)vRLn8#vOYi9Q+#=.(TS+4^SnK+7R)D+ig/c$euA9rZ[l.CCN_7exWn]O#8@l&)YZ%&GWlFF_PhB#o4s(*2wM(jtlAqDjhC+*beZP/3H=c49UbvQ@Tp@#wq5O2OP#f*kDnR/d<Wi0/X`Y#lA;/DaM1g'g[6-*AQU-2#a(:8cnWT%)^dEn[F-Yu^DG'vI3&_MneN78akQ4Cepb59BBZ?.huJf3j_b<%u+Mv-,JIF%3B#/v?v@1v[$ffL:@uj)&&Fcu0sk>7h.BP8]K<SRToMJ(S1h13$S9+*8bCE4;qQ)4K)'J3cMM?#nYQZ$ZGV0(^FjN'/l*E,<>U$-0&@n&+WRW.mW=>>]SxKPVVK1C_#uA#FM0lBD):^#AU/lB'/CB#nHl1BL#1^Z62%#8t8'ZH`gar7Y=UB#(6XM06C_%t&Or`=r5g<-CakO%hl2=.P;ts-t>-7&D*YK1/(P,kt3MS.T`6>>'j`-6Y]###1I_t%G2WF3u,OH*#L75/fcCg'w*sEOwOx?pC9A/7EMZY#h11X:i9aX:/8t-MAFA+OcU>[.h#te3Y)KO2eI/79c7L[I/Tt._euH<.H+Ve$iOu_.>bNw9F=4s7*[6p/`=D90?R$m8-?V7WPsN.3E<X=-7=QC+:Kg/1KExA,)Pt.).@aq.F:'`YWS.1(Z[C%,AFwY#Xt%@#,v58/q^$XL)>Kq#i:q+$NMc##,hJ]=^,p;-as?^4._KSJCe5PK)HulKuAa%/cECaF74A2C[=D)4v7*5g2M_G3x&7s.7G+q]xUToJrWSA#aHoH-0@ufie$3,Ntw81$o;8F-U4+ONf6I+'gH;+70S,,*C_ep.8[-127L?bFt_ke)qeOq&<J-W.42d&6QA3,#<$sr7W'Hf?wdF6/N5pb4c'kbNI;#(f=3mY%Bh%U&kpoW$mHm)4jhmW_Huk]+>4<VmKGc;-nGvt$/KcCFNO_0Fb1<VmdfK_0i[^-mJWiV6u``>-P9jp7dN:Mqn&M)3U@S=-7@d_+8<Bj0KExA,WBNr7@S?dF4,Gh#Vt7[#:L,D4pt=/(Ju(v#<oJ0%4P/a#l6i($E#-H.qc4c4pmDC#p1)d_Q'p]#0^jV]^C-jL8IC<.#1fX-3_bZ6$RbOo?4[fM9Sriq@B)pL76*c#[h1($,''*<,btK3ldHH33w//1*ug+*@Mxe)GFgv-hD,2T`;C[-Kage$lSKlLb$*c#R')x.6.`$#,Q1R3'%PgjJ1Me$O_.uu4x,n&pmOx#Tu^I*2jsa*&Yf34X/2)3INgY>HZs`=(Xi-MunOw9Gg:p/PZ$U&]tL6snd(j'M+;v#x4U`5^_(D+c9R],CVg[Y_L6jL^`2E-Xgi&.M,KkLxBEE-dxF[Od)B;1teB+*$LjT+'iKf)Y^@E._[A.*#AF&#,VO<._PnV6?-,/(*L^j)7ehF*Xcxp*l[5c*eJc<[k=7v71=^;Ip*e/M$:u`#nrB+$#Nc###pao76m1T/19xb4p>aB#;Zl$0D=9a%u5R61mZ+]#T07)I)(xv*Y2kr0r1vu#jfkf:3(bG)2>uAO):dDO8ZX:.H^QJ(a<X,*;Sdl.n=1;$j[vi&vvWlL'Vb`#1--$$q[,%.%_?iL=RN;&uetaeG+Ox'q)****iB+*o'%o+-gGb%b`=sMDmq17&U5kM;o`Y$DAdrH'AiG*9UDE#AD5*8%[<;n<X.NMnP4C5h5le3[kf1p+;hi0R[$###B2#$hsvH&N,QW-OG>GcW0S8%xmx46KD=@A,j7I2FgFlEbJv*,p(A;%K#Ah2uxG>#4D(M&vi/UJfHLn#B<TL_cwl:ALEC(#`/2>5QiT>#u/>G2:fnx4'/Ug*Ofp<.BR:a4wRkA#8,MIRf#8<&vB?tL_Li(al^3,U4,MIR]jS(<P1H,)8q'##_r2%v=CcY#vPS?2AXI%#mWt7IF;t1)JI3Q/NGW$>R@M9/xYP;/CnG,4Rk1A*pt&f+4_YOGV+[pBrN3eHS>i3'rL[v7R9TprI@oV%(:7c$#kbS9P5.0(O;B68G%_Q8I->i$A<TJ12h'##6epeVqs9R'Kv$)*JC$##ef^F*YaDm$a]d8/B=;W-<`rS%QF9a#ae_F*'C)s-=Cn8%eEiC?&i),+3B^(66-6?#4W;iK4n%Zujt$<6TvseV5dOg1)hO?#q`=f#1%7W$j)qpRe=us8IxSH+Bfl;&#'X;$5GslA4BP##F5YY#=KI#Mriu&#DW6[$kE#W.B$s8.7YlS.qEHH36PP8.%=,^>w2]-*SDCe$HTcS.F.ZL#)/JD<P6)6psV6cOVht(#]aVFl'3Db=6(pNO'1E'S&>0N([SS8-CCIL#a]0H$/p.T?)6*?+vx4f3<8j`#aHbGM^Xog#P#x%#hQk&#x,_'#>p^G.][_a4qoZm/Xw9a#pn0N(@Xxv$^f2T/gDl-$<Bvv+eVSZL)kRh#`>/?L*wRh#^5F,'6U4e(?sjI3[AP##E>uu#X-f'08pm(#HJa)#^U@q$M9Ed*pc&@-.Cd=M9>_;.5AYjL`X7Dau#B33H/mJ$]drK$'9joVMcO)S$?^n2i_Hc4Zx$##KQk&#ChrmLK$=6JcjH(#rr_v#@SB+*/A#G4xXR8%f,Xd*SwI^4M.LN@,>':%LH^q%?76;?-VuYu'Xf._;Kj`#]]/.$A6ZFr/f+.)m0TM'PW$[`>+GaG<;,XC(MFG)n)lc2-l68%=wfi':o#C%MiSD*BsfX-8_j-$qI'#,A_av@sk(5U$%2M^cJ.&UB>8RQ0N+<7bg>Z7(AP##$q?o#Lm=WM;K5P9?WSs7j,LB#67wtdNDL/)I?iB#idRx6:vs,4W<-`=?lmw-3,r]#3#,v0)W(^G<,%x*rBKV.[b5ZIVcCB914l%lns*T&cxgK-alTK-cDJq*fvv39iNhB#fMIx6945?6=?c?K9PnjDO7#s6wk%]uXC'f+%rM*ISngdFM=1p7wa0^#;61X%s0sD%el[]4^FN1C3SBWn%1#D#-1;H4DX0E+kT@D.:D+JEXT_#83&V'#(G:;$8)]-#ix?qL+rY<-x79;-=3]Y-sJ4L#ZY<,#6^V4#)UI@#d&dN#M/F]#tQ,j#tgww#F43-$S5d7$/1.<$LN7D$@>xL$r#OX$^jlf$ulpu$`mw%%%N#3%?gp:%7_AE%6+1n%#Ym_%tS<p%UBRw%AJb*&A0wO&T5t=&E5MK&aE:V&eEl^&+031'Gsat&luLG'<Sg:'a.4I'C5;O'0okQ'+SDW'/jL((gI=m'.MDs'fB8&(n3N-(K#20(<0w4(*DB>(Jb)d(@nZO(5S`S(#e$W(sBJ](iR<t(s$&x(fAR%)H(-()#e]*)TM7-).1h/)E,e8)]i>;)7Oo=)EjoE)P;%H)&uTJ)VZ/M)1A`O)b':R)<djT)mIDW)8aL(*>n)h)oSYj)I:4m)$wdo)RV5r)-=ft)0N:C*Xm].*+&K6*qb%9*(<(_*mYuJ*G@OM*x&*P*RcYR*b0vv*qlCg*A6Lr*rr&u*Mbr<+GWZ0+P=`4+g3)<+opX>+J`N]+$=dC+T#>F+/`nH+`EHK+:,#N+khRP+EN-S+v4^U+Q$St+q(%d+W1`k+0h0n+]ANp+3rlr+bZX:,fd2-,?DY/,n$+2,-s0V,bYUC,::'F,gjDH,>JlJ,n*=M,DZZO,LT*a,xhLg,tBki,Js2l,wLPn,P94q,-#w8--xj&-XO[--1wn5-x`ZS-`f-@-'j4F-UI[H-,$$K-XSAM-aX/q-sPoa-N;&i-'rLk-TT03..Gm,.nSdO.+0x9.qV4B.I7[D.vg#G.LAAI.%xhK.T^BN./DsP.`-`o.7ZkU.e:<X.>qcZ.nV=^.Fpep.;`V)/u'1?/wEeH/k4/i/V:WT/Nv[X/^K100VI$w/>:JI0S$w<0SCQO0f_X^0ob2l0AS%x0<b;11rFF>1R$oX1Jpc_1P1Zg1E&Om1n16o18=sp1XHYr1#T@t1C`'v1gwvw159p#2YPi%2(ib'2M3wD2(Tu72Kdsa2`QLK2wgoQ2*Xk#3>nVl2(Y9r2O_'?3j^q,3Qk^73Yh0?3e%2`3rJ3I3.6lN31YKR3w&,V3DJG$4B@3/1fw,o3S??<4I<].4Xvwl&JFVOqH7q7'#YSu.WINu76x1]?gCkCGAfM+OvUH+X]_C+b;O>+kxW9+tZHSi)5k6P1f6p79@XRu@q$6]HKFoCP&iQ+XV45i`0MR4h`l5ro:2AA$kMq(,EpSf3v;7M;P^p4C/Nk4Ld&NrS>H1Y[ojj@dI6M(l?EEM2pg(5:J3brA%UDYIUw'AQ0Ca(YaeCfa;1'MilR`4qFokY%%Y]Y.-*JVJ^K->R8nf%Zbfp:o<,&a#mGUG+Gj8/3x5rl:RWTSB-$8;J]<U]Q=-5AZj67GbEnl+kw0o1rM4Cv%'Ms]-[=n]6:lPD>w6d]HW'CAQ3@EGX`IGM`9i*5hi+HVo?/sD#m;1g*G^jM2$6iP:QBkVA)U2#Ie/A8TJs$v[%?^]dUa@Dl0-$,tcZxM)>t$T0k''Z7A1)a>qObGF_:#m_8S@8ghr#vnA/j)#o;(K*FH*Q1sQ,W8Lqe>@&4-aGSFJ,O27E,Xge(j`@(F5hpF)soN1LZ%8O:W/x#Mp9UHk;A-[2^H^'lDP54nJWm@[g*[>#NV_/)*,SVZ)Y9Di;foX>90iVDQCQMX)l%pFH=uC+0ERc2Qq-XiQ1?/QQL7P*9gK]VB60pqjMtF^gj/4$X/`MeNDL/aW]`2`*,_48'Z,0g-4$%bEY/3bHbFoP[%BOh?R4vAC$=`&IO`/0bl%.n6UVo%Rqjq2@I[#BblgQVR:G%7Ib,8jI+m1TLEw^AIb-`kC-/$0xIA:j7(b,b:0-(=.X0XpnqRp;oCd4wUK6&B%R():+lXJshs:6Z%7kW=c>Ph<oU+4vU^[UX=fP]',#jb+D61Sd7U#/FG,:Zj:^=-=81oABYS8HYM3F=*8UFY*Aelt0&7gShoU.sB2<'I>5M<.-5ibKiD-d?rcP^TNMjYc`/4j:<vJTMZJb[WW#/8:Z2Et[U;^nKOZ&?BT&IW:`a$Wx3TLkE)WgPn-*-mg*EQnWK<'a*r,POABgtZ9ca?*>K-,LHDHY_Y;n2obF9L4Y`dl(ApTCrisdYoh2I#lZ5e>xb6w]Vou-#>5wE?RTM-Y5H:@&)j[$ADOQ'[n=W0bp-fb$x&AI,()'=B-i*CI1_Jq_7Qj<gdZlBn:enHuFOoq1:&1FQUYY-uuRC@8?jLL=P)v3aR8dC%vQdO*@im[/a)wh4+@*u9KV3+?+mIOWNt.c-lLbXKX3u'n:]I=T_S;4a>TE@f_kNLk),XXpIBbeu(WT(.]T_43'lh@8G,rL=hB%YB5oeFHYGO4N(w9xSLO$fYq(eR`?WN@fd09.l2`#rqV26G$%[m4*X-ErC-DwelLr;S;9G=lWkY$V_:*.cdx.5rq^>,^Xo3t4<f*Ixf+n25*Ma1GH-;g.YxCA82CFMcZEj&Af&Z[%o/Z9,-slSJ5cKsrCeuglN]To%]^$5JlQK`M4^tH>Bo0b`R3_$,d<es.ufJ+g5vs3vB0^%sU>axxfvde2+6raGHXm,v^Tjp/#?9Gs:Ms8pM/-o]fW3q82515aI26x]fH-,NFb/=vpwtYvKHVbW(Hb*E[a<]K,/MUgY$,>>#.UQ_#?5ISh*^ws'X#(v#M5DX(aJp]VwY5F%2O?YIf)odu1>wO$HCi9.+/5##<Q/a#Jn@-#Z7YY#kY/E#ufw[#9,N`#0p2`#[eK^#Fej/1No]a#Lvg^#u+#b#)3v11Hs_Z#>Crc#GP/a#v4,H2Qt:c#@6`c#-W8a#n:VG#(YlS.B@k]#8e^o/(?%)$1DGb#=hG<-<@:@-qM#<-5fF?-7N#<-aLj$7-r3]#h%Dc#CPew#NGt]#Lx<]#jxhZ#6Wd_#SDpkLdQIF#E(E`#E2W`#tr)D#i4X]#'-$_#bO>+#%b&g1:'4A#qZYF#IqC($bF+4M@8*#5bS.p8e+@^5BDBVQ9CG&u)+x1Kb+h9;S`wf(qf2#5Mp^4(MdYJ(5Y,Yu[BW;$0W_uc9:]cV]wDVnR$K<e%:&VmLTb:mUJ;lo$5R7phupc;fB.##6rRJ(x9uFrGrO%t_Ev+Dn^u/D8tDJ:Ybm-$^4587=LPS7b8P+b#r1M^vWa`<D?1/LER6ci;x9fh)81>G%S'aF<^c-?M6?69fkLS.oZai0B?Bs@L6T9Vm)W]+wJHS@l;_-?jIIJ1,VjfLrq$F#?I`,#<*gE#x1,b#;Te,V3jSVQ<2r^oj[@/$Sp))*kVhu>(lu8.Qt:c#^pa>HD)S]Oft,wL-+O4#>Muuu`LY##_M#<-T7T;-^hG<-&M#<-m7T;-ghG<-6G5s-oHZ>8<6[#6'*,>>0ODW%P=e%b.,8/$vxNV6==qV-^&+F.l4b-6WgAg2A8kuP9-C*#w5g.$E$p92305A=C[Q8.O[uu,,iB^#IXi#P*(f(#5tA.$>SFEFmsRVQI&qoIv3Us.L_WfUcN2,DATGonA@7/$2DN)#niGlLM7LkLQ$^%#SYr0$Hw*207$'g1@>Kq#sGY##LF9:#+Y5lLR?b'MOEk'MsnS+Mg%<*MX&h(Mua/@#eQ>+#<Ubh8^(g,3Gj4D<a1jV7oHh2:*4629;Qx]OZnHlL$?qV-a#?KE:cL2#S<K2#]mo=#eFiP/:cxx+h;[]+*]0^#w1(D.UOYb#Dr^#$UNx_O]2ZJ(ofg.$F#,>#XilS.l'=D3'_AN-GM#<-KX`=-+>8F-l(Qe50/a%$PM8&$-wfa#/2W`#c@5F#8MQ_#$Si2Mf;vf(3Dl-$p1j`3IJhQab+F>5^J<-EX(Hf_5*dV6H$gw'P>>##Qfu##Fs%'.`k#tL.vWuLAGD/#w5@i.vG+.#qgI>/==J5#I-niL+a5oLOB[+#x$I0#J?s<#jVF.#nKrM%i-c6#w?(7#TAD0vbTp2#,b''#dx=wLoi.3#Xf`4#m[$0#Hm>3#-8C/#U@S5#Ug53#/gxvLo%1kL<OvwL4u,wLD*jxLnv-tL6+?wLhQLsLKTS#MgUn3#5P_/#.WUpL.)>$M@9o(#Lvm(#:G/e%XJAYYPTB2'ecKG;8k:#,Zu$#>Z9C;6R8,)<)/4Mg%F#,M^5guGm;7Pf't6j:>:E_&E3]i9[^$&+/Rqu,:8Zc2k%PS.NpBG20psr-o&dERx9N%kQktu5O3oxc,MX?Q^nCxtx,0/1Hn+DW,$Wak.,35A3]v.UYo6.m6GN)#cQ`,#MRm--v].KjG;3c)nOKV6G=ju>F,5.$bPJvLW:QI'V`5WolA:@-'vH6%LE%F7&xKB#0U4Q#eetgLv(doLk;TnLB)t8$6.22%w&PF%diX.#ukrn8rxK#$`dqm85Ds>nBs'p8hv5q9,8.j'FwX9VbiGm8V<+m^aX-8RoVKp8Rc2'Qljg=+B.=dtInuh%j+ox4E%ox4r/g<-w<@n8eM4Wo)6(t8Du0'#pjc+#Jn_xL,_uGMIcK=#qM#<-+X,11X`]=#isB'#BRb&#rM#<-f%&V%ZdM#$GSwA-B#x/&N(8`&l<p`&m7S]4VbC29qM(B#@HFgLmGgnL9-LE#?:WK9xInw'G]69.TpWf:=>-9.pOYb#t;8'-#Blh'tU#?5M@##,V^vx+nK_]+lA[]+Hu65&)=fu>m?n-$L6,>>w7T;-/`Ys-2^`R8jV?$$&Gt]#qjT^#^_9HNCRR&M-S.2N.5l1#HiX.#t8LK*4b0a#%Z`=-l908%Qx]`*n%ac)-LQ$$9j)`#O(F]#T/22M8V]cV6h%/_:k*,Wq)SD=dWxookhffLMtcrdfAWigbG^g2Hwuo7;]l-$i^bpBZtd>#CI0#$F$Ox#H%loLiJ7_#lcDE-_4I*.];4gLf11a#hGI[#EfLZ#r?%)$:G`.MJA1sLaNpnL,p+1#_L9:#/Of5#cWUpL(4$)M26&#MwlGoLd%[lL,E?A1jxhZ#^:7[#(,Xx#:o8Z.;?j`#96T;-V'l?-`QP8.TU1Z#vRkA#o0^Z.&Gt]#0fRU.cBlY#mN#<-'whP/iZv$$CDGb#%fEj0c4U:vQ;l%=`%HM06]l2;QLH##&c#]%3e0_Jh#;A4#J5s-$h+t7:?>F%JB2;6hA`EepVrE@N<A^>;aBA=)Y'9/<BZcM4GuMUoLcl]fW6)FG/vx?mFj1p@qK]XWbvl/CU#s6A,YM0B`j4fMC).$lPYc;8b:>,$smx4+(q#$[NtA#,C1).@ConL<>T;-3gG<-B4.m/kR[[#W-#b#q(m<-8p-A-pwJg1gelF#I+<D#**F]#%F6IMrw+9#pF%%#>fG<-Q=F_0Gh''#`Sa)#<]`mLx3pfLrE:sLn_e&M(dc&#DmsjL1>6>#,T7+M@P_=#Hdf=#pg+:vvlo=#57g*#4h?iLBE>&#W[wm/?:VV$-bwr$P#5<1[C7@#E%Pu#4e1($X*gN-OhX(0BM(Z#E6YY#x(m<-(>8F-K#T,MbCQ6#EOm;#n$p(M32L*#J)MP-,1SF/W#%8#0?NJM[j?lL;n)Y$^pS:v)1I20pN8A=^@lr-];8_8^S5-veqm]>:ggJ)D.S/r=jxl/4Ju-$[Dx-#t^Xv-Pe?iLF`+p7Dk'B#q&sr7]u?w^C5l;-)-m28(aKd43F4D#A^lb#sM44MeivIqF6b/)RavE7l$vo7%[^`5@+4#5S8rc)oOpl8w6=;?%c7)3(3Z.q%YReOs5R+#m5+*vq=>##-Z@+MuZ6+#;tHm1#k0'#Fc^:#$jZ(#Z?3jL8$Q.#0aO.#(6T;-q5T;-x5T;-E5T;-*6T;-.5m<-vrG<-dM#<-56T;-%6T;-h5T;-K5T;-K':W.nuA*#ifG<-D2J)0C:%0MG)wB*w#h#vbYL7#NMFgL$JilM0U/Vm*)l-$udNJ:A3]uGh/q.rj@HJV-PNh#l+4&+42RS@Z(K>,;/;;?p`)#5<*'Vmo)kV$>9DVZ'm7PfAI^V6<#`s-_XYF#RMB>$Q0;,#N$^E#N`cF#GHjD#-[0B#vTG+#3l&kL?8xiL2c7(#RKiMMOF$Yuv'>uuqsxXuD7T;-86T;-RBT;-oN#<-e7T;-Xa/,MrOqkL2(8qLRV*uLRMDpL$@,gL1:SqL-0sxLXb6lL4KihLkbgvL2VU2#kQVmLvel&#QI+_.HD6C#j4I*.BLjJML-'1vJbV4#df/,M#5/8#n@#-Mr9T;-m]AN-hQP8.MOHC#D=5s.u-&dW8'q+MqX5.#jLVX-jq+wp`o3>5qG`-6J%q=#0(R0#_>>##I<D,#q,02#Bfu##YS=.#]G+.#w,Z3#@%-*4OiNV6$&###E'lx4q&r+r2`]:Z)tKX(#ea1#ZSY##YM?C#dBP##2W2uL?5$##v.Vp.`Xw(3RL.]0A>)4#fRs)#)6M:)8X?1<)UL7#`7')N4tXL#&8?>#+SO;.l3)5]D(k>-XjJe$tlIfLP?pV-.xn4ra^/%#O.,wLh`CmnT1vr$C(32'6`3>5ihar?S?t4J@1-/:3_duPY=NcVMs6SeN1/PopmSJ1<fe]4<-o+`_P@Se`J^;$D6,j'V`s]+va*m/3&vc2hB:>YQ6X`aiqU8.SHiP8C/&jBbKfVH?E_,)taW20)c*s%0+QG*HZbY-Zxrl0qWd`49uMM:d`8;@8WY`FaT[fM-f.;R@6ZiUg8%T&3(-g)FBx],VMQ8/rB_G37P-p8M('sI93ifVZfb`XfUZYZwd45^1pdf`9@Q,*XSZ8/A8;^#'5Fm'9:?g)JN4^,0SV2:-OnMCg-Nu#BijWq-m4;-8lNY5kt&8@UK9PJeTef:aL%LVD'^xbL%j4oKI`M0obE'oskn(ar'2Gi0o6s$l?sM(*Do;.ow8(onW<;$k,-?$UCPB$M)UF$)I>f$WQBY$CWK_,t*mZ,:6S],NgF^,cML_,%Ae`,CX^b,npVd,DcCg,o<bi,Ffd5.nG5gLf&/=-BN4>-)ed5.313MMojUG-2`d5.f]2xLPaJM-d`d5.F<a6P`<#gLl/;hL$A'cNj$/qL6RHuuZpj1##]v&M?:.&M9lL%MnLG8.shU._:@Ti#Cm+uu-(X$5]%.8#DvO6#4Kf5#o.sWukVURu;uxXu66T;-HqY^YR;Crcf8^t1HvN<M5'#d23YFf05;a1/6:m%3&+DJ'GTlq)Ci(##x/&cUwn_US@.ErYCnuLS+7%fKwuJ7HUEX=X;_OqA'c7l7gk2`)_B3mS1le34.0+##VTj-$*tj-$xPEA+hPMfL#Zr4fve9MgD>$;m7V1m/>bXt(-=XG2>fRA4cVTG;adgw'5(q#$o>uu#+^rS%1/q(j:Q4Ak3455f0q%)jLcmrmXbFMpm#w(suS8At'/PYu/S1Z#[+,Z,.5eA4VKV58s=H)<,j.F%L#,##=Xj5&OjCg(Hq#/$:h?v$JXk-$X1N.-Fm]=#7O(&O(_03'c$r+;9k8>>otNV?xDNcDl.6D<r2rr6iCix=uau1B^/x.:UH258aSTc;YPP`<,(n%=JB0>>_m4A=/=N]=BG2GV`,JM9ohnu>xaYlAbC(;Qk0,5A[Eq(Nb=xu5ku28@?&q.UNBM]O>.8;?peGYPvXJPALchrHhj+8I0&0DERCh%FV[H]F^9&;HlDq1KwrQiK0C_xO?'@YP.&v4Jdba(Wl0B`WpH#AXe;7YYB:Df_G[@c`OUd._g2wLgwt^.h%7?fh,krCj:vg:mEMHrmTtT+rdW6crTiLul0%[S%8I<5&<bsl&w(7/(g_YV-l*VS.t$$v,r`'>GobHYGqnduGu6arH#I&8I%UASI'b]oI*w=PJ,-YlJ2^6JL9#RfL;/n+M=;3GM?GNcMASj(NC`/DNElJ`NGxf%OI.,AOK:G]OPb_uPV*@VQY9[rQ[Ew7R^Q<SR=DPoRags4Scs8PS[)D>5f=(YuhICuujO1##l[L>#nhhY#r*I;$t6eV$vB*s$xNE8%.B>2'0NYM'2Zui'6sUJ(8)rf(:57,)<ARG)>Mnc)@Y3)*BfND*Drj`*ObcY,KI,#,MUG>,YH@8.^awo.`m<5/b#XP/d/tl/f;920l`5/1t:MG2e]i7e#E)Se%QDoe9R7]kj32]t;@Uo[KCp]+jxRoe-&Jlf5n,v5hAB20`ki`<+7b]4*(+&4)+FA4<A[G)BfWD*YB.s-`g*p.q%vf1$`RD3Cm@58YFmc;hE+#>l^bY>*,slA<=_cDF(0&+I=g]+E#]P8f9f]=G/xl8H0W]F]d9Ab^/muc(8guP*Xgrda>2;dcJMVdCEEVQQ2^oRP#'8RrFFPf'1$/hs7JSevw>JhvL+5fxmKMKN@O]XA>v+VhhWcVn09DWb=@JUS9?DN=3NVQ6&qrHm)PSIsShlJ%/*/L+MafL1xx(NMp/8RQ,KSRUJGPS^%`iTbO<GVtT5AXYe4Mp^'l.qfW-Grn2E`srJ&At/.<p%?k/m&AwJ2'HNcJ(KQG/(]x8#,;/Acr=,xY,0*H)*VMw`*]lWA+P#`G)B%6Yu,uvS%5LgxXF0->YH<HYYJHduY%IYcMdeWont@n4oZWKPJrt0;ZNaDVZPm`rZR#&8[T/AS[V;]o[XGx4]ZS=P]]`Xl]_lt1^ax9M^d7q._gF6J_iRQf_k_m+`mk2G`owMc`q-j(as9/DauEJ`awQf%b%kF]b'wbxb)-(>c,_lV6.k1s60wL872-iS749.p76EI588QeP82#Woe;Ds4f=P8Pf?]SlfAio1gCu4MgE+PigG7l.hIC1JhKOLfhM[h+iOh-GiQtHciS*e(jU6*DjWBE`jYNa%k[Z&Ak^gA]k`s]xkb)#>ld5>YlfAYulhMu:mjY:VmlfUrmnrq7np(7Sn?qVi^o?+AbL&2PoxXNlo;7:S[Fgn4]Hs3P]V@@`ac_%DaWVk1^[b<]blHt=cmEXxbo^TucxA2Se*gi4f-v.Pf05f1g2A+Mg5Vb.hLpGonccd4oaJh7n]8Lrmcu`1plFAipqh=fqu$Y+rsb].qqbxIqu*uFr$FU(s'UqCs4j4v#?/pY#SG6]bi9OxblN0YcW0N;$Gr-p%EF>VZ?9VrZ9RB]X4O#>Y7_>YY9kYuY7R^xX.ie(W*iE`W-xa%X/.'AX-l*DWCD(G`]@Dc`bh[%bZf0M^QVg._Tf,J_VrGf_TYKi^dH5Vdw&q:d57V%kJ's@kB.(Jh;%_+i>4$Gi@@?ci>(CfhE$SxkQT4YlTdOulVpk:mTWo=lj'Q%t-$n@t09Nxt4Q/Yu7aJuu9g8##7Tj=uR]MucY<jV$EY1s$HohS%Hb18[8A05]8GKP]'/MY>)GouY*RFV?/hbr?1*_o@DDSfCCwdl]hfBG;-j')<,4)2^C%HM^Mn[c`;>887is6DNc3X(Nf.'2#5d#k(Z2'v#1:<p%pFhiU9___&R+35&`N_R*WRJM'^Un_&#x[f1l*o_&fp;A+Dap_&+QC_&)Zq_&fdZ`*#Mi_&j&<A+;@j_&787`&1qT`3bP[R*:A7`&vr=;-@C^R*3$U`3TmNb.PLR[#b2xU.0:jl&D[:d-M9'xT01LhL'>ABN-]gJ),5Txt+/G]FcgXoIT1PcDH]4GDcM8;-0m>G22/;D3#N4&><UXMCjwX59ETA_/W_k>-wTWw0#2l(EA)WiB8qBs7x)0F%M1h--+7auGo&3p/,%H>H=eQ#H7&$,2.79/D@hH>HT`0ZH_@`f1m('aF(;Wq)1w`l8kCM]=GZ<H<jA&29a,v9)^_hM1$$Sj1''+20erAFI2n<kFAwDqDi,w1Bx)F,3=ocJ2t(_g2WAp(<M=m-$jUe'&:oU,3tbh9;NN;'f?8JcMsHreM+HkB-*Op4M:B]qLGa4rLW&MYS`HgnLe.lrL7_4rL.(8qLpKG&#lY5<-8H5s--#krL;9_4NZW`/#OKNj1KMs.C7H3#H4K/vHEl[MCRcP^$K/w+#O@xu-dtRNMg.lrLGh>oL5.AqL3RhSMk*8qLkX5.#>Bg;-[qX?-kV3B-AsY<-qu&$.=:TSM^Ag-#U(A>-3qv.%9^=J:VK^w'Z]cxFch6f?^L_(8m]^'/]aJg2*Og+MhGG&#K%(GID1-F[st[rH&32gDmQNe$-4Ne$;iG;Is#t;-]kl-MSit)#)H+_.N5C/#(#Pp7:(=#Hl+:w^uUdxFVM+#H[d@#HT6r?9EHsjt%vo+DL&5D<_eA-dZ&uP_u`5oL)Y+rL?)d.#x/j?8s=_M:AMD5BC.tfD%`3f-v(+GMQJtL^7uZb%0rg>$oT=U%d-(,)Ls_c)P5@D*TMw%+XfW]+dhLS.o?.5/sWel/wpEM0%3'/1)K^f1c:$K2xnh9;n>V`39V7A4=onx4A1OY5EI0;6OB`l8t(C3k60x.:bGXf:f`9G;jxp(<j/=e<rR2A=vkix=$.JY>p.$q@*=M,#.I`,#2Ur,#0;P>#,Gc>#94i$#O'+&#B+85#v<G##=GX&#:l:$#LPj)#7h7-#v[&*#4^+6#<vO6#8j=6#Xu$8#LPC7#t<r$#ma.-#^3n0#Tih7#`a($#+7J5#`+78#4uI-#9Tu>#3Vl##n*]-#,i:?#-&5>#ptL?#PA[8#Q0@8#R*`?#B4r?#F@.@#/ZfX#LRI@#OU@%#kIe8#_^I%#bmn@#Wne%#;*4A#_3FA#c?XA#fBO&#n@4I#kW'B#nZt&#sb39#OE]5#^kBB#tm9'#gS+Q##-hB#'9$C#Ldf=#8G6C#/QHC#2T?(#=1k9#$4'U#kJFI#9pvC#=&3D#A2ED#E>WD#HAN)#NIW)#vW&E#KCmV#SiAE#Vl8*#LH4.#QaX.#Tp'J#[+gE#a>)4#=*GY#b=,F#pB5F#eQv;#Zst.#`8UJ#hOGF#l[YF#o_P+#qpuF#v$2G#B;L/#eJqJ#FP$K#(=VG#,IiG#0U%H#4b7H#7e.-#+X-K#<$]H#?'S-#mSq/#rl?0#[6xH#E9o-#xY4Q#JNFI#NZXI#6ko=#w_O.#rmtI#X#1J#-lD<#wrH0#l&(/#o5LJ#cA_J#gMqJ#kY-K#of?K#7iMW#[:1R#vuH0#70nK#';*L#*>w0#&ea1#;rs1#wpM<#x&Y6#c3=&#KMc##-G31#bm%P#/SNL#3`aL#7lsL#;x/M#?.BM#cHY##hC17#_Tl##oD<L#D7B2#`3m3#tFgM#KR#N#O_5N#SkGN#WwYN#[-mN#`9)O#dE;O#hQMO#l^`O#h:&=#fG8=#MRp2#IWs)#nE^2#]aV4#Uk>3#YwP3#hg`4#n^V4#tmi4#kx&2#6t#;#0=':#9TK:#Ffg:#4np:#1LKU#7VL7#;-AP#&9SP#*EfP#.QxP#2^4Q#6jFQ#:vXQ#>,lQ#B8(R#FD:R#JPLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#gOwS#k[3T#ohET#stWT#w*kT#%7'U#)C9U#-OKU#1[^U#5hpU#9t,V#=*?V#A6QV#EBdV#INvV#MZ2W#QgDW#UsVW#Y)jW#^5&X#bA8X#fMJX#jY]X#nfoX#rr+Y#v(>Y#%>lu#(AcY#,MuY#0Y1Z#4fCZ#8rUZ#<(iZ#@4%[#D@7[#HLI[#LX[[#Pen[#Tq*]#X'=]#]3O]#a?b]#eKt]#iW0^#mdB^#qpT^#u&h^##3$_#'?6_#+KH_#/WZ_#3dm_#7p)`#;&<`#?2N`#C>a`#7GTq#IP&a#M]8a#QiJa#Uu]a#Y+pa#^7,b#bC>b#fOPb#j[cb#nhub#rt1c#v*Dc#$7Vc#(Cic#,O%d#0[7d#4hId#8t[d#<*od#@6+e#DB=e#HNOe#LZbe#Pgte#Ts0f#X)Cf#]5Uf#aAhf#eM$g#95^Eu'B]g#u(ng##5*h#Kx__$E=2MM3(#)N7@Y`N;X:AO?qqxOC3RYPGK3;QKdjrQO&KSRS>,5SWVclS[oCMT`1%/UdI[fUhb<GV3NWb$cq3l#t&Al#x2Sl#&?fl#*Kxl#.W4m#2dFm#6pXm#:&lm#>2(n#B>:n#FJLn#JV_n#Ncqn#Ro-o#V%@o#Z1Ro#_=eo#cIwo#gU3p#kbEp#onWp#s$kp#w0'q#%=9q#)IKq#-U^q#1bpq#5n,r#9$?r#=0Qr#A<dr#EHvr#IT2s#MaDs#QmVs#JlFa;Zj?NqdKh+rhdHcr.w%Fcir-ctxox=u&2Yuu*>Y>#.V:v#2oqV$61R8%:I3p%>bjP&B$K2'F<,j'JTcJ(NmC,)R/%d)VG[D*QSfn$>ksx#cK'#$gW9#$kdK#$op^#$s&q#$w2-$$%??$$)KQ$$-Wd$$1dv$$5p2%$9&E%$=2W%$A>j%$EJ&&$IV8&$McJ&$Qo]&$U%p&$Y1,'$^=>'$bIP'$fUc'$jbu'$nn1($r$D($v0V($$=i($(I%)$,U7)$0bI)$4n[)$8$o)$<0+*$@<=*$DHO*$HTb*$Lat*$Pm0+$T#C+$X/U+$];h+$aG$,$eS6,$i`H,$mlZ,$qxm,$u.*-$#;<-$'GN-$+Sa-$/`s-$3l/.$7xA.$;.T.$?:g.$CF#/$GR5/$K_G/$OkY/$Swl/$W-)0$[9;0$`EM0$dQ`0$h^r0$lj.1$pv@1$t,S1$x8f1$&Ex1$*Q42$.^F2$2jX2$6vk2$:,(3$>8:3$BDL3$C5c6#%B+2$J]q3$Ni-4$2i=:$T%I4$X1[4$]=n4$aI*5$eU<5$ibN5$mna5$q$t5$u006$#=B6$'IT6$+Ug6$/b#7$3n57$7$H7$;0Z7$?<m7$CH)8$GT;8$KaM8$Om`8$S#s8$W//9$[;A9$`GS9$dSf9$h`x9$ll4:$pxF:$t.Y:$x:l:$&G(;$+V:;$.`L;$2l_;$6xq;$:..<$>:@<$BFR<$FRe<$PD2[Aj_j-$<g?RM7RxqL6-?@H:<U=B,SvLF?>kdGl)(C%UxGhFn>v[&P%VeG%^4rCx.&B&Y_nFH[6iTCPdBm8BC'=1eMtdGpDZD%J>RA-IAn]-x3w_/l6fjM+rZ29X2'T&cbKC-Aadp/KGRR2oKmU&@dVM13eF<BY^fBHnWrTCY.X_AqxE_ApN4kM<1NJ:L0U-OUXlGMOd]F4:'usBNKR3NFNv#%:iUd-eQwNF#B?IOuPJ+4llEO+TZHHFh'11N$bPOMgvUE<,mX7D/o;2F0%OGH<DwO4c?_x$Q#@]-lMiq)1>/cP+uvh2*4[a.#wm#%F*uZ-u^YEefGKg2<5e>>GeVA>:9SA>D:hZ$n.?LF#6EfOm^m>>j[:w$a#/>B]7Gv>:H4#?PtMt%X^IUC-mgoD%OUPMwCSW?EwHv$RNU[-0`i2DVMCE<-p(*HG]V=-2S+SMBULp7KC$P.`9`2Bq$F5B?,c;-]_ne-wk]F@:fsjNX4Q/C_.l;%djh@-cm-]-;UdI-6M3nMD=mJC8mb;-&8bB-40.j'AWAHDJ3@?$mGcdGX<v228et3NNS9@8`SpfD#dN^#mf$*Em@%U.p?hx$eDON.b8,aEG+l>$Lp=c-<F(P+b<_x$UIXr.b:X7D-hU[BD[C[BX=p@8pee]G<%[)4W:9SMIg>vG>9&T&)qu<1rN?>%KGRR2$'w#%g*uZ-6+''$2IBx$h&fQ-Z)5G-`cH]/$@_oD&xbWH?AL<-.=J/0%UDeGgvb'%Zv+G-`5Gc->4''$I^$TMAfepIEwHv$=+tV$gkj2DjbSTC;0&T&?3D6&G:UW&o>rg%j2sr&#HFVCpjM=BnKitBph>lE3D)iFx)A>B*&r`E9h16M1pZL2(/RF%Dq?/CmW=F$kwViFstS88WY#<-XY#<-[Y#<--<w>5D(-oD6)YVCf`DtBosT$&:GViFMb;2F1=EtCFsN>HSP`t-78VqLklRU.xm3cHG#ms-B?rQMvxPvG<I^b%+4LVCHK3oMvQ:nDApNSMsP'BFSRx$0>V[2CHZeRMA/^,MCGY)NDJPdMC8g,Ma?x/McQXgMEMPdMcNFKMA2g,M1&EI3GL?5.`E#<8045H3++VP85%AY--[ut(?]#03jfPH3^O1EHn*2EH$L>t75[I*H%bV=B:RL6M#%8796VIF%CBO.NVbm-Niw/?.fXZg3o_/s7^cX$K=G=:2DKb.N(b&NM_kZL2q-`ENn<K$.:17LMnw779)Wqw-N^p/NIcm-NGP6LMeY`=-=SwA-he`=-#r@u-dDq/N'$KN2+LgS8qcmw907PR<jcE_Au4*.Q2G(g2atk_/0?=j9u:ViF1cp_-irQF%1P:g2E/6C/&i47<.P07N,LgS8a=e--E&rZ^?&=F7buXtCX1w--D%ZK3p`9g2%YU*[Sv3x'K$8R*<tK88<%%d3FN6p8^1m<--lcHMPx779E&.A-D#.A-/67^$/Q<.3R[)K2>=RhMTeov7&$GT8%hUODrhBem1]q'/VsC99N/.(/A>h3kJ8Se6gX1x'&Md_/kaQR*Aj,0N=%<.N3iZLM$ILTMbp).3x&(w-S3fLMdw_EN0'(w-VKO.NgvmLMNpC*N/1N.N'1N.NGN/JN[WgoLaO,hLXVwA-ooYs-=ad.OB8,0NM5gN2IfTDNh7,0NU?GKN7xUH-QuM..WQX.N7+*MM0x779na2E-7'(w-?U3.NX=50N*Cj.N03:T9srM88UPGm8hmAg2e04.NM9M2%iU[F%$9RR*:e=:2Nke8.s&$<8rnm;-,9FGNn<K$.:17LMo$8791a+.-A`uw9xMVwK>:WU8@`&g2#+K88hG9g2Df1:D>t[hMD*p/NRn8NMgeGPM83J;Ne-,KN3'.A-kUlDNbZ2$%a*nU&P9Yh>0k>O4Cr>03Q]=h>U-S-3`Xnq1$E'kEE>IkM6*p/N4n8NMuMOKMbp).3v4SnMW=@^M0x779rK4v-T?=.N`jZLME]cHMrdF?-d9QD-.TU[--cxw'tQ5x'EH-p8EH-p82PC,3v-*W-pg4X_wv*g2C?hS8#Fj8.wVu]F:*4<->RII-oH#1NCkxv7JhF595,:'fdG>)4&;?)4hA0g2NVwA-5&.A-06]jLVAMt-;7@LM8x77916]jL(7nMM8x779iNGO-tj]$M^J:@-'qF?-CqQT-2wIJMSB=KMfE51NO?GKN3XK]$vokR-MS*^-4[q&$(FaM-T%XB-gn/0N]%wLMb#8798&.A-wK4v-gV60Nl*TNM$q).3E8$L-?dvp/Pw)gCm1e#J(oL5/opB,$Ija8Mp*ae3#x#gLWhv-Nan).Nqjar$dH(auZ/ae3*XZR*Z(RF%kHnJ2j#^c$tLMF7C=.W-B]p3OH7?O2rQkO:]xxc35#Us-Wg^/N=Sh29t(,d3=CO(MG+p/N-0#0Nl5,0Nn>W6.@U*.N6p).Nto).N`#EIN,ODR9sxxc3W%2W-R9K_SNuSkX4kEiM]dOC5UWaJ2f>kwKjQs;-M5E/%m;3$%xiV^N*S#9%LYl;-VOsM-YmDE-;.Qu9M),d3Ut1f9EM?-dW&vjVX)ae3','gL0mDE-.A4R-/^nv8$`sJ2'15x'kvXA5vB]A5::WA5&<MZeZ/ae3Od>kkZ0OR<D$%gLuRwA-shF<%D$%gL4H[61[%+?>4K/>B3u3$JD1KgL0HwOEp)iv7ft66%l(7'ZX)ae3j?)gLcDbJ-T:'C-h&>D%(+n;-UO?a$F$P4:Z-,F%F5RqVnR#gL(7H&%8_$gLq>-.%b3)gL8B/(%>(Is-Rm#0NC]-i$juDqi.Z+*c?e(eMD)8r8vk;j9EWjJ2qMP)%UeG<SPRCq7=hF59^+CNiHH7+N)bim$XMw8Bfw6q$EhoR90jcga@nC*Ng%9k$%`DF7:GjwKNS=F7=<=QL[,<i2>4I)4xvbZ-7Ad_/`:[F%x,Nv[ln`:8(Z]BHY,ae32E[#%xk#gL/Zps$KSCs-H30JNtq'S-R[)'%E0o;-)R1x$Z5Mt8o6oR98(,d3f$22%7nIpKkeDu7NG:&5)<#K:4^sJ2f(TkX(+$gLk(D*N+lmhMl:jI3)K9W-dY1ppX$<.NYkH.%-SodF+E51N-%<.NH$2e$3p/f33_n;-S[)'%SO(gL>@)UNS.iH-BG'`$3b<.NZ5aIN^e`=-RQ#9%H_/F[_GW_Ao-akFl53?%I$>w$?BxTKo6oR9$##d3A%.W-<IJ-+8=P)N+sVu7^>u`4kvXA5hlUA5J+V_AENK_S:?mk45iBRN(I?_fM[wt7d?/s7`7UNiX)ae3c6/W-YQ%ElPA]n$5ktw9*)0w%Po1i%cP_,b)npC-rchY:wVjJ2$w%3%F1ZK3qY6.%Aag/NJZUp$BLsU8W>nk)PRCq7+/*I+PRCq7qTfS8'DV,;5i4R*?&_/:_]sJ2T4CRN$o#gL=`Vu$D$%gLUrRQ-aBS<:'VjJ2SE9s$8Zm?.@nC*N,8,0Nj3Eb$-xDF7OH%gL;*gN-`7H&%:GjwKOYFF73Rn;->sw^$EhoR9OsdP9:4gP9>4I)4:]<^-Nj<F70I[hM'-<i2)V;&5ha;:2ogIs65>:q'KGRR2Msel1$E'kE^ft?%:GViF*^k'%?tU6M6x?DI1UvV%m[[5/ds=gCR#]rLvQ;gCQi$.-E6O_I1XvV%QLIs-LJe)<4YX$0K>@RMf_uGM#<P+He#Mn<--i3=+L;s%1)f'&#GRk=2Ke0>*=Z;%0v.F%(lWh>7vs-?,IvV%52Jb%<SK>H0kl*%>bQ>H/,<M-KVm=M/BKoLF<BoLG<9oL/60oL9k,`-dS_ha?-lrL(VY,M49#HMY3(F<+O&:)i9%dM7d#pLC_uGMY[Fa<CR6L,3qU_A/7%].fP_b<vJC&5VY#<-WY#<-XY#<-YY#<-ZY#<-[Y#<-]Y#<-^Y#<-_Y#<-d*>K.7;2*H=Q`b%;KVb%@^7C&@a.(&[jU_/[jU_/TuXGM@B8ZMG37oDSba0M>fxb-nrQF%*:73;WjZL2G,hK-un/t;di4R*pI*%G)8ZhFj>pKF*BFVC<'thFxJrv7jk:t/_NYs8eu*7DTl@u-;QRnMTiv-N?$]f$Dh+4:j.,F%)#,.-^q(gLhBj.NppJjM&wXs8o$598@l0VCnLSM=:2da5#Kib=30,F%A0*KCD$$&J%N*:2u4l9'X#<.3e4m;-nYcd$@@WU8J-,F%(.rJ2i25)%X2`99saTL;5p:_$VedhM#LTT8+dA,3<kn;-aWA(%%sDKEw/me<Yo]G3#@3L2rQdu%'+OGHtrY1Fs^wuLc7i&MXn).NhJ@^$IA[qVD+nt7ww^kEncA70<UMhFm'ZWBT8Tr)0QbG3MSl;-&Bo3%J:<:8x^nFHrxuhF7i`V:Hp]G3F<o;-+aF4%E0dgjk`aI3xVM<BLVIr1q4s]&8<7nM5'1$JsE0C-L0%I-OHiIMQ9VT.*G%'IGG5HMZ-E$>VFCO+wMx34OKN.-u%>s%.&o'&kcrWB*QCLMIjv#>t#Qe6anO_/W4Fx[D<S>-+m6e%7nV8&H+$444m:C&]DpP'q)nX1wh5qr(DZe6Y5T5'l/]n3qA'=:VATX%>Aiq1Br;MFok>lE>WWoMBV6X$5q`s%$]eFHp-c59TpwRM*YVWH^A^L2+Ps$'W'3acA*/Y--fS%'C?4MM)YIpI.+^b%6$/iF9xEcH-R:@'0j_lMnlm?>LE3=(W@hGMWI$##%/>>#2[oi'$]X&#l4[w'x_9^#:4E_&:Ys9)d3,/(4NBj(pYKe$-G5;-D4Kv-xrKe$:=.5/JkCp/*5Le$JH^f1PQaJ2SK2B#?+OY5e1e>6<lLe$nn,87ApW>HujNe$E';YYY7,HjUmE>#FHPJ(_dUaOj[$v#:W=]k*l=atwxF>#,NTJ1V,5d36SLe$+3oi90+4mBf6Ne$4korHFG5sI&$Oe$Bj-2KM1I2L/?Oe$T+#)NX?u`O8ZOe$iN3;Qb;jVRAvOe$))`iTnRZJVNGPe$@`t1gQVjfi1FRe$c,CYlfa45pE-Se$)+l.qmJHJrLBSe$9<a%t&ltAu$)G>#-MuY#)@m;%`vJe$_ejP&4NBj(kAKe$wJ[D*JkCp/+/Le$[-hfLp,</:QqE_&>Pm`<?Li)b_5'v#uS/Atoro)3$####Q.`$#//5##&k9'#i$2eG38=+FcWJ.#OG#m8`Yx+#O0=gG.#feEhpf.#1)ofLx:-##m>:@-(G5s-enx_M/D#W-R?3L#3WGb%^2CD/A8wu#JiI3,#)P:v@UG&#7FuA#Wuq-6%'0WD9lTJH/w=8NoIfiP0(9L#?:A/R`2;mQ/iWGT<u(mQg^;/T7*(IU(d;/Ts>t$RW6-aQ'q[BQe'Wq/^)raR#64KQQSjf16u*WVbH#IVo$(-RANq`M(9&7R:`x-$N5goN]f/^^h:;&pABgJ61Y%jY$SXcR1b1j#+b@p&fKWfL%e.UNR8N8*[?cJ-b;`iP%$n]0v)n'&/OXv61&T]T_ddYQ'mWfLY@#`QXZH>Q$0720E+JL6ZiTpaE9QM#ihlrM3%sMQ;e6@'9#$UU_IboSw@sFQoT`S%rM/kU=_T)SPl:YU6<k_Q5bx_R.%;^Vk6pOQ78V2R-$?ARJ3MmQ1]mEQ8FDUR[%k?R6P7fQe4B,O/A59sn.qiU<I^V-u.xL#G&fnQfkMuO=eSsRbLLASQ6K%TMAQeR/t&SR#vcPQ]I3DW?;G##h0Y9ZMXN1#>Qj)#89Q:vw3-#vV$`UQ'r^8Qx84X-Fp[G7o%gWPJmD+r3JADtkeSY(0lkxuK]CQSBsD+rhHvl+'+`:Qvgt[tgd*(/<9A9vx5c%N3`,W--kS_&Eaf=#^3d7vuvu8e;DPd$ZN_3v%dDE-8IpgLeR#sMe31.8Hrkxu/lr:%UHJL5,Skxu3duK.H]Z7ncp@@'wL^6v7bCH-i[lS.5<m7vxcw'Og<^:d.4L#vX(>uuuZSCMUkqV-V6C_A=Ej,FeOo^QJCpL8s;%m42Y1KEt[up'8_;,/7m5xM0YHm%rI/x'*FxY-wVB@0JSkxuKvlx'Q3/90vt]+MDs?xkCj0jr%07lf$h,(/_ET_&:2x3k'`hp7[qkxuetnm-Y0NdXA1IxM=%lOoF')g$i>I'N4DcCj?E0(&.Skxu,WrEN08,ci75;onHqlF%-`]e$e2I8#QWw&/SF8log,gw0$GT6v`(>uu1gDWZ46L1p.7jv%M7Q:v:FlxuNQ:&O-K/VQ*fkxu:JU2T?JPd$31]5+vj?38F=<M,Shx_MvWt<#RFT6vnTJCMYIC29_Qhxl-R]j2tb?_t.u&-))(si^39qXu]+V:m5JN`o_VT58TSpYCSQY:RhkVX-4d$#()o&x'jDR'NY]=m8LTOAuZouXlt9fk9#9&8oa?*?R+93`XGKQm's%fE5JM=%tGBcU*'QA-:5vQ:;Dj4:vUwu=P8sMf:P[kxu$j_g`Rm;3(:<>S<5_/K:UEl(/)fbxukI6/MQrP8.ZtO.qTE@@'dL;<-)>SK)aa4LG]tee$V_[e$V_'L36+L19B6@-+eo5f_6p^WfIVX@t/CZFWPUN.h;RwQ8^@)jrMcx_sJP_:mo#@(sYQ$`A?>H&M(`JFM#07lf&bj0M9`G58^4@*/@@lxu:?q5'XEL_/PNp&?V)9@P;v`Frf(i9.sGW@t+B0<-mtY<->Ho$QO5$##7'`B+BarxuuLQ:8Ke6^ZYm@o[,TjH%8DgoTe3jm.fSf9vdO#<-l8>l&/BIk;vEIR($58O,:Rwq77k9x9$0wN8brvDGdd794^44h8WBu3Fp7@-bXw-78X.3:MR1@p.n]+##A&]R1tXAFMT1kB-8jg>[g$L]8%Ta9D`<#EPEDx_snEe-FhfR^$pbvFN4WX@t+1`eM&0av7,l<Ec:[dxLg:W*MNW/+M#L:`Nq&qXuZ]9eMv9,a<VQkxueQ9SPX6VHP9ImdMTf8)8AE-x0Wa+W-QP[vR603k+JEYjV+(pg%0k64+[m;@0O$IL*N@6uu]+V:mmlG-+$'rOfcx.(/(Fm,Mvn,p7uHD?%U%&FPp280)3O3D'r@V9.R[O.qkn7j9M>h-OS(vx)l<NQ_4JBr-S(#(8e5e4v?FGS._2Huct]W_&h0*##H6&.$AGqs-&>'@MBDT;-kP_-%6L_#vDpM<#EM35v&b_68AVv&6O[O%X>-[qDO4Ng:$]>_HM=$##C)c=l+FZqgX,r]$4W^[MG-P?MS-R8.Q(wRnv?k22$=SK)aUQ2gU^U2)<_Z:gI%qXuI5HY-J8%_QE7NV('CWQ8g`*9BvQgl-$[Q#v]AJ9vS%'58gB^EuR[*_&;/i+OB/QW-?k[jMk2p1:FBADtJ-<L#4nip'k(-*O0h4on]UR9.sl+##/T9<-_B05-)q=X10ReEN4g](NgEx_s/GtxusV5p%uvmxuC;I*.KDKwM1N$MTY8u'&n4>,M=XI20HB*##$X.`jf78r9[81[-2hNF%pg.R3Fl(R(IK]Y-dn3@'N(85#x$J1vXH)8vcjSN-0hPhLbp52vb;m7vKG`t-&thxL`>FgMbk-W-6Few0imI-MZ(G58:cJ^dqei#QK%qXuJ86wPB6&R89w9#vc#s8v]JvD-F1D]&<]#dM/*Mn-^2$^m<3eu)UqxCMOxhH-a3,#?Hd`'QXZr.M@#E+rg0gLpnrSf+t9glT5?hLp]i2EcY>fn$mih3=0F)8v1NlDMAYeQ%`W(EMhP?iTvnHVnIJ(KI_?H?7$pJ+i-PH-ki=M(a.8f'HKlp9vY5U.<_E*m+8xkxu[%En')P?^Ow]bK&sY$VmX]>xkdYcW-/<CX(As(:2L2IC:@<g'/G@pPq2Wsq-q;JQ(8B6@.sGW@tkJm+sS1k3TWWf78]Ykxu+8/B.ZhoLpPK+<-K4J'QwtA5-laxwB8xs-$Xj&:)5Nkxu;t'T&$vWQC+W8xY/K/VQ#QnxuBAG[$Bo71vIBk8.jJY.UXR->mRlfcjbptk=.K,/vr.(dMs<^:dNq5F%A#w?0X+0&;v8EX(=YZ.kZj%S[LLUe->;QAMJ;hiTLRC%kDt1'#bK28vY.[$;BfMcs;(.W-S<Zk+:T3@'Hf9#v:Z+6#F2t@,Wdt<-c#MhMlEX0&'Uwk$T?kp.OFoLp>G^?^O=x'-'#gFi&;j(t&wS/:<Ek+J.k6T@5Vf?n*B;A.&%Z=u3<xp7hP/F.dQ-+8Dccp7OblQsOqraNIw9/3,rN6OV*%dMKM,W-=mh<2@UP&#^@Pp''C@k$xGYT.Om`8v_oVE-8u6^&n6qxu>O/Z$8fGc_i2[]-G>Ye$&MkxuO1r&OqVHI%AO#TM'GQ:v['>uu0<`T.fp71vErTH%$Ie>MC(,)NE)u-vWP`0vAg<_&-4?,M)W`S@?p/:)^I:]Oj3e@k^[3@',Mkxu<Q44'>Llxu%gNj0iBG.qSC(P]LoK(jn##ToiFjx45R^9M1mCk=ew=X(ZN1MKYpwXu'<6m9-(''-=]$XNPm>W-005`&(`kxuvx7p[1Y.R&H&>uuX7h#=Q6gZ/AA(A&C_f:.w(/fqKuv1q@=2r9uu3P.JL,rKnmb(&nIj52AZlO-m$G%(<SgR3o;vh:Om'#v4/&d:wO:4+H_MdMC4d8.ri+##pbi(O;'$*&3G46)KjE((5]_F;Es0l4vK@II/A_B<E<o34E&>uulp'=-@Ggv&0cZ0C9Z`(ZHi`;U9,^ZPMj8ZPFMg<-4FCw]ea0m]0(Au7`EJj`bu9xttPs[tw+],V7Wg_-VDY2r`HjCYP;/B.n,eCsfr-2MOF,(M5@M#C9hH,Z19W$#BpJC04J;&54D4`/<PtvR?RBtTiua;&1hN_/r%m<-Y[m)%-s>W-5IU'mX%wT%hFV+`)^V.$;0`%Es^kxuc$)t-3a9NAA/:@0?AZAMI;K`(2+P&#H9F`9kUkxut[k0&'6JdM8_.W-GRD-XIvor']WU7#<@xj'K]+#vbF:MQxLPk%n'U5^Agf@kn&1;eW1iv%_Z@fMabe@bNph3XGo;'MRdia'>4*<-2H)m$0>1F;90V)H#UKC-.HrE''t:C=pabk44Skxu,j:l'n7N6Sn<0t>]C/F.`[pxuA:m,`X6#k'uvXX-wBspBl/CH%PO8(Mbtnf$l^k'&@kYXLJ>LW-9j-:)7'&9v&*@2M9rY<-F9vGD7S:#vH2s<#:/PX*hkk18:Ltw91VMF%r>E-Z#AK6vh=n4vx6`T.agV8v`4'G.7)Z7n9x-W-Bmc^-%wB=R`Ve^$%V2<)PtS-;iRf%ufjkWQ%)#s)GP-<-MX3B-4utZ)2Cw9;nIZ+UK)?F;0vO?I71fBMPAKGMv?dl*UWkq01p&AYWV9C%=:n(<FI)RqT<1k$)?*#v#J.+MKV/+MQ_8/(59xDG87_19?C14+wLbxuUH'X-l@Sj;KZb%=aoVq2JMkxux&:l'fHs&O3eIj%FaKm8ju'#vv-FcM_$gFi1*(`85D]Rj4pFdMC1'YcUT2XClP+F[Ako=>VYkxu*pRF'wE)&laJ?R3'mc8._sf1Tk,,<->a`=-1apV%VElw'VaPF>7vFoR]W6S*H&>uuk4f*D@I<M,Ds^DlRIc^E3/6/=x#?D-b&?D-UX<^-Bk;L#G`HS83a'#v2=YI:Vdkxu0e$mL&Y]'NJrT=uf<<;nY*f(6jx`&Ng:$##ksCcM(ZH.qkcR'fbX3^Z]lB-N'K3#.(4a'MK&@e%)e*$Mt:jEMw^_@-bjG@.ZOW4or9i-MS4qV-rJiWqCk?99B]B=#l%3/%tPBeMJ^CF>r&a^6tTKD&N?u8RAB,49+05(J4W1?nrL/FMgPT?M(=[J:lRb8TK-1loj`IjT*<xCRaI^@PqAnLg6i[CFoG9vnQD;<(B?PJ(u8=p70FY_-:I?i9<9@@'@e(jr]A2Cut>mU,8v5X-/SeKEPq>4HKOGG.O<=WSs*Rq$Js+>#dWD8v+35)M/r>E;Jfkxug6)=-]qFA;7b7TEKbe@#vb]&4p>na-N4=(*b9*L#D;WMUV2KEN+N$t&Iq;dMG?hLpOvE6A'BbL<+W:'-g'Hb:WNhkFqLV'OxdRW-$bjkkk&9XZL'vmZe][Hj<)J[>kLuwR$%DgMfv&3;WTC$NtqPK*7sT=u;crxPp`OY$ck#'ZcI?*(-oqB'/;:b;x*s(t)a(['vfQfrfs9Mq[b&-;WOQq;:_9NA1:pZL0-B^Hg(U=uT*-crZ?BT.RT;8vhRZL-6Z@F'[NsB'Khla/=(Y.<]`9BBWu2;;2CsF5Q/T(%*F,'=V(/Dt#[;QAadoSs8Ok[-[l:RqR&f[]=#eEMXdsq-aYL(&)O.4$,NQJ;MeKZL%rm]OLN+s'co>r)L>).-7W^e$&PkxugS2x$5Mst(GHUr?2uO&#79@'(QSLm$?c)1=.NbxuZ@e;-hdjR%_V=sM+sTH%J59b*0]?<-cM.0V.l8('nRm,Xnba>.LtcCs(WvE&eDwq)Z#Qf=*uZ=lVLY35H9MqM?;N^=H^L_A3m(>-mBG-&Hqlxu'vQ>P`e*]b%PwD<;52hb7_H]%@-(Ls8Vej'eu'eMZV=b&v5Ylp#SbxuRn+Q/Sd*##0k2ciGc+#vg8>)Mx+E*MM?'_MKM^D;03ew'_eD]F^KF]uwvWdM4l4d&P6v&#_9m7v<=5?IxnS+MJUov$_j;G%EPf8@/nHl+78oxuIO?d(6wRAK(FlL:@kO&#+DD6&%N-@'L1r-$Sk2ciN#/#vVQ8(MF#X8vl0V2);)P3;DM=%tB2$9.to+##I5Z2V^Vqw-5pm/9/g'#vu8cu>rU8F..;Ze$uFbxua+La*1'/eMcn@o[('Z>>)2sF5XoKH'+dV.$<ES9v#WQ6'ph)W-/luF.PUQ+i/Z?N0F]E5vV(>uu_mk6@r^6.6>XWX--D4qr<kKNAvVOvINgi/)J`NK*joAh,k8nf$%tKwP%`mWQ%Q:W-fVad=mtIC)R9TpRG[_@kAc.qRpo#o8J<;G@VaAFN+gWV&)t/WNgxmJU`p3HWom)VWbpKp8QtL)/?`UIl02/$(aKmxuA]'1&W1n`O$fdW-,8iL>vK)s+b&Y2=*aH[$Za5E.b@B;MP6.a$)Y`s-e2@>MqV`S@3El'&1#Z&mw]Pi:c4lxu3%Af&2D3ikr2w?Y7R8rm@po-$C4Hdbf[tvRZ1Xk'cMZh:LkiR<;Y:_?V;&#dblB>0Pk(hQXH;KULZor77W4Ls_kCA8U*u5VWTM.MvRP,'cc6X-F1xjiEm-h`shpT*qQce`LKaVSFY=<R=p#m)?n8=)m=v>PM?l@74Irfr<u3k'?F3X-rj]b?3IEI.o=xOf@Y?e6]br-$iJ-WQ7P1f-DP/>8']dpK1f2YQq$q391_[)CI%on&w+2Rfq19x7Je3_?HPc19:gGXC77J9?[RkxuJ[(p$;#8Ic$aU.(M'dxuZwF-;T)jq2Yl?2MlN98R1q/oTXuM:%?[Jx=3xZM52>P.:=bbxuU@hdM#Q-`6B]Er$4,)1:(MS_mDZdIq7ST%8jOnxuZCmX$#QX]<ZQkxu3YX0&xBSX-&2/7D/#K)88#=-=n=Xv%s1gh$j8rRSgUS7n@J'<;64lxuniGp%GN$S@Owm+sx`q.rp9(9I3Ilxu^1dq8(4ewBv0E:gMd.G-s=*8:rX)Paug+A-0[e/M*%+#G(*Bf-e-+A[I+qXuWkr9`$S=Auf8VR:l;$a&QCP#vh#s8vwU0_E$J14+6(1i8*HM'o&?ksM8C9j9/np.tmX,sM?X0o%r%uc'C+s&FNqiq2BSkxuUriU)<NoL.5+89?o28)tkT(fqEvu.rrAnxuqT<j02Z4f_ThkIq&l=lfsV$jqlZwI_8:lxuPHkDux&rOfeMpP8h8N.-ZPj&=D/9:B@vXvMld*gL.p<8v7?G)MDxp9vel4:vc[5<--OM=-%OM=-Y(KV-hO#<-vZ`=-uO#<-k*m<-shmX$KvrrpH?f>-mB;=-^T7r'Otfd;(L_AnND,#/-M^6vVf+:v5b#7vLN28vtbYs-(D%+MJ)X8vwQ8(Mv:-)M=B[7v0aXv-]_7P@9bC?@kIO;P%op9v`*m<-8t7c(r1_&O@Yh5)7w93/+IJvT3XPgL&#;'#VZw<(XY<#-=_9j,<[EM03`(G)(?5g:&F3/kueo'NQ5E3&RVG^$[58r'0K,U7g8-ji8tT=ugB&LCxXqKew`M30`L[7nkS+##a0_?%au5Gc)jQW%CWT7A7HRa-m2A(sgcK+QW6sTI-5Zca=pK'H%c`d`#F)>&;x&+<LQmxuqr7tMRw:oen]+##BYYa*&`)<-TMi9&$cl--r<5Y8-98$&*3:N0h`x9vWgV8v?($v=-/(#viun&E/R4*?B1/Z$$hIYm1^,f*psfs-UuC*Mg9-)MW#qCMix&`(,jJL9AsF_/0f9#vv(>uu$Z1&QebG-MCxBT(C#_M%$1R1Hn/[4v5aM8vmO35vk9j'ME:.&MiVZ)MET[7v4rN9#&o;'M.+G5vTsi8vgRd&MH(i%MFh*BM-p?xk_)`0%(AjGs?'*##WbS6ri<Fc%iq]#G4ng-6RmqiQdMGL[HH3$vaCw4vD(>uurZp6vM[WfLvUx4vY54V.Wna5v<7T;-uhG<-ONM=-cj9`$HUsCn,@bDuvj:oebv[MUBVA;.CFgFr8J,#mS1svK/@W:mAgcw'/6=eQ+%6;#JJ@FM+/Qt$u[4/iop/`d`>ojLa`^9vbCg;-#e^L(c1H^$J_o&4F<s&8Cdkx[/)/w+0/,i9E])FP+nD+r8V]A^Yh5F@xRFsOud4G>Zba-ZanHdMV19a*'T'68NVS2`;I:](P^l>-a^(@%ACsu21C_4F)t`:gp:_HN^.qH'cJfH%wG9J=SWEBK[3PK3f6FZ7dBCK5LiqX'FscW-(3X1:M'+Wo(^$u+YCb?+@0sa*/3`A-<guTq@bRq;v?)gL/R'-Ujt*De`4/?7E[0Z80q.?7]iR$8W*+w@ngPT%cAdY-BEK-OYK2Vq:C01(a,K3)VACO&>+ZCeVvT=u&pvq9j0r/Zh)a&(k$q$>Onw@B<w>gBCis.-PqS2`v@V/X:un]-,*^:BR7ah*+(*r7%KLa8*xKpphA2u8G;I&#7tOp/K<ET,p)T<-6gMa-<g.eZKlJn*u;+Y?XBl)6od(Se^be@bJ3Uj;S<u-(dP,Y]T@5D'Rc0=+r('6v9u<x>goKoWl8uZP#VFK?tMg$(Bj4:v/n1se5lPp'>6egL[d1t'X&Nk#n]EgU4^,v-#ec`*7Li7TN)8*&DLrP8b9WFlMv^kM+tU4fWso3)_%H^$F5.'(KfLw9>O#fMYpM>nGM.X:'2L0SUKnxuNg_T&:.WL53$TX-w<Z-bt7h*+:qDb-J=m`]OU3N%OS[xe*-#+G2]YCFt%UL5gSsxuBUs&fUl*1BJ.UL5FlKXoH-+@,C`2X-QTV[Ld_Gx7%%oU1]:7##^v/M#i?uu#spg:#1),##-m:$#@(V$#^iSb*l26X6_-4&#c9F&#jQk&#o^''#upB'#$-_'#)9q'#tS>7]Kmv5/=vv(#A,3)#HDW)#,5C/#UW^U#F@.@#W%Gu#3v2`#'<4e#-3Sm*eVFT%lXU]OLsJSRdU<GVE#s1g9gBYl[wk.qjv)Dsp>a%t(D(Z#;XjP&R;[D*8xJ;6m7m`<oI;eH7hN^,U'O2_6iG,acA@&cBtjudDHcofNA*jhN8mv$TlScj&ik&#,Tq]le9EVncW=Ppi86Jroo.Dtgn8F.MtcgL83DhL6W%iLiD5&#EY=jLLotjLN=UkLTb6lLZ0nlLaTNmLg#0nLmGgnLslGoL#;)pL)``pL/.AqL5RxqL;wXrLAE:sLGjqsLM8RtL>^3uLY+kuL6o$3#j--wLpBdwLJ6t4#0qb2vTIg;-Q*`5/E4G>#iGIbMmC/bMnI8bMj1jaMshfbMi+aaMh%WaMj+E*MZc%(#$),##O`R+MI#e'vMF(v#3^=R*n:U+vf=cY#N[I+MSVEUMJgo#MgF6##esC*MDYl9#o2s<#v>/=#1`5<-QFuG-qnls-Q+V*M#oS+MC-lrLfHYxul[5<-5a5<-snls-ET[bM>H6##L/kCNu[SbM+,aaMP]oBN7-d2v&bEN0k:P>#uw>V#$v4`MZLu9#F7>)M.ef/.r];^MKx_%Mh/'G.>gsXuf](5pS4K&#`kp&#quUfUwNF&Y5luu#<A5:)]6%A'5FZl+t8-@'GJF(sEj0RN[gPEn$WQ@'=^,A0-/3A'q5?@'X8u?0Y:Fk4r2-@'wkH(j]DqRne+jLpov=PpsV6JrB%r?B)&(##OP,l4CEeCs3@C#$$[^A,#(m$$3LgIq3FK.qCj<xt)uY<-rtY<-s0;t-Q+ofLxo+G-a=ClL0E/bMCQrhLcX1)Ntu2*M$Zlxu`;3jL<.lrLT,d2vjSx>-XKx>-AfoF--teU.E(:+vwhi6Mi,E*MxO1:#$j$jq7q(crPnHX(j8VX(7wwF.1^^V$C7]w9E`J&#`fEa3xTG+#<bY+#<nl+#I#S-#C9Xxu=)l?-%<8F-x5T;-$6T;-?MM=-`M#<-BFuG-Wp,D-rU=_.3C_+v?bCH-7wT-3@Qw8#X+?;#ehD<#mCd;#S0`*MVjQ'v[Zc'vksr=-uNM=-1/l?-k6)=-8)l?->M-X.&m7-#3SM=-`NM=-oNM=-uNM=-wNM=-wRM=-xNM=-+OM=-.OM=-xNM=-#SM=-=YQ.%k%_q)=*tr$g5U9V%-:rm#E>Pp?i7Jr8%.<-.(MT.;?/=#_Ae>%H6G/rGM&cr@0D-mkF1fhV*7qVZSsxu,BOr.^_;D<:8s3+G6Oq;l:V9`9Ww.Chkt3+JY$kk5]bFr-cf%uNA;Jr]8/4:>aW=u+A>>#<w9>5X,ru5A$#?6S)RV6@x7v67FO2CZ[5L,WhjreQ>0>m*C'?@3`SV6@7-<%JeH(js_-;n#-'8o.;RfrOxu%cloJDkH%V-H$u%/1phX^6d]d)MW2X<#.`e6/JZu##+#:hLeqT=#n9_hLj?`P-ALwA-N(6-.BcqpL`-lrLx$9-#m&l?-`QFv-)<r*M,dA+MfeB(MH-q(M5p)*MJ-F<#&p:*Mu/pWnJ?a]FiJ'#GpgE>GpmaYGt)'vGEN=;HW6]VHlxurH=J?8I+oVSItP55&]3P'AK2###J=On-fE/F%14n-$>[n-$$#Rq2k5p-$oAp-$LG,F.m$=wTWmWV-/v88.*<1$6-X*;H,$#5J[=voJfr02U[/J_#3m*v,YXg%OqRVP&;UfZ$i,hJsGxp=#jU,gLqgm##[KL@-26T;-f+4,%Rj<s%4I-Z1gUsY1Y(d;-$9F,%?ijv.?,&cr9ISZ$;WB>GA<fYGA&9vH+Z[3Ov5Ks-:^=oL#P>*vC/LW.`v=Y#tQUA4V-&X#x&GY#nTG/$3+j<#fn57vWr:*M4et<#H9&=#o>/=#N8i*M`+L=#JLIwucgnwu;&eiL$bo$v/>-$vPtC$#eT)<#hC9:#2[2<#,N7+MY<.&MV%m180O5se(_$`s`3R?H0TKulV5[V6u:n34(J.`a4s2_Ap;I.q,mV4f/8VQp:1sRn%/vUma=ArdAq)bk1xnOoqTQ.h:h,fqL#Yw0:Ta9Dcb=A4Ogqu5K>k>HkDE]O[Uhxl,x[']1>6j(aqWm/DLSX#5^^:#auQx-o/wiL[n(#vpNP'vdFHL-WN>1%HZ%2B6t*;H,9/M^x&UKEho)*MfjJ+M<vxbMJ8W*M1Lt'MA4N*M>'h=#/6i*M;X0(M%)i%M8Fk'M:/q(MJ^d)MVHu9#KH@2.mZI+M5Lt'M:I/wuaZU).<N$iLnSlxuw&KZ.(D?$vZDGO-+3'C-43'C-jm6a.BJ#/vuSs#0_,Q7v:cx9v.(@A-Sw^4.`Tl)MN97;#:x^4.;tC*Mf@b'Mr3$)M%kv)Mxp)*MSZBX#*$M*MUaBX#v98X#VwR/MPFj*Mt[i28V7l%l4gBSoPmboo&u4/i'@`'/GE*58070ip>Z<xttQn-$;Y%N0f*V$#IuP3#:rB*8K4(<-F<A9viA/=#8KA=#vPJ=#6Y1vusgCvutMIwuPgnwu7m4<%v;-$vYQE#.O`R+M@Fj*MdRQ)M?jJ+MmdA+McX0=#^T-iLbP]('.>a%vdQ/N-qvFg.3=U+vG@eA-=4@m/6*j<#6tV<#FqdT-)`CH-$;Mt-&>s'McQiM8'EASo-@t+sj+b]u9Uh--=W+##W1B(sBs+;nmXm;->bU).KZI+MOc;7#NIY)MB%>T#Pq`W#m*(]46saT#RkVW#qW+:$A?uu#.c;<#blRfL#cSwuYi_h.QCj%v.j(1.mwE$MK%6wL:u738(wsY-Ix:m'@Ebs-_Zu)M`.aaMx,F<#:i2'Mvw2*M^ifbMVld'v,m*J-j,#O-@m*J-&ps7%uhMq;c>uq;8Bc^Z<2X<#nb&Z.$EkxuY'KZ.PNP'v0<7I-#@eA-:@eA-B@eA-@MWU-A`Y%0hsb2v)<Xxup@110,+:+v@1C+v0hov$<%S]=D]3VI]B%JMto'##+re7SpR$3UOJO%Yh0Ao]8Pti_1PQe$OR$VeZ8lIiU6K_&0hU7oi&12qhHSe$s-b]#GjPV%MM###k3_c3TiC]PBr<X(R/-8/N9[21aE6R*7pOV7'Qfu6$u-20?7Wi::JMc<seMe$&Y:PB2?,DFAKG_&gnl1LlSUP0oS^%P'W^$0Q+JoSrUAX(r>GP9`($##j>p-$h[2V[.p[P^.DQe$B(l=dquTK2(b`7faVU+jee(&lXnRe$K#9iqCC0>?_V,cs_gaw9WiIT,D)8>,2t1hL8^IIMJ,+JMCGF/M>&]iL28$##LlM_&33`&#qR'eZa]%^,bH@X(VH:D=+3@k=/(=2C[v6,E=?.&GCv&vHO%VpJnV'##X>Z_&[pbe$b,ce$h>ce$nPce$tcce$$vce$*2de$0Dde$6Vde$<ide$B%ee$H7ee$NIee$T[ee$2[1Vn/;xOpFr*^,4M,W-jNfe$)#WX(xRX&#,aU_&.<^e$f3c^,Y2SY,^VtJMX+UKMQFq0McD),)rkV:m'PD_&kYK+iV=#`sOG.ip%H:cVB1KuYObK+r?lll/If7T%IQ*`s[xViK3sv+MJoWcMAlo%O[xg]F9*+vGo*aVH+eKG)h3gLpX(DSo6tAO(Bo9xtS@Y@t$^po%V:k?Bth.F%J^98%LhoSfBCff(`HSs-CHKsLD<R7vnIJF-xlb_./KA=#MY+(.[.vlLGE`hL*Xe;#9x19.k9c`*ZDlD4%:tQWll$4=ga0`aovFp.iQJulvrsvICP0=#'C33Md]j?#8EJX#SH]t#f05)M0+t8$NgGP21mG3#IFf5#AYV4#&)85#x5T;-#6T;-(ZlS./#/5#1N#<-26T;-36T;-UL-X.CMC7#/O#<-h@:@-<7T;-LjA,2>erO#a7]P#b1SP#0;S5#/ruE@TGl-$YVl-$$KvW7$@r+;*_Rc;5X_E[kdk%=UYL]=]nt1BO?PQBmTUiBD7p.C(<=$mHPxu,+#``3x1su5dK;3t4c+5AEuEPAIp$)*+7)qiuJwxu<I<L>q4wK>q4wK>(]wK>q4wK>,iwK>*oEL>+M`3=5;Hxke(:#m..<5&6s(d*?iN#-U[8e?uX8e?(u8e?uX8e?_QZ`*).K0%Wg7-#rK5+#],uoL';)pL+lrpL,r%qLHkY9:;9B;ISIniLeiklTfr02Ug%LMUnTs;-Jwb4%ul1F%)sp-$*vp-$3rvppf&g%#uQ[I-K5T;-L5T;-M5T;-N5T;-O5T;-_5T;-lG5s-pL70:/-h>?^7JfLva`r?(2H;@t9<qMK<;qMXtnj(>J:8%i9n-$:drEe@#&FeB/8Fe](9Fe`X'L5.+n-$U0x?0k4m-$l7m-$vUm-$wXm-$[jO;@2u@5BoCA/DnR=,EBsaYHn0)FngZ,kb:On-$;Rn-$Dn)xg*gT$h[<4D<j@P9iFkS]=McRfLm54R-`'d-0)H`,#?sI-#g@4R-NF4R-%'a>MSR5W-KD<qMYVl-$Mm-/(PgGJ()egc)--d`*G[*,2Q<OE4DEqu5MmQV63s/-<d-8A=8$+;H9P/^Pv)s:QtHixl7WC/r#?.crtl2Gs3[LfsOrw+MBVWcMG(p%O6_i]F,F.#G?0J>GBE+vGEvE>HNYTZH43B8I8E^SI53C&,]_kERo:@v7XSF&#D[alp@7ISoLN:GsX>N&#]Vs&#+$w[t_Ja&#GfIk4Gv2kk+T,kk8-&X#;Y`=-s'LS-?*LS-?<-5.c;3jL,b@$vRo)%v3BqS-?g2m.WTY'vBTQ5.e$krLcR12#w*Q7vR5s<#b9-5.A;i*Mjfg9vM*LS-8*LS-8*LS-?*LS-8*LS-HNdl.>7L+vVTQ5.S-krLoTi+vX9'sL`^%,vFmv5.[)niLu_9(M&4$)MOFI;##K#D/Ds+>#mNc)Ma#`%Me;.&M$fB(Ms:X'M798BN44#&#s#>G-X>fF/5@0:#@V@+Me-4<#`mVW#Eo;'MoG@&M)S'(M3:-)Ms`e&MP<'d:tK4&ub4a:dG,Q6poH6igw//ci)sBxkMeFp^Fhk)#>LMmLcaamL$*P<8e$WG<`g'6/7?M,#f2(pL?m3g&A7%<-vB9981Ym;%1Gw9)Bhn-$Ftn-$H$o-$-95WfO2ItLkff_8CCiJs.p=1#sL24#R@cwLqHmwL.knb8F34m^C8#/_<7)-a^/MY5'N@(sf/k-$8Hk-$:Nk-$-gT._TG=l]W]tL^,G-F%jg-ip[o9i^jtiCa1>l-$c'u9)Wi-F%Xl-F%Yo-F%LCJ%bI)M1puQf@b2MO.h:Yl-$ME$Vd@..F%Mk+]bGnD%kF(m-$lu8lfTRm-$vUm-$qf[7e$lg--U,>kF?_n-$Aen-$Bhn-$P<o-$Q?o-$RBo-$l8p-$m;p-$n>p-$oAp-$pDp-$qGp-$sMp-$tPp-$uSp-$M*M-ZiNf@k>W<l],*hLp,b4onTV@g1+jI)verY/vXxc/vAnLxLhG6##AmRfLH:$##t?hhLi&T%#Sf1$#E;#s-=^jjLmJg%#%-_'#m8q'#p'+&#Y;#s-W+vlLgJG&#erql/6%T*#8FX&#i;#s-l0SnLt+v&#m[P+#Fhc+#YPE#.W61pL@5'-#`Q?(#>*]-#A)IqL1Ix(#LN=.#%/:/#D*0o1s.e0#;:w0#G2g*#kkVuLoDC2#Gv&$.$@AvL&&.3#f%),#rfJG2m,d3#x1;,#'E]5#7Po5#rc1t/?8u6#MC17#-2it/]On8#$mp:#Xian1PZ)<#DlD<#GZN1#;/V*MCjB=#T#'2#n+B;-.C#n%lEhY#cH7VQC3pi't/qf(u5o7RMpLG)()JA+)aOoR_.B>,8Xrl/:PLlSP9258Z$ii9`9FfU%+8>>u@38@v2(GV;ZdlAE7]iKF]`(W,Vs+MMtTcMN+A`W8Il%Od.v1Te$#AX?/q:msU5]t(@1VZf`KG;<wliBG<&J_#qlxX;&juY<F<`aimd(sx3pY5&nOxbb5xi9]xg]FhIj:d'-;>YMZaY#HC?>#-B&##Ti]Qs_vr.C,oe5Bu?7SR$fu9S/Y#;Q.@b]4)=B>5;>dc2vX$B>Z+nu>pj20;.ekr?#OKS@mox,<%l0AO8afER'B]cDuO:L#IXnN#ohET#>tWT#A@2O#0uvC#T3N`#QHlY#N,Jl#p7]l#HBhf#KIwo#@0$&M;LNZQut5Jh=50GiOW'/UJur4oe#QloOj`rZvTI5/7V1m/<3p7n58VD3l(v)4*@Gfqgt6L#)RicDEI5<.ddXSIHL#_f2p2%$AJU3$mZq3$Jh>lLI$TfLH,9nLw6$##iKs'%3'2>5;inx4gcer6hdrjtK6GY>2'Mk+7^*87%`AD*#GEG)TI2#?LLFf*PY8>,0dCV?T+ar?^hHP/22w4ADiUw0<A^l8L045&(ok&#tUx%+:No9&kC#29E&<A+Aw/2'^H5-N0$)DNNf4;-,wWw0NL)F..[Xc2bRxS8t2h34-(n-$5@n-$3:n-$*um-$)rm-$RG(.$l<[i9H4).$^sL/D#,Wq)hs?PA'5dV@vOX&#lNNe$'q@M93N*Z$-`B#$YE,a+F4pV.ol3W.cD^M#;+GcM*,NZRmpaV$6rFcMYT/%##MkA#+c#s-n^ZIMU<a$#?JeA,wC#s-m-OsQr:`'#3ET/)v:^V-$C<L#5q'kbRjR3O/CVuPJLH##iO-/:wug>$*Y^V-tNNL#nKX,O+QC*P)+o(#5)B;-dlhq7uUF_/QSYY#0op>$nAFL#2r'DNWFp-#/G#s-X'FsQvR.(#+R%T&v:^V-sB<L##f8e?9vX3F/i]o@BsJa#ApeRV(.F+Nv3E$#Qt7nL@M6u'RuIa+o3MS.<`W>-%#h68=S@&,PZ.gLnAK;-=lls-SCDmL_W/%#X%Y58(Eew'Hk_%Oi2F885#)d*goCT.rCW)#[]458BRY8/3%TcMTK*78X(W&d>fZu'Oxw],4C^>-%#h68A+X#-/+(588VD)+Nj=<-_sW88m6:^#,;(M#@]j2MOvj786HtM(C.Ve$%2f+Mo(D'#@qdw']fXvI,_YgLDDOJM3klgL4O=)#_/:/#AA#s-MEpkL`pI(#E%mlL%2K;-5fG<-?xAgL3E`hLBZ$+#hI5+#K;#s-OK#lL=E@*Ns1M'#].g,Mg0v.#?X'@0*lO&#Ba5<-p`><-2Y5<-Q-/b->HPq;+l3L>c*gi'V?iP0IiUPKbG`88;?Bk=9>[w'qSi.LvD+a=4><L5C[G&#CdFm'7D5L#X5;D3P:6L#SLW>6<IG&#6b/g)qD._SYU=X(Aj'.$G4Iq;W@Mw^K.IM0Ohe'&B#JV6s'af1vYFL#u.18.060j(4_d;%u=#s-o'ChLM_d##JsY<-:lL5/lUG+#%-KkLj^i/#&)m<-0S5s-Qj&kL.i(T.oY$0#Cg>5MD#e+#TMM=-3r.>-@@;=-`ND6M_1CkLx8v%.qkBHMc'<$#I=v%.PhOoLj$<$#cu?kON'UwK=08p&[nsY6*>M,*tSX3XDEd3X:(t-$8WJ/2NL9v-2<0j(@n8/MmKkfM@-@,<P=:_Jnv@hLuP;F(CM?7$+o?>#=VQ`aV9-87Ef]&#@FvNFOQ^f1,G-F%PPuu#UTj-$/3mx4)xT#$In&@'FY'58pFnw'VoL7'C_RS%=qux+2]./(H[VV$db@k=7Ek-$qA<A+3w.T&a,Ke$fk35&sFbA#.+XMC=,qn'?Xno%%x-20ggGG)KG->>gk@T.f?O&#a)B;-s?19M..AqL-r%qL#;)pLLMN,#MSGs-lS6n93??X1V9$5AE3hJDXkMe$uRm-$TVo.COBwM1tlPKN[XZ##8n6:&+e[58nQGf$)0Kj9<jWX(WDT58?G9j(ITL=%wv0-O.e&kMC[Er$-Mr>n>eZM9<q2W%rSXL#/]FcMfGG&#uO'^#%9-W7MC8_-0LYGMEbdi94Ni)+CY@S@wGYt-p&N+NENwq74b%T&(S^V-0md8^h5hh$6[3dXq(/C'RP14+0l'DNEZj395BkM(lq.=-]=hl%3iFcMnx:'#xk#Z$%HA[$86_c)7#o+D=AOcD>IKi#Gtd--t?3-vI5YY#lkOn*%Zw%+[`6#6*u'^#&]X&#eD,F%UQEN1]nt1BqMq['O`%pAN[aSALHi,%[_u8*Iv'N(q7i_&WXfi'WmKKsdw<(&$ZOdFTfCE%#FDdMqC?##EEx;-+]Be,(%e^OCto<8^]L&5j/4L#`Lh-MJ;>d$AlW>-_cC=-;k.u-mddIMGdDN(Nl%E+*r'58Yqh,Ff1X_$1q'*89;uk4<xv/:wpN-Xmj]h:mxCp/cp3L#o^(,);9HcMhJ5&#]rt.#h:iT.-Lb&#uXL&OxU.(#tlP<-;lL5/:XI%#:3*jLe9)/#aPGLM3D^;->Hp;-<ZlS.;`X.#rS#<-`-:w-q-BSMCD4jL#XUsLE']iLLIMiL<vRiL#8K;-6<v%.,PVmL6wRiLxK2&.FIxnL]D4jLN=UkLw1K;-mIA/.ckGTMn/,GMAMg=;jXvf;,7>v-#_#^,f$#^,FFMg2(UAG2M2UML:%Xh#Cxpu,FP>;$6XNs-)mBHMkcl&#h(]n&s,p(<6*8p&@N]p&(hio.A,KvH*t.5/k4C;IKV>8JB5#sIVuXG<1am-$bb]w'J*U]4@.pV.W1voJCZ8F@`Z.L,L$JP/Na;eHxS1A=T2lD40*#L>_W.L,AUj%=xnp>$cS8_8d+u9DrY<qMBmb;-2hSN-UwRu-YqPTMBqSN-YdBK-*JwA-`lRQ-JV)..ZK#lLm-@tLMGPGM'JJ(#G,3)#d7p*#3&*)#+9q'#k[imL$osmL&e$AOH]d.Ues?-a]mgWRh1x(#u(B;-&:/>-CSR6/2),##2A3jLJwN^MP>[tLbR-##vl0'#Klap#OSGs-@qAKM_2oiL.#PZM&c,WM/F(q#N),##CvcW-sG6L,kE0:2FU]_&[pbe$FlBL,$u`e$QDRX(iUl'88KHX(CWs/M>WPrH:T0j(9=P]ulO,W-Lvl?KEgAKM[-w1M5n7S@d6U;.9Doxu6Jj:/mW?(#5r(MMoPbJMivHTM>$Ua#dX`=-h<Ab-,D_e$g;ce$tcce$TY_e$>jTe$5/N`#R4G>#N</=#e.eQMH0Ua#Y4G>#s@DX-G_W_&lnW_&jv1Po_dI21G$;^u);>>#Tv9Vml?qM:SaSe$'<Urm^>Z9i*Ps34I'dTM#h`XM%R:q#Z+,##TT[Q/xfn1gL7QP/(cO&#cf%Y-5%N_&,wWZM>tFZM?eXRM:F+RMF9CSM^<EMM?24JMO&xIM$RbJMIJXJM.hr+vs4G>#bN&(MkPl]#JCg;-O_`=-YQx>-PL@6/b&L'#[OkGM2L9_M:wCHMD^IIMv@Jo#=4G>#NlG<-%b,%.=t0hL=0M-M5p:SIfm.m06=(^#W3&9JlSF>#udTX(8puf1R7,2_WZE/2DSO50q6uP9vv%F.;%q'8SJRX(*TU_&5kH(s*4[JV2HOe$,POR*_MQk=h.lWM_ToYM9+5cM*7,,M1s-&4.5F/;=@7AcjO9giI@?>#`vPX(O;s-6w9X_&s*O_&GqPTMbEY]#ifRQ-D()t-G&9kL;Hr-MxDWY5nmmS/RQaJ2?Rnxc$]'^#1'4m'`dmA#/mG<-QGg;-pGg;-<Gg;-UGg;-sN,W-NTfe$8a5G`K.65/8[Re$+pAL,oR`e$2[of17'sS&8u.d*X3c`OaaBMqt(J`tOJ<v-Ou%a+(+?v$&o^>$5LTJD7Vn+s?,dG*Pr:5KoOdfV`PT5'McD)+@Yw],VJa&#R?3L#mtH`E<^e--e>uu#Ner*>LQ8$JR@e@t)>MMFLuKS.v#0/1>[f`3Zid>6A`5L#6jBG;W_mL#gs%/C[3/;H.2`lJ0EOe$u3ESR<R`#5f4vN#w>]P#AJCR#bU*T#+XK:#lcjjE9jvoB_?/I#f*B0Fc*1CCb-AI#*-2iFn/*&D][7e#0XGh1n4YvEvvxI#94JuBGVS_MZ,6`MaPm`MguMaMmC/bMr_JFMK=6##(+?v$.b7p&vX,^G):=rLl+o`*-ggKF^5d7MH-pxGd?Se#=cfYB680$H)?uf#ciAR*-(+D#@.>>#)+0585sdA#B)Y6#bwX;9x#ej81SE#$Qu6oL:/R2;7fE#$sC_O;'l<P=8>E#$$@9L,'N4J=C(As$QiIfLgOPGM]2>F%tM)x'6nD<#242X-3B1x'[,UF%]0XF%QdTF%O^TF%MWTF%JKKF%rjtkMh,kxF?3MDF=wlcE;e5,ErF$jUiDs9DB`L>?8FC#$BeL#$j5m<-2b>W-@u;:2E?TF%X7BkXh6JYG+[8(&M7hxOjGjVRTg(F@??WJM0F#l$J`V_&6T^e$E,_e$?p^e$0B^e$1E^e$''^e$/?^e$,6^e$+3^e$*0^e$-9^e$.<^e$5Q^e$B#_e$@s^e$3K^e$2H^e$4N^e$?jKe$(Bu'&K5YY#Yosx+7wm$$N)%)*:i###$2G>#cD>F%`5/RNJDuu#UrbZ$0u68%>sq6r`n)v#vas)#uX`k#$M,W->rLe$I,b]O<C.&cC#Pe$os[cDZTh]Pr2)A.9IKPAvw;,W`)Ke$iTjRRGVuoJSnS,NK$USeKcc8J.oq;$,9_^YnVGMTTwRJ1:xd'&G?P'J]GKl]Yia]+4j2W[12*5A`tv-$c:V3(Ahd`E(-+#Gpj190^3mfCs#oca]FU?^KGuu#BcxA#CR&@'EG)d*lAwuQV'Q8/IPD)+L(x],Gd.&GKc%a+:08p&=_tiC4oF&#6*8p&_T2&GJ$8R*hwsWU>5;5&e4ViT`77JUEOa^&H&>uuv-Qq7;^vV%Ao7qRqH$BXrN-BXsT6BXtZ?BXuaHBXvgQBXaPY<Qt[mY#CF.%#^i?6/4Yu##P>ja*(ilq.eb*Sn*O*+jGA7X1i-=X1$_$a*bkOb*[Teq.pk1/:>#i,F1)i`3:WdlAgt,58,i'B#j62l*CIm20_0NYGcH/;Hmh4_A3NWY,.+gG)GMHFjGwY;)M:?>#H0/20?EUG)*sh`3kI%#>Uw7;H@NJSRAE6GMFaASRfdB9RT^$F#s*;G#5tRH#->fF/fY-K#%nRfLJ1CkLLU)v#NlG<-.Hg;-Gm+G-bJ;#4wPf5#)D(v#dVh/#%/5##2#]H#?)29.07NP&+.CB#Vh?>#eTg34.u[f1W3WV$oIDA=0#2)3ulwE7*4$$$Eb.)<s[Ge-VqHo[HxND*'SV_&p2<A+(mU`3)rtA#HF5F765[w'tIW-?J@Tq)JRgGE'Ul?B*._#$QWf?N+n-7$`$ms-[$&VMO=6##YL-RW0aC_&Vl>sI,Mj+MM#>[MG*TJ1(93_#SRd]F9+lfCt^Ne$wkD>G5XgJDvdNe$%.&vG7kG,ExjNe$)F]VH9')dE$qNe$-_=8I=ErDFLS#v#4CkMC3T0F%^wuE7QW0F%a:1,D5Z0F%cFLGD6^0F%eRhcD7a0F%g_-)E8d0F%ikHDE9g0F%kwd`E:j0F%m-*&F;m0F%m9EAF2<.B#%]bo7'GE/2q7[5B@Pm&-cn'2B@&aiBD>AJC/1A@ll(_#$(;4gLHLoqLX8o,$N-)0$-A^01IgkI#5Bq+$2L,/$$A^01KmtI#7H$,$4R5/$%A^01Ms'J#9N-,$6X>/$&A^01Q5h+$p:<-$VEM0$.A^01S;q+$r@E-$XKV0$/A^01UA$,$tFN-$ZQ`0$0A^01WG-,$vLW-$]Wi0$1A^01YM6,$xRa-$_^r0$4S>h1[S?,$$Yj-$ad%1$Ot[fL%O6##.####L;#s-xb<rL7?/w#JseU.GoA*#u:#s-_x=wLO@FD#mN,W-A%Me$aiq1TPK<j1F2Pe$B26;H[YhA5xmNe$q3)58(g/m0PphS8Ua&g245Bm0c7Ye-]qZe-v.FcM8VGs-V4+gLUdRIMJi(T.,`CZ#t,@A-u3kn/Oj9'#1vv(#SJB<MUM>gL/5$##F-pG2ld08Ii#cJ#7.LcDg3oI#`D:@-qhJ;/&8P>#;#juL35P$M:.gfLhbQ>#7####$),##EKXRIRbC*#"
--#endregion