#ifndef GADMIN_PLUGIN_TYPES_SIMPLE_H
#define GADMIN_PLUGIN_TYPES_SIMPLE_H

namespace plugin::types {

using zstring_t = const char*;

struct vector_3d {
    float x, y, z;

    float magnitude() const;
}; // struct vector_3d

} // namespace plugin::types

#endif // GADMIN_PLUGIN_TYPES_SIMPLE_H
