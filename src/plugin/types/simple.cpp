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
