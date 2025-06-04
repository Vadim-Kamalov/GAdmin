#ifndef GADMIN_PLUGIN_SAMP_CORE_MENU_H
#define GADMIN_PLUGIN_SAMP_CORE_MENU_H

#include <cstdint>

namespace plugin::samp {

class menu final {
public:
    static constexpr std::uint8_t select_id = 132;
    static auto select(std::uint8_t id) noexcept -> void;
}; // class menu final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_MENU_H
