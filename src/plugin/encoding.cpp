#include "plugin/encoding.h"
#include <windows.h>
#include <vector>

static std::string
convert(const std::string& text, unsigned int code_page_from, unsigned int code_page_to) {
    int wide_char_size = MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, nullptr, 0);
    std::vector<wchar_t> wide_char_string(wide_char_size);
    
    MultiByteToWideChar(code_page_from, 0, text.c_str(), -1, wide_char_string.data(), wide_char_size);

    int size = WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, nullptr, 0, nullptr, nullptr);
    std::vector<char> new_string(size);

    WideCharToMultiByte(code_page_to, 0, wide_char_string.data(), -1, new_string.data(), size, nullptr, nullptr);

    return std::string(new_string.data());
}

std::string
plugin::encoding::to_utf8(const std::string& text) {
    return convert(text, 1251, CP_UTF8);
}

std::string
plugin::encoding::to_cp1251(const std::string& text) {
    return convert(text, CP_UTF8, 1251);
}
