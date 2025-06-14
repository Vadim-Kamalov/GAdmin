#include "plugin/gui/widgets/menu_selector.h"
#include "plugin/gui/animation.h"

using namespace plugin::gui;
using namespace std::literals;

struct menu_selector_animation final {
    static inline std::chrono::milliseconds duration = 500ms;
    
    ImVec4 color;
    bool hovered_state_current = false, hovered_state_previous = false;
    std::chrono::steady_clock::time_point hovered_time, click_time;

    struct colors final {
        ImVec4 background = ImGui::GetStyle().Colors[ImGuiCol_ChildBg];
        ImVec4 hovered = ImGui::GetStyle().Colors[ImGuiCol_ButtonHovered];
    }; // struct colors final
}; // struct menu_selector_animation final

static auto update_color(menu_selector_animation& it, const menu_selector_animation::colors& colors)
    noexcept -> void
{
    auto now = std::chrono::steady_clock::now();

    it.hovered_state_current = ImGui::IsItemHovered();

    if (it.hovered_state_previous != it.hovered_state_current) {
        it.hovered_state_previous = it.hovered_state_current;
        it.hovered_time = now;
    }

    if (!animation::is_time_available(it.hovered_time))
        return;

    if (now - it.hovered_time <= it.duration) {
        ImVec4 to = (it.hovered_state_current) ? colors.hovered : colors.background;
        it.color = animation::bring_to(it.color, to, it.hovered_time, it.duration);
        
        return;
    }

    it.color = (it.hovered_state_current) ? colors.hovered : colors.background;
}

static auto update_menu_width(menu_selector_animation& it, plugin::types::not_null<windows::main*> child)
    noexcept -> void
{
    if (!animation::is_time_available(it.click_time))
        return;

    float to = (child->menu_opened) ? child->menu_max_width : child->menu_min_width;
    child->menu_width = animation::bring_to(child->menu_width, to, it.click_time, child->menu_open_duration);
}

static auto draw_frame(const ImVec2& size, const ImVec4& color, plugin::types::not_null<windows::main*> child)
    noexcept -> void
{
    plugin::gui_initializer* gui = child->child;
    ImVec2 pos = ImGui::GetWindowPos();
    float rounding = ImGui::GetStyle().ChildRounding;

    ImGui::GetWindowDrawList()->AddRectFilled(pos, { pos.x + child->menu_width, pos.y + size.y },
                                              ImGui::GetColorU32(color), rounding, ImDrawFlags_RoundCornersTopLeft);

    ImGui::PushFont(gui->fonts->icon, 24);
    {
        ImVec2 icon_size = ImGui::CalcTextSize(ICON_HAMBURGER_M_D);
        ImGui::SetCursorPos({ (size.x - icon_size.x) / 2, (size.y - icon_size.y) / 2 });
        ImGui::Text(ICON_HAMBURGER_M_D);
    }
    ImGui::PopFont();
}

auto plugin::gui::widgets::menu_selector(types::not_null<windows::main*> child) noexcept -> void {
    static menu_selector_animation::colors colors;
    static menu_selector_animation it = { colors.background };
    
    if (ImGui::InvisibleButton("widgets::menu_selector", { child->menu_width, child->menu_min_width })) {
        it.click_time = std::chrono::steady_clock::now();
        child->menu_opened ^= true;
    }

    update_color(it, colors);
    update_menu_width(it, child);
    draw_frame({ child->menu_min_width, child->menu_min_width }, it.color, child);
}
