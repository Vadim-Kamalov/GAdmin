#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H

#include "plugin/gui/windows/main/base/custom_setting.h"

namespace plugin::gui::windows::main::custom_settings {

class double_line_input : public basic_custom_setting {
private:
    static constexpr float placeholder_font_size = 16;
    std::pair<std::string, std::string> keys, placeholders;
public:
    auto render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void override;
    
    explicit double_line_input(const std::pair<std::string, std::string>& keys,
                               const std::pair<std::string, std::string>& placeholders)
        : keys(std::move(keys)), placeholders(std::move(placeholders)) {}
}; // class double_line_input final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_DOUBLE_LINE_INPUT_H
