#include "plugin/gui/widgets/button.h"
#include "plugin/gui/animation.h"
#include "plugin/log.h"

std::string
plugin::gui::widgets::button::get_text_before_hashtag() const {
    if (std::size_t pos = label.find("##"); pos != std::string::npos)
        return label.substr(0, pos);
    
    return label;
}

void
plugin::gui::widgets::button::register_in_pool() const {
    if (pool.contains(label))
        return;

    pool[label] = {};
}

bool
plugin::gui::widgets::button::render() {
    configuration_t& it = pool[label];
    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImVec2 cursor_pos = ImGui::GetCursorPos();
    bool clicked = false;

    float rounding = ImGui::GetStyle().FrameRounding;

    std::uint32_t active_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_ButtonActive]);
    std::uint32_t hovered_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_ButtonHovered]);
    std::uint32_t default_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Button]);
    
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    auto now = std::chrono::steady_clock::now();

    it.hovered_alpha = animation::bring_to(it.hovered_alpha, (it.hovered_state_current)
        ? ImGui::GetStyle().Alpha * 255 : 0, it.hovered_time, durations[2]);

    draw_list->AddRectFilled({ pos.x - 1, pos.y - 1 }, { pos.x + size.x + 1, pos.y + size.y + 1 },
                             animation::get_alpha_changed_color(hovered_color, it.hovered_alpha), rounding, draw_flags);

    draw_list->AddRectFilled(pos, { pos.x + size.x, pos.y + size.y }, default_color, rounding, draw_flags);
    draw_list->PushClipRect({ pos.x + 1, pos.y + 1 }, { pos.x + size.x - 1, pos.y + size.y - 1 });
    {
        if (it.pos.has_value()) {
            std::uint8_t alpha = 0;
            
            auto alpha_time = std::chrono::duration_cast<std::chrono::milliseconds>(now - it.time[1]).count();
            auto alpha_duration = std::chrono::duration_cast<std::chrono::milliseconds>(durations[1]).count();

            if (alpha_time <= alpha_duration)
                alpha = std::clamp(255.0f - ((255.0f / alpha_duration) * alpha_time), 0.0f, 255.0f);

            auto radius_time = std::chrono::duration_cast<std::chrono::milliseconds>(now - it.time[0]).count();
            auto radius_duration = std::chrono::duration_cast<std::chrono::milliseconds>(durations[0]).count();
        
            if (radius_time <= radius_duration) {
                alpha = std::clamp((255.0f / radius_duration) * radius_time, 0.0f, 255.0f);
                it.radius = (size.x * 1.5 / radius_duration) * radius_time;
            }

            draw_list->AddCircleFilled(*it.pos, it.radius, animation::get_alpha_changed_color(active_color, alpha), 0xFF);

            if (alpha <= 0)
                it.pos = {};
        }
    }
    draw_list->PopClipRect();

    std::string text = get_text_before_hashtag();
    ImVec2 text_size = ImGui::CalcTextSize(text.c_str());
    ImVec2 text_align = ImGui::GetStyle().ButtonTextAlign;

    ImGui::SetCursorScreenPos({ pos.x + ((size.x - text_size.x) * text_align.x), pos.y + ((size.y - text_size.y) * text_align.y) });
    ImGui::TextUnformatted(text.c_str());
    ImGui::SetCursorPos(cursor_pos);

    if (ImGui::InvisibleButton(label.c_str(), size)) {
        it.radius = 0;
        it.pos = ImGui::GetMousePos();
        it.time[0] = now;
        it.time[1] = now + durations[0];
        clicked = true;
    }

    it.hovered_state_current = ImGui::IsItemHovered() || now - it.time[1] <= 0ms;

    if (it.hovered_state_current != it.hovered_state_before) {
        log::info("now!");
        it.hovered_state_before = it.hovered_state_current;
        it.hovered_time = now;
    }

    return clicked;
}

plugin::gui::widgets::button::button(const std::string_view& new_label) : label(std::move(new_label)) {
    ImVec2 text_size = ImGui::CalcTextSize(label.c_str(), nullptr, true);
    ImVec2 frame_padding = ImGui::GetStyle().FramePadding;
    
    size = { text_size.x + frame_padding.x * 2, text_size.y + frame_padding.y * 2 };

    register_in_pool();
}
