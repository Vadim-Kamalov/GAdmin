#ifndef GADMIN_PLUGIN_SAMP_CORE_INPUT_H
#define GADMIN_PLUGIN_SAMP_CORE_INPUT_H

#include "plugin/samp/samp.h"
#include "plugin/encoding.h"
#include <format>

namespace plugin {
namespace signatures {

using SendCommand = void(__thiscall*)(std::uintptr_t, const char*);

} // namespace signatures

namespace samp::input {

std::uintptr_t instance() noexcept;

template<typename... Args>
static void send_command(std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x65C60, 0x69190, 0x69900, 0x69340 };
    reinterpret_cast<signatures::SendCommand>(base(offsets[std::to_underlying(get_version())]))
        (instance(), encoding::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

} // namespace samp::input
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_INPUT_H
