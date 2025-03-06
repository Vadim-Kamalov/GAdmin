#ifndef GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
#define GADMIN_PLUGIN_SAMP_CORE_ENTITY_H

#include "plugin/types/address.h"

namespace plugin {
namespace signatures {

using get_model_index_t = int(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class entity {
private:
    static types::versioned_address_container<signatures::get_model_index_t> get_model_index_container;
    static inline types::offset<std::uintptr_t> game_handle = 0x40;
protected:
    types::dynamic_address<std::uintptr_t> handle;
public:
    bool is_available() const;
    int get_model_index() const;
    
    bool operator==(const entity& other) const;

    explicit entity(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}
}; // class entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_ENTITY_H
