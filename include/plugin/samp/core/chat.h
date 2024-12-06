#ifndef GADMIN_PLUGIN_SAMP_CORE_CHAT_H
#define GADMIN_PLUGIN_SAMP_CORE_CHAT_H

#include "plugin/encoding.h"
#include "plugin/samp/samp.h"
#include <format>

namespace plugin {
namespace signatures {

using AddMessage = void(__thiscall*)(std::uintptr_t, unsigned long, const char*);

} // namespace signatures

namespace samp::chat {

static inline std::uintptr_t
instance() noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x21A0E4, 0x26E8C8, 0x26EB80, 0x2ACA10 };
    return *reinterpret_cast<std::uintptr_t*>(base(offsets[std::to_underlying(get_version())]));
}

template<typename... Args>
static void
add_message(unsigned long color, std::format_string<Args...> fmt, Args&&... args) noexcept {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x645A0, 0x679F0, 0x68170, 0x67BE0 };
    reinterpret_cast<signatures::AddMessage>(base(offsets[std::to_underlying(get_version())]))
        (instance(), color, encoding::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

} // namespace samp::chat
} // namespace plugin

#endif // GADMIN_PLUGIN_SAMP_CORE_CHAT_H
