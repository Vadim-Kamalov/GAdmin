/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only
/// 
/// @file plugin/gui/windows/main/frames/frames.h
/// @brief Defines the frames and their properties in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H

#include "plugin/types/simple.h"
#include "plugin/gui/icon.h"
#include <cstdint>
#include <utility>

namespace plugin::gui::windows::main {

/// @enum frame
/// @brief Enumeration of available frames in the GUI
enum class frame : std::uint8_t {
    home,
    settings,
    key_binds,
    player_checker,
    windows_customization,
    logs,
    server_information,
    binder,
    notes,
    statistics,
    plugin_information,
    count
}; // enum class frame : std::uint8_t

/// @brief Total number of frames.
static constexpr std::uint8_t frames_count = std::to_underlying(frame::count);

namespace frames {

static constexpr types::zstring_t icon_list[frames_count] = {
    ICON_HOUSE01,               ///< frame::home
    ICON_SETTINGS,              ///< frame::settings
    ICON_KEYBOARD,              ///< frame::key_binds
    ICON_USERS,                 ///< frame::player_checker
    ICON_WINDOW,                ///< frame::windows_customization
    ICON_DATA,                  ///< frame::logs
    ICON_TABLE,                 ///< frame::server_information
    ICON_NOTEBOOK,              ///< frame::binder
    ICON_NOTE,                  ///< frame::notes
    ICON_CHART_BAR_VERTICAL01,  ///< frame::statistics
    ICON_INFO                   ///< frame::plugin_information
}; // static constexpr types::zstring_t icon_list[frames_count]

static constexpr types::zstring_t label_list[frames_count] = {
    "Главная",          ///< frame::home
    "Настройки",        ///< frame::settings
    "Горячие клавиши",  ///< frame::key_binds
    "Чекер игроков",    ///< frame::player_checker
    "Оформление окон",  ///< frame::windows_customization
    "Логи",             ///< frame::logs
    "Таблицы",          ///< frame::server_information
    "Биндер",           ///< frame::binder
    "Заметки",          ///< frame::notes
    "Статистика",       ///< frame::statistics
    "Информация"        ///< frame::plugin_information
}; // static constexpr types::zstring_t label_list[frames_count]

} // namespace frames
} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H
