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

#ifndef GADMIN_PLUGIN_SAMP_UTILS_H
#define GADMIN_PLUGIN_SAMP_UTILS_H

namespace plugin::samp {

/// Provides different methods for interacting with the SA:MP client.
class utils final {
public:
    /// Check if any input is active.
    ///
    /// @return True if any input is active.
    static auto is_inputs_active() noexcept -> bool;
}; // class utils final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_UTILS_H
