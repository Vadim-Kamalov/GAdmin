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

@import "Requests"  => requests
@import "Common"    => common

@define MAPVK_VSC_TO_VK_EX 3

ffi.cdef("
    typedef unsigned short WORD;
    typedef int BOOL;
    typedef struct {
        WORD wYear;
        WORD wMonth;
        WORD wDayOfWeek;
        WORD wDay;
        WORD wHour;
        WORD wMinute;
        WORD wSecond;
        WORD wMilliseconds;
    } SYSTEMTIME, *PSYSTEMTIME;

    typedef struct {
        int Data[4];
    } GUID;

    typedef void            *PVOID;
    typedef PVOID           HANDLE;
    typedef HANDLE          HKL;
    typedef HANDLE          HWND;
    typedef unsigned long   DWORD;
    typedef unsigned int    UINT;
    typedef const char      *LPCSTR;
    typedef long            LONG;
    typedef intptr_t        HICON;
    typedef intptr_t        HINSTANCE;

    typedef struct {
        DWORD   cbSize;
        HWND    hWnd;
        UINT    uID;
        UINT    uFlags;
        UINT    uCallbackMessage;
        HICON   hIcon;
        char    szTip[128];
        DWORD   dwState;
        DWORD   dwStateMask;
        char    szInfo[256];
        union {
            UINT uTimeout;
            UINT uVersion;
        };
        char    szInfoTitle[64];
        DWORD   dwInfoFlags;
        GUID    guidItem;
        HICON   hBalloonIcon;
    } NOTIFYICONDATAA;

    BOOL Shell_NotifyIconA(int dwMessage, NOTIFYICONDATAA * lpData);
    HICON LoadIconA(HINSTANCE hInstance, intptr_t IconCode);
    BOOL DestroyIcon(HICON hIcon);

    HKL GetKeyboardLayout(DWORD idThread);
    UINT MapVirtualKeyExA(UINT uCode, UINT uMapType, HKL dwhkl);
    void GetLocalTime(PSYSTEMTIME lpSystemTime);
    int MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, UINT uType);
    HWND GetDesktopWindow();

    int __stdcall GetModuleHandleA(const char* lpModuleName);
")

local assets = {}

assets.randomICNicknames = {
    "Marcus_Tullius_Cicero",
    "Francois_Marie_Arouet",
    "Thales_of_Miletus",
    "Friedrich_Nietzsche",
    "Leonardo_da_Vinci",
    "Immanuel_Kant",
    "John_Locke",
    "Augustine_of_Hippo",
    "Arthur_Schopenhauer",
    "Gottfried_Wilhelm_von_Leibniz",
    "Diogenes_of_Sinope"
}

assets.randomStrings = {
    "Недостаточно овладеть премудростью, нужно также уметь пользоваться ею.",
    "Тем, кто хочет учиться, часто вредит авторитет тех, кто учит.",
    "Подумай, как трудно изменить себя самого, и ты поймешь, сколь ничтожны твои возможности изменить других.",
    "Невежество — ночь ума, ночь безлунная и беззвездная.",
    "Есть только одно благо — знание, и только одно зло — невежество.",
    "Блаженство тела состоит в здоровье, блаженство ума — в знании.",
    "Познавший самого себя — собственный палач.",
    "Речь истины проста.",
    "Единственным критерием истины является опыт.",
    "Весёлое выражение лица постепенно отражается и на внутреннем мире.",
    "Образование создаёт разницу между людьми.",
    "Что легко? — Давать советы другим.",
    "Кто ненавидит мир? Те, кто растерзал истину.",
    "Многие философы так же тягостны, как ночные гуляки, нарушающие сон мирных жителей",
    "Всякое учение истинно в том, что оно утверждает, и ложно в том, что оно отрицает или исключает.",
    "Философия и медицина сделали человека самым разумным из животных, гадание и астрология — самым безумным, суеверие и деспотизм — самым несчастным.",
    "С большой властью приходит большая ответственность."
}

assets.randomOOCNicknames = {
    "covboy",
    "defaultzone",
    "montreal",
    "ivanrampage",
    "Toshik",
    "Furofushi",
    "dontkillme",
    "GoblinJr",
    "krutenka",
    "refraction",
    "GMengland"
}

