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

@import "CompressedData"    => compressedData
@import "Assets"            => assets

@define MIN_ICON 0xF000
@define MAX_ICON 0xFFFF

local icons = {
    ICON_XLS_DOCUMENT = "\u{F000}",
    ICON_WORD_DOCUMENT = "\u{F001}",
    ICON_WAVE = "\u{F002}",
    ICON_WARNING = "\u{F003}",
    ICON_VISIBILITY = "\u{F004}",
    ICON_VISIBILITY_OFF = "\u{F005}",
    ICON_VIDEO = "\u{F006}",
    ICON_VERTICAL_BAR_CHART = "\u{F007}",
    ICON_PLAY = "\u{F008}",
    ICON_PLUS = "\u{F009}",
    ICON_PNG = "\u{F010}",
    ICON_POWERPOINT_DOCUMENT = "\u{F011}",
    ICON_PRINTER = "\u{F012}",
    ICON_PYRAMID = "\u{F013}",
    ICON_QUESTION_MARK_CIRCLE = "\u{F014}",
    ICON_REFRESH = "\u{F015}",
    ICON_ROTATE_LEFT = "\u{F016}",
    ICON_ROTATE_RIGHT = "\u{F017}",
    ICON_SAVE = "\u{F018}",
    ICON_SEARCH = "\u{F019}",
    ICON_SEND = "\u{F020}",
    ICON_SETTINGS = "\u{F021}",
    ICON_SHIELD_WITH_CHECKMARK = "\u{F022}",
    ICON_SHIELD_OUTLINED_WITH_CHECKMARK = "\u{F023}",
    ICON_SHIELD_OUTLINED = "\u{F024}",
    ICON_SHIELD = "\u{F025}",
    ICON_STAR = "\u{F026}",
    ICON_SVG_DOCUMENT = "\u{F027}",
    ICON_TRASH = "\u{F028}",
    ICON_TREE_MAP = "\u{F029}",
    ICON_TEXT_DOCUMENT = "\u{F030}",
    ICON_TRENDING_DOWN = "\u{F031}",
    ICON_TRENDING_UP = "\u{F032}",
    ICON_TRIPLE_DOTS = "\u{F033}",
    ICON_TWO_LINES_HORIZONTAL = "\u{F034}",
    ICON_TWO_LINES_VERTICAL = "\u{F035}",
    ICON_TXT_DOCUMENT = "\u{F036}",
    ICON_UPLOAD_VERSION_1 = "\u{F037}",
    ICON_UPLOAD_VERSION_2 = "\u{F038}",
    ICON_PIE_CHART = "\u{F039}",
    ICON_PHONE = "\u{F040}",
    ICON_PHONE_VERTICAL = "\u{F041}",
    ICON_PHONE_OPEN = "\u{F042}",
    ICON_PHONE_CLOSED = "\u{F043}",
    ICON_PERSON = "\u{F044}",
    ICON_PEOPLE = "\u{F045}",
    ICON_PENCIL = "\u{F046}",
    ICON_PEN = "\u{F047}",
    ICON_PEN_BRUSH = "\u{F048}",
    ICON_PDF_DOCUMENT = "\u{F049}",
    ICON_PDF_DOCUMENT_ALTERNATE = "\u{F050}",
    ICON_PAW = "\u{F051}",
    ICON_PAUSE = "\u{F052}",
    ICON_PAPERCLIP_V2 = "\u{F053}",
    ICON_PAPERCLIP_V1 = "\u{F054}",
    ICON_PALETTE = "\u{F055}",
    ICON_MUSIC_NOTE = "\u{F056}",
    ICON_MUSIC_NOTE_ALT = "\u{F057}",
    ICON_MOUSE = "\u{F058}",
    ICON_MONITOR = "\u{F059}",
    ICON_MOBILE = "\u{F060}",
    ICON_MINUS = "\u{F061}",
    ICON_MINIMIZE = "\u{F062}",
    ICON_MICROPHONE = "\u{F063}",
    ICON_MENU = "\u{F064}",
    ICON_MAXIMIZE = "\u{F065}",
    ICON_MAIL = "\u{F066}",
    ICON_LOCKED_DOCUMENT = "\u{F067}",
    ICON_LOCK = "\u{F068}",
    ICON_LOCK_OPEN = "\u{F069}",
    ICON_LOCATION_PIN = "\u{F070}",
    ICON_HEADPHONE = "\u{F071}",
    ICON_HEART = "\u{F072}",
    ICON_HOME_EMPTY = "\u{F073}",
    ICON_HOME = "\u{F074}",
    ICON_HORIZONTAL_BAR_CHART = "\u{F075}",
    ICON_HOURGLAS_FLOWING = "\u{F076}",
    ICON_HOURGLASS_BOTTOM_FILLED = "\u{F077}",
    ICON_HOURGLASS_TOP_FILLED = "\u{F078}",
    ICON_IMAGE = "\u{F079}",
    ICON_INBOX_ARROW_DOWN = "\u{F080}",
    ICON_INBOX_ARROW_UP = "\u{F081}",
    ICON_INBOX_TRAY_FULL = "\u{F082}",
    ICON_INBOX_TRAY = "\u{F083}",
    ICON_INBOXES = "\u{F084}",
    ICON_JPEG = "\u{F085}",
    ICON_KEY = "\u{F086}",
    ICON_KEYBOARD = "\u{F087}",
    ICON_LANDMARK = "\u{F088}",
    ICON_LAPTOP_COMPUTER = "\u{F089}",
    ICON_LAYERS = "\u{F090}",
    ICON_LEAF = "\u{F091}",
    ICON_LIGHTBULB_EMPTY = "\u{F092}",
    ICON_LIGHTBULB_FILLED = "\u{F093}",
    ICON_LIGHTNING_BOLT = "\u{F094}",
    ICON_LINE_CHART = "\u{F095}",
    ICON_LINK_ALT = "\u{F096}",
    ICON_LINK = "\u{F097}",
    ICON_LIST_CIRCLE = "\u{F098}",
    ICON_LIST_DASH = "\u{F099}",
    ICON_LIST_SQUARE = "\u{F100}",
    ICON_LIST = "\u{F101}",
    ICON_LOCATION_ALT = "\u{F102}",
    ICON_HAMMER = "\u{F103}",
    ICON_CODE = "\u{F104}",
    ICON_BRAIN = "\u{F105}",
    ICON_BOOKMARK_OUTLINED = "\u{F106}",
    ICON_CLOSE = "\u{F107}",
    ICON_GLASSES = "\u{F108}",
    ICON_GLASSES_ALT = "\u{F109}",
    ICON_CLOSE_CIRCLE = "\u{F110}",
    ICON_BOOKMARK_FILLED = "\u{F111}",
    ICON_BOOK_OPEN = "\u{F112}",
    ICON_CLOCK_FILLED = "\u{F113}",
    ICON_GIFT = "\u{F114}",
    ICON_FOLDER = "\u{F115}",
    ICON_CLIPBOARD = "\u{F116}",
    ICON_BIN = "\u{F117}",
    ICON_BELL = "\u{F118}",
    ICON_CHEVRON_UP = "\u{F119}",
    ICON_FLAG = "\u{F120}",
    ICON_FIRE = "\u{F121}",
    ICON_CHEVRON_RIGHT = "\u{F122}",
    ICON_BAG = "\u{F123}",
    ICON_ARCHIVE = "\u{F124}",
    ICON_AREA_CHART = "\u{F125}",
    ICON_ARROW_DOWN_FROM_LINE = "\u{F126}",
    ICON_ARROW_DOWN_LEFT = "\u{F127}",
    ICON_ARROW_DOWN_RIGHT = "\u{F128}",
    ICON_ARROW_DOWN_TO_LINE = "\u{F129}",
    ICON_ARROW_DOWN = "\u{F130}",
    ICON_ARROW_LEFT_FROM_LINE = "\u{F131}",
    ICON_ARROW_LEFT_TO_LINE = "\u{F132}",
    ICON_ARROW_LEFT = "\u{F133}",
    ICON_ARROW_RIGHT_FROM_LINE = "\u{F134}",
    ICON_ARROW_RIGHT_TO_LINE = "\u{F135}",
    ICON_ARROW_RIGHT = "\u{F136}",
    ICON_ARROW_TOP_LEFT = "\u{F137}",
    ICON_ARROW_TOP_RIGHT = "\u{F138}",
    ICON_ARROW_UP_FROM_LINE = "\u{F139}",
    ICON_ARROW_UP_TO_LINE = "\u{F140}",
    ICON_ARROW_UP = "\u{F141}",
    ICON_BADGE_WITH_CHECKMARK = "\u{F142}",
    ICON_BADGE = "\u{F143}",
    ICON_BRIEFCASE = "\u{F144}",
    ICON_BRUSH = "\u{F145}",
    ICON_BUBBLE_CHART = "\u{F146}",
    ICON_BUG = "\u{F147}",
    ICON_CABINET = "\u{F148}",
    ICON_CALENDAR_ALT = "\u{F149}",
    ICON_CALENDAR = "\u{F150}",
    ICON_CAMERA = "\u{F151}",
    ICON_CANDLESTICK_CHART = "\u{F152}",
    ICON_CAR = "\u{F153}",
    ICON_CART = "\u{F154}",
    ICON_CASE = "\u{F155}",
    ICON_CERTIFICATE = "\u{F156}",
    ICON_CHAT_BUBBLE_ADD = "\u{F157}",
    ICON_CHAT_BUBBLE_QUESTION_MARK = "\u{F158}",
    ICON_CHAT_BUBBLE_WARNING = "\u{F159}",
    ICON_CHAT_BUBBLE = "\u{F160}",
    ICON_CHAT_MULTIPLE = "\u{F161}",
    ICON_CHECKLIST = "\u{F162}",
    ICON_CHECKMARK_CIRCLE = "\u{F163}",
    ICON_CHECKMARK = "\u{F164}",
    ICON_CHEVRON_DOWN = "\u{F165}",
    ICON_CHEVRON_LEFT_END = "\u{F166}",
    ICON_CHEVRON_LEFT = "\u{F167}",
    ICON_CHEVRON_RIGHT_END = "\u{F168}",
    ICON_COLLAPSE = "\u{F169}",
    ICON_CONTACT_CARD = "\u{F170}",
    ICON_CREDIT_CARD = "\u{F171}",
    ICON_DASHBOARD = "\u{F172}",
    ICON_DATABASE = "\u{F173}",
    ICON_DENY = "\u{F174}",
    ICON_DESKTOP_COMPUTER = "\u{F175}",
    ICON_DOCUMENT = "\u{F176}",
    ICON_DOTS_HORIZONTAL = "\u{F177}",
    ICON_DOTS_VERTICAL = "\u{F178}",
    ICON_DOUBLE_DOTS = "\u{F179}",
    ICON_DOWNLOAD_VERSION_1 = "\u{F180}",
    ICON_DOWNLOAD_VERSION_2 = "\u{F181}",
    ICON_DROPLET = "\u{F182}",
    ICON_ELECTRIC_CAR = "\u{F183}",
    ICON_EMOJI_FILLED = "\u{F184}",
    ICON_EMOJI_OUTLINED = "\u{F185}",
    ICON_EPS_DOCUMENT = "\u{F186}",
    ICON_ERROR = "\u{F187}",
    ICON_EXPAND = "\u{F188}",
    ICON_EXTERNAL = "\u{F189}",
    ICON_FIGMA_DOCUMENT = "\u{F190}",
    ICON_FILTER_ALTERNATE = "\u{F191}",
    ICON_FILTER = "\u{F192}",
    ICON_FIRE_ALT = "\u{F193}",
    ICON_2_PEOPLE = "\u{F194}",
    ICON_ADDRESS_BOOK = "\u{F195}",
    ICON_ALARM_CLOCK = "\u{F196}",
    ICON_ALIEN = "\u{F197}",
    ICON_AI_DOCUMENT = "\u{F198}",
    ICON_PLUS_CIRCLE = "\u{F199}"
}

method icons::init(iconSize = 14.0) {
    local config        = imgui.ImFontConfig()
    local glyphRanges   = imgui.GetIO().Fonts::GetGlyphRangesCyrillic()
    local iconRanges    = imgui.new.ImWchar[3](0xE005, 0xF8FF, 0)
    
    config.MergeMode = true
    imgui.GetIO().Fonts::AddFontFromFileTTF("trebucbd.ttf", iconSize, nil, glyphRanges)

    global icon = imgui.GetIO().Fonts::AddFontFromMemoryCompressedBase85TTF(
        compressedData.iconFont,
        iconSize,
        config,
        iconRanges
    )
}

return setmetatable(icons, {
    __call = fn (table, value) {
        if type(value) == "string" {
            return t["ICON_" .. string.upper(value)] || "?"
        } elseif type(value) == "number" && (value >= $MIN_ICON && value <= $MAX_ICON) {
            return assets::convertUnicode2Utf8(value)
        } else {
            return "Unknown icon"
        }
    }
})
