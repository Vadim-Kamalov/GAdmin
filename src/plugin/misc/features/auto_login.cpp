#include "plugin/misc/features/auto_login.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/plugin.h"

bool
plugin::misc::features::auto_login::on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog) const {
    if (!dialog || dialog.style != samp::dialog::style::password)
        return true;

    auto& feature_settings = (*configuration)["misc"]["auto_login"];
    configuration_t configuration = feature_settings;
    
    if (dialog.text.contains("Для продолжения игры, Вам необходимо авторизоваться") &&
        !configuration.account_password.empty())
    {
        if (dialog.text.contains("Попытка входа:")) {
            gui::notify::send(gui::notification("Неверный пароль!", incorrect_password_notification, ICON_CIRCLE_WARNING));
            feature_settings["account_password"] = "";
            return true;
        }

        dialog.send_response(samp::dialog::button::right, samp::dialog::list_item_none, configuration.account_password);

        return false;
    }

    if (dialog.text.contains("{FFFFFF}Введите пароль:") && dialog.text.contains("{4a86b6}Авторизация") &&
        dialog.buttons.first == "Далее" && dialog.buttons.second == "Отмена" && !configuration.alogin_password.empty())
    {
        dialog.send_response(samp::dialog::button::right, samp::dialog::list_item_none, configuration.alogin_password);
        return false;
    }

    return true;
}

bool
plugin::misc::features::auto_login::on_server_message(const samp::event<samp::event_id::server_message>& message) const {
    configuration_t feature_configuration = (*configuration)["misc"]["auto_login"];
    
    if (message.text == "Вы были отсоединены от сервера за неправильный пароль администрирования." &&
        !feature_configuration.alogin_password.empty())
    {
        gui::notify::send(gui::notification("Неверный пароль!", incorrect_password_notification, ICON_CIRCLE_WARNING));
        (*configuration)["misc"]["auto_login"]["alogin_password"] = "";
    }

    return true;
}

bool
plugin::misc::features::auto_login::on_event(const samp::event_info& event) {
    configuration_t feature_configuration = (*configuration)["misc"]["auto_login"];
    
    if (!feature_configuration.use || event != samp::event_type::incoming_rpc)
        return true;

    if (event == samp::event_id::show_dialog)
        return on_show_dialog(event.create<samp::event_id::show_dialog>());
    else if (event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}
