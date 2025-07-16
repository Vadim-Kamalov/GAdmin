#include "plugin/gui/windows/main/frames/key_binds.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/hotkey.h"
#include <ranges>

auto plugin::gui::windows::main::frames::key_binds::get_buttons_size() -> ImVec2 {
    return {
        (buttons_size_percentage.x * child->window_size.x) / 100.0f, 
        (buttons_size_percentage.y * child->window_size.y) / 100.0f
    };
}

auto plugin::gui::windows::main::frames::key_binds::render() -> void {
    buttons_size = get_buttons_size();

    widgets::text(bold_font, title_font_size, 0, "Горячие клавиши");
    ImGui::SameLine(0, 5);
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 4);
    ImGui::PushFont(regular_font, common_font_size);
    {
        ImGui::TextDisabled("ПКМ - детальная настройка хоткея");

        float longest_item_width = 0;
        float cursor_offset_x = 0;
        float start_cursor_pos_y = ImGui::GetCursorPosY();
        ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    
        std::deque<hotkey>& hotkey_pool = child->child->hotkey_handler->pool;
        
        std::size_t hotkey_pool_size = hotkey_pool.size();
        std::size_t group_index = 0;
        std::size_t items_in_grop_count = (child->window_size.y - ImGui::GetCursorPosY()
                - child->window_padding.y + item_spacing.y) / (buttons_size.y + item_spacing.y);

        for (const auto& [ index, hotkey ] : child->child->hotkey_handler->pool | std::views::enumerate) {
            ImVec2 label_size = ImGui::CalcTextSize(hotkey.label.c_str());
            ImVec2 item_size = { buttons_size.x + item_spacing.x + label_size.x, buttons_size.y };
            
            if (longest_item_width < item_size.x)
                longest_item_width = item_size.x;

            ImGui::SetCursorPosX(ImGui::GetCursorPosX() + cursor_offset_x);
            ImGui::BeginGroup();
            {
                hotkey.render(buttons_size);
                ImGui::SameLine();
                ImGui::SetCursorPosY(ImGui::GetCursorPosY() + (item_size.y - label_size.y) / 2);
                ImGui::TextUnformatted(hotkey.label.c_str());
            }
            ImGui::EndGroup();

            if (((index + 1) - items_in_grop_count * group_index) % items_in_grop_count == 0) {
                cursor_offset_x += longest_item_width + item_spacing.x;
                group_index++;
                ImGui::SetCursorPosY(start_cursor_pos_y);
            }
        }
    }
    ImGui::PopFont();
}
