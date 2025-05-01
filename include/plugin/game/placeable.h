#ifndef GADMIN_PLUGIN_GAME_PLACEABLE_H
#define GADMIN_PLUGIN_GAME_PLACEABLE_H

#include "plugin/game/entity.h"
#include "plugin/types/address.h"
#include <numbers>

namespace plugin {
namespace signatures {

using get_placeable_rotation = float(__thiscall*)(std::uintptr_t);
using set_placeable_heading = void(__thiscall*)(std::uintptr_t, float);

} // namespace signatures

namespace game {

class placeable : public entity {
public:
    struct physical_flags_t {
        std::uint8_t : 8;
        std::uint8_t : 5;
        std::uint8_t locked : 1;
        std::uint8_t : 2;
        std::uint8_t soft : 1;
        std::uint8_t : 7;
        std::uint8_t : 8;
    }; // struct physical_flags_t
protected:
    void set_heading_in_rad(float angle) const;
    void set_heading_in_deg(float angle) const;
    float clamp_angle(float angle) const;

    static constexpr float rad_to_deg_multiplier = 180.0f / std::numbers::pi;
    static constexpr float deg_to_rad_multiplier = std::numbers::pi / 180.0f;
private:
    static inline types::address<signatures::get_placeable_rotation> get_placeable_rotation = 0x441DB0;
    static inline types::address<signatures::set_placeable_heading> set_placeable_heading = 0x43E0C0;
    static inline types::offset<physical_flags_t> physical_flags_offset = 0x40;
    static inline types::offset<int> entity_flags_offset = 0x1C;
public:
    virtual ~placeable() = default;
    
    inline bool is_available() const;
    inline explicit operator bool() const;
    
    bool is_locked() const;
    void set_lock(bool state) const;

    float get_heading() const;
    virtual void set_heading(float angle) const;

    using entity::entity;
}; // class placeable

} // namespace game
} // namespace plugin

inline bool
plugin::game::placeable::is_available() const {
    return handle.is_available();
}

inline plugin::game::placeable::operator bool() const {
    return is_available();
}

#endif // GADMIN_PLUGIN_GAME_PLACEABLE_H
