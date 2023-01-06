script_name('GAdmin')
script_version(1.0)

local mem = require('memory')
local encoding = require 'encoding'
local imgui = require 'mimgui'
local samp = require 'lib.samp.events'
local ffi = require 'ffi'
local new, str, sizeof = imgui.new, ffi.string, ffi.sizeof
local hotkey = require('mimhotkey')
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
            gadm = {77}
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
local players_platform = {}
-- для информации в спеке --
in_sp = false
checking_stats = false
last_checking_stats = 0
last_speed_check = 0
spectate_id = -1
info_about = -1
spec_textdraw = -1
player_data = {}
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


-- ИМГУИ ПЕРЕМЕННЫЕ
local show_main_menu = new.bool()
local show_online_menu = new.bool(true)
local show_info_menu = new.bool()
local car_spec = new.bool(cfg.car_spec)
local gg_msg = new.char[256](cfg.gg_msg)
local game_pass = new.char[256](cfg.game_pass)
local adm_pass = new.char[256](cfg.adm_pass)

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

        imgui.End()
    end
)

local onlineFrame = imgui.OnFrame(
    function() return show_online_menu[0] end,
    function(player)
        player.HideCursor = true
        local full_online = string.format("Общий онлайн: %02d:%02d:%02d", cfg.online.total / 3600,cfg.online.total / 60 % 60, cfg.online.total % 60)
        local temp_online = string.format("Онлайн за сессию: %02d:%02d:%02d", session_online / 3600, session_online / 60 % 60, session_online % 60)
        size = {imgui.GetStyle().WindowPadding.x*2 + imgui.CalcTextSize(temp_online).x, 
        imgui.GetStyle().ItemSpacing.y + imgui.GetStyle().WindowPadding.y*2 + imgui.CalcTextSize(temp_online).y + imgui.CalcTextSize(full_online).y}

        imgui.SetNextWindowSize(imgui.ImVec2(size[1], size[2]))
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX - size[1]/2, sizeY - size[2]/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("GAdmin_online", show_main_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)

        imgui.Text(full_online)
        imgui.Text(temp_online)

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


        player.HideCursor = true
        imgui.SetNextWindowSize(imgui.ImVec2(100 * column_num, (column_num == 4 and 155 or 287)))
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("GAdmin_info", show_info_menu, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)

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

    -- сокращенные команды
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
    -- TODO: взять другую либу (либо самому написать :D), ибо это говно
    hotkey.RegisterCallback("gadm", cfg.hotkeys.gadm, gadm_cmd)


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
    imgui.GetStyle().FramePadding = imgui.ImVec2(3.5, 3.5)
    imgui.GetStyle().FrameRounding = 8
    imgui.GetStyle().ChildRounding = 8
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().WindowRounding = 4
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5.0, 4.0)
    imgui.GetStyle().ScrollbarSize = 13.0
    imgui.GetStyle().ScrollbarRounding = 8
    imgui.GetStyle().GrabMinSize = 8.0
    imgui.GetStyle().GrabRounding = 8.0
    imgui.GetStyle().WindowPadding = imgui.ImVec2(4.0, 4.0)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.0, 0.5)

    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.14, 0.12, 0.16, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.30, 0.20, 0.39, 0.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.05, 0.05, 0.10, 0.90)
    imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.89, 0.85, 0.92, 0.30)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.30, 0.20, 0.39, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.68)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.41, 0.19, 0.63, 0.45)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.41, 0.19, 0.63, 0.35)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.30, 0.20, 0.39, 0.57)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.30, 0.20, 0.39, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.41, 0.19, 0.63, 0.31)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.56, 0.61, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.41, 0.19, 0.63, 0.24)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.41, 0.19, 0.63, 0.44)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.86)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.64, 0.33, 0.94, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.41, 0.19, 0.63, 0.76)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.86)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.41, 0.19, 0.63, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 0.78)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.89, 0.85, 0.92, 0.63)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.89, 0.85, 0.92, 0.63)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(0.41, 0.19, 0.63, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.41, 0.19, 0.63, 0.43)
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