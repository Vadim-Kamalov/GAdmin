#include "plugin/samp/core/audio.h"
#include "plugin/samp/core/game.h"

plugin::types::versioned_address_container<plugin::signatures::play_sound_t>
plugin::samp::audio::play_sound_container = { 0x9D730, 0xA1B90, 0xA22C0, 0xA20E0 };

std::uintptr_t
plugin::samp::audio::instance() noexcept {
    return *reinterpret_cast<std::uintptr_t*>(samp::game::instance_container->read());
}

void
plugin::samp::audio::play_sound(const sound_id& id, types::vector_3d pos) noexcept {
    play_sound_container->invoke(instance(), std::to_underlying(id), pos);
}
