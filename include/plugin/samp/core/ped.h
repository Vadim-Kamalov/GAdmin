#ifndef GADMIN_PLUGIN_SAMP_CORE_PED_H
#define GADMIN_PLUGIN_SAMP_CORE_PED_H

#include "plugin/game/ped.h"
#include "plugin/samp/core/entity.h"

namespace plugin::samp {

class ped final : public entity {
private:
    static inline types::offset<game::ped> game_ped = 0x2A4;
public:
    auto get_game_ped() const -> game::ped;
    using entity::entity;
}; // class ped final : public entity

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_PED_H
