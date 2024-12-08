#include "plugin/gui/widgets/menu_selector.h"
#include "plugin/gui/animation.h"

void
plugin::gui::widgets::menu_selector(utils::not_null<windows::Main*> child) noexcept {
    ImVec4 default_color = ImGui::GetStyle().Colors[ImGuiCol_ChildBg],
           hovered_color = ImGui::GetStyle().Colors[ImGuiCol_ButtonHovered];

    static MenuSelectorAnimation it = { .color = default_color };
    
    ImVec2 size = { child->menu_min_width, child->menu_min_width };
    ImVec2 cursor = ImGui::GetCursorScreenPos();
    float rounding = ImGui::GetStyle().ChildRounding;
    auto now = std::chrono::steady_clock::now();

    if (ImGui::InvisibleButton("widgets::menu_selector", { child->menu_width, size.y })) {
        child->menu_opened ^= true;
        it.click_time = now;
    }

    it.hovered_state_current = ImGui::IsItemHovered();

    if (it.hovered_state_previous != it.hovered_state_current) {
        it.hovered_state_previous = it.hovered_state_current;
        it.hovered_time = now;
    }

    if (animation::time_available(it.hovered_time)) {
        if (now - it.hovered_time <= it.duration)
            it.color = animation::bring_to(it.color, (it.hovered_state_current) ? hovered_color : default_color, it.hovered_time, it.duration);
        else
            it.color = (it.hovered_state_current) ? hovered_color : default_color;
    }

    if (animation::time_available(it.click_time)) {
        float to = (child->menu_opened) ? child->menu_max_width : child->menu_min_width;
        child->menu_width = animation::bring_to(child->menu_width, to, it.click_time, child->menu_open_duration);
    }

    ImGui::GetWindowDrawList()->AddRectFilled(cursor, { cursor.x + child->menu_width, cursor.y + size.y },
                                              ImGui::GetColorU32(it.color), rounding, ImDrawFlags_RoundCornersTopLeft);

    GraphicalUserInterface* gui = child->child;

    gui->fonts->icon->push(24);
    {
        ImVec2 icon_size = ImGui::CalcTextSize(ICON_HAMBURGER_M_D);
        ImGui::SetCursorPos({ (size.x - icon_size.x) / 2, (size.y - icon_size.y) / 2 });
        ImGui::Text(ICON_HAMBURGER_M_D);
    }
    gui->fonts->pop();
}
