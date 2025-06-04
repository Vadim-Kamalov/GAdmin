#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <nlohmann/json.hpp>

namespace plugin::misc::features {

class auto_login final : public feature {
private:
    struct configuration_t final {
        bool use;
        std::string account_password;
        std::string alogin_password;
    }; // struct configuration_t final

    auto on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const -> bool;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(configuration_t, use, account_password, alogin_password);
    
    static constexpr types::zstring_t incorrect_password_notification
        = "Вы ввели неверный пароль в настройка для авто-ввода. Пароль был сброшен";
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class auto_login : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H
