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

#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/animation.h"
#include "plugin/plugin.h"
#include "plugin/string_utils.h"
#include <algorithm>
#include <sstream>

auto plugin::gui::widgets::hint::default_renderer() const -> void {
    std::istringstream stream(string_utils::truncate_until_hashtag(label));
    for (std::string line; std::getline(stream, line);) {
        ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize(line.c_str()).x) / 2);
        ImGui::TextUnformatted(line.c_str());
    }
}

auto plugin::gui::widgets::hint::render_hint(float alpha) const -> void {
    ImVec2 size = ImGui::GetItemRectSize();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    {
        ImVec2 spacing = ImGui::GetStyle().ItemSpacing;
        pos.x += size.x;
        pos.y -= size.y + spacing.y;
    }
    ImVec2 center = { pos.x - size.x / 2, pos.y + size.y / 2 - alpha * 4 + 10 };
    
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, alpha);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 8, 8 });
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 6);
    ImGui::PushStyleColor(ImGuiCol_PopupBg, *color);
    ImGui::PushStyleColor(ImGuiCol_Text, animation::get_contrast_color(ImGui::ColorConvertU32ToFloat4(*color)));
    {
        ImGui::SetNextWindowPos({ center.x, center.y - size.y - 3 }, ImGuiCond_Always, { 0.5, 1 });
        ImGui::SetNextWindowSize({ pool[label].width, -1 }, ImGuiCond_Always);
        
        if (using_custom_renderer)
            ImGui::SetNextWindowFocus();
        
        ImGui::Begin(label.c_str(), nullptr, ImGuiWindowFlags_Tooltip | ImGuiWindowFlags_NoDecoration);
        {
            ImGui::BeginGroup();
            {
                renderer();
            }
            ImGui::EndGroup();
            pool[label].width = ImGui::GetItemRectSize().x + ImGui::GetStyle().WindowPadding.x * 2;
        }
        ImGui::End();
    }
    ImGui::PopStyleVar(3);
    ImGui::PopStyleColor(2);

    ImVec2 a = { center.x - 10, center.y - size.y - 4 };
    ImVec2 b = { center.x + 10, center.y - size.y - 4 };
    ImVec2 c = { center.x, center.y - size.y + 3 };

    ImDrawList* draw_list = ImGui::GetForegroundDrawList();
    std::uint8_t normal_alpha = alpha * 255;
    types::color border_color = types::color(ImGui::GetColorU32(ImGuiCol_Border), normal_alpha);
    
    draw_list->Flags = ImDrawListFlags_AntiAliasedLines * 3;
    draw_list->AddTriangleFilled(a, b, c, *types::color(color, normal_alpha));
    draw_list->AddLine(a, c, *types::color(border_color, normal_alpha));
    draw_list->AddLine({ b.x - 1, b.y }, { c.x - 1, c.y }, *border_color);
}

auto plugin::gui::widgets::hint::render() -> void {
    bool hovered = condition();
    auto now = std::chrono::steady_clock::now();
    bool show = true;

    if (!using_custom_condition) {
        for (const auto& [ id, hint ] : pool) {
            if (id != label && now - hint.time <= show_hide_duration) {
                show = false;
                break;
            }
        }
    }

    if (!pool.contains(label))
        pool[label] = { 0, false, {} }; 

    configuration_t& it = pool[label];

    if (show) {
        if (it.opened != hovered) {
            it.opened = hovered;
            it.time = now;
        }

        auto between = std::chrono::duration_cast<std::chrono::milliseconds>(now - it.time).count();
        auto show_hide_duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(show_hide_duration).count();
        
        if (animation::is_time_available(it.time)) {
            if (it.width == 0) {
                render_hint(0);
                it.time = now;
            } else if (between <= show_hide_duration_ms) {
                render_hint(std::clamp((hovered) ? static_cast<float>(between) / show_hide_duration_ms
                            : 1.0f - static_cast<float>(between) / show_hide_duration_ms, 0.0f, 1.0f));
            } else if (hovered) {
                render_hint(1);
            }
        }
    }
}

auto plugin::gui::widgets::hint::render_as_guide(const std::string& label, bool optional_condition)
    noexcept -> void
{
    static std::unordered_map<std::string, std::chrono::steady_clock::time_point> timers;

    auto& deleted_hints = (*configuration)["internal"]["guide_hints"];
    bool deleted = std::find(deleted_hints.begin(), deleted_hints.end(), label) != std::end(deleted_hints);
    auto now = std::chrono::steady_clock::now();

    if (!timers.contains(label) && !deleted && optional_condition)
        timers[label] = now;

    hint(label).with_condition([=, &deleted_hints] mutable {
        if (deleted || !optional_condition)
            return false;

        if (now - timers[label] >= 10s) {
            deleted_hints.push_back(label);
            return false;
        }

        return true;
    }).render();
}
