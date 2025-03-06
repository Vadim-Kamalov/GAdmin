#ifndef GADMIN_PLUGIN_SERVER_USER_H
#define GADMIN_PLUGIN_SERVER_USER_H

#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <chrono>

namespace plugin::server {

class user {
private:
    inline static bool on_alogin = false;
    inline static bool can_send_command = false;
    inline static std::chrono::steady_clock::time_point last_time_authorized;

    static bool on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog);
    static bool on_server_message(const samp::event<samp::event_id::server_message>& message);
public:
    static inline bool is_on_alogin() noexcept;
    static void main_loop();
    static void set_alogin_status(bool status);
    static bool on_event(const samp::event_info& event);
}; // class user

} // namespace plugin::server

inline bool
plugin::server::user::is_on_alogin() noexcept {
    return on_alogin;
}

#endif // GADMIN_PLUGIN_SERVER_USER_H
