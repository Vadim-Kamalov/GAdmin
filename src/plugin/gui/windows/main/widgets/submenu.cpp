#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/gui.h"
#include "plugin/string_utils.h"
#include <ranges>

auto plugin::gui::windows::main::widgets::submenu::add_entry(const std::string_view& label, const std::any& payload) -> void {
    entries.emplace_back(std::string(label), std::move(payload));
}

auto plugin::gui::windows::main::widgets::submenu::set_frame_renderer(frame_renderer_t new_frame_renderer) -> void {
    frame_renderer = std::move(new_frame_renderer);
}

auto plugin::gui::windows::main::widgets::submenu::render_menu(types::not_null<initializer*> child) -> void {
    float child_width = (child_width_percent * child->window_size.x) / 100.0f;

    ImGui::BeginChild(label.c_str(), { child_width, 0 }, ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
    {
        gui::widgets::text(child->child->fonts->bold, title_font_size, 0, "{}",
                           string_utils::truncate_until_hashtag(label));
        
        for (const auto& [ index, entry ] : entries | std::views::enumerate) {
            ImVec2 size = { ImGui::GetContentRegionAvail().x, (switch_button_percent * child->window_size.y) / 100.0f };
            
            if (!gui::widgets::button(entry.label + "##submenu::" + std::to_string(index), size).render() || index == future_entry_index)
                continue;

            future_entry_index = index;
            time_clicked = std::chrono::steady_clock::now();
        }
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::main::widgets::submenu::render_current_frame(types::not_null<initializer*> child) -> void {
    auto now = std::chrono::steady_clock::now();

    if (now - time_clicked <= fade_in_out_duration) {
        bool change_animation_duration = now - time_clicked > fade_in_duration;
        std::chrono::milliseconds animation_duration = fade_in_duration;

        if (change_animation_duration) {
            current_entry_index = future_entry_index;
            animation_duration = fade_out_duration;
        }

        frame_alpha = animation::bring_to(frame_alpha, static_cast<float>(change_animation_duration),
                                          time_clicked, animation_duration);
    }

    ImU32 child_bg_color = ImGui::GetColorU32(ImGuiCol_ChildBg);
    ImU32 window_bg_color = ImGui::GetColorU32(ImGuiCol_WindowBg);
    
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, frame_alpha * ImGui::GetStyle().Alpha);
    ImGui::PushStyleColor(ImGuiCol_ChildBg, window_bg_color);
    ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, window_bg_color);
    ImGui::BeginChild((label + "::current_frame").c_str(), { 0, 0 }, ImGuiChildFlags_None, child->window_flags);
    {
        ImGui::PushStyleColor(ImGuiCol_ChildBg, child_bg_color);
        {
            entry_t& entry = entries[current_entry_index];
            frame_renderer(entry.label, entry.payload);
        }
        ImGui::PopStyleColor();
    }
    ImGui::EndChild();
    ImGui::PopStyleVar();
    ImGui::PopStyleColor(2);
}
