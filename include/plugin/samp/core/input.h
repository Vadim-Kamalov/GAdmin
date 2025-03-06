#ifndef GADMIN_PLUGIN_SAMP_CORE_INPUT_H
#define GADMIN_PLUGIN_SAMP_CORE_INPUT_H

#include "plugin/encoding.h"
#include "plugin/types/address.h"
#include "plugin/types/simple.h"
#include <format>

namespace plugin {
namespace signatures {

using send_command_t = void(__thiscall*)(std::uintptr_t, types::zstring_t);
using get_text_t = types::zstring_t(__thiscall*)(std::uintptr_t);
using set_text_t = void(__thiscall*)(std::uintptr_t, types::zstring_t, bool);
using open_t = void(__thiscall*)(std::uintptr_t);
using process_input_t = void(__thiscall*)(std::uintptr_t);

} // namespace signatures

namespace samp {

class input {
public:
    static constexpr std::uint8_t max_commands_count = 144;
    static constexpr std::uint8_t max_command_length = 32;
private:
    static inline types::offset<int> active_offset = 0x14E0;
    static inline types::offset<char(*)[max_command_length + 1]> commands_offset = 0x24C;
    static inline types::offset<std::uintptr_t> dxut_input_offset = 0x8;

    static types::versioned_address_container<std::uintptr_t> instance_container;
    static types::versioned_address_container<signatures::send_command_t> send_command_container;
    static types::versioned_address_container<signatures::open_t> open_container;
    static types::versioned_address_container<signatures::process_input_t> process_input_container;
    static types::versioned_address_container<signatures::set_text_t> set_text_container;
    static types::versioned_address_container<signatures::get_text_t> get_text_container;
public:
    static bool is_active() noexcept;
    static bool is_command_defined(const std::string_view& command) noexcept;

    static void open() noexcept;
    static void process(const std::string_view& text) noexcept;
    static void set_text(const std::string_view& text) noexcept;

    static std::string get_text() noexcept;

    template<typename... Args>
    static void send_command(std::format_string<Args...> fmt, Args&&... args) noexcept;
}; // class input

} // namespace samp
} // namespace plugin

template<typename... Args>
void
plugin::samp::input::send_command(std::format_string<Args...> fmt, Args&&... args) noexcept {
    send_command_container->invoke(instance_container->read(), encoding::to_cp1251(
        std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_INPUT_H
