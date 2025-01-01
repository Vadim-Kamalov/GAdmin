#ifndef GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
#define GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H

#include "plugin/samp/core/ped.h"

namespace plugin::samp {

class remote_player {
private:
    std::uintptr_t handle;
public:
    ped get_ped() const;
    explicit remote_player(std::uintptr_t handle) : handle(handle) {}
}; // class remote_player

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_REMOTE_PLAYER_H
