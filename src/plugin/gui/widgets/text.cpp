#include "plugin/gui/widgets/text.h"

static void
render_border(const ImVec2& pos, const ImVec4& border_color, std::uint8_t border_size, const char* text) noexcept {
    for (std::uint8_t i = 1; i <= border_size; i++) {
        ImGui::SetCursorPos({ pos.x + i, pos.y });
        ImGui::TextColored(border_color, "%s", text);
        ImGui::SetCursorPos({ pos.x - i, pos.y });
        ImGui::TextColored(border_color, "%s", text);
        ImGui::SetCursorPos({ pos.x, pos.y + i });
        ImGui::TextColored(border_color, "%s", text);
        ImGui::SetCursorPos({ pos.x, pos.y - i });
        ImGui::TextColored(border_color, "%s", text);
    }
}

void
plugin::gui::widgets::basic_text::render() const {
    ImVec2 pos = ImGui::GetCursorPos();

    if (font)
        ImGui::PushFont(font);
    
    ImGui::BeginGroup();
    {
        render_border(pos, colors.border, border_size, text);
        ImGui::SetCursorPos(pos);
        ImGui::TextColored(colors.text, "%s", text);
    }
    ImGui::EndGroup();

    if (font)
        ImGui::PopFont();
}
