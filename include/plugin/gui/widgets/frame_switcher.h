#ifndef GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
#define GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H

#include "plugin/gui/animation.h"
#include "plugin/gui/windows/main.h"
#include "plugin/utils.h"
#include <utility>

namespace plugin::gui::widgets {

struct FrameSwitcherConfiguration {
    ImVec4 color;
    bool hovered_state_current = false, hovered_state_previous;
    std::chrono::steady_clock::time_point time[2] = { {}, {} }, hovered_time, clicked_time;
    std::chrono::milliseconds clicked_duration = std::chrono::milliseconds(200),
                              hovered_duration = std::chrono::milliseconds(400);
}; // struct FrameSwitcherConfiguration

template<windows::Main::SelectedFrame Frame>
void
frame_switcher(utils::not_null<windows::Main*> child) noexcept {
    static std::unordered_map<std::string, FrameSwitcherConfiguration> entries;

    std::string id = std::format("widgets::frame_switcher::{}", std::to_underlying(Frame));
    ImVec4 default_color = ImGui::GetStyle().Colors[ImGuiCol_ChildBg],
           hovered_color = ImGui::GetStyle().Colors[ImGuiCol_FrameBgHovered],
           clicked_color = ImGui::GetStyle().Colors[ImGuiCol_FrameBgActive],
           text_color = ImGui::GetStyle().Colors[ImGuiCol_Text];

    if (entries.find(id) == entries.end())
        entries.emplace(id, FrameSwitcherConfiguration { .color = (child->selected_frame == Frame) ? clicked_color : default_color });

    FrameSwitcherConfiguration& it = entries[id];
    ImVec2 cursor = ImGui::GetCursorScreenPos(), size = { child->menu_width, 30 };
    auto now = std::chrono::steady_clock::now();

    if (ImGui::InvisibleButton(id.c_str(), size) && child->selected_frame != Frame) {
        it.time[0] = it.clicked_time = now;
        it.time[1] = now + it.clicked_duration;
        child->selected_frame = Frame;
    }

    if (child->selected_frame == Frame)
        it.color = animation::bring_to(it.color, clicked_color, it.time[0], it.hovered_duration);
    else {
        it.hovered_state_current = ImGui::IsItemHovered() || now - it.time[1] < std::chrono::milliseconds(0);
        
        if (it.hovered_state_current != it.hovered_state_previous) {
            it.hovered_state_previous = it.hovered_state_current;
            it.hovered_time = now;
        }

        it.color = animation::bring_to(it.color, (it.hovered_state_current) ? hovered_color : default_color,
                                       it.hovered_time, it.hovered_duration);
    }
    
    GraphicalUserInterface* gui = child->child;
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    draw_list->AddRectFilled(cursor, { cursor.x + size.x, cursor.y + size.y }, ImGui::GetColorU32(it.color));

    const char *text = child->frame_labels[std::to_underlying(Frame)], *icon = child->frame_icons[std::to_underlying(Frame)];
    ImFont *icon_font = (*gui->fonts->icon)[24], *light_font = (*gui->fonts->bold)[18];
    ImU32 color = ImGui::GetColorU32(text_color);
    ImVec2 icon_size = icon_font->CalcTextSizeA(icon_font->FontSize, FLT_MAX, 0, icon),
           text_size = light_font->CalcTextSizeA(light_font->FontSize, FLT_MAX, 0, text);

    draw_list->AddText(icon_font, icon_font->FontSize, { cursor.x + (child->menu_min_width - icon_size.x) / 2,
            cursor.y + (size.y - icon_size.y) / 2 }, color, icon);

    draw_list->AddText(light_font, light_font->FontSize, { cursor.x + child->menu_min_width + ImGui::GetStyle().ItemSpacing.x,
        cursor.y + (size.y - text_size.y) / 2 }, color, text);
}

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
