/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

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

/// Provies methods for managing SA:MP audio interface.
class audio final {
private:
    static types::versioned_address_container<signatures::play_sound_t> play_sound_container;
    static auto instance() noexcept -> std::uintptr_t;
public:
    /// Sound IDs available to play.
    enum class sound_id {
        bell = 1137 ///< Bell sound.
    }; // enum class sound_id

    /// Play sound using SA:MP audio interface.
    ///
    /// @param id[in]  Sound ID to play.
    /// @param pos[in] Coordinates where to play sound. When set to default value,
    ///                sound will be played independently from the coordinates.
    static auto play_sound(const sound_id& id, types::vector_3d pos = {}) noexcept -> void;
}; // class audio

} // namespace samp
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_AUDIO_H
