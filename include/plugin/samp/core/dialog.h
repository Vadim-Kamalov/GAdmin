#ifndef GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
#define GADMIN_PLUGIN_SAMP_CORE_DIALOG_H

#include "plugin/types/address.h"
#include <cstdint>

namespace plugin::samp {

class dialog final {
private:
    static types::versioned_address_container<std::uintptr_t> instance_container;
    static inline types::offset<int> active_address = 0x50; 
public:
    enum class button : std::uint8_t { left, right };
    enum class style : std::uint8_t {
        message_box,
        input,
        list,
        password,
        tab_list,
        tab_list_headers
    }; // enum class style : std::uint8_t
public:
    static constexpr std::uint16_t list_item_none = 0xFFFF;
    static constexpr std::uint16_t invalid_id = 0xFFFF;
    static constexpr std::uint8_t send_response_id = 62;

    static auto send_response(std::uint16_t id, const button& button, std::uint16_t list_item = list_item_none,
                              const std::string_view& input = "") noexcept -> void;

    static auto is_active() noexcept -> bool;
}; // class dialog final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
