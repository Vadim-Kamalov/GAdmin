#include "plugin/gui/windows/main/custom_settings/double_line_input.h"
#include <imgui.h>
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::custom_settings::double_line_input::render(types::not_null<gui_initializer*> gui, nlohmann::json& setter) -> void {
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;

    float frame_height = ImGui::GetFrameHeight();
    float items_count = setter.size();
    float child_height = window_padding.y * 2 + placeholder_font_size + (frame_height + item_spacing.y) * items_count;

    ImGui::BeginChild(get_id(), { 0, child_height }, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        float half_item_width = (ImGui::GetContentRegionAvail().x - item_spacing.x) / 2.0f;

        ImGui::PushFont(gui->fonts->bold, placeholder_font_size);
        {
            ImGui::TextUnformatted(placeholders.first.c_str());
            ImGui::SameLine(half_item_width + item_spacing.x + window_padding.x);
            ImGui::TextUnformatted(placeholders.second.c_str());
        }
        ImGui::PopFont();

        for (std::size_t index = 0; index < items_count; index++) {
            std::string ids[2] = { std::format("##{}[{}][0]", get_id(), index),
                                   std::format("##{}[{}][1]", get_id(), index) };
            
            nlohmann::json& object = setter[index];
            std::string* left = &object[keys.first].get_ref<std::string&>();
            std::string* right = &object[keys.second].get_ref<std::string&>();

            ImGui::SetNextItemWidth(half_item_width);
            ImGui::InputTextWithHint(ids[0].c_str(), placeholders.first.c_str(), left);
            ImGui::SameLine();
            ImGui::SetNextItemWidth(half_item_width);
            ImGui::InputTextWithHint(ids[1].c_str(), placeholders.second.c_str(), right);
        }
    }
    ImGui::EndChild();
}
