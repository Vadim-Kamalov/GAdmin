#ifndef GADMIN_PLUGIN_GAME_PAD_H
#define GADMIN_PLUGIN_GAME_PAD_H

#include "plugin/types/address.h"

namespace plugin::game {

class pad {
private:
    static inline types::address<std::uintptr_t> instance = 0xB73458;
    static inline types::offset<bool> disable_player_controls_offset = 0x10E;
    static inline types::offset<bool> disable_player_enter_vehicle_offset = 0x119;
public:
    static void disable_player_control() noexcept;
    static void set_player_enter_vehicle(bool state) noexcept;
}; // class pad

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_PAD_H