assets.voidQuotes = {
    "Для того, чтобы началось что-то новое, что-то должно закончиться.",
    "Добравшись до конца, начинаешь думать о начале.",
    "Похоже, кто-то видит звезды, а кто-то пустоту между ними.",
    "Пустота сверху, пустота снизу и еще большая пустота между ними, а в ней я.",
    "Пустота никогда не может заменить цели...",
    "Мне стала домом эта пустота, объятая воспоминаньями о былых мечтах.",
    "Если не можешь улететь в космос, сделай так, чтобы он прилетел к тебе.",
    "Весь мир состоит из атомов и пустоты.",
    "Сплошные солнечные дни порождают пустыню.",
    "Если построить что-то на пустоте, рано или поздно оно обрушится.",
    "Вокруг меня только черная пустота, и нет мне утешения.",
    "Тот, кто не ощущал, не пережил сам пустоту и заброшенность, не сможет передать её.",
    "Нет порока страшнее, чем душевная пустота.",
    "Нет большей пустоты, чем в ожидание.",
    "Любая речь соткана из тишины. Любой объект наполнен пустотой.",
    "Пустяковые вещи начинают отбрасывать большие тени.",
    "Ты не за мной бежишь. Ты от пустоты бежишь."
}

static enum /** @enum WINDOWS_NOTIFICATION_ICON */ {
    WINDOWS_NOTIFICATION_ICON_NONE = 0,
    WINDOWS_NOTIFICATION_ICON_APPLICATION = 32512,
    WINDOWS_NOTIFICATION_ICON_ERROR,
    WINDOWS_NOTIFICATION_ICON_QUESTION,
    WINDOWS_NOTIFICATION_ICON_WARNING,
    WINDOWS_NOTIFICATION_ICON_INFORMATION,
    WINDOWS_NOTIFICATION_ICON_SECURITY = 32518
}

/**
 * Download a list of files. The `files` argument is represented by a table, device:
 *
 * ```clue
 * files = { { url = String, destination = String }... }
 * ```
 * 
 * Note that each file is downloaded every second to prevent undefined behavior.
 * If no files are downloaded after 120 seconds, the function will return false.
 * After files are successfully downloaded, the `afterDownloadCallback`
 * argument is called (this is a function that accepts the list of `files` that was passed to the main function).
 *
 * @param files table
 * @param afterDownloadCallback
 * @return void
 */
method assets::downloadFileList(files, afterDownloadCallback, iteration = 1) {
    if iteration > #files {
        return afterDownloadCallback(files)
    } else {
        lua_thread.create(fn {
            requests::asyncHttpRequest("GET", files[iteration].url, nil, fn (response) {
                if response.status_code == 200 {
@ifdef __GADMIN_DEBUG__
{
                    $debugSuccessful!("assets::downloadFileList", "downloaded " .. files[iteration].url .. " in " .. files[iteration].destination)
}

                    common::writeInFile(files[iteration].destination, response.text)
                    return self::downloadFileList(files, afterDownloadCallback, iteration + 1)
                } else {
                    $debugWarning!("assets::downloadFileList", "received response.status = " .. response.status .. " on ...")
                    $debugWarning!("assets::downloadFileList", "iteration = " .. iteration .. ", url = " .. files[iteration].url)
                    common::sendScriptMessage("Что-то пошло не так при загрузке файла(-ов). Подробнее в консоле.")
                }
            }, fn (error) {
                $debugWarning!("assets::downloadFileList", "failed to download file. Iteration = " .. iteration .. ", url = " .. files[iteration].url)
                $debugWarning!("assets::downloadFileList", "error = " .. error)
                common::sendScriptMessage("Что-то пошло не так при загрузке файла(-ов). Подробнее в консоле.")
            })
        })
    }
}

/**
 * Convert map scan code to virtual key.
 * 
 * @param scanCode number
 * @return number
 */
method assets::mapScanCodeToVKey(scanCode) {
    local layout    = ffi.C.GetKeyboardLayout(0)
    local vkey      = ffi.C.MapVirtualKeyExA(scanCode, $MAPVK_VSC_TO_VK_EX, layout)
    return vkey
}

/**
 * Merge two tables into one.
 *
 * @param first table
 * @param second table
 * @return table
 */
method assets::mergeTables(first, second) {
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
 * Explode timestamp to date-table.
 * 
 * @param timestamp number
 * @return table
 */
method assets::explodeDate(timestamp) {
    return {
        sec  = timestamp % 60,
        min  = math.floor(timestamp / 60) % 60,
        hour = math.floor(timestamp / 3600)
    }
}

/**
 * Convert week table-representation to string.
 * @param week table
 * @return string
 */
method assets::weekToString(week) {
    local result, days = "", {
        "Понедельник",
        "Вторник",
        "Среда",
        "Четверг",
        "Пятница",
        "Суббота"
    }

    for day = 2, #week {
        local time = self::explodeDate(week[day] || 0)
        result ..= string.format("%s: %02d:%02d:%02d\n", days[day - 1], time.hour, time.min, time.sec)
    }

    local time = self::explodeDate(week[1] || 0)
    result ..= string.format("Воскресенье: %02d:%02d:%02d", time.hour, time.min, time.sec)

    return result
}

/**
 * Convert Unicode character to UTF8 string.
 *
 * @param code number   Unicode character.
 * @return string       UTF8 string.
 */
