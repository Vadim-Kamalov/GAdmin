#ifndef GADMIN_PLUGIN_SERVER_USER_H
#define GADMIN_PLUGIN_SERVER_USER_H

#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <chrono>

namespace plugin::server {

class user final {
private:
    inline static bool on_alogin = false;
    inline static bool can_send_command = false;
    inline static std::chrono::steady_clock::time_point last_time_authorized;

    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
public:
    static inline auto is_on_alogin() noexcept -> bool;
    static auto main_loop() -> void;
    static auto set_alogin_status(bool status) -> void;
    static auto on_event(const samp::event_info& event) -> bool;
}; // class user final

} // namespace plugin::server

inline auto plugin::server::user::is_on_alogin() noexcept -> bool {
    return on_alogin;
}

#endif // GADMIN_PLUGIN_SERVER_USER_H
