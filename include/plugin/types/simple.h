#ifndef GADMIN_PLUGIN_TYPES_SIMPLE_H
#define GADMIN_PLUGIN_TYPES_SIMPLE_H

#include <format>

namespace plugin::types {

using meter_per_second_t = float;
using zstring_t = const char*;

struct vector_3d final {
    float x, y, z;

    auto magnitude() const -> float;
    auto get_distance_to(const vector_3d& vector) const -> float;

    auto operator+(const vector_3d& other) const -> vector_3d;
    auto operator-(const vector_3d& other) const -> vector_3d;
    auto operator*(const vector_3d& other) const -> vector_3d;
    auto operator*(float other) const -> vector_3d;
    auto operator-() const -> vector_3d;
}; // struct vector_3d final

} // namespace plugin::types

template<>
struct std::formatter<plugin::types::vector_3d> : std::formatter<std::string_view> {
    auto format(const plugin::types::vector_3d& vector, std::format_context& ctx) const {
        return std::format_to(ctx.out(), "X: {} | Y: {} | Z: {}", vector.x, vector.y, vector.z);
    }
}; // struct std::formatter<plugin::types::vector_3d> : std::formatter<std::string_view>

#endif // GADMIN_PLUGIN_TYPES_SIMPLE_H
