#ifndef GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H
#define GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H

#include <optional>
#include <string>

namespace plugin::types {

class string_iterator {
protected:
    std::string input;
    std::size_t index = 0;
public:
    std::optional<unsigned char> current() const;
    unsigned char consume();

    template<typename callback_until>
    void skip(callback_until until);

    template<typename callback_until>
    std::string collect(callback_until until);

    explicit string_iterator(const std::string_view& input, std::size_t index = 0)
        : input(std::move(input)), index(index) {}
}; // class string_iterator

} // namespace plugin::types

template<typename callback_until>
void
plugin::types::string_iterator::skip(callback_until until) {
    while (current().has_value() && until(*current()))
        consume();
}

template<typename callback_until>
std::string
plugin::types::string_iterator::collect(callback_until until) {
    std::string output;

    while (current().has_value() && until(*current()))
        output.push_back(consume());

    return output;
}

#endif // GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H
