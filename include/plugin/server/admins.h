#ifndef GADMIN_PLUGIN_SERVER_ADMINS_H
#define GADMIN_PLUGIN_SERVER_ADMINS_H

#include "plugin/samp/core/chat.h"
#include "plugin/samp/core/dialog.h"
#include "plugin/samp/network/event_handler.h"
#include <nlohmann/detail/macro_scope.hpp>

namespace plugin::server {

struct admin {
    std::string nickname;
    std::uint16_t id;
    std::uint8_t level;

    enum class sort_option { disabled, length, id, level };

    static void sort(std::vector<admin>& admins, const sort_option& option);
}; // struct admin

class admins {
private:
    static bool on_show_dialog(const samp::dialog& dialog);
    static bool on_server_message(const samp::server_message& message);
    static void update_admins(const std::string_view& dialog_text);
    static void add_connected_admin(const admin& connected_admin);
    static void remove_disconnected_admin(std::uint16_t id);
public:
    inline static std::vector<admin> list;

    static void on_alogout();
    static bool on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream);
}; // class admins

NLOHMANN_JSON_SERIALIZE_ENUM(admin::sort_option, {
    { admin::sort_option::disabled, "disabled" },
    { admin::sort_option::length, "length" },
    { admin::sort_option::id, "id" },
    { admin::sort_option::level, "level" },
})

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_ADMINS_H
