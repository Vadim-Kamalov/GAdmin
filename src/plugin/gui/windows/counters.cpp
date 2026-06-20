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

#include "plugin/gui/windows/counters.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include <ranges>

auto plugin::gui::windows::counters::insert_metric(window_information_t& window, const metric_t& metric) const
    -> void
{
    float font_size = ImGui::GetFontSize();

    if (window.width != 0.0f)
        window.width += ImGui::GetStyle().ItemSpacing.x;

    window.width += bold_font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, metric.first.c_str()).x
        + regular_font->CalcTextSizeA(font_size, FLT_MAX, 0.0f, metric.second.c_str()).x;

    window.metrics.push_back(metric);
}

auto plugin::gui::windows::counters::get_window_information() const -> std::optional<window_information_t> {
    auto& window_configuration = (*configuration)["windows"]["counters"];

    if (!window_configuration["use"] || samp::net_game::instance_container->read() == 0)
        return {};

    window_information_t information;

    if (window_configuration["show_fps"])
        insert_metric(information, std::make_pair("FPS: ", std::to_string(static_cast<int>(ImGui::GetIO().Framerate))));

    if (window_configuration["show_ping"])
        insert_metric(information, std::make_pair("PING: ", std::to_string(samp::user::get_ping())));

    if (information.metrics.empty())
        return {};

    information.width += ImGui::GetStyle().WindowPadding.x * 2;

    return information;
}

auto plugin::gui::windows::counters::render() -> void {
    auto window_information = get_window_information();

    if (!window_information.has_value())
        return;

    auto [ size_x, size_y ] = game::get_screen_resolution();
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
    float window_height = window_padding.y * 2 + ImGui::GetFontSize();

    ImGui::SetNextWindowPos({ window_padding.x, size_y - window_height - window_padding.y }, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize({ window_information->width, window_height });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration);
    {
        for (const auto& [ index, metric ] : window_information->metrics | std::views::enumerate) {
            if (index > 0)
                ImGui::SameLine();

            ImGui::BeginGroup();
            {
                ImGui::PushFont(bold_font);
                {
                    ImGui::TextUnformatted(metric.first.c_str());
                }
                ImGui::PopFont();
                ImGui::SameLine(0.0f, 0.0f);
                ImGui::PushFont(regular_font);
                {
                    ImGui::TextUnformatted(metric.second.c_str());
                }
                ImGui::PopFont();
            }
            ImGui::EndGroup();
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::counters::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<counters>(child);
}
