#include "plugin/gui/windows/main/frames/settings.h"
#include "plugin/cheats/wallhack.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/text_button.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/windows/main/custom_settings/report.h"
#include "plugin/gui/windows/main/custom_settings/short_commands.h"
#include "plugin/gui/windows/main/custom_settings/spectator_actions.h"
#include "plugin/gui/windows/main/custom_settings/spectator_information.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>
#include <unordered_map>
#include <algorithm>

static constexpr std::uint8_t options_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../../../../../embed/main_frame_settings.mpk"
#else
#embed "../../../../../../embed/main_frame_settings.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t options_bytes[]

auto plugin::gui::windows::main::frames::settings::render_section_items(const std::string& key, nlohmann::ordered_json& items) -> void {
    for (const auto& [ item_key, item ] : items.items()) {
        if (item_key.starts_with('_'))
            continue;

        nlohmann::json& item_configuration = (*configuration)[key][item_key];
        item_type type = item["_type"];
        bool* configuration_value = nullptr;

        switch (type) {
            case item_type::boolean:
                configuration_value = item_configuration.get_ptr<bool*>();
                break;
            case item_type::subsection:
                configuration_value = item_configuration["use"].get_ptr<bool*>();
                break;
            default:
                log::fatal("settings::render_section_items [with item_key = \"{}\"]: items[\"_type\"] must be boolean or subsection", item_key);
                return;
        }

        if (configuration_value == nullptr) {
            log::fatal("settings::render_section_items [with item_key = \"{}\"]: configuration_value == nullptr", item_key);
            return;
        }

        std::string name = item["_name"];
        std::string label = ((type == item_type::subsection) ? "##" + name : name + "##") + item_key;

        gui::widgets::toggle_button(label, *configuration_value).render();

        if (type != item_type::subsection)
            continue;

        ImGui::SameLine();
        render_subsection(item_key, name, item_configuration, item);
    }
}

auto plugin::gui::windows::main::frames::settings::render_subsection(const std::string_view& subsection_key, const std::string& subsection_name,
                                                                     nlohmann::json& item_configuration, nlohmann::ordered_json& item) -> void
{
    bool button_clicked = gui::widgets::text_button(subsection_name).render();

    if (guide_hint_id.empty())
        guide_hint_id = subsection_key;

    if (guide_hint_id == subsection_key)
        gui::widgets::hint::render_as_guide("Нажмите на текст, чтобы открыть детальную настройку");

    if (!button_clicked)
        return;

    popup.set_renderer([=, this, &item_configuration, &item] {
        float region_avail_x = ImGui::GetContentRegionAvail().x;
        
        gui::widgets::text(bold_font, section_title_font_size, 0, "{}", subsection_name);

        for (auto& [ key, option ] : item.items()) {
            if (key.starts_with('_'))
                continue;

            item_type option_type = option["_type"];
            std::string option_name = option["_name"];
            std::string option_label = option_name + "##" + subsection_key;
            nlohmann::ordered_json config = option["_config"];

            if (option_type != item_type::boolean) {
                gui::widgets::text(bold_font, common_text_size, 0, "{}", option_name);
                option_label.insert(0, "##");
            }

            ImGui::PushFont(regular_font, common_text_size);
            {
                switch (option_type) {
                    case item_type::int_range:
                        render_range<std::uint64_t>(option_label.c_str(), item_configuration[key].get_ptr<std::uint64_t*>(),
                                                    std::make_pair(config[0], config[1]));
                        break;
                    case item_type::float_range:
                        render_range<double>(option_label.c_str(), item_configuration[key].get_ptr<double*>(),
                                             std::make_pair(config[0], config[1]));
                        break;
                    case item_type::boolean:
                        render_boolean(option_label, config, item_configuration[key].get_ref<bool&>());
                        break;
                    case item_type::input:
                        ImGui::SetNextItemWidth(region_avail_x);
                        ImGui::InputText(option_label.c_str(), item_configuration[key].get_ptr<std::string*>());
                        break;
                    case item_type::variant:
                        render_variant(option_label, config, item_configuration[key].get_ref<std::string&>());
                        break;
                    case item_type::color:
                        render_color(option_label, item_configuration[key]);
                        break;
                    case item_type::custom:
                        render_custom(std::format("{}.{}", subsection_key, key), item_configuration[key]);
                        break;
                    default:
                        break;
                }
            }
            ImGui::PopFont();
        }
    });

    popup.open();
}

auto plugin::gui::windows::main::frames::settings::render_variant(const std::string& label, nlohmann::ordered_json& config, std::string& setter) const
    -> void
{
    static std::unordered_map<std::string, int> pool;

    if (!pool.contains(label)) {
        auto it = std::find_if(config.begin(), config.end(), [&setter](nlohmann::ordered_json& array) {
            return array[0] == setter;
        });

        if (it == config.end()) {
            log::fatal("settings::render_variant: `{}` is not found in `config`", setter);
            return;
        }

        pool[label] = std::distance(config.begin(), it);
    }

    int& index = pool[label];
    std::string format = config[index][1];

    ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);
    
    if (ImGui::SliderInt(label.c_str(), &index, 0, config.size() - 1, format.c_str()))
        setter = config[index][0];
}

