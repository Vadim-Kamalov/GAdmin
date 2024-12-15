#ifndef GADMIN_PLUGIN_SAMP_CORE_USER_H
#define GADMIN_PLUGIN_SAMP_CORE_USER_H

#include <cstdint>
#include <string>

namespace plugin {
namespace signatures {

using get_local_player_ping_t = int(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp::user {

std::uint16_t get_id() noexcept;
std::string get_name() noexcept;
int get_ping() noexcept;

} // namespace samp::user
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_USER_H
