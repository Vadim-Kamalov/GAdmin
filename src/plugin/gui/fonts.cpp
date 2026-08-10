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

#include "plugin/gui/fonts.h"
#include "plugin/gui/icon.h"
#include <common/log.h>

auto plugin::gui::fonts_initializer::assign_fonts() -> void {
    static constexpr std::size_t icon_font_index = 3;
    static constexpr std::initializer_list<std::initializer_list<std::uint8_t>> fonts_bytes = {
        {
#embed "../../../resources/notosans-regular.ttf"
        },
        {
#embed "../../../resources/notosans-bold.ttf"
        },
        {
#embed "../../../resources/notosans-light.ttf"
        },
        {
#embed "../../../resources/coolicons.ttf"
        }
    }; // static constexpr std::initializer_list<std::initializer_list<std::uint8_t>> fonts_bytes

    ImFontAtlas* font_atlas = ImGui::GetIO().Fonts;
    ImFont** font_ptrs[] = { &regular, &bold, &light, &icon };

    ImFontConfig font_config;
    font_config.FontDataOwnedByAtlas = false;

    for (const auto& [ index, font ] : fonts_bytes | std::views::enumerate) {
        if (index == icon_font_index) {
            ImWchar icon_ranges[] = { ICON_MIN, ICON_MAX, 0 };

            *font_ptrs[index] = font_atlas->AddFontFromMemoryTTF(const_cast<std::uint8_t*>(font.begin()),
                                                                 font.size(), default_font_size, &font_config,
                                                                 icon_ranges);
        
            continue;
        }

        *font_ptrs[index] = font_atlas->AddFontFromMemoryTTF(const_cast<std::uint8_t*>(font.begin()),
                                                             font.size(), default_font_size, &font_config);
    }
}
