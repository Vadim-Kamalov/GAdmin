#include "plugin/gui/widgets/text.h"

void
plugin::gui::widgets::TextConfiguration::render() const {
    ImVec2 pos = ImGui::GetCursorPos();

    if (font)
        ImGui::PushFont(font);
    
    ImGui::BeginGroup();
    {
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

        ImGui::SetCursorPos(pos);
        ImGui::TextColored(text_color, "%s", text);
    }
    ImGui::EndGroup();

    if (font)
        ImGui::PopFont();
}
