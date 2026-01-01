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

#ifndef GADMIN_PLUGIN_TYPES_COLOR_H
#define GADMIN_PLUGIN_TYPES_COLOR_H

#include <cstdint>
#include <nlohmann/json.hpp>

namespace plugin::types {

/// Represents a colors in different formats available to use in `basic_color<color_type>`.
enum class color_type {
    argb, ///< AARRGGBB
    rgba, ///< RRGGBBAA
    abgr  ///< AABBGGRR
}; // enum class color_type

/// Template class (wrapper) representing a color with specific channel ordering.
///
/// @tparam type Color channel ordering type (argb, rgba, or abgr).
template<color_type type>
class basic_color final {
public:
    using joined_t = std::uint32_t; ///< Represents a color as a single 32-bit value.
    using channel_t = std::uint8_t; ///< Represents a single color channel (8-bit).

    channel_t alpha = 0; ///< Alpha channel value (transparency).
    channel_t red = 0;   ///< Red channel value.
    channel_t green = 0; ///< Green channel value.
    channel_t blue = 0;  ///< Blue channel value.

    /// Check if the current color and another are equal.
    ///
    /// @param other[in] Color to compare with.
    /// @return          True if all color channels match.
    constexpr auto operator==(const basic_color& other) const noexcept -> bool;

    /// Construct a color from a single 32-bit value.
    ///
    /// @param color[in] Color value in the format specified by the passed color type.
    constexpr basic_color(joined_t color);

    /// Construct a color from individual channel values.
    ///
    /// @param alpha[in] Alpha channel value.
    /// @param red[in]   Red channel value.
    /// @param green[in] Green channel value.
    /// @param blue[in]  Blue channel value.
    constexpr basic_color(channel_t alpha, channel_t red, channel_t green, channel_t blue)
        : alpha(alpha), red(red), green(green), blue(blue) {}

    /// Default constructor creating a trasparent black color.
    constexpr basic_color() = default;
}; // class basic_color final

class color final {
public:
    using argb = basic_color<color_type::argb>; ///< Color in the ARGB format (0xAARRGGBB).
    using rgba = basic_color<color_type::rgba>; ///< Color in the RGBA format (0xRRGGBBAA).
    using abgr = basic_color<color_type::abgr>; ///< Color in the ABGR format (0xAABBGGRR).

    /// Internal color value storage in ABGR format.
    abgr value;
  
    /// Convert the color to a different format and get it as a single value.
    ///
    /// @tparam convert_type Target color format.
    /// @return              Color value in the requested format.
    template<color_type convert_type>
    constexpr auto cast() const noexcept -> basic_color<convert_type>::joined_t;

    /// Get the color value in ABGR format.
    ///
    /// @return Color value in ABGR format (AABBGGRR).
    constexpr auto get() const noexcept -> abgr::joined_t;
    
    /// Get the color value in ABGR format. Same as the
    /// `color::get()`, but as the operator function.
    ///
    /// @return Color value in ABGR format (AABBGGRR). 
    constexpr auto operator*() const noexcept -> abgr::joined_t;

    /// Check if the current color is equal to another.
    ///
    /// @param other[in] Other color to compare with.
    /// @return          True if the colors are equal.
    constexpr auto operator==(const color& other) const noexcept -> bool;

    /// Construct a color with the modified alpha channel.
    ///
    /// @param other[in] Source color.
    /// @param alpha[in] New alpha value.
    constexpr color(const color& other, std::uint8_t alpha)
        : value(abgr(alpha, other.value.red, other.value.green, other.value.blue)) {}

    /// Construct a color from an ARGB color value.
    ///
    /// @param value[in] ARGB color value to convert.
    constexpr color(const argb& value)
        : value(abgr(value.alpha, value.red, value.green, value.blue)) {}

    /// Construct a color from an RGBA color value.
    ///
    /// @param value[in] RGBA color value to convert.
    constexpr color(const rgba& value)
        : value(abgr(value.alpha, value.red, value.green, value.blue)) {}

    /// Construct a color from an ABGR color value.
    ///
    /// @param value[in] ABGR color value to use directly.
    constexpr color(const abgr& value)
        : value(value) {}

    /// Construct a color from a single 32-bit ABGR value.
    ///
    /// @param color[in] Color value in ABGR format.
    constexpr color(abgr::joined_t color)
        : value(abgr(color)) {}

    /// Default constructor creating a transparent black color.
    constexpr color() = default;
}; // class color final

/// Convers a color to JSON object.
///
/// @param json[out] JSON object to store the color in.
/// @param col[in]   Color to convert to JSON.
auto to_json(nlohmann::json& json, const color& col) -> void;

/// Convert a JSON value to a color.
///
/// @param json[in] JSON object containing color data.
/// @param col[in]  Color to populate from JSON.
auto from_json(const nlohmann::json& json, color& col) -> void;

} // namespace plugin::types

template<plugin::types::color_type type>
constexpr auto plugin::types::basic_color<type>::operator==(const basic_color& other) const noexcept -> bool {
    return alpha == other.alpha && red == other.red &&
            blue == other.blue && green == other.green;
}

template<plugin::types::color_type type>
constexpr plugin::types::basic_color<type>::basic_color(joined_t color) {
    switch (type) {
        case color_type::argb:
            alpha = (color >> 24) & 0xFF;
            red = (color >> 16) & 0xFF;
            green = (color >> 8) & 0xFF;
            blue = color & 0xFF;
            break;
        case color_type::rgba:
            red = (color >> 24) & 0xFF;
            green = (color >> 16) & 0xFF;
            blue = (color >> 8) & 0xFF;
            alpha = color & 0xFF;
            break;
        case color_type::abgr:
            alpha = (color >> 24) & 0xFF;
            blue = (color >> 16) & 0xFF;
            green = (color >> 8) & 0xFF;
            red = color & 0xFF;
            break;
    }
}

template<plugin::types::color_type convert_type>
constexpr auto plugin::types::color::cast() const noexcept -> basic_color<convert_type>::joined_t {
    switch (convert_type) {
        case color_type::argb:
            return (value.alpha << 24) | (value.red << 16) | (value.green << 8) | value.blue;
        case color_type::rgba:
            return (value.red << 24) | (value.green << 16) | (value.blue << 8) | value.alpha;
        case color_type::abgr:
            return (value.alpha << 24) | (value.blue << 16) | (value.green << 8) | value.red;
    }
}

constexpr auto plugin::types::color::get() const noexcept -> abgr::joined_t {
    return cast<color_type::abgr>();
}

constexpr auto plugin::types::color::operator*() const noexcept -> abgr::joined_t {
    return get();
}

constexpr auto plugin::types::color::operator==(const color& other) const noexcept -> bool {
    return value == other.value;
}

#endif // GADMIN_PLUGIN_TYPES_COLOR_H
