/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#include "plugin/gui/windows/release_information.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/animation.h"
#include "plugin/game/game.h"
#include "plugin/gui/widgets/markdown.h"
#include "plugin/log.h"
#include <fstream>
#include <ranges>
#include <windows.h>

std::filesystem::path
plugin::gui::windows::release_information::file_path = std::filesystem::current_path() / "gadmin" / "release_information.mpk";

auto plugin::gui::windows::release_information::render_title() const -> void {
    std::array<std::string, 3> entries_aligned = {
        // Left (0)
        std::format("{} => {} · {:.2f}mb", parsed_information->old_tag_name,
                    parsed_information->tag_name, parsed_information->file_size / 1e+6),
        
        // Center (1)
        parsed_information->name,
        
        // Right (2)
        std::format("{} · {} установок", parsed_information->date_created,
                    parsed_information->download_count)
    };

    ImVec2 center_text_size = bold_font->CalcTextSizeA(bold_font_size, FLT_MAX, 0.0f, entries_aligned[1].c_str());
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;

    for (const auto& [ index, entry ] : entries_aligned | std::views::enumerate) {
        ImVec2 size = (index == 1) ? center_text_size : regular_font->CalcTextSizeA(regular_font_size, FLT_MAX, 0.0f, entry.c_str());
        ImVec2 pos = { window_padding.x, (index == 1) ? window_padding.y : window_padding.y + (center_text_size.y - size.y) / 2.0f };
        ImVec4 color = ImGui::GetStyle().Colors[(index == 1) ? ImGuiCol_Text : ImGuiCol_TextDisabled];

        if (index == 1)
            pos.x = (ImGui::GetContentRegionAvail().x - center_text_size.x) / 2;
        else if (index == 2)
            pos.x = ImGui::GetContentRegionAvail().x - size.x;

        ImGui::PushFont((index == 1) ? bold_font : regular_font);
        {
            ImGui::SetCursorPos(pos);
            ImGui::TextColored(color, "%s", entry.c_str());
        }
        ImGui::PopFont();
    }
}

auto plugin::gui::windows::release_information::close_window() -> void {
    time = std::chrono::steady_clock::now();
    closing = true;
    
    child->disable_cursor();

    try {
        std::filesystem::remove(file_path);
    } catch (const std::exception& e) {
        log::error("failed to remove \"{}\": {}", file_path.string(), e.what());
    }
}

auto plugin::gui::windows::release_information::render() -> void {
    if (!parsed_information.has_value())
        return;

    if (closing) {
        background_alpha = animation::bring_to(background_alpha, 0, time, animation_duration);
        window_alpha = animation::bring_to(window_alpha, 0, time, animation_duration);

        if (background_alpha == 0) {
            closing = false;
            parsed_information = {};
            return;
        }
    }
    
    auto window_flags = ImGuiWindowFlags_NoMove | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoDecoration;
    auto [ size_x, size_y ] = game::get_screen_resolution();
    
    ImGui::GetBackgroundDrawList()->AddRectFilled({ 0, 0 }, { size_x, size_y }, background_alpha << 24);

    ImGui::SetNextWindowSize({ 800, 0 });
    ImGui::SetNextWindowPos({ size_x / 2, size_y / 2 }, ImGuiCond_Always, { 0.5, 0.5 });
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.f);
    ImGui::Begin(get_id(), nullptr, window_flags);
    {
        render_title();
        widgets::markdown(parsed_information->body, child->fonts->bold).render();

        if (widgets::button("Закрыть##windows::release_information", { ImGui::GetContentRegionAvail().x, 30 })
                .render() && !closing)
        {
            close_window();
        }
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::release_information::create(types::not_null<gui_initializer*> child)
    noexcept -> window_ptr_t
{
    return std::make_unique<release_information>(child);
}

plugin::gui::windows::release_information::release_information(types::not_null<gui_initializer*> child)
    : window(child, get_id()),
      bold_font(child->fonts->bold),
      regular_font(child->fonts->regular)
{
    if (!std::filesystem::exists(file_path))
        return;

    std::ifstream file(file_path, std::ios::binary | std::ios::ate);
    std::ifstream::pos_type pos = file.tellg();

    if (!file) {
        log::warn("failed to get relase information from \"{}\"", file_path.string());
        return;
    }

    child->enable_cursor();

    std::vector<char> bytes(pos);

    file.seekg(0, std::ios::beg);
    file.read(&bytes[0], pos);

    parsed_information = nlohmann::json::from_msgpack(bytes);
}
