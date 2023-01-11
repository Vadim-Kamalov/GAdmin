script_name('GAdmin')
script_version(1.0)

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
            spectateCursor = {66}
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
                alpha = 0
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
info_show = {
    {"hp", "Здоровье"},
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
    {"game", "Игра"}
}
column_num = 2
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
local playersNearby = new.bool()
local car_spec = new.bool(cfg.car_spec)
local gg_msg = new.char[256](cfg.gg_msg)
local game_pass = new.char[256](cfg.game_pass)
local adm_pass = new.char[256](cfg.adm_pass)

-- для хоткеев
local gadmKeys = {v = cfg.hotkeys.gadm}
local showSpectateCursor = {v = cfg.hotkeys.spectateCursor}
local acceptFormKeys = {v = cfg.hotkeys.acceptForm}

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
            if imgui.Button("<<", imgui.ImVec2(50, 70)) then sampSendMenuSelectRow(0) end
            imgui.SameLine()

            imgui.BeginGroup()
                for index = 1, #buttonsPlaceholder[1] do
                    if imgui.Button(buttonsPlaceholder[1][index][1], imgui.ImVec2(100, 35)) then
                        buttonsPlaceholder[1][index][2]()
                    end

                    if index ~= 7 then imgui.SameLine() end
                end
                imgui.BeginGroup() -- New line content
                    for index = 1, #buttonsPlaceholder[2] do
                        if imgui.Button(buttonsPlaceholder[2][index][1], imgui.ImVec2(100, 35)) then
                        buttonsPlaceholder[2][index][2]()
                        end
                    
                        if index ~= 7 then imgui.SameLine() end
                    end
                imgui.EndGroup()
            imgui.EndGroup()

            imgui.SameLine()

            if imgui.Button(">>", imgui.ImVec2(50, 70)) then sampSendMenuSelectRow(2) end
        imgui.End()

        imgui.PopStyleVar(5)
    end
)

local playersNearbyFrame = imgui.OnFrame(
    function() return playersNearby[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.playersNearby.x, cfg.windowsPosition.playersNearby.y))
        imgui.SetNextWindowSize(imgui.ImVec2(200, 350))

        imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0.07, 0.07, 0.07, 0))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.07, 0.07, 0.07, 0.30))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.07, 0.07, 0.07, 0))

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
                    nickname = sampGetPlayerNickname(id)

                    if id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) and id ~= tonumber(info_about) then
                        imgui.SetCursorPosX(100 - imgui.CalcTextSize(("%s[%s}"):format(nickname, id)).x / 2)
                        imgui.Text(("%s[%s]"):format(nickname, id))
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
                            if imgui.Button("STATS", imgui.ImVec2(200, 30)) then sampSendChat("/stats "..popupId); imgui.CloseCurrentPopup() end
                            if imgui.Button("PAME", imgui.ImVec2(200, 30)) then sampSendChat("/pame "..popupId); imgui.CloseCurrentPopup() end
                            if imgui.Button("SPEC", imgui.ImVec2(200, 30)) then sampSendChat("/sp "..popupId); imgui.CloseCurrentPopup() end
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

local adminForm = imgui.OnFrame(
    function() return admin_form_menu[0] end,
    function(self)
        self.HideCursor = _showSpectateCursor
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, 70))

        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.07, 0.07, 0.07, 0.50))
        imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 0)
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowRounding, 0)
        imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)

        imgui.Begin("admin_form_menu", admin_form_menu, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
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

        imgui.PopStyleVar(2)
        imgui.PopStyleColor()
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

        if rkeys.HotKey("Главное меню", gadmKeys) then
            cfg.hotkeys.gadm = gadmKeys.v
            rkeys.changeHotKey(openMainMenu, gadmKeys.v)
            save_config()
        end
        if rkeys.HotKey("Принятие формы", acceptFormKeys) then
            cfg.hotkeys.acceptForm = acceptFormKeys.v
            rkeys.changeHotKey(acceptForm, acceptFormKeys.v)
            save_config()
        end

        if rkeys.HotKey("Открытие курсора в /sp", showSpectateCursor) then
            cfg.hotkeys.spectateCursor = acceptFormKeys.v
            rkeys.changeHotKey(showSpectateCursor, showSpectateCursor.v)
            save_config()
        end

        if imgui.Button("Настроить позицию окон") then
            imgui.OpenPopup("windowsPosition")
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
        imgui.SetNextWindowSize(imgui.ImVec2(100 * column_num, (column_num == 4 and 155 or 287)))
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.windowsPosition.playerStatsFrame.x, cfg.windowsPosition.playerStatsFrame.y))
        imgui.Begin("GAdmin_info", show_info_menu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove)

        imgui.CenterText(tostring(player_data["nick"]) .. "[" .. spectate_id .. "]")
        imgui.Columns(column_num, "##player_info", true)
        for i = 1, 4 do imgui.NextColumn() end
        imgui.Separator()
        if column_num == 4 then
            imgui.SetColumnWidth(0, 70)
            imgui.SetColumnWidth(1, 100)
            imgui.SetColumnWidth(2, 85)
            imgui.SetColumnWidth(3, 145)
        else
            imgui.SetColumnWidth(0, 100)
            imgui.SetColumnWidth(1, 100)
        end
        for k, v in pairs(info_show) do
            imgui.Text(v[2])
            imgui.NextColumn()
            imgui.Text(tostring(player_data[v[1]]))
            imgui.NextColumn()
            if (k % 2 == 0 and column_num == 4 or (column_num == 2)) and k ~= #info_show then
                imgui.Separator()
            end
        end

        imgui.Columns(1)
        imgui.Separator()

        imgui.End()
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
    sampRegisterChatCommand("test", function()
        column_num = column_num % 4 + 2
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
                    local vehname = (getGxtText(getNameOfVehicleModel(carmodel))) -- TODO: там есть названия тачек которые становятся мусором
                    local sx, sy = convert3DCoordsToScreen(x, y, z)
                    local text = "ID: {8dff85}" .. id .. " {FFFFFF}HP: {8dff85}" .. hp
                    local text2 = vehname .. " [" .. engine_status .. "{FFFFFF} / " .. door_status .. "{FFFFFF}]"
                    renderFontDrawTextAlign(font, text, sx, sy, 0xFFFFFFFF, 2)
                    renderFontDrawTextAlign(font, text2, sx, sy + 15, 0xFFFFFFFF, 2)
                end
            end
        end

        show_action_menu[0], playersNearby[0] = show_info_menu[0], show_action_menu[0]

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
    "ban",
    "jail",
    "mute",
    "warn",
    "iban",
    "ck",
    "pk"
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

    for k, v in ipairs(formCommands) do
        if text:find("%[A%] .*%[%d+%]: /"..v..".*") and color == 866792362 then
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
        if new_id ~= info_about and os.clock() - last_checking_stats > 1 and not sampIsDialogActive() then
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
