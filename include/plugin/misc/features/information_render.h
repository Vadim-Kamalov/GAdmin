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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H
#define GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H

#include "plugin/misc/base/feature.h"
#include "plugin/types/color.h"
#include <nlohmann/json.hpp>

namespace plugin::misc::features {

/// Represents a feature that allows rendering current information on the screen:
///
///     - Cars' health, door and engine states;
///     - Peds' currently holding weapon;
///     - Administrators' nickname if it's present;
///
/// Only works if a feature is enabled and user is on the `/alogin`.
class information_render final : public feature {
private:
    struct feature_configuration final {
        bool use;
        float font_size;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(feature_configuration, use, font_size);
    }; // struct feature_configuration final

    struct text_object final {
        std::string text;
        types::color color;
        ImFont* font;
    }; // struct text_object final

    bool samp_initialized = false;

    auto render_cars_information(ImDrawList* draw_list, ImFont* bold_font,
                                 ImFont* regular_font, float font_size) const -> void;
public:
    auto on_samp_initialize() -> void override;
    auto render(types::not_null<gui_initializer*> child) -> void override;
}; // class information_render final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H
