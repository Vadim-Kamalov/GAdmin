#include "plugin/types/simple.h"
#include <cmath>

float
plugin::types::vector_3d::magnitude() const {
    return std::hypot(x, y, z);
}
