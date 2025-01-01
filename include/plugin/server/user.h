#ifndef GADMIN_PLUGIN_SERVER_USER_H
#define GADMIN_PLUGIN_SERVER_USER_H

#include "plugin/samp/core/chat.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/network/event_handler.h"
#include <chrono>

namespace plugin::server {

class user {
private:
    inline static bool on_alogin = false;
    inline static bool can_send_command = false;
    inline static std::chrono::steady_clock::time_point last_time_authorized;

    static bool on_show_dialog(const samp::dialog& dialog);
    static bool on_server_message(const samp::server_message& message);
public:
    static inline bool is_on_alogin() noexcept;
    static void main_loop();
    static void set_alogin_status(bool status);
    static bool on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream);
}; // class user

} // namespace plugin::server

inline bool
plugin::server::user::is_on_alogin() noexcept {
    return on_alogin;
}

#endif // GADMIN_PLUGIN_SERVER_USER_H
