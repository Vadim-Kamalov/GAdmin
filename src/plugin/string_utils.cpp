#include "plugin/string_utils.h"
#include "plugin/types/string_iterator.h"
#include <algorithm>
#include <cctype>
#include <windows.h>
#include <vector>

auto plugin::string_utils::convert_encoding(const std::string& text, unsigned int code_page_from, unsigned int code_page_to) -> std::string {
    int wide_char_size = MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, nullptr, 0);
    std::vector<wchar_t> wide_char_string(wide_char_size);
    
    MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, wide_char_string.data(), wide_char_size);

    int size = WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, nullptr, 0, nullptr, nullptr);
    std::vector<char> new_string(size);

    WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, new_string.data(), size, nullptr, nullptr);

    return std::string(new_string.data());
}

auto plugin::string_utils::to_lowercase(const std::string_view& string) -> std::string {
    std::wstring result(string.begin(), string.end());
    std::transform(result.begin(), result.end(), result.begin(), towlower);
    return std::string(result.begin(), result.end());
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
