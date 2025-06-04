#include "plugin/misc/features/report_one_color.h"
#include "plugin/types/simple.h"
#include "plugin/plugin.h"

auto plugin::misc::features::report_one_color::on_server_message(const samp::event<samp::event_id::server_message>& message)
    -> bool
{
    static constexpr types::zstring_t complaint_text_start = "[A] Жалоба от ";
    static constexpr types::zstring_t report_text_start = "[A] Репорт от ";

    std::size_t text_size = message.text.size();
    std::string end = (text_size > 3) ? message.text.substr(text_size - 3) : "";
    bool have_ellipsis = end == "..." || end == " ..";

    if (change_next_message_color) {
        types::color new_color = (*configuration)["misc"]["report_one_color"]["color"];
        
        change_next_message_color = have_ellipsis;
        message.write(message.text, new_color);
        
        return true;
    }
    
    std::string start = message.text.substr(0, std::char_traits<char>::length(complaint_text_start));

    if (start == complaint_text_start || start == report_text_start) {
        types::color new_color = (*configuration)["misc"]["report_one_color"]["color"];
        
        if (have_ellipsis)
            change_next_message_color = true;

        message.write(message.text, new_color);
    }

    return true;
}

auto plugin::misc::features::report_one_color::on_event(const samp::event_info& event) -> bool {
    bool use = (*configuration)["misc"]["report_one_color"]["use"];

    if (use && event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
