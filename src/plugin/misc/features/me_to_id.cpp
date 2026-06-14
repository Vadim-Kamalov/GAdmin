/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/misc/features/me_to_id.h"
#include "plugin/samp/core/user.h"
#include "plugin/types/string_iterator.h"
#include "plugin/plugin.h"

#include <cctype>
#include <string>

auto plugin::misc::features::me_to_id::on_send_command(const samp::out_event<samp::event_id::send_command>& event) const
    -> bool
{
    if (!(*configuration)["misc"]["me_to_id"])
        return true;

    types::string_iterator iterator(event.command, 1);

    std::string command_name = iterator.collect([](unsigned char c) { return !std::isspace(c); });
    std::string separator    = iterator.collect([](unsigned char c) { return  std::isspace(c); });
    std::string first_argument = iterator.collect([](unsigned char c) { return !std::isspace(c); });

    if (first_argument != "me")
        return true;

    std::string rest = iterator.remaining();
    std::string new_command = command_name + separator + std::to_string(samp::user::get_id()) + rest;

    event.write_command('/' + new_command);

    return true;
}

auto plugin::misc::features::me_to_id::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    return true;
}
