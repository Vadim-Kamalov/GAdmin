#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/game/ped.h"
#include "plugin/game/weapon.h"
#include "plugin/samp/core/entity.h"

namespace plugin {
namespace signatures {

using get_current_weapon_t = char(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class ped final : public entity {
private:
    static inline types::offset<game::ped> game_ped = 0x2A4;
    static types::versioned_address_container<signatures::get_current_weapon_t> get_current_weapon_container;
public:
    auto get_game_ped() const -> game::ped;
    auto get_current_weapon() const -> game::weapon;

    using entity::entity;
}; // class ped final : public entity

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
