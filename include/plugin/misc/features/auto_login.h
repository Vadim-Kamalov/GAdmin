#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <nlohmann/json.hpp>

namespace plugin::misc::features {

class auto_login : public feature {
private:
    struct configuration_t {
        bool use;
        std::string account_password;
        std::string alogin_password;
    }; // struct configuration_t

    bool on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const;
    bool on_server_message(const samp::event<samp::event_id::server_message>& message) const;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(configuration_t, use, account_password, alogin_password);
    
    static constexpr types::zstring_t incorrect_password_notification
        = "Вы ввели неверный пароль в настройка для авто-ввода. Пароль был сброшен";
public:
    bool on_event(const samp::event_info& event) override;
}; // class auto_login : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H
