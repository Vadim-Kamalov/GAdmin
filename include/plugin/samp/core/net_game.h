#ifndef GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
#define GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H

#include "plugin/samp/core/server_settings.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <cstdint>

namespace plugin {
namespace signatures {

using update_players_t = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class net_game {
private:
    static types::versioned_address_container<types::zstring_t, types::version_container_option::offsets> host_address_offsets;
    static types::versioned_address_container<server_settings, types::version_container_option::offsets> server_settings_container;
    static types::versioned_address_container<signatures::update_players_t> update_players_container;
public:
    static types::versioned_address_container<std::uintptr_t> instance_container;

    static server_settings get_server_settings() noexcept;
    static std::string get_host_address() noexcept;
    static void update_players() noexcept;
}; // class net_game

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_NET_GAME_H
