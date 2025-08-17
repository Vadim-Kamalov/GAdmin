#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_FRAMES_H

#include "plugin/types/simple.h"
#include "plugin/gui/icon.h"
#include <cstdint>
#include <utility>

namespace plugin::gui::windows::main {

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
    "Настройка окон",   ///< frame::windows_customization
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
