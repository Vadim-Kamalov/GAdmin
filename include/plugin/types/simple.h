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

#ifndef GADMIN_PLUGIN_TYPES_SIMPLE_H
#define GADMIN_PLUGIN_TYPES_SIMPLE_H

#include <format>

namespace plugin::types {

using meter_per_second_t = float; ///< Represents speed in meters per second.
using zstring_t = const char*;    ///< Represents null-terminated (C-style) string. 

/// Represents 3D vector with `x`, `y`, `z` components.
struct vector_3d final {
    float x; ///< X coordinate.
    float y; ///< Y coordinate.
    float z; ///< Z coordinate.

    /// Calculate vector magnitude (length).
    ///
    /// Formula: `magnitude = \sqrt{x^2 + y^2 + z^2}`
    ///
    /// @return Vector magnitude.
    auto magnitude() const -> float;

    // Calculate distance to another vector.
    ///
    /// Formula: `distance = \sqrt{(x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2}`
    ///
    /// @param vector[in] Target vector to calculate distance to.
    /// @return           Distance between vectors.
    auto get_distance_to(const vector_3d& vector) const -> float;

    /// Add two vectors.
    ///
    /// @param other[in] Vector to add.
    /// @return          Resulting vector.
    auto operator+(const vector_3d& other) const -> vector_3d;

    /// Subtract two vectors.
    ///
    /// @param other[in] Vector to subtract.
    /// @return          Resulting vector.
    auto operator-(const vector_3d& other) const -> vector_3d;

    /// Multiply two vectors (component-wise).
    ///
    /// @param other[in] Vector to multiply with.
    /// @return          Resulting vector.
    auto operator*(const vector_3d& other) const -> vector_3d;

    /// Multiply vector by scalar.
    ///
    /// @param other[in] Scalar value to multiply by.
    /// @return          Resulting vector.
    auto operator*(float other) const -> vector_3d;

    /// Negate vector.
    ///
    /// @return Negated vector.
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
