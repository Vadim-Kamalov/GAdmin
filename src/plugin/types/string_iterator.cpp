#include "plugin/types/string_iterator.h"

auto plugin::types::string_iterator::current() const
    -> std::optional<unsigned char>
{
    if (index >= input.length())
        return {};

    return input[index];
}

auto plugin::types::string_iterator::consume()
    -> unsigned char
{
    return input[index++];
}

auto plugin::types::string_iterator::remaining()
    -> std::string
{
    return input.substr(index);
}
