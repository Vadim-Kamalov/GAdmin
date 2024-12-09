#ifndef GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
#define GADMIN_PLUGIN_SAMP_CORE_DIALOG_H

#include "plugin/samp/network/bit_stream.h"
#include <cstdint>

namespace plugin::samp {
namespace dialog {

void send_response(std::uint16_t id, std::uint8_t button_id, std::uint16_t list_item = 65535, const std::string_view& input = "") noexcept;

} // namespace dialog

class Dialog {
public:
    static constexpr std::uint8_t event_id = 61;

    std::uint16_t id;
    std::uint8_t style;
    std::string title, text;
    std::pair<std::string, std::string> buttons;
    bool valid = true;

    template<std::uint8_t ButtonId, std::uint16_t ListItem = 65535>
    void send_response(const std::string_view& input = "") const {
        dialog::send_response(id, ButtonId, ListItem, input);
    }

    explicit Dialog(samp::BitStream* bit_stream);
}; // class Dialog

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
