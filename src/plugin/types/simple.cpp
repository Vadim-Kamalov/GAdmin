#include "plugin/types/simple.h"
#include <cmath>

float
plugin::types::vector_3d::magnitude() const {
    return std::hypot(x, y, z);
}

float
plugin::types::vector_3d::get_distance_to(const vector_3d& vector) const {
    return std::hypot(x - vector.x, y - vector.y, z - vector.z);
}

plugin::types::vector_3d
plugin::types::vector_3d::operator+(const vector_3d& other) const {
    return { x + other.x, y + other.y, z + other.z };
}

plugin::types::vector_3d
plugin::types::vector_3d::operator-(const vector_3d& other) const {
    return { x - other.x, y - other.y, z - other.z };
}
