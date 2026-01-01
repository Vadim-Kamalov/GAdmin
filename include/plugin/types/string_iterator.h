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

#ifndef GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H
#define GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H

#include <optional>
#include <string>

namespace plugin::types {

/// Class for iterating in the `std::string` character by character.
/// Provides methods for consuming characters, skipping or collecting
/// substrings based on the certain conditions.
class string_iterator final {
private:
    std::string input;
    std::size_t index = 0;
public:
    /// Get current character without consuming it.
    ///
    /// @return Current character or `std::nullopt` if at end of string.
    auto current() const -> std::optional<unsigned char>;

    /// Consume and return current character.
    ///
    /// @note   Advances iterator position by one.
    /// @return Current character.
    auto consume() -> unsigned char;
    
    /// Get remaining string from current position.
    ///
    /// @return Substring from current position to end.
    auto remaining() -> std::string;

    /// Skip characters until predicate returns false.
    ///
    /// @tparam callback_until Type of predicate function.
    /// @param until[in]       Predicate function returning true for characters to skip.
    template<typename callback_until>
    auto skip(callback_until until) -> void;

    /// Collect characters while predicate returns true.
    ///
    /// @tparam callback_until Type of predicate function.
    /// @param until[in]       Predicate function returning true for characters to collect.
    /// @return                Collected substring.
    template<typename callback_until>
    auto collect(callback_until until) -> std::string;

    /// Construct string iterator.
    ///
    /// @param input[in] String view to iterate over.
    /// @param index[in] Starting position (default: 0).
    explicit string_iterator(const std::string_view& input, std::size_t index = 0)
        : input(std::move(input)), index(index) {}
}; // class string_iterator final

} // namespace plugin::types

template<typename callback_until>
auto plugin::types::string_iterator::skip(callback_until until) -> void {
    while (current().has_value() && until(*current()))
        consume();
}

template<typename callback_until>
auto plugin::types::string_iterator::collect(callback_until until) -> std::string {
    std::string output;

    while (current().has_value() && until(*current()))
        output.push_back(consume());

    return output;
}

#endif // GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H
