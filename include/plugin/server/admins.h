#ifndef GADMIN_PLUGIN_SERVER_ADMINS_H
#define GADMIN_PLUGIN_SERVER_ADMINS_H

#include "plugin/samp/core/chat.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/network/event_handler.h"

namespace plugin::server {

struct Admin {
    std::string nickname;
    std::uint16_t id;
    std::uint8_t level;
}; // struct Admin

class Admins {
private:
    inline static std::vector<Admin> list;
    static bool on_show_dialog(const samp::Dialog& dialog);
    static bool on_server_message(const samp::ServerMessage& message);
public:
    static std::optional<Admin> find(const std::string_view& nickname);
    static void on_alogout();
    static bool on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream);
}; // class Admins

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_ADMINS_H
