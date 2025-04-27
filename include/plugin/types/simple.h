#ifndef GADMIN_PLUGIN_TYPES_SIMPLE_H
#define GADMIN_PLUGIN_TYPES_SIMPLE_H

namespace plugin::types {

using zstring_t = const char*;

struct vector_3d {
    float x, y, z;

    float magnitude() const;
    float get_distance_to(const vector_3d& vector) const;

    vector_3d operator+(const vector_3d& other) const;
    vector_3d operator-(const vector_3d& other) const;
}; // struct vector_3d

} // namespace plugin::types

#endif // GADMIN_PLUGIN_TYPES_SIMPLE_H
