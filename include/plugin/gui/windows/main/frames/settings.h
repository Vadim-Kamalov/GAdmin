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

class settings final : public basic_frame {
private:
    static constexpr float section_title_font_size = 24;
    static constexpr float common_text_size = 18;
    static constexpr float color_border_size = 3;
    static constexpr float close_button_height = 30;

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
    enum class item_type : std::uint8_t {
        subsection,
        custom,
        int_range,
        float_range,
        variant,
        boolean,
        input,
        color
    }; // enum class item_type : std::uint8_t

    auto render() -> void override;

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
        ImGui::SliderFloat(label, reinterpret_cast<float*>(value), range.first, range.second);
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SETTINGS_H
