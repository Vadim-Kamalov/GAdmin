#ifndef GADMIN_PLUGIN_SAMP_CORE_INPUT_H
#define GADMIN_PLUGIN_SAMP_CORE_INPUT_H

#include "plugin/samp/samp.h"
#include "plugin/encoding.h"
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

namespace samp::input {

static constexpr std::uint8_t max_commands_count = 144;
static constexpr std::uint8_t max_command_length = 32;

std::uintptr_t instance() noexcept;

bool is_active() noexcept;
bool is_command_defined(const std::string_view& command) noexcept;

void open() noexcept;
void process(const std::string_view& text) noexcept;
void set_text(const std::string_view& text) noexcept;

std::string get_text() noexcept;

template<typename... Args>
void send_command(std::format_string<Args...> fmt, Args&&... args) noexcept;

} // namespace samp::input
} // namespace plugin

template<typename... Args>
void
plugin::samp::input::send_command(std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x65C60, 0x69190, 0x69900, 0x69340 };
    reinterpret_cast<signatures::send_command_t>(base(offsets))(instance(), encoding::to_cp1251(
        std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_INPUT_H
