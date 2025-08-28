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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H

#include "plugin/types/simple.h"
#include "plugin/gui/icon.h"
#include <cstdint>
#include <utility>

namespace plugin::gui::windows::main {

/// All available frames to switch to in the main window.
enum class frame : std::uint8_t {
    home,                   ///< Home frame: displayed when no other frame is selected.
    settings,               ///< Settings frame: allows the user to configure all settings.
    key_binds,              ///< Key Binds frame: allows configuring all hotkeys.
    player_checker,         ///< Player Checker frame: allows managing all players in the checker.
    windows_customization,  ///< Windows Customization frame: allows customizing all windows and installing themes.
    logs,                   ///< Logs frame: displays all messages sent in the chat by the server.
    server_information,     ///< Server Information frame: provides information about the server, e.g., prices of valuables.
    binder,                 ///< Binder frame: allows configuring binds.
    notes,                  ///< Notes frame: allows the user to manage notes.
    statistics,             ///< Statistics frame: provides detailed user statistics since the plugin was first loaded.
    plugin_information,     ///< Plugin Information frame: displays information about the plugin, its sponsors, and contributors.
    count                   ///< Count of all frames. Must always be the last entry in the enumeration.
}; // enum class frame : std::uint8_t

/// Total number of frames, same as `std::to_underlying(frame::count)`.
static constexpr std::uint8_t frames_count = std::to_underlying(frame::count);

namespace frames {

/// Icons of the all frames in the main window.
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

/// Titles of the all frames in the main window.
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
