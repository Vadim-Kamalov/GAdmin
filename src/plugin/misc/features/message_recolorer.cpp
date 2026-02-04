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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/misc/features/message_recolorer.h"
#include "plugin/types/u8regex.h"
#include "plugin/plugin.h"
#include <ctre.hpp>

plugin::misc::features::message_recolorer::messages_to_recolor_t
plugin::misc::features::message_recolorer::messages_to_recolor = {
    { "Репорт", [](const std::string_view& text, const types::color&) {
        return text.starts_with("[A] Жалоба от ") || text.starts_with("[A] Репорт от ");
    }},

    { "Чат администрации", [](const std::string_view& text, const types::color&) {
        static constexpr ctll::fixed_string pattern = R"(^\[A\d\] \S+\[\d+\]: )";
        return !!ctre::search<pattern>(text);
    }},

    { "Входы/выходы администрации", [](const std::string_view& text, const types::color&) {
        static constexpr ctll::fixed_string pattern =
            R"(\[A\] (\S+)\[(\d+)\] авторизовался как)"
            R"(|\[A\d\] \S+\[(\d+)\] вышел как)"
            R"(|^\[A\] .*\[\d+\] ввёл неверный пароль)";

        return !!types::u8regex::search<pattern>(text);
    }},

    { "Обработка репортов", [](const std::string_view& text, const types::color&) {
        static constexpr ctll::fixed_string pattern = R"(^\[A\] \S+\[\d+\] взялся за обработку репорта)";
        return !!types::u8regex::search<pattern>(text);
    }},

    { "Ответы", [](const std::string_view& text, const types::color&) {
        static constexpr ctll::fixed_string pattern = R"(^\[A\] \S+\[\d+\] ответил \S+\[\d+\]:)";
        return !!types::u8regex::search<pattern>(text);
    }},

    { "Действия администрации", [](const std::string_view& text, const types::color& color) {
        return color == 0xAAAFAFAF && text.starts_with("[A] ");
    }},

    { "Наказания", [](const std::string_view& text, const types::color& color) {
        return text.starts_with("Администратор ") && color == 0xAA4763FF;
    }},

    { "Античит", [](const std::string_view& text, const types::color&) {
        return text.starts_with("Античит")
               || text.starts_with("[BOT DETECTOR]")
               || text.starts_with("ADS <");
    }}
}; // plugin::misc::features::message_recolorer::messages_to_recolor

auto plugin::misc::features::message_recolorer::get_recolored_text(const std::string_view& text,
                                                                   const types::color& original_color) const
    -> std::string
{
    std::string search = std::format("{{{:06X}}}", original_color.cast<types::color_type::rgba>() >> 8);
    std::string replace = std::format("{{{:06X}}}", new_message_color.cast<types::color_type::rgba>() >> 8);

    std::string result(text);
    std::size_t pos = 0;

    while ((pos = result.find(search, pos)) != std::string::npos) {
         result.replace(pos, search.length(), replace);
         pos += replace.length();
    }

    return result;
}

auto plugin::misc::features::message_recolorer::on_server_message(const samp::event<samp::event_id::server_message>& message)
    -> bool
{
    std::size_t text_size = message.text.size();
    std::string end = (text_size > 3) ? message.text.substr(text_size - 3) : "";
    bool have_ellipsis = (end == "..." || end == " ..");

    if (change_next_message_color) {
        change_next_message_color = have_ellipsis;
        message.write(get_recolored_text(message.text, message.color), new_message_color);
        return true;
    }

    auto& items = (*configuration)["misc"]["message_recolorer"]["items"];
    std::string raw_text = string_utils::remove_samp_colors(message.text);

    for (const auto& item : items) {
        if (!item["use"])
            continue;

        std::string key = item["key"];

        if (!messages_to_recolor[key](raw_text, message.color))
            continue;

        new_message_color = item["value"];

        if (have_ellipsis)
            change_next_message_color = true;

        message.write(get_recolored_text(message.text, message.color), new_message_color);

        return true;
    }

    return true;
}

auto plugin::misc::features::message_recolorer::on_event(const samp::event_info& event) -> bool {
    if ((*configuration)["misc"]["message_recolorer"]["use"]
        && event == samp::event_type::incoming_rpc
        && event == samp::event_id::server_message)
    {
        return on_server_message(event.create<samp::event_id::server_message>());
    }

    return true;
}
