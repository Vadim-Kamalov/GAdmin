#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/gui.h"
#include <imgui.h>

auto plugin::gui::windows::main::widgets::popup::open() -> void {
    time = std::chrono::steady_clock::now();
    active = true;
}

auto plugin::gui::windows::main::widgets::popup::close() -> void {
    time = std::chrono::steady_clock::now();
    closing = true;
}

auto plugin::gui::windows::main::widgets::popup::set_renderer(renderer_t new_renderer) -> void {
    renderer = std::move(new_renderer);
}

auto plugin::gui::windows::main::widgets::popup::render(types::not_null<initializer*> child) -> void {
    if (!active)
        return;

    auto flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize;
    ImVec2 pos = { child->window_pos.x + child->window_size.x / 2.0f, child->window_pos.y + child->window_size.y / 2.0f };
    ImVec2 size = { content_size.x + child->window_padding.x * 2, content_size.y + child->window_padding.y * 2 };

    child->window_flags |= ImGuiWindowFlags_NoInputs;

    ImGui::SetNextWindowPos(pos, ImGuiCond_Always, { 0.5f, 0.5f });
    ImGui::SetNextWindowSize(size);
    ImGui::SetNextWindowFocus();
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.0f);
    ImGui::Begin(id.c_str(), nullptr, flags);
    {
        ImGui::BeginGroup();
        {
            renderer();
            ImGui::PushFont(child->child->fonts->bold);
            {
                if (gui::widgets::button("Закрыть##widgets::popup::" + id, { ImGui::GetContentRegionAvail().x, close_button_height })
                        .with_durations({ 200ms, 0ms, 0ms }).render() && window_alpha == 255.0f)
                {
                    close();
                }
            }
            ImGui::PopFont();
        }
        ImGui::EndGroup();
        content_size = ImGui::GetItemRectSize();
    }
    ImGui::End();
    ImGui::PopStyleVar();
    
    child->window_items_alpha = animation::bring_to(child->window_items_alpha, (closing) ? 255 : 100, time, animation_duration);
    window_alpha = animation::bring_to(window_alpha, (closing) ? 0 : 255, time, animation_duration);

    if (window_alpha == 0 && closing) {
        closing = active = false;
        child->window_flags &= ~ImGuiWindowFlags_NoInputs;
    }
}
