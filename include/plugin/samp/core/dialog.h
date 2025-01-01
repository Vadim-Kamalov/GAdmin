#ifndef GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
#define GADMIN_PLUGIN_SAMP_CORE_DIALOG_H

#include "plugin/samp/network/bit_stream.h"
#include <cstdint>
#include <utility>

namespace plugin::samp {

class dialog {
private:
    static std::uintptr_t instance() noexcept;
public:
    enum class button { left, right };
public:
    static constexpr std::uint8_t event_id = 61;
    static constexpr std::uint8_t send_response_id = 62;

    std::uint16_t id;
    std::uint8_t style;
    std::string title, text;
    std::pair<std::string, std::string> buttons;
    bool valid = true;

    static void send_response(std::uint16_t id, std::uint8_t button_id, std::uint16_t list_item = 65535,
                              const std::string_view& input = "") noexcept;

    static bool is_active() noexcept;

    template<button button>
    void send_response(std::uint16_t list_item = 65535, const std::string_view& input = "") const;

    explicit dialog(samp::bit_stream* bit_stream);
}; // class dialog

} // namespace plugin::samp

template<plugin::samp::dialog::button button>
void
plugin::samp::dialog::send_response(std::uint16_t list_item, const std::string_view& input) const {
    send_response(id, std::to_underlying(button), list_item, input);
}

#endif // GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
