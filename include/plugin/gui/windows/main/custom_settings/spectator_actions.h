#ifndef GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

class spectator_actions final : public basic_custom_setting {
private:
    static constexpr types::zstring_t action_selector_placeholders[2] = {
        "Отправка или вставка текст в чат",
        "Функциональное"
    }; // static constexpr types::zstring_t action_selector_placeholders[2]
    
    static constexpr float button_width = 100;
    static constexpr float button_border_size = 1;
    static constexpr float button_count_on_line = 3;

    std::size_t selected_index = 0;
    bool selected_action_from_menu = false;

    auto render_lines(float width, nlohmann::json& setter) -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
}; // class spectator_actions final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::spectator_actions::get_id() const
    -> types::zstring_t
{
    return "spectator_actions.buttons";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_CUSTOM_SETTINGS_SPECTATOR_ACTIONS_H
