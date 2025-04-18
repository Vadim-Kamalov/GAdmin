#include "plugin/samp/core/input.h"
#include "plugin/string_utils.h"

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::input::instance_container = { 0x21A0E8, 0x26E8CC, 0x26EB84, 0x2ACA14 };

plugin::types::versioned_address_container<plugin::signatures::send_command_t>
plugin::samp::input::send_command_container = { 0x65C60, 0x69190, 0x69900, 0x69340 };

plugin::types::versioned_address_container<plugin::signatures::open_t>
plugin::samp::input::open_container = { 0x657E0, 0x68D10, 0x69480, 0x68EC0 };

plugin::types::versioned_address_container<plugin::signatures::process_input_t>
plugin::samp::input::process_input_container = { 0x65D30, 0x69260, 0x699D0, 0x69410 };

plugin::types::versioned_address_container<plugin::signatures::set_text_t>
plugin::samp::input::set_text_container = { 0x80F60, 0x84E70, 0x85580, 0x85000 };

plugin::types::versioned_address_container<plugin::signatures::get_text_t>
plugin::samp::input::get_text_container = { 0x81030, 0x84F40, 0x85650, 0x850D0 };

bool
plugin::samp::input::is_active() noexcept {
    return active_offset.read(instance_container->read()) != 0;
}

bool
plugin::samp::input::is_command_defined(const std::string_view& command) noexcept {
    auto commands = commands_offset.read(instance_container->read());

    for (std::uint8_t i = 0; i < max_commands_count; i++)
        if (command == std::string_view(commands[i], max_command_length + 1))
            return true;

    return false;
}

void
plugin::samp::input::open() noexcept {
    open_container->invoke(instance_container->read());
}

void
plugin::samp::input::process(const std::string_view& text) noexcept {
    set_text(text);
    process_input_container->invoke(instance_container->read());
}

void
plugin::samp::input::set_text(const std::string_view& text) noexcept {
    set_text_container->invoke(dxut_input_offset.read(instance_container->read()),
                               string_utils::to_cp1251(std::string(text)).c_str(), false);
}

std::string
plugin::samp::input::get_text() noexcept {
    return string_utils::to_utf8(get_text_container->invoke(dxut_input_offset.read(instance_container->read())));
}
