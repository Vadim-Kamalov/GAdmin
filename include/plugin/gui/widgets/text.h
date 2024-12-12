#ifndef GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
#define GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H

#include <cstdint>
#include <format>
#include <imgui.h>

namespace plugin::gui::widgets {

struct TextConfiguration {
    ImFont* font = nullptr;
    std::uint8_t border_size = 0;
    ImVec4 text_color = ImGui::GetStyle().Colors[ImGuiCol_Text],
           border_color = { 0, 0, 0, 1 };

    const char* text;

    void render() const;
}; // struct TextConfiguration

template<typename... Args>
static void
text(ImFont* font, std::uint8_t border_size, std::format_string<Args...> fmt, Args&&... args) {
    TextConfiguration {
        .font = font,
        .border_size = border_size,
        .text = std::format(fmt, std::forward<Args>(args)...).c_str()
    }.render();
}

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_TEXT_H
