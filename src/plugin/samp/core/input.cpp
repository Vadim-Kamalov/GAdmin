#include "plugin/samp/core/input.h"

std::uintptr_t
plugin::samp::input::instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0E8, 0x26E8CC, 0x26EB84, 0x2ACA14 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets));
}

bool
plugin::samp::input::is_active() noexcept {
    return *reinterpret_cast<int*>(instance() + 0x14E0) != 0;
}

bool
plugin::samp::input::is_command_defined(const std::string_view& command) noexcept {
    char (*commands)[max_command_length + 1] = reinterpret_cast<char(*)[max_command_length + 1]>(instance() + 0x24C);

    for (std::uint8_t i = 0; i < max_commands_count; i++)
        if (command == std::string_view(commands[i], max_command_length + 1))
            return true;

    return false;
}

void
plugin::samp::input::open() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x657E0, 0x68D10, 0x69480, 0x68EC0 };
    reinterpret_cast<signatures::open_t>(base(offsets))(instance());
}

void
plugin::samp::input::process(const std::string_view& text) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x65D30, 0x69260, 0x699D0, 0x69410 };
    set_text(text);
    reinterpret_cast<signatures::process_input_t>(base(offsets))(instance());
}

void
plugin::samp::input::set_text(const std::string_view& text) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x80F60, 0x84E70, 0x85580, 0x85000 };
    reinterpret_cast<signatures::set_text_t>(base(offsets))(*reinterpret_cast<std::uintptr_t*>(instance() + 0x8),
                                                            std::string(text).c_str(), false);
}

std::string
plugin::samp::input::get_text() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x81030, 0x84F40, 0x85650, 0x850D0 };
    return std::string(reinterpret_cast<signatures::get_text_t>(base(offsets))(*reinterpret_cast<std::uintptr_t*>(instance() + 0x8)));
}