auto plugin::gui::windows::main::frames::settings::render_color(const std::string& label, nlohmann::json& setter) const
    -> void
{
    static std::unordered_map<std::string, ImVec4> pool;

    if (!pool.contains(label))
        pool[label] = ImGui::ColorConvertU32ToFloat4(*setter.get<types::color>());

    ImVec4& vector_color = pool[label];

    ImGui::PushFont(bold_font, common_text_size);
    {
        float frame_height = ImGui::GetFrameHeight();
        types::color color = ImGui::ColorConvertFloat4ToU32(vector_color);
        
        ImDrawList* draw_list = ImGui::GetWindowDrawList();
        ImVec2 frame_padding = ImGui::GetStyle().FramePadding;
        ImVec2 pos = ImGui::GetCursorScreenPos();

        ImGui::BeginGroup();
        {
            std::string hexadecimal_color = std::format("{:02X}{:02X}{:02X}",
                static_cast<std::uint8_t>(vector_color.x * 255.0f),
                static_cast<std::uint8_t>(vector_color.y * 255.0f),
                static_cast<std::uint8_t>(vector_color.z * 255.0f));

            ImGui::SetCursorScreenPos({ pos.x + frame_padding.x,
                    pos.y + (frame_height - ImGui::CalcTextSize(hexadecimal_color.c_str()).y) / 2.0f });
            
            ImGui::TextColored(vector_color, "%s", hexadecimal_color.c_str());
            ImGui::SetCursorScreenPos({ pos.x + ImGui::GetContentRegionAvail().x - frame_height, pos.y });

            if (ImGui::ColorEdit3(label.c_str(), reinterpret_cast<float*>(&vector_color), ImGuiColorEditFlags_NoInputs)) {
                color = ImGui::ColorConvertFloat4ToU32(vector_color);
                setter = color;
            }

            ImVec2 rect_min = ImGui::GetItemRectMin();
            float frame_rounding = ImGui::GetStyle().FrameRounding;

            draw_list->AddRect(pos, ImGui::GetItemRectMax(), *color, frame_rounding, ImDrawFlags_None, color_border_size);
            draw_list->AddRectFilled(rect_min, { rect_min.x + frame_rounding, rect_min.y + frame_height }, *color);
        }
        ImGui::EndGroup();
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::settings::render_custom(const std::string_view& id, nlohmann::json& setter) const -> void {
    static auto custom_settings = std::to_array<custom_setting_ptr_t>({
        std::make_unique<custom_settings::report>(),
        std::make_unique<custom_settings::short_commands>(),
        std::make_unique<custom_settings::spectator_information>(),
        std::make_unique<custom_settings::spectator_actions>()
    }); // static auto custom_settings = std::to_array<custom_setting_ptr_t>({ ... })

    auto custom_setting = std::find_if(custom_settings.begin(), custom_settings.end(),
        [&id](const custom_setting_ptr_t& setting) { return setting->get_id() == id; });

    if (custom_setting == custom_settings.end()) {
        log::fatal("settings::render_custom [with id = {}]: custom_setting_ptr_t is not found", id);
        return;
    }

    (*custom_setting)->render(child->child, setter);
}

auto plugin::gui::windows::main::frames::settings::render_boolean(const std::string_view& label, nlohmann::ordered_json& config, bool& setter) const -> void {
    static std::unordered_map<std::string, std::function<void(bool&)>> events = {
        { "cheats::wallhack", [](bool& state) { cheats::wallhack::set_samp_render_state(state); }}
    }; // static std::unorederd_map<std::string, std::function<void(bool&)>> events

    if (!gui::widgets::toggle_button(label, setter).render() || config.is_null())
        return;

    events[config](setter);
}

auto plugin::gui::windows::main::frames::settings::render() -> void {
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
    popup.render(child);
}

plugin::gui::windows::main::frames::settings::settings(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
#ifdef USE_EMBEDDED_MESSAGE_PACK
    options = nlohmann::ordered_json::from_msgpack(options_bytes);
#else
    options = nlohmann::ordered_json::parse(options_bytes);
#endif // USE_EMBEDDED_MESSAGE_PACK

    for (auto& [ key, section ] : options.items()) {
        submenu.add_entry(section["_name"].get<std::string>() + "##" + key,
                          std::make_any<nlohmann::ordered_json&>(section));
    }

    submenu.set_frame_renderer([this](std::string& label, std::any& payload) {
        std::size_t pos = label.find("##");

        [[assume(pos != std::string_view::npos)]];
        
        std::string name = label.substr(0, pos);
        std::string key = label.substr(pos + 2);

        gui::widgets::text(bold_font, section_title_font_size, 0, "{}", name);
        ImGui::PushFont(regular_font, common_text_size);
        ImGui::BeginGroup();
        {
            render_section_items(key, std::any_cast<nlohmann::ordered_json&>(payload));
        }
        ImGui::EndGroup();
        ImGui::PopFont();
    });
}
