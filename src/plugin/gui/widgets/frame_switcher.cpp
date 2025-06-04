#include "plugin/gui/widgets/frame_switcher.h"
#include "plugin/gui/animation.h"
#include <utility>

using namespace plugin::gui;
using namespace std::literals;

struct frame_switcher_settings final {
    static inline std::chrono::milliseconds clicked_duration = 200ms;
    static inline std::chrono::milliseconds hovered_duration = 400ms;
    
    ImVec4 color;
    bool hovered_state_previous = false, hovered_state_current = false;
    std::chrono::steady_clock::time_point time[2], hovered_time, clicked_time;

    struct colors_t {
        ImVec4 background = ImGui::GetStyle().Colors[ImGuiCol_ChildBg];
        ImVec4 hovered = ImGui::GetStyle().Colors[ImGuiCol_FrameBgHovered];
        ImVec4 clicked = ImGui::GetStyle().Colors[ImGuiCol_FrameBgActive];
        ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_Text];
    } colors; // struct colors_t
}; // struct frame_switcher_settings final

static auto get_settings(const std::string& id, const windows::main::frame& current_frame, const windows::main::frame& frame)
    noexcept -> frame_switcher_settings&
{
    static std::unordered_map<std::string, frame_switcher_settings> entries;

    if (entries.find(id) == entries.end()) {
        frame_switcher_settings settings;
        settings.color = (current_frame == frame) ? settings.colors.clicked : settings.colors.background;
        entries.emplace(id, settings);
    }

    return entries[id];
}

static auto update_color(frame_switcher_settings& it, plugin::types::not_null<windows::main*> child, const windows::main::frame& frame)
    noexcept -> void
{
    if (child->current_frame == frame) {
        it.color = animation::bring_to(it.color, it.colors.clicked, it.time[0], it.hovered_duration);
        return;
    }
    
    auto now = std::chrono::steady_clock::now();

    it.hovered_state_current = ImGui::IsItemHovered() || now - it.time[1] < 0ms;

    if (it.hovered_state_current != it.hovered_state_previous) {
        it.hovered_state_previous = it.hovered_state_current;
        it.hovered_time = now;
    }

    it.color = animation::bring_to(it.color, (it.hovered_state_current) ? it.colors.hovered : it.colors.background,
                                   it.hovered_time, it.hovered_duration);
}

static auto draw_frame(const ImVec2& pos, const ImVec2& size, const frame_switcher_settings& it,
                       plugin::types::not_null<windows::main*> child, const windows::main::frame& frame)
    noexcept -> void
{
    plugin::gui_initializer* gui = child->child;
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    draw_list->AddRectFilled(pos, { pos.x + size.x, pos.y + size.y }, ImGui::GetColorU32(it.color));

    plugin::types::zstring_t text = child->frame_labels[std::to_underlying(frame)];
    plugin::types::zstring_t icon = child->frame_icons[std::to_underlying(frame)];
    ImFont *icon_font = (*gui->fonts->icon)[24], *bold_font = (*gui->fonts->bold)[18];
    ImVec2 icon_size = icon_font->CalcTextSizeA(icon_font->FontSize, FLT_MAX, 0, icon);
    ImVec2 text_size = bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0, text);
    ImU32 text_color = ImGui::GetColorU32(it.colors.text);

    draw_list->AddText(icon_font, icon_font->FontSize, { pos.x + (child->menu_min_width - icon_size.x) / 2,
                                                         pos.y + (size.y - icon_size.y) / 2 }, text_color, icon);

    draw_list->AddText(bold_font, bold_font->FontSize, { pos.x + child->menu_min_width + ImGui::GetStyle().ItemSpacing.x,
                                                         pos.y + (size.y - text_size.y) / 2 }, text_color, text);
}

auto plugin::gui::widgets::frame_switcher(const windows::main::frame& frame, types::not_null<windows::main*> child) -> void {
    std::string id = std::format("widgets::frame_switcher::{}", std::to_underlying(frame));
    ImVec2 size = { child->menu_width, 30 }, pos = ImGui::GetCursorScreenPos();
    auto now = std::chrono::steady_clock::now();
    
    frame_switcher_settings& it = get_settings(id, child->current_frame, frame);

    if (ImGui::InvisibleButton(id.c_str(), size) && child->current_frame != frame) {
        it.time[0] = it.clicked_time = now;
        it.time[1] = now + it.clicked_duration;
        child->current_frame = frame;
    }

    update_color(it, child, frame);
    draw_frame(pos, size, it, child, frame);
}
