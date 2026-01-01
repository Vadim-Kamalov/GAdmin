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

#include "plugin/types/simple.h"
#include <cmath>

auto plugin::types::vector_3d::magnitude() const -> float {
    return std::hypot(x, y, z);
}

auto plugin::types::vector_3d::get_distance_to(const vector_3d& vector) const -> float {
    return std::hypot(x - vector.x, y - vector.y, z - vector.z);
}

auto plugin::types::vector_3d::operator+(const vector_3d& other) const -> vector_3d {
    return { x + other.x, y + other.y, z + other.z };
}

auto plugin::types::vector_3d::operator-(const vector_3d& other) const -> vector_3d {
    return { x - other.x, y - other.y, z - other.z };
}

auto plugin::types::vector_3d::operator*(const vector_3d& other) const -> vector_3d {
    return { x * other.x, y * other.y, z * other.z };
}

auto plugin::types::vector_3d::operator*(float other) const -> vector_3d {
    return { x * other, y * other, z * other };
}

auto plugin::types::vector_3d::operator-() const -> vector_3d {
    return { -x, -y, -z };
}
