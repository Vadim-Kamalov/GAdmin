/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

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
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, (window_alpha / 255.0f) * (child->window_alpha / 255.0f));
    ImGui::Begin(id.c_str(), nullptr, flags);
    {
        ImGui::BeginGroup();
        {
            renderer();
            ImGui::PushFont(child->child->fonts->bold);
            {
                if (gui::widgets::button("Закрыть##widgets::popup::" + id, { ImGui::GetContentRegionAvail().x, close_button_height })
                        .render())
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
