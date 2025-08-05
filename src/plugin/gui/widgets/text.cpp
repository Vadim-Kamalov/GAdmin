#include "plugin/gui/widgets/text.h"
#include <imgui_internal.h>

static auto render_border(const ImVec2& pos, const ImVec4& border_color, std::uint8_t border_size, plugin::types::zstring_t text)
    noexcept -> void
{
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    ImFont* font = draw_list->_Data->Font;
    float font_size = draw_list->_Data->FontSize;

    // imgui.h does not provide any way to get the current text wrap position without using imgui_internal.h
    float wrap_width = ImGui::CalcWrapWidthForPos(window->DC.CursorPos, window->DC.TextWrapPos);
    ImU32 text_color = ImGui::ColorConvertFloat4ToU32(border_color);

    for (std::uint8_t i = 1; i <= border_size; i++) {
        draw_list->AddText(font, font_size, { pos.x + i, pos.y }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x - i, pos.y }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x, pos.y + i }, text_color, text, nullptr, wrap_width);
        draw_list->AddText(font, font_size, { pos.x, pos.y - i }, text_color, text, nullptr, wrap_width);
    }
}

auto plugin::gui::widgets::basic_text::render() const -> void {
    if (font)
        ImGui::PushFont(font, font_size);

    render_border(ImGui::GetCursorScreenPos(), colors.border, border_size, text);
    ImGui::TextColored(colors.text, "%s", text);

    if (font)
        ImGui::PopFont();
}
