#include "plugin/samp/core/net_game.h"

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::net_game::instance_container = { 0x21A0F8, 0x26E8DC, 0x26EB94, 0x2ACA24 };

plugin::types::versioned_address_container<plugin::types::zstring_t, plugin::types::version_container_option::offsets>
plugin::samp::net_game::host_address_offsets = { 0x20, 0x30, 0x30, 0x30 };
    
plugin::types::versioned_address_container<plugin::samp::server_settings, plugin::types::version_container_option::offsets>
plugin::samp::net_game::server_settings_container = { 0x3C5, 0x3D5, 0x3D5, 0x3D5 };

plugin::types::versioned_address_container<plugin::signatures::update_players_t>
plugin::samp::net_game::update_players_container = { 0x8A10, 0x8BA0, 0x8F10, 0x8C00 };

auto plugin::samp::net_game::get_server_settings() noexcept -> server_settings {
    return server_settings_container->read(instance_container->read());
}

auto plugin::samp::net_game::get_host_address() noexcept -> std::string {
    return host_address_offsets->read(instance_container->read());
}

auto plugin::samp::net_game::update_players() noexcept -> void {
    update_players_container->invoke(instance_container->read());
}
