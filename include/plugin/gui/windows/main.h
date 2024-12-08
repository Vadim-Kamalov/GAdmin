#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"
#include <utility>

namespace plugin::gui::windows {

class Main : public Window {
private:
    void render_menu();
public:
    enum class SelectedFrame {
        Home,
        Settings,
        KeyBinds,
        PlayerChecker,
        WindowsCustomization,
        Logs,
        ServerInformation,
        Binder,
        Notes,
        Statistics,
        PluginInformation,
        Count
    } selected_frame = SelectedFrame::Home; // enum class SelectedFrame

    static constexpr const char* const frame_icons[std::to_underlying(SelectedFrame::Count)] = {
        ICON_HOUSE01, ICON_SETTINGS, ICON_KEYBOARD, ICON_USERS,
        ICON_WINDOW, ICON_DATA, ICON_BOOK, ICON_NOTEBOOK, ICON_NOTE,
        ICON_CHART_BAR_VERTICAL01, ICON_INFO
    }; // static constexpr const char* const frame_icons[std::to_underlying(SelectedFrame::Count)]

    static constexpr const char* const frame_labels[std::to_underlying(SelectedFrame::Count)] = {
        "Главная", "Настройки", "Горячие клавиши", "Чекер игроков", "Настройка окон",
        "Логи", "Таблицы", "Биндер", "Заметки", "Статистика", "Информация"
    }; // static constexpr const char* const frame_labels[std::to_underlying(SelectedFrame::Count)]

    utils::not_null<GraphicalUserInterface*> child;
    
    static constexpr float menu_min_width = 44;
    static constexpr float menu_max_width = 200;
    static constexpr std::chrono::milliseconds menu_open_duration = std::chrono::milliseconds(500);

    float menu_width = menu_min_width;
    bool menu_opened = false;

    constexpr const char* get_id() const override;

    void render() override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    
    explicit Main(utils::not_null<GraphicalUserInterface*> child);
}; // class Main : public Window

WindowRef main(utils::not_null<GraphicalUserInterface*> child) noexcept;

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
