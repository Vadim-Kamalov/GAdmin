#ifndef GADMIN_PLUGIN_SERVER_ADMINS_H
#define GADMIN_PLUGIN_SERVER_ADMINS_H

#include "plugin/samp/events/dialog.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/server_quit.h"
#include "plugin/samp/events/set_player_name.h"
#include <nlohmann/detail/macro_scope.hpp>
#include <vector>

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
    static bool on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog);
    static bool on_server_message(const samp::event<samp::event_id::server_message>& message);
    static bool on_server_quit(const samp::event<samp::event_id::server_quit>& disconnected);
    static bool on_set_player_name(const samp::event<samp::event_id::set_player_name>& player);

    static void update_admins(const std::string_view& dialog_text);
    static void add_connected_admin(const admin& connected_admin);
    static void remove_disconnected_admin(std::uint16_t id);
public:
    inline static std::vector<admin> list;

    static std::optional<admin> get_admin(std::uint16_t id);
    static void on_alogout();
    static bool on_event(const samp::event_info& info);
}; // class admins

NLOHMANN_JSON_SERIALIZE_ENUM(admin::sort_option, {
    { admin::sort_option::disabled, "disabled" },
    { admin::sort_option::length, "length" },
    { admin::sort_option::id, "id" },
    { admin::sort_option::level, "level" },
})

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_ADMINS_H
