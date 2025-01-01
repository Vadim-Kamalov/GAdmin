#ifndef GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
#define GADMIN_PLUGIN_SAMP_CORE_ENTITY_H

#include <cstdint>

namespace plugin {
namespace signatures {

using get_model_index_t = int(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class entity {
protected:
    std::uintptr_t handle;
public:
    bool is_available() const;
    int get_model_index() const;
    
    explicit entity(std::uintptr_t handle) : handle(handle) {}
}; // class entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
