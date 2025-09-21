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

#include "plugin/gui/fonts.h"
#include "plugin/gui/icon.h"
#include "common/network.h"
#include <functional>
#include <ranges>

auto plugin::gui::fonts_initializer::get_missing_fonts() const -> std::queue<missing_font> {
    std::filesystem::path resources = std::filesystem::current_path() / "gadmin" / "resources";
    std::queue<missing_font> missing_fonts;

    for (const auto& filename : filenames) {
        std::filesystem::path font_path = resources / filename;

        if (std::filesystem::exists(font_path))
            continue;

        missing_fonts.push({ font_path, filename });
    }

    return missing_fonts;
}

auto plugin::gui::fonts_initializer::download_missing_fonts() -> void {
    while (!missing_fonts.empty()) {
        missing_font& font = missing_fonts.front();
        
        common::network::download_file(std::format(PROJECT_DATABASE "/resources/{}", font.filename),
                                       font.path, network_thread.get_stop_token());

        missing_fonts.pop();
    }
}

auto plugin::gui::fonts_initializer::assign_fonts() -> void {
    ImFontAtlas* font_atlas = ImGui::GetIO().Fonts;
    ImFont** fonts[] = { &regular, &bold, &light, &icon };
    
    std::filesystem::path resources = std::filesystem::current_path() / "gadmin" / "resources";

    for (const auto& [ index, filename ] : filenames | std::views::enumerate) {
        std::filesystem::path path = resources / filename;

        if (index == icon_font_index) {
            const ImWchar icon_ranges[] = { ICON_MIN, ICON_MAX, 0 };
            
            *fonts[index] = font_atlas->AddFontFromFileTTF(path.string().c_str(), default_font_size, nullptr, icon_ranges);
            
            break;
        }

        *fonts[index] = font_atlas->AddFontFromFileTTF(path.string().c_str(), default_font_size);
    }
}

auto plugin::gui::fonts_initializer::can_assign_fonts() const -> bool {
    return missing_fonts.empty();
}

plugin::gui::fonts_initializer::fonts_initializer()
    : missing_fonts(get_missing_fonts())
{
    if (missing_fonts.empty())
        return;

    network_thread = std::jthread(std::bind_front(&fonts_initializer::download_missing_fonts, this));
}
