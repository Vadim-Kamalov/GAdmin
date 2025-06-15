#ifndef GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H
#define GADMIN_PLUGIN_TYPES_STRING_ITERATOR_H

#include <optional>
#include <string>

namespace plugin::types {

class string_iterator final {
protected:
    std::string input;
    std::size_t index = 0;
public:
    auto current() const -> std::optional<unsigned char>;
    auto consume() -> unsigned char;
    auto remaining() -> std::string;

    template<typename callback_until>
    auto skip(callback_until until) -> void;

    template<typename callback_until>
    auto collect(callback_until until) -> std::string;

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
