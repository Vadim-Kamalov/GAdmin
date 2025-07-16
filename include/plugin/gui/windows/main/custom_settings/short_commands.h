#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

class short_commands final : public basic_custom_setting {
public:
    inline auto get_id() const -> types::zstring_t override;
    auto render(nlohmann::json& setter) -> void override;
}; // class short_commands final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::short_commands::get_id() const
    -> types::zstring_t
{
    return "short_commands.commands";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_SHORT_COMMANDS_H
