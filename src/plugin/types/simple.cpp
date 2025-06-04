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
