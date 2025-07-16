#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H

#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <memory>

namespace plugin::gui::windows::main {

class basic_custom_setting {
public:
    virtual ~basic_custom_setting() = default;
    virtual auto get_id() const -> types::zstring_t = 0;
    virtual auto render(nlohmann::json& setter) -> void = 0;
}; // class basic_custom_setting

using custom_setting_ptr_t = std::unique_ptr<basic_custom_setting>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_CUSTOM_SETTING_H
