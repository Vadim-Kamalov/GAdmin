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

#include "plugin/string_utils.h"
#include "plugin/types/string_iterator.h"
#include <algorithm>
#include <cctype>
#include <vector>
#include <windows.h>
#include <imgui.h>

auto plugin::string_utils::convert_encoding(const std::string& text, unsigned int code_page_from, unsigned int code_page_to)
    -> std::string
{
    int wide_char_size = MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, nullptr, 0);
    std::vector<wchar_t> wide_char_string(wide_char_size);
    
    MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, wide_char_string.data(), wide_char_size);

    int size = WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, nullptr, 0, nullptr, nullptr);
    std::vector<char> new_string(size);

    WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, new_string.data(), size, nullptr, nullptr);

    return std::string(new_string.data());
}

auto plugin::string_utils::to_lowercase(const std::string_view& string) -> std::string {
    /// Because our codebase (as well as ImGui, which uses only `const char*` and not `const wchar_t*`) uses
    /// `std::string` everywhere, converting Cyrillic characters to lowercase is difficult if we take into
    /// account that the `i686-w64-mingw32-g++` compiler does not support `std::locale` (as of v15.2.0) for
    /// `ru_RU.UTF-8` and that `std::wstring_convert` is deprecated since C++17.
    ///
    /// In simple terms, this implementation does three steps to convert a potential string with Cyrillic
    /// characters to lowercase:
    ///
    ///     1. Converts `std::string` to `std::wstring` using WinAPI methods;
    ///     2. Converts characters in the resulting `std::wstring` to lowercase;
    ///     3. Converts `std::wstring` back to `std::string` using WinAPI methods.
    ///
    /// Additionally, calling this function requires the call of `std::setlocale(LC_ALL, "Russian_Russia.UTF8")`
    /// (which we are calling in the `plugin::plugin()` constructor), otherwise the conversion will fail.

    int wide_length = MultiByteToWideChar(CP_UTF8, 0, string.data(), static_cast<int>(string.size()), nullptr, 0);
    std::wstring wide_string(wide_length, 0);

    MultiByteToWideChar(CP_UTF8, 0, string.data(), static_cast<int>(string.size()), &wide_string[0], wide_length);

    for (wchar_t& wide_char : wide_string)
        CharLowerW(&wide_char);

    int length = WideCharToMultiByte(CP_UTF8, 0, wide_string.c_str(), static_cast<int>(wide_string.size()), nullptr, 0, nullptr, nullptr);
    std::string result(length, 0);

    WideCharToMultiByte(CP_UTF8, 0, wide_string.c_str(), static_cast<int>(wide_string.size()), &result[0], length, nullptr, nullptr);

    return result;
}

auto plugin::string_utils::truncate_until_hashtag(const std::string_view& text) -> std::string {
    if (std::size_t pos = text.find("##"); pos != std::string::npos)
        return std::string(text.substr(0, pos));

    return std::string(text);
}

auto plugin::string_utils::remove_samp_colors(const std::string_view& text) -> std::string {
    types::string_iterator iterator(text);
    std::string output;

    while (iterator.current().has_value()) {
        if (*iterator.current() != '{') {
            output.push_back(iterator.consume());
            continue;
        }

        iterator.consume();

        std::string hexadecimal_part = iterator.collect(::isxdigit);

        if (hexadecimal_part.size() == 6 && *iterator.current() == '}') {
            iterator.consume();
            continue;
        }

        output.push_back('{');
        output.append(hexadecimal_part);

        if (*iterator.current() == '}')
            output.push_back(iterator.consume());
    }

    return output;
}

auto plugin::string_utils::to_utf8(const std::string& text) -> std::string {
    return convert_encoding(text, 1251, CP_UTF8);
}

auto plugin::string_utils::to_cp1251(const std::string& text) -> std::string {
    return convert_encoding(text, CP_UTF8, 1251);
}

auto plugin::string_utils::truncate_text(const std::string& text, float width) noexcept -> std::string {
    std::string output(text);
    std::string ellipsis = " ...";

    ImVec2 size = ImGui::CalcTextSize(output.c_str());
    ImVec2 padding = ImGui::GetStyle().FramePadding;
    float available_width = width - padding.x * 2;

    if (available_width >= size.x)
        return output;

    while (available_width < size.x && !output.empty()) {
        output.pop_back();
        size = ImGui::CalcTextSize((output + ellipsis).c_str());
    }

    if (!output.empty())
        output.append(ellipsis);

    return output;
}
