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

#ifndef GADMIN_PLUGIN_COMMON_UTILS_H
#define GADMIN_PLUGIN_COMMON_UTILS_H

#include <random>
#include <iterator>

namespace plugin {

/// Utility class providing common functionality.
class common_utils final {
public:
    /// Get current timestamp as string in `[HH:MM:SS]` format.
    ///
    /// @return Current timestamp in string format.
    static auto get_current_timestamp() noexcept -> std::string;

    /// Select random element from range using custom random generator.
    ///
    /// @tparam iterator         Iterator type for range.
    /// @tparam random_generator Random number generator type.
    /// @param start[in]         Start of range.
    /// @param end[in]           End of range.
    /// @param g[out]            Random number generator.
    /// @return                  Iterator pointing to randomly selected element.
    template<typename iterator, typename random_generator>
    static auto select_randomly(iterator start, iterator end, random_generator& g) -> iterator;

    /// Select random element from range using default random generator.
    /// Uses std::random_device and std::mt19937 as default generator.
    ///
    /// @tparam iterator Iterator type for range.
    /// @param start[in] Start of range.
    /// @param end[in]   End of range.
    /// @return          Iterator pointing to randomly selected element.
    template<typename iterator>
    static auto select_randomly(iterator start, iterator end) -> iterator;
}; // class common_utils final

} // namespace plugin

template<typename iterator, typename random_generator>
auto plugin::common_utils::select_randomly(iterator start, iterator end, random_generator& g) -> iterator {
    std::uniform_int_distribution<> dis(0, std::distance(start, end) - 1);
    std::advance(start, dis(g));
    return start;
}

template<typename iterator>
auto plugin::common_utils::select_randomly(iterator start, iterator end) -> iterator {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    return select_randomly(start, end, gen);
}

#endif // GADMIN_PLUGIN_COMMON_UTILS_H
