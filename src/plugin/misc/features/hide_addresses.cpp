#include "plugin/misc/features/hide_addresses.h"
#include "plugin/types/string_iterator.h"
#include "plugin/plugin.h"

std::optional<std::string>
plugin::misc::features::hide_addresses::try_change_addresses(const std::string_view& input) const {
    types::string_iterator iterator(input);
    std::string output;

    while (iterator.current().has_value()) {
        if (std::isdigit(*iterator.current())) {
            std::string potential_ip =
                iterator.collect([](unsigned char c) { return std::isdigit(c) || c == '.'; });

            output.append((is_ip_address(potential_ip) ? "XXX.XXX.XXX.XXX" : potential_ip));
        } else
            output.push_back(iterator.consume());
    }

    if (output == input)
        return {};

    return output;
}

bool
plugin::misc::features::hide_addresses::is_ip_address(const std::string_view& input) const {
    std::size_t dot_count = 0;
    std::size_t digit_count = 0;
    bool valid = true;

    for (char c : input) {
        if (c == '.') {
            if (digit_count == 0 || digit_count > 3) {
                valid = false;
                break;
            }

            digit_count = 0;
            dot_count++;
        } else if (std::isdigit(c))
            digit_count++;
        else {
            valid = false;
            break;
        }
    }

    return valid && digit_count >= 1 && digit_count <= 3 && dot_count == 3;
}

bool
plugin::misc::features::hide_addresses::on_server_message(const samp::event<samp::event_id::server_message>& message) const {
    if (auto new_text = try_change_addresses(message.text))
        message.write_text(*new_text);

    return true;
}

bool
plugin::misc::features::hide_addresses::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const {
    if (!dialog)
        return true;

    if (auto new_text = try_change_addresses(dialog.text))
        dialog.write_text(*new_text);

    return true;
}

bool
plugin::misc::features::hide_addresses::on_event(const samp::event_info& event) {
    bool use = (*configuration)["misc"]["hide_addresses"];

    if (!use || event != samp::event_type::incoming_rpc)
        return true;

    if (event == samp::event_id::show_dialog)
        return on_show_dialog(event.create<samp::event_id::show_dialog>());
    else if (event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
