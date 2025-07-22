#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

class spectator_information final : public basic_custom_setting {
private:
    static constexpr float button_width = 100;
    static constexpr float button_border_size = 1;
public:
    inline auto get_id() const -> types::zstring_t override;
    auto render(types::not_null<gui_initializer*>, nlohmann::json& setter) -> void override;
}; // class spectator_information final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::spectator_information::get_id() const
    -> types::zstring_t
{
    return "spectator_information.row_order";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SPECTATOR_INFORMATION_H
