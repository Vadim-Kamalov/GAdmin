#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"

namespace plugin::gui::windows {

class main final : public window {
private:
    auto render_menu() -> void;
public:
    enum class frame {
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
        plugin_information
    }; // enum class frame
public:
    frame current_frame = frame::home;
    float menu_width = menu_min_width;
    bool menu_opened = false;

    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;

    explicit main(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
public:
    static constexpr types::zstring_t frame_icons[] = {
        ICON_HOUSE01, ICON_SETTINGS, ICON_KEYBOARD, ICON_USERS,
        ICON_WINDOW, ICON_DATA, ICON_BOOK, ICON_NOTEBOOK, ICON_NOTE,
        ICON_CHART_BAR_VERTICAL01, ICON_INFO
    }; // static constexpr types::zstring_t const frame_icons[]

    static constexpr types::zstring_t frame_labels[] = {
        "Главная", "Настройки", "Горячие клавиши", "Чекер игроков", "Настройка окон",
        "Логи", "Таблицы", "Биндер", "Заметки", "Статистика", "Информация"
    }; // static constexpr types::zstring_t const frame_labels[]

    static constexpr float menu_min_width = 44;
    static constexpr float menu_max_width = 200;
    static constexpr std::chrono::milliseconds menu_open_duration = std::chrono::milliseconds(500);
}; // class main : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::main::get_id() const -> types::zstring_t {
    return "windows::main";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
