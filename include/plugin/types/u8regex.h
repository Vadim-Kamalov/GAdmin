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

#ifndef GADMIN_PLUGIN_TYPES_U8REGEX_H
#define GADMIN_PLUGIN_TYPES_U8REGEX_H

#include <ctre.hpp>
#include <unicode-db.hpp>

namespace plugin::types {

/// Regular expression engine based on CTRE (Compile-Time Regular Expressions) library.
///
/// Specialized for handling UTF-8 encoded strings, including non-ASCII characters
/// such as Cyrillic. Provides search and match operations with compile-time patterns.
class u8regex final {
public:
    /// Result container for regex operations.
    ///
    /// Stores match results from search or match operations
    /// and provides access to captured groups.
    ///
    /// @tparam regex_results Internal CTRE match results type.
    template<typename regex_results>
    class results final {
    private:
        regex_results matches;
    public:
        /// Get matched string at specific capture group index.
        ///
        /// @note         Index 0 returns entire matched string.
        /// @tparam index Capture group index.
        /// @return       Matched string converted to std::string.
        template<std::size_t index>
        auto get_string() const -> std::string {
            std::u8string string = matches.template get<index>().str();
            return std::string(string.begin(), string.end());
        }

        /// Get internal match data at specific capture group index.
        ///
        /// @note         Index 0 returns entire match data.
        /// @tparam index Capture group index.
        /// @return       Reference to internal match data.
        template<std::size_t index>
        auto& get() const { return matches.template get<index>(); }

        /// Check if any matches found.
        ///
        /// @return True if matches exist.
        explicit operator bool() const { return matches; }
    
        /// Construct results container.
        ///
        /// @param matches[in] CTRE match results to store.
        explicit results(const regex_results& matches)
            : matches(std::move(matches)) {}
    }; // class results final
private:
    template<ctll::fixed_string pattern, typename ctre_function>
    static auto pass(const std::string_view& input, ctre_function function) noexcept;
public:
    /// Search for pattern in input string. Finds first
    /// occurrence of pattern anywhere in input.
    ///
    /// @tparam pattern  Compile-time regex pattern.
    /// @param input[in] String to search in.
    /// @return          `results` object containing match information.
    template<ctll::fixed_string pattern>
    static inline auto search(const std::string_view& input) noexcept;

    /// Match pattern against entire input string.
    /// Requires entire string to match pattern.
    ///
    /// @tparam pattern  Compile-time regex pattern.
    /// @param input[in] String to match against.
    /// @return          `results` object containing match information.
    template<ctll::fixed_string pattern>
    static inline auto match(const std::string_view& input) noexcept;
}; // class u8regex final

} // namespace plugin::types

template<ctll::fixed_string pattern, typename ctre_function>
auto plugin::types::u8regex::pass(const std::string_view& input, ctre_function function) noexcept {
    std::u8string to_search = std::u8string(input.begin(), input.end());
    ctre::regex_results regex_results = function(to_search);
    return results<decltype(regex_results)>(regex_results);
}

template<ctll::fixed_string pattern>
inline auto plugin::types::u8regex::search(const std::string_view& input) noexcept {
    return pass<pattern>(input, ctre::search<pattern>);
}

template<ctll::fixed_string pattern>
inline auto plugin::types::u8regex::match(const std::string_view& input) noexcept {
    return pass<pattern>(input, ctre::match<pattern>);
}

#endif // GADMIN_PLUGIN_TYPES_U8REGEX_H
