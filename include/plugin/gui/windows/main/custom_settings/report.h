#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H

#include "plugin/gui/windows/main/custom_settings/double_line_input.h"

namespace plugin::gui::windows::main::custom_settings {

class report final : public double_line_input {
public:
    inline auto get_id() const -> types::zstring_t override;

    explicit report()
        : double_line_input({ "name", "insert" },
                            { "Название кнопки", "Текст для вставки" }) {}
}; // class report final : public basic_custom_setting

} // namespace plugin::gui::windows::main::custom_settings

inline auto plugin::gui::windows::main::custom_settings::report::get_id() const
    -> types::zstring_t
{
    return "report.insert_buttons";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_CUSTOM_SETTINGS_REPORT_H
