#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H

#include "plugin/utils.h"
#include <cstdint>
#include <format>
#include <imgui.h>

namespace plugin::gui::widgets {

struct basic_text {
    utils::zstring_t text;
    std::uint8_t border_size = 0;
    ImFont* font;

    struct colors_t {
        ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_Text];
        ImVec4 border = { 0, 0, 0, 1 };
    } colors;

    void render() const;
}; // struct basic_text

template<typename... Args>
static void
text(ImFont* font, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args) noexcept {
    basic_text {
        .text = std::format(fmt, std::forward<Args>(args)...).c_str(),
        .border_size = border_size,
        .font = font
    }.render();
}

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
