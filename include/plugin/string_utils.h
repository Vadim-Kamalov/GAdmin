#ifndef GADMIN_STRING_UTILS_H
#define GADMIN_STRING_UTILS_H

#include <string>

namespace plugin {

class string_utils {
private:
    static std::string convert_encoding(const std::string& text, unsigned int code_page_from, unsigned int code_page_to);
public:
    static std::string to_lowercase(const std::string_view& str);
    static std::string to_utf8(const std::string& text);
    static std::string to_cp1251(const std::string& text); 
}; // class string_utils

} // namespace plugin

#endif // GADMIN_STRING_UTILS_H
