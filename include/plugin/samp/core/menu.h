#ifndef GADMIN_PLUGIN_SAMP_CORE_MENU_H
#define GADMIN_PLUGIN_SAMP_CORE_MENU_H

#include <cstdint>

namespace plugin::samp {

class menu {
public:
    static constexpr std::uint8_t event_id = 77;
    static constexpr std::uint8_t select_id = 132;
    static void select(std::uint8_t id) noexcept;
}; // class menu

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_MENU_H
