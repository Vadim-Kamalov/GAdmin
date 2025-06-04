#ifndef GADMIN_STRING_UTILS_H
#define GADMIN_STRING_UTILS_H

#include <string>

namespace plugin {

class string_utils final {
private:
    static auto convert_encoding(const std::string& text, unsigned int code_page_from, unsigned int code_page_to) -> std::string;
public:
    static auto to_lowercase(const std::string_view& str) -> std::string;
    static auto truncate_until_hashtag(const std::string_view& text) -> std::string;
    static auto remove_samp_colors(const std::string_view& text) -> std::string;
    static auto to_utf8(const std::string& text) -> std::string;
    static auto to_cp1251(const std::string& text) -> std::string;
}; // class string_utils

} // namespace plugin


#endif // GADMIN_STRING_UTILS_H
