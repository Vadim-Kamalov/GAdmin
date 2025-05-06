#ifndef GADMIN_PLUGIN_GAME_ENTITY_H
#define GADMIN_PLUGIN_GAME_ENTITY_H

#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using is_vehicle_pointer_valid = bool(__stdcall*)(std::uintptr_t);
using is_on_screen = bool(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace game {

class vehicle;

class entity {
public:
    types::dynamic_address<std::uintptr_t> handle;
protected:
    void set_coordinates(const types::vector_3d& pos) const;
private:
    static inline types::address<signatures::is_vehicle_pointer_valid> is_vehicle_pointer_valid_address = 0x6E38F0;
    static inline types::address<signatures::is_on_screen> is_on_screen_address = 0x534540;
    static inline types::offset<std::uintptr_t> matrix_offset = 0x14;
    static inline types::offset<std::uint16_t> model_index_offset = 0x22;
    static inline types::offset<types::vector_3d> position_offset_in_matrix = 0x30;
public:
    virtual ~entity() = default;

    inline bool is_available() const;
    bool is_on_screen() const;
    
    std::uint16_t get_model_index() const;
    types::vector_3d get_position() const;
    vehicle get_vehicle() const;
    
    bool operator==(const entity& other) const;
    inline explicit operator bool() const;

    virtual void teleport(const types::vector_3d& pos) const;

    explicit entity(const types::dynamic_address<std::uintptr_t>& handle)
        : handle(handle) {}
}; // class entity

} // namespace game
} // namespace plugin

inline bool
plugin::game::entity::is_available() const {
    return handle.is_available();
}

inline plugin::game::entity::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_GAME_ENTITY_H
