#ifndef GADMIN_PLUGIN_SAMP_CORE_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_GAME_H

#include "plugin/types/address.h"

namespace plugin::samp {
    
class game {
public:
    static types::versioned_address_container<std::uintptr_t> instance_container;
}; // class game

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_GAME_H
