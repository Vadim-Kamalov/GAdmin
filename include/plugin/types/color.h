#ifndef GADMIN_PLUGIN_TYPES_COLOR_H
#define GADMIN_PLUGIN_TYPES_COLOR_H

#include <cstdint>
#include <nlohmann/json.hpp>

namespace plugin::types {

enum class color_type {
    argb,
    rgba,
    abgr
}; // enum class color_type

template<color_type type>
class basic_color final {
public:
    using joined_t = std::uint32_t;
    using channel_t = std::uint8_t;
public:
    channel_t alpha = 0;
    channel_t red = 0;
    channel_t green = 0;
    channel_t blue = 0;

    constexpr auto operator==(const basic_color& other) const noexcept -> bool;

    constexpr basic_color(joined_t color);

    constexpr basic_color(channel_t alpha, channel_t red, channel_t green, channel_t blue)
        : alpha(alpha), red(red), green(green), blue(blue) {}

    constexpr basic_color() = default;
}; // class basic_color final

class color final {
public:
    using argb = basic_color<color_type::argb>;
    using rgba = basic_color<color_type::rgba>;
    using abgr = basic_color<color_type::abgr>;
public:
    abgr value;
  
    template<color_type convert_type>
    constexpr auto cast() const noexcept -> basic_color<convert_type>::joined_t;

    constexpr auto get() const noexcept -> abgr::joined_t;
    constexpr auto operator*() const noexcept -> abgr::joined_t;
    constexpr auto operator==(const color& other) const noexcept -> bool;

    constexpr color(const color& other, std::uint8_t alpha)
        : value(abgr(alpha, other.value.red, other.value.green, other.value.blue)) {}

    constexpr color(const argb& value)
        : value(abgr(value.alpha, value.red, value.green, value.blue)) {}
    
    constexpr color(const rgba& value)
        : value(abgr(value.alpha, value.red, value.green, value.blue)) {}
    
    constexpr color(const abgr& value)
        : value(value) {}
    
    constexpr color(abgr::joined_t color)
        : value(abgr(color)) {}

    constexpr color() = default;
}; // class color final

auto to_json(nlohmann::json& json, const color& col) -> void;
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
