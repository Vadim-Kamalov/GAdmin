#include "plugin/gui/key_names.h"

std::string
plugin::gui::key_to_string(std::uint8_t key) {
    return (key_names.contains(key)) ? key_names.at(key) : "Unknown";
}
