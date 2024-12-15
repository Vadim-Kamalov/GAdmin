#ifndef GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
#define GADMIN_PLUGIN_SAMP_CORE_DIALOG_H

#include "plugin/samp/network/bit_stream.h"
#include <cstdint>

namespace plugin::samp {

class dialog {
public:
    static constexpr std::uint8_t event_id = 61;

    std::uint16_t id;
    std::uint8_t style;
    std::string title, text;
    std::pair<std::string, std::string> buttons;
    bool valid = true;

    static void send_response_to(std::uint16_t id, std::uint8_t button_id, std::uint16_t list_item = 65535,
                                 const std::string_view& input = "") noexcept;

    void send_response(std::uint8_t button_id, std::uint16_t list_item = 65535,
                       const std::string_view& input = "") const;

    explicit dialog(samp::bit_stream* bit_stream);
}; // class dialog

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
