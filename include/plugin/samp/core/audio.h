#ifndef GADMIN_PLUGIN_SAMP_CORE_AUDIO_H
#define GADMIN_PLUGIN_SAMP_CORE_AUDIO_H

#include <cstdint>
#include "plugin/types/address.h"
#include "plugin/types/simple.h"

namespace plugin {
namespace signatures {

using play_sound_t = void(__thiscall*)(std::uintptr_t, int, types::vector_3d);

} // namespace signatures

namespace samp {

class audio final {
private:
    static types::versioned_address_container<signatures::play_sound_t> play_sound_container;
    static auto instance() noexcept -> std::uintptr_t;
public:
    enum class sound_id { bell = 1137 };

    static auto play_sound(const sound_id& id, types::vector_3d pos = {}) noexcept -> void;
}; // class audio

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_AUDIO_H
