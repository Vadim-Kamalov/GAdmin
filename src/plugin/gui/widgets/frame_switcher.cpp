#include "plugin/gui/widgets/frame_switcher.h"
#include "plugin/gui/animation.h"

using namespace plugin::gui;
using namespace std::literals;

struct frame_switcher_settings {
    ImVec4 color;
    bool hovered_state_previous, hovered_state_current = false;
    
    std::chrono::steady_clock::time_point time[2], hovered_time, clicked_time;
    std::chrono::milliseconds clicked_duration = 200ms;
    std::chrono::milliseconds hovered_duration = 400ms;

    struct colors {
        ImVec4 background = ImGui::GetStyle().Colors[ImGuiCol_ChildBg];
        ImVec4 hovered = ImGui::GetStyle().Colors[ImGuiCol_FrameBgHovered];
        ImVec4 clicked = ImGui::GetStyle().Colors[ImGuiCol_FrameBgActive];
        ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_Text];
    }; // struct colors
}; // struct frame_switcher_settings

static frame_switcher_settings&
get_settings(const std::string_view& id, ImVec4 default_color) {
    static std::unordered_map<std::string_view, frame_switcher_settings> entries;

    if (entries.find(id) == entries.end())
        entries.emplace(id, frame_switcher_settings { default_color });

    return entries[id];
}

static void
draw_text(ImDrawList* draw_list, const ImVec2& pos, const ImVec2& size, const char* text, ImFont* font, ImU32 color) noexcept {
    ImVec2 text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, text);
    draw_list->AddText(font, font->FontSize, pos, color, text);
}

static void
update_color(frame_switcher_settings& it, const frame_switcher_settings::colors& colors,
             plugin::utils::not_null<windows::main*> child, const windows::main::frame& frame) noexcept
{
    if (child->current_frame == frame) {
        it.color = animation::bring_to(it.color, colors.clicked, it.time[0], it.hovered_duration);
        return;
    }
    
    auto now = std::chrono::steady_clock::now();

    it.hovered_state_current = ImGui::IsItemHovered() || now - it.time[1] < std::chrono::milliseconds(0);

    if (it.hovered_state_current != it.hovered_state_previous) {
        it.hovered_state_previous = it.hovered_state_current;
        it.hovered_time = now;
    }

    it.color = animation::bring_to(it.color, (it.hovered_state_current) ? colors.hovered : colors.background,
                                   it.hovered_time, it.hovered_duration);
}

static void
draw_frame(const ImVec2& size, const ImVec4& color, plugin::utils::not_null<windows::main*> child,
           const windows::main::frame& frame) noexcept
{
    plugin::gui_initializer* gui = child->child;
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 cursor = ImGui::GetCursorScreenPos();

    draw_list->AddRectFilled(cursor, { cursor.x + size.x, cursor.y + size.y }, ImGui::GetColorU32(color));

    const char* text = child->frame_labels[std::to_underlying(frame)];
    const char* icon = child->frame_icons[std::to_underlying(frame)];
    ImFont *icon_font = (*gui->fonts->icon)[24], *bold_font = (*gui->fonts->bold)[18];
    ImU32 text_color = ImGui::GetColorU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

    draw_text(draw_list, cursor, { child->menu_min_width, size.y }, icon, icon_font, text_color);
    draw_text(draw_list, { cursor.x + child->menu_min_width + ImGui::GetStyle().ItemSpacing.x, cursor.y },
              size, text, bold_font, text_color);
}

void
plugin::gui::widgets::frame_switcher(const windows::main::frame& frame, utils::not_null<windows::main*> child) {
    std::string id = std::format("widgets::frame_switcher::{}", std::to_underlying(frame));

    frame_switcher_settings::colors colors;
    frame_switcher_settings& it = get_settings(id, (child->current_frame == frame) ? colors.clicked : colors.background);

    ImVec2 size = { child->menu_width, 30 };
    auto now = std::chrono::steady_clock::now();

    if (ImGui::InvisibleButton(id.c_str(), size) && child->current_frame != frame) {
        it.time[0] = it.clicked_time = now;
        it.time[1] = now + it.clicked_duration;
        child->current_frame = frame;
    }

    update_color(it, colors, child, frame);
    draw_frame(size, it.color, child, frame);
}
