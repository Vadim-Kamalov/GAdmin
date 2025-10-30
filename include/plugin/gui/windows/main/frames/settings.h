/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SETTINGS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SETTINGS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows::main::frames {

/// Represents the settings frame in the main window.
class settings final : public basic_frame {
private:
    static constexpr float section_title_font_size = 24;
    static constexpr float common_text_size = 18;
    static constexpr float color_border_size = 3;
    static constexpr float close_button_height = 30;

    static std::unordered_map<std::string, std::function<void(bool&)>> toggle_events;

    widgets::submenu submenu = widgets::submenu("Настройки##frames::settings");
    widgets::popup popup = widgets::popup("frames::settings::popup");

    nlohmann::ordered_json options;
    types::not_null<initializer*> child;
    std::string guide_hint_id = "";

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto render_section_items(const std::string& key, nlohmann::ordered_json& items) -> void;
    
    auto render_subsection(const std::string_view& subsection_key, const std::string& subsection_name,
                           nlohmann::json& item_configuration, nlohmann::ordered_json& item) -> void;

    template<typename T> requires std::is_integral_v<T> || std::is_floating_point_v<T>
    auto render_range(types::zstring_t label, T* value, const std::pair<T, T>& range) const -> void;

    auto render_variant(const std::string& label, nlohmann::ordered_json& config, std::string& setter) const -> void;
    auto render_color(const std::string& label, nlohmann::json& setter) const -> void;
    auto render_custom(const std::string_view& id, nlohmann::json& setter) const -> void;
    auto render_boolean(const std::string_view& label, nlohmann::ordered_json& config, bool& setter) const -> void;
public:
    /// Item types to parse from the JSON and later to render them.
    enum class item_type : std::uint8_t {
        subsection,     ///< Represents the group of settings.
        custom,         ///< Represents the custom setting (`basic_custom_setting`).
        int_range,      ///< Represents the integer range (`ImGui::SliderInt`).
        float_range,    ///< Represents the floating range (`ImGui::SliderDouble`).
        variant,        ///< Represents the map (`"key": "value"`).
        boolean,        ///< Represents the boolean setting (`widgets::toggle_button`).
        input,          ///< Represents the text input (`ImGui::InputText`).
        color           ///< Represents the color (`ImGui::ColorEdit3`).
    }; // enum class item_type : std::uint8_t

    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit settings(types::not_null<initializer*> child);
}; // class settings final

NLOHMANN_JSON_SERIALIZE_ENUM(settings::item_type, {
    { settings::item_type::subsection, "subsection" },
    { settings::item_type::custom, "custom" },
    { settings::item_type::int_range, "intrange" },
    { settings::item_type::float_range, "floatrange" },
    { settings::item_type::variant, "variant" },
    { settings::item_type::boolean, "bool" },
    { settings::item_type::input, "input" },
    { settings::item_type::color, "color" }
});

} // namespace plugin::gui::windows::main::frames

template<typename T> requires std::is_integral_v<T> || std::is_floating_point_v<T>
auto plugin::gui::windows::main::frames::settings::render_range(types::zstring_t label, T* value, const std::pair<T, T>& range) const
    -> void
{
    ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);

    if constexpr (std::is_integral_v<T>)
        ImGui::SliderInt(label, reinterpret_cast<int*>(value), range.first, range.second);
    else if constexpr (std::is_floating_point_v<T>)
        ImGui::SliderScalar(label, ImGuiDataType_Double, value, &range.first, &range.second, "%.3f");
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SETTINGS_H
