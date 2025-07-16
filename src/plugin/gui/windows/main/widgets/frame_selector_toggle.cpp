#include "plugin/gui/windows/main/widgets/frame_selector_toggle.h"

auto plugin::gui::windows::main::widgets::frame_selector_toggle::handle_hover_animation() -> void {
    types::color hovered_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_ButtonHovered]);
    types::color background_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_ChildBg]);
    
    hover_info.update();

    current_color = animation::bring_to(current_color, (hover_info.state) ? hovered_color : background_color,
                                        hover_info.time, animation_duration);
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::render_rect_with_icon() -> void {
    ImVec2 start = ImGui::GetItemRectMin();
    ImVec2 end = ImGui::GetItemRectMax();

    ImGui::GetWindowDrawList()->AddRectFilled(start, end, *current_color, ImGui::GetStyle().ChildRounding,
                                              ImDrawFlags_RoundCornersTopLeft);

    ImGui::PushFont(icon_font, icon_font_size);
    {
        ImVec2 icon_size = ImGui::CalcTextSize(icon);
        float button_height = child->state_width.first;
        
        ImGui::SetCursorPos({ (button_height - icon_size.x) / 2.0f, (button_height - icon_size.y) / 2.0f });
        ImGui::TextUnformatted(icon);
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::update_menu_width() -> void {
    child->width = animation::bring_to(child->width, (child->state) ? child->state_width.second : child->state_width.first,
                                       time_clicked, width_change_duration);
}

auto plugin::gui::windows::main::widgets::frame_selector_toggle::render() -> void {
    if (ImGui::InvisibleButton("widgets::frame_selector_toggle", { child->width, child->state_width.first })) {
        time_clicked = std::chrono::steady_clock::now();
        child->state ^= true;
    }

    handle_hover_animation();
    render_rect_with_icon();
    update_menu_width();
}