method assets::convertUnicode2Utf8(code) {
    local t, h = {}, 128
    while code >= h {
        table.insert(t, 128 + code % 64)
        code = math.floor(code / 64)
        h = (h > 32) ? 32 : h / 2
    }
    table.insert(t, 256 - 2 * h + code)
    return string.reverse(string.char(table.unpack(t)))
}

/**
 * Get system time.
 * @return table
 */
method assets::getLocalTime() {
    local time = ffi.new("SYSTEMTIME")
    ffi.C.GetLocalTime(time)
    return time
}

/**
 * Expode ARGB number to variables.
 * 
 * @param argb number
 * @return number, number, number, number
 */
method assets::explodeARGB(argb) {
    local a = (argb >> 24) & 255
    local r = (argb >> 16) & 255
    local g = (argb >> 8) & 255
    local b = argb & 255
    return a, r, g, b
}

/**
 * Convert U32 to ARGB.
 * @param u32 number
 * @return number
 */
method assets::convertU32ToARGB(abgr) {
    local r     = abgr & 255
    local g     = (abgr >> 8) & 255
    local b     = (abgr >> 16) & 255
    local a     = (abgr >> 24) & 255
    return b | (g << 8) | (r << 16) | (a << 24)
}

/**
 * Convert ARGB to U32.
 * @param argb number
 * @return number
 */
method assets::convertARGBToU32(argb) {
    local a = (argb >> 24) & 255
    local r = (argb >> 16) & 255
    local g = (argb >> 8) & 255
    local b = argb & 255
    return r | (g << 8) | (b << 16) | (a << 24)
}

/**
 * Get elements in the XML group, as an array.
 *
 * @param where table
 * @param what string
 * @return table[]
 */
method assets::getXMLElements(where, what) {
    if where {
        if where[what] && #where[what] > 1 {
            local elements = {}
            for _, element in where[what] { table.insert(elements, element) }
            return elements
        } else {
            return { where[what] }
        }
    } else {
        return {}
    }
}

/**
 * Swap language layout from russian to english.
 * 
 * @param text string
 * @return string
 */
