/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_LOGIN_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <nlohmann/json.hpp>

namespace plugin::misc::features {

/// Represents a feature that allows to automatically type and send user's passwords
/// in the dialog of an authorization and `/alogin`. Only works if a feature is enabled.
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
