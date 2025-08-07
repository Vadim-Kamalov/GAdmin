#include "plugin/gui/widgets/button.h"
#include "plugin/string_utils.h"

auto plugin::gui::widgets::button::register_in_pool() const -> void {
    if (pool.contains(id))
        return;

    pool[id] = {};
}

auto plugin::gui::widgets::button::render() -> bool {
    configuration_t& it = pool[id];
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    types::color button_color = ImGui::GetColorU32(ImGuiCol_Button);
    types::color button_active = ImGui::GetColorU32(ImGuiCol_ButtonActive);
    types::color hovered_color = ImGui::GetColorU32(ImGuiCol_ButtonHovered, it.border_alpha / 255.0f);

    float rounding = ImGui::GetStyle().FrameRounding;
    float border_size = ImGui::GetStyle().FrameBorderSize;

    ImVec2 start = ImGui::GetCursorScreenPos();
    ImVec2 end = { start.x + size.x, start.y + size.y };

    draw_list->AddRectFilled(start, end, *button_color, rounding, draw_flags);

    ImVec2 border_start = { start.x - border_size, start.y - border_size };
    ImVec2 border_end = { end.x + border_size, end.y + border_size };

    draw_list->AddRect(border_start, border_end, *hovered_color, rounding, draw_flags, border_size);

    it.border_alpha = animation::bring_to(it.border_alpha, (it.hovered.state) ? 255 : 0, it.hovered.time, durations[0]);

    if (it.click_position.has_value()) {
        ImVec2 clip_rect_min = { start.x + border_size, start.y + border_size };
        ImVec2 clip_rect_max = { end.x - border_size, end.y - border_size };

        // The current implementation of the circle rendering inside the rectangle
        // is done using Push/PopClipRect functions. Note that parts of the circle that
        // are within the rectangle (in the area where the rectangle is rounded) will still
        // be drawn because region clipping is done (in Dear ImGui) using scissoring rectangles.
        //
        // There is currently no better implementation. However, if one is found, you would
        // need to draw the intersection of a circle and a rounded rectangle manually.
        //
        // In the future, the following resources may help to draw the intersection:
        //
        //  https://mathworld.wolfram.com/Circle-CircleIntersection.html
        //  https://mathworld.wolfram.com/Circle-LineIntersection.html
        //
        // Either way, the implementation will be extremely challenging.
        draw_list->PushClipRect(clip_rect_min, clip_rect_max, true);
        {
            it.alpha = animation::bring_to(it.alpha, 1.00, it.click_time, durations[1]);
            it.radius = animation::bring_to(it.radius, std::max(size.x, size.y), it.click_time, durations[1] + durations[2]);

            if (std::chrono::steady_clock::now() >= it.click_time + durations[1])
                it.alpha = animation::bring_to(it.alpha, 0.00, it.click_time + durations[1], durations[2]);
        
            draw_list->AddCircleFilled(*it.click_position, it.radius, *types::color(button_active, it.alpha * 255), 0xFF);
        }
        draw_list->PopClipRect();    

        if (it.alpha == 0.00) {
            it.click_position = {};
            it.radius = 0;
        }
    }

    std::string text = string_utils::truncate_until_hashtag(label);

    if (!text.empty()) {
        ImVec2 text_size = ImGui::CalcTextSize(text.c_str());
        ImVec2 text_align = ImGui::GetStyle().ButtonTextAlign;
        ImVec2 text_pos = { start.x + ((size.x - text_size.x) * text_align.x),
                            start.y + ((size.y - text_size.y) * text_align.y) };

        draw_list->AddText(text_pos, ImGui::GetColorU32(ImGuiCol_Text), text.c_str());
    }

    bool result = false;

    if (ImGui::InvisibleButton((text + "##" + id).c_str(), size)) {
        it.radius = 0;
        it.click_time = std::chrono::steady_clock::now();
        it.click_position = ImGui::GetMousePos();
        result = true;
    }

    it.hovered.update();

    return result;
}

plugin::gui::widgets::button::button(const std::string_view& new_label)
    : label(std::move(new_label)),
      id(std::move(new_label))
{
    ImVec2 text_size = ImGui::CalcTextSize(label.c_str(), nullptr, true);
    ImVec2 frame_padding = ImGui::GetStyle().FramePadding;
    
    size = { text_size.x + frame_padding.x * 2, text_size.y + frame_padding.y * 2 };

    register_in_pool();
}
