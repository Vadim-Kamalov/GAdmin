#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class main : public window {
private:
    void render_menu();
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
    utils::not_null<gui_initializer*> child;
    
    frame current_frame = frame::home;
    float menu_width = menu_min_width;
    bool menu_opened = false;

    constexpr const char* get_id() const override { return "windows::main"; }

    void render() override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    
    static window_ptr_t create(utils::not_null<gui_initializer*> child) noexcept;
    explicit main(utils::not_null<gui_initializer*> child);
public:
    static constexpr const char* frame_icons[] = {
        ICON_HOUSE01, ICON_SETTINGS, ICON_KEYBOARD, ICON_USERS,
        ICON_WINDOW, ICON_DATA, ICON_BOOK, ICON_NOTEBOOK, ICON_NOTE,
        ICON_CHART_BAR_VERTICAL01, ICON_INFO
    }; // static constexpr const char* const frame_icons[]

    static constexpr const char* frame_labels[] = {
        "Главная", "Настройки", "Горячие клавиши", "Чекер игроков", "Настройка окон",
        "Логи", "Таблицы", "Биндер", "Заметки", "Статистика", "Информация"
    }; // static constexpr const char* const frame_labels[]

    static constexpr float menu_min_width = 44;
    static constexpr float menu_max_width = 200;
    static constexpr std::chrono::milliseconds menu_open_duration = std::chrono::milliseconds(500);
}; // class main : public window

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
