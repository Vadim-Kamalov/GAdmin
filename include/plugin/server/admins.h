#ifndef GADMIN_PLUGIN_SERVER_ADMINS_H
#define GADMIN_PLUGIN_SERVER_ADMINS_H

#include "plugin/samp/events/dialog.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/server_quit.h"
#include "plugin/samp/events/set_player_name.h"
#include <nlohmann/detail/macro_scope.hpp>
#include <vector>

namespace plugin::server {

struct admin final {
    std::string nickname;
    std::uint16_t id;
    std::uint8_t level;

    enum class sort_option {
        disabled,
        length,
        id,
        level
    }; // enum class sort_option;

    static auto sort(std::vector<admin>& admins, const sort_option& option) -> void;
}; // struct admin final

class admins final {
private:
    static auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) -> bool;
    static auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    static auto on_server_quit(const samp::event<samp::event_id::server_quit>& disconnected) -> bool;
    static auto on_set_player_name(const samp::event<samp::event_id::set_player_name>& player) -> bool;

    static auto update_admins(const std::string_view& dialog_text) -> void;
    static auto add_connected_admin(const admin& connected_admin) -> void;
    static auto remove_disconnected_admin(std::uint16_t id) -> void;
public:
    inline static std::vector<admin> list;

    static auto get_admin(std::uint16_t id) -> std::optional<admin>;
    static auto on_alogout() -> void;
    static auto on_event(const samp::event_info& info) -> bool;
}; // class admins final

NLOHMANN_JSON_SERIALIZE_ENUM(admin::sort_option, {
    { admin::sort_option::disabled, "disabled" },
    { admin::sort_option::length, "length" },
    { admin::sort_option::id, "id" },
    { admin::sort_option::level, "level" },
})

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_ADMINS_H
