#include "plugin/gui/key_names.h"

auto plugin::gui::key_to_string(std::uint8_t key) noexcept -> std::string {
    return (key_names.contains(key)) ? key_names.at(key) : "Unknown";
}