method assets::swapLayout(text) {
    text = u8(text)

    for k, v of ({
        ["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t",
        ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p",
        ["х"] = "[", ["ъ"] = "]", ["ф"] = "a", ["ы"] = "s", ["в"] = "d",
        ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k",
        ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x",
        ["с"] = "c", ["м"] = "v", ["и"] = "b", ["т"] = "n", ["ь"] = "m",
        ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "Q", ["У"] = "W",
        ["К"] = "E", ["Е"] = "R", ["Н"] = "T", ["Г"] = "Y", ["Ш"] = "U",
        ["Щ"] = "I", ["З"] = "O", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A",
        ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H",
        ["О"] = "J", ["Л"] = "K", ["Д"] = "L", ["Ж"] = ":", ["Э"] = "\"",
        ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B",
        ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
    }) {
        text = string.gsub(text, k, v)
    }

    return text
}

/**
 * Copy table with handling next cases:
 *  tables as keys,
 *  preserving metatables, and
 *  recursive tables.
 * @author https://stackoverflow.com/a/26367080
 *
 * @param object table
 * @param seen table|nil
 * @return table
 */
method assets::copyTable(object, seen) {
    if type(object) != "table" { return object }
    if seen?[object] { return seen[object] }

    local s         = seen || {}
    local result    = setmetatable({}, getmetatable(object))
    s[object]       = result

    for key, value of object { result[self::copyTable(key, value)] = self::copyTable(value, s) }

    return result
}

/**
 * Collect all information about this script. User password`s will replaced by `"***"` in `config.root`.
 * @return string JSON
 */
assets.collectScriptInformation = fn {
    local config                                = assets::copyTable(import("Config").root)
    config.additions.autoLogin.accountPassword  = "***"
    config.additions.autoLogin.aloginPassword   = "***"

    local user              = __user__
    local greport           = __greport__
    local spectator         = __spectator__
    local imguiAssets       = __imguiAssets__
    local movableWindows    = __movableWindows__
    local admins            = __admins__

    local config        = neatJSON($, { lua = true })
    local windowsList   = (fn {
        local indent    = string.rep(" ", 8)
        local list      = ""

        for index, window in registeredWindows {
            list ..= string.format(
                "%s[%d] %s (%s)%s",
                (list == "") ? "" : indent,
                index,
                window.id,
                window.description,
                (index == #registeredWindows) ? "" : "\n"
            )
        }

        return list
    })()

    return string.format(`
Date:   %s
Clock:  %d

System information:
    OS:             %s
    Architecture:   %s
    Resolution:     %d x %d
    Wine prefix:    %s

Script information:
    Version:        %s
    Memory:         %d
    Package.cpath:  %s
    Package.path:   %s

User information:
    OOC nickname:   %s
    IC nickname:    %s
    ID:             %d
    Alogin status:  %s
    Ping:           %d
    Admin LVL:      %d

Spectator information:
    Status:         %s
    ID:             %d
    Nickname:       %s
    TextDraw ID:    %s

GReport information:
    Window state: %s
    Dialog:
        ID:     %d
        State:  %s
    Player:
        Active:     %s
        Nickname:   %s
        ID:         %d
        Context:    %s

ImGui information:
    Cursor Status:  %s
    Moving windows: %s
    Registered windows:
        %s

Logs:
    MoonLoader:
%s
    SAMPFUNCS:
%s
    CLEO:
%s

Configuration: %s
    `, os.date(), os.clock(),

        //! System information
        jit.os, jit.arch, select(1, getScreenResolution()), select(2, getScreenResolution()), os.getenv("WINEPREFIX"),

        //! Script information
        $GADMIN_VERSION, collectgarbage("count"), package.cpath, package.path,

        //! User information
        user::getOOCNickname(), user::getNickname(), user::getId(), user::getAloginStatus(),
        user::getPing(), user::getAdminLvl(),

        //! Spectator information
        spectator.status, spectator.id, spectator.nickname, spectator.textDrawId,

        //! GReport information
        greport.window.state, greport.dialog.id, greport.dialog.state,
        greport.player.active, greport.player.nickname, greport.player.id,
        greport.player.context,

        //! ImGui information
        imguiAssets::getCursorStatus(), movableWindows::isChangingWindowsPositions(), windowsList,

        //! Logs
        common::readFileContent(getWorkingDirectory() .. "\\moonloader.log"),
        common::readFileContent(getGameDirectory() .. "\\SAMPFUNCS\\SAMPFUNCS.log"),
        common::readFileContent(getGameDirectory() .. "\\cleo.log"),

        //! Configuration
        config
    )
}

/**
 * Send a notification by the WinAPI and `shell32` methods.
 *
 * @param icon WINDOWS_NOTIFICATION_ICON
 * @param title string
 * @param text string
 * @return void
 */
method assets::sendWindowsNotification(icon, title, text) {
    local instance = (icon) ? 0 : ffi.C.GetModuleHandleA(ffi.NULL)
    local iconType = (icon) ? 100 : 0

    local trayIconHandle    = ffi.C.LoadIconA(instance, (iconType == 0) ? 100 : iconType)
    local balloonIconHandle = ffi.C.LoadIconA(instance, iconType)
    local iconData          = ffi.new("NOTIFYICONDATAA")

    iconData.cbSize       = ffi.sizeof(iconData)
    iconData.hWnd         = ffi.cast("HWND", readMemory(0x00C8CF88, 4, false))
    iconData.uFlags       = 3
    iconData.hIcon        = trayIconHandle
    iconData.uVersion     = 4
    iconData.hBalloonIcon = balloonIconHandle

    shell32.Shell_NotifyIconA(0, iconData)
    shell32.Shell_NotifyIconA(4, iconData)

    iconData.uFlags      = 19
    iconData.dwInfoFlags = (iconType == 0) ? 0 : 36
    
    imgui.StrCopy(iconData.szInfoTitle, u8::decode(title))
    imgui.StrCopy(iconData.szInfo, u8::decode(text))
    shell32.Shell_NotifyIconA(1, iconData)
}

/**
 * Change wallhack state using default SA:MP render.
 * 
 * @param state boolean
 * @return void
 */
method assets::changeWallhackState(state) {
    local pointer = sampGetServerSettingsPtr()
	memory.setfloat(pointer + 39, (state) ? 0x7D0 : $SERVER_NAME_TAGS_DISTANCE)
	memory.setint8(pointer + 47, (state) ? 0 : 1)
}

/**
 * Set work in background for this script.
 * @param state boolean
 * @return void
 */
method assets::workInBackground(state) {
    if state {
        memory.setuint8(7634870, 1, false)
        memory.setuint8(7635034, 1, false)
        memory.fill(7623723, 144, 8, false)
        memory.fill(5499528, 144, 6, false)
    } else {
        memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin("0F 84 7B 01 00 00", 7623723, 8)
        memory.hex2bin("50 51 FF 15 00 83 85 00", 5499528, 6)
    }
}

/**
 * Get all files in the `mask` (example - `moonloader\\*.lua`).
 *
 * @param mask string
 * @return string[]
 */
method assets::getFilesByMask(mask) {
    local handle, file = findFirstFile(mask)
    local files        = {}

    while file {
        if file {
            table.insert(files, file)
            file = findNextFile(handle)
        } else {
            findClose(handle)
        }
    }

    return files
}

return assets
