#include "plugin/encoding.h"
#include <vector>

std::string
plugin::encoding::to_utf8(const std::string& text) {
    int wide_char_size = MultiByteToWideChar(1251, 0, text.c_str(), -1, nullptr, 0);
    std::vector<wchar_t> wide_char_string(wide_char_size);
    
    MultiByteToWideChar(1251, 0, text.c_str(), -1, wide_char_string.data(), wide_char_size);

    int utf8_size = WideCharToMultiByte(CP_UTF8, 0, wide_char_string.data(), -1, nullptr, 0, nullptr, nullptr);
    std::vector<char> utf8_string(utf8_size);

    WideCharToMultiByte(CP_UTF8, 0, wide_char_string.data(), -1, utf8_string.data(), utf8_size, nullptr, nullptr);

    return std::string(utf8_string.data());
}
