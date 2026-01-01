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

#ifndef GADMIN_STRING_UTILS_H
#define GADMIN_STRING_UTILS_H

#include <string>

namespace plugin {

/// Provides string manipulation utilities.
class string_utils final {
private:
    static auto convert_encoding(const std::string& text, unsigned int code_page_from, unsigned int code_page_to) -> std::string;
public:
    /// Convert string to lowercase.
    ///
    /// @param str[in] Input string to convert.
    /// @return        Lowercase version of input string.
    static auto to_lowercase(const std::string_view& str) -> std::string;

    /// Truncate string at first hashtag (#) character.
    ///
    /// @param text[in] Input string to process.
    /// @return         String truncated at first hashtag, or original string if no hashtag found.
    static auto truncate_until_hashtag(const std::string_view& text) -> std::string;

    /// Remove SA:MP color codes from string: all color codes in
    /// format `{RRGGBB}` where RR, GG, BB are hexadecimal values.
    ///
    /// @param text[in] Input string containing color codes.
    /// @return         String with all SA:MP color codes removed.
    static auto remove_samp_colors(const std::string_view& text) -> std::string;

    /// Convert string from CP1251 to UTF-8 encoding.
    ///
    /// @param text[in] Input string in CP1251 encoding.
    /// @return         String converted to UTF-8 encoding.
    static auto to_utf8(const std::string& text) -> std::string;

    /// Convert string from UTF-8 to CP1251 encoding.
    ///
    /// @param text[in] Input string in UTF-8 encoding.
    /// @return         String converted to CP1251 encoding.
    static auto to_cp1251(const std::string& text) -> std::string;
}; // class string_utils

} // namespace plugin

#endif // GADMIN_STRING_UTILS_H
