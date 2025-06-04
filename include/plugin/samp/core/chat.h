#ifndef GADMIN_PLUGIN_SAMP_CORE_CHAT_H
#define GADMIN_PLUGIN_SAMP_CORE_CHAT_H

#include "plugin/string_utils.h"
#include "plugin/types/address.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include <format>

namespace plugin {
namespace signatures {

using add_message_t = void(__thiscall*)(std::uintptr_t, unsigned long, types::zstring_t);

} // namespace signatures

namespace samp {

class chat final {
private:
    static types::versioned_address_container<signatures::add_message_t> add_message_container;
    static types::versioned_address_container<std::uintptr_t> instance_container;
public:
    template<typename... Args>
    static auto add_message(const types::color& color, std::format_string<Args...> fmt, Args&&... args) noexcept -> void;
}; // class chat final

} // namespace samp
} // namespace plugin

template<typename... Args>
auto plugin::samp::chat::add_message(const types::color& color, std::format_string<Args...> fmt, Args&&... args)
    noexcept -> void
{
    add_message_container->invoke(instance_container->read(), color.cast<types::color_type::rgba>(),
                                  string_utils::to_cp1251(std::format(fmt, std::forward<Args>(args)...)).c_str());
}

#endif // GADMIN_PLUGIN_SAMP_CORE_CHAT_H
