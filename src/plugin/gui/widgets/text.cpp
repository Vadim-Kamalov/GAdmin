#include "plugin/gui/widgets/text.h"

static auto render_border(const ImVec2& pos, const ImVec4& border_color, std::uint8_t border_size, plugin::types::zstring_t text)
    noexcept -> void
{
    ImGui::PushStyleColor(ImGuiCol_Text, border_color);
    {
        for (std::uint8_t i = 1; i <= border_size; i++) {
            ImGui::SetCursorPos({ pos.x + i, pos.y });
            ImGui::TextUnformatted(text);
            ImGui::SetCursorPos({ pos.x - i, pos.y });
            ImGui::TextUnformatted(text);
            ImGui::SetCursorPos({ pos.x, pos.y + i });
            ImGui::TextUnformatted(text);
            ImGui::SetCursorPos({ pos.x, pos.y - i });
            ImGui::TextUnformatted(text);
        }
    }
    ImGui::PopStyleColor();
}

auto plugin::gui::widgets::basic_text::render() const -> void {
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
