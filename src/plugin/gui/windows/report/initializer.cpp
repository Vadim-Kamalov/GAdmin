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

#include "plugin/gui/windows/report/initializer.h"
#include "plugin/gui/windows/report/frames/current_report.h"
#include "plugin/gui/windows/report/frames/previous_answers.h"
#include "plugin/gui/windows/report/frames/user_all_answers.h"
#include "plugin/gui/windows/report/frames/gps.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/core/input.h"
#include "plugin/game/game.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::report::window_controls::go_to_frame(frame new_frame) -> void {
    initializer_details.switch_info.handle_transition(new_frame);
}

auto plugin::gui::windows::report::window_controls::set_answer_input_text(const std::string_view& text, bool focus)
    -> void
{
    current_report_frame_details.answer_input = text;
    current_report_frame_details.focus_answer_input = focus;
}

auto plugin::gui::windows::report::initializer::render_menu() -> void {
    std::size_t frame_count = std::ranges::count_if(frames, [](const auto& frame) { return frame->is_enabled(); });

    if (frame_count == 1)
        return;

    float button_height = ImGui::GetFrameHeight();
    float child_width = ImGui::GetWindowWidth();

    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;

    ImGui::SetCursorPos({ 0, 0 });
    ImGui::BeginChild("menu", { child_width, button_height + window_padding.y * 2 },
                      ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        ImVec2 button_size = { ((child_width - window_padding.x * 2) - item_spacing.x
                * (frame_count - 1)) / frame_count, button_height };

        for (const auto& [ index, frame ] : frames | std::views::enumerate) {
            if (!frame->is_enabled())
                continue;

            if (index > 0)
                ImGui::SameLine();

            std::string label = (server::user::is_on_alogin())
                ? frame->get_label_for_admin()
                : frame->get_label_for_helper();

            if (!widgets::button(label, button_size).render())
                continue;

            controls.go_to_frame(static_cast<report::frame>(index));
        }
    }
    ImGui::EndChild();

    float child_rounding = ImGui::GetStyle().ChildRounding;
    ImVec2 rect_min = ImGui::GetItemRectMin();
    ImVec2 rect_max = ImGui::GetItemRectMax();

    ImGui::GetWindowDrawList()->AddRectFilled({ rect_min.x, rect_max.y - child_rounding },
                                              rect_max, ImGui::GetColorU32(ImGuiCol_ChildBg));
}

auto plugin::gui::windows::report::initializer::on_event(const samp::event_info& event) -> bool {
    if (!network.on_event(event))
        return false;

    for (const auto& frame : frames) {
        event.stream->reset_read_pointer();
        if (!frame->on_event(event))
            return false;
    }

    return true;
}

auto plugin::gui::windows::report::initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    return network.on_event(message, wparam, lparam);
}

auto plugin::gui::windows::report::initializer::render() -> void {
    if (!network.can_render_window())
        return;

    float frame_height = ImGui::GetFrameHeight();
    auto [ size_x, size_y ] = game::get_screen_resolution();
    auto flags = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_AlwaysAutoResize;
    auto& controls_details = controls.initializer_details;

    controls_details.switch_info.handle_animation();

    ImGui::SetNextWindowPos({ size_x / 2.0f, size_y / 2.0f }, ImGuiCond_FirstUseEver, { 0.5f, 0.5f });
    ImGui::SetNextWindowSize({ frame_height * 28, frame_height * 13 });
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, controls_details.window_alpha / 255.0f);
    ImGui::Begin(get_id(), nullptr, flags );
    {
        render_menu();
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, controls_details.switch_info.get_alpha() * ImGui::GetStyle().Alpha);
        {
            frames[std::to_underlying(controls_details.current_frame)]->render();
        }
        ImGui::PopStyleVar();
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
}

plugin::gui::windows::report::initializer::initializer(types::not_null<gui_initializer*> child)
    : window(child, get_id()),
      controls(this),
      network(this)
{
    frames = {
        std::make_unique<frames::current_report>(this),
        std::make_unique<frames::previous_answers>(this),
        std::make_unique<frames::user_all_answers>(this),
        std::make_unique<frames::gps>(this)
    };
}

auto plugin::gui::windows::report::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<report::initializer>(child);
}
