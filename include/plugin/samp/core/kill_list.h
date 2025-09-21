/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#ifndef GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H
#define GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H

#include "plugin/types/address.h"

namespace plugin::samp {

/// Provides methods for operating with SA:MP kill-list window.
class kill_list final {
private:
    static inline types::offset<bool> enabled_offset = 0x0;
    static types::versioned_address_container<std::uintptr_t> instance_container;
public:
    /// Hide window.
    static auto hide_window() noexcept -> void;
}; // class kill_list final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H
