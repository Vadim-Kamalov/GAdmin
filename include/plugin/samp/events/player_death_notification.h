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

#ifndef GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H
#define GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
class event<event_id::player_death_notification> final {
private:
    enum special_reason {
        special_reason_car = 49,
        special_reason_helicopter,
        special_reason_explosion,
        special_reason_drowned = 53,
        special_reason_suicide
    }; // enum special_reason 
public:
    static constexpr std::uint16_t id_none = 0xFFFF; ///< None ID.
    
    /// Killer's ID.
    std::uint16_t killer_id = id_none;

    /// Killed player's ID. If equal to `id_none` then death is occured by the single player's action(s)
    std::uint16_t killed_id = id_none;
   
    /// Reason of the death.
    std::uint8_t reason = 0xFF;

    /// Convert death notification to the string.
    ///
    /// @return Death notification as the string.
    auto to_string() const -> std::string;

    /// Get the reason of the death as the string.
    ///
    /// @return Reason of the death as the string.
    auto get_reason() const -> std::string;

    /// Construct an event.
    ///
    /// @param bit_stream[in] Bit stream with the event parameters.
    explicit event(bit_stream* stream);
}; // class event<event_id::player_death_notification> final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_PLAYER_DEATH_NOTIFICATION_H
