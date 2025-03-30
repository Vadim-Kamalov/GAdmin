#include "plugin/types/string_iterator.h"

std::optional<unsigned char>
plugin::types::string_iterator::current() const {
    if (index >= input.length())
        return {};

    return input[index];
}

unsigned char
plugin::types::string_iterator::consume() {
    return input[index++];
}
