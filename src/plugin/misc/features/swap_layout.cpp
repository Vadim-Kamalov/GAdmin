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

#include "plugin/misc/features/swap_layout.h"
#include "plugin/types/string_iterator.h"
#include "plugin/samp/core/input.h"
#include "plugin/server/user.h"
#include "plugin/server/spectator.h"
#include "plugin/plugin.h"

std::unordered_map<std::string, char> plugin::misc::features::swap_layout::russian_to_english_keymap = {
    { "й", 'q' }, { "ц", 'w' }, { "у", 'e' }, { "к", 'r' }, { "е", 't' }, { "н", 'y' }, { "г", 'u' },
    { "ш", 'i' }, { "щ", 'o' }, { "з", 'p' }, { "х", '[' }, { "ъ", ']' }, { "ф", 'a' }, { "ы", 's' },
    { "в", 'd' }, { "а", 'f' }, { "п", 'g' }, { "р", 'h' }, { "о", 'j' }, { "л", 'k' }, { "д", 'l' },
    { "ж", ';' }, { "э", '\'' }, { "я", 'z' }, { "ч", 'x' }, { "с", 'c' }, { "м", 'v' }, { "и", 'b' },
    { "т", 'n' }, { "ь", 'm' }, { "б", ',' }, { "ю", '.' }, { "Й", 'Q' }, { "Ц", 'Q' }, { "У", 'W' },
    { "К", 'E' }, { "Е", 'R' }, { "Н", 'T' }, { "Г", 'Y' }, { "Ш", 'U' }, { "Щ", 'I' }, { "З", 'O' },
    { "Х", '{' }, { "Ъ", '}' }, { "Ф", 'A' }, { "Ы", 'S' }, { "В", 'D' }, { "А", 'F' }, { "П", 'G' },
    { "Р", 'H' }, { "О", 'J' }, { "Л", 'K' }, { "Д", 'L' }, { "Ж", ':' }, { "Э", '"' }, { "Я", 'Z' },
    { "Ч", 'X' }, { "С", 'C' }, { "М", 'V' }, { "И", 'B' }, { "Т", 'N' }, { "Ь", 'M' }, { "Б", '<' },
    { "Ю", '>' },
}; // std::unordered_map<std::string, char> plugin::misc::features::swap_layout::russian_to_english_keymap

auto plugin::misc::features::swap_layout::swap_characters(std::string input) -> std::string {
    for (const auto& [ first, second ] : russian_to_english_keymap) {
        std::size_t pos = 0;

        while ((pos = input.find(first, pos)) != std::string::npos) {
            input.replace(pos, first.length(), 1, second);
            pos += 1; 
        }
    }

    return input;
}

auto plugin::misc::features::swap_layout::on_send_chat(const samp::out_event<samp::event_id::send_chat>& chat) const
    -> bool
{
    types::string_iterator iterator(chat.text);

    if (iterator.consume() != '.') // chat.text.length() is always > 0
        return true;

    std::string command_name = iterator.collect_word();

    if (command_name.empty())
        return true;

    std::string new_command_name = swap_characters(command_name);

    if (new_command_name == command_name)
        return true;

    std::string full_command = std::format("/{}{}", new_command_name, iterator.remaining());

    if (samp::input::is_command_defined(new_command_name))
        samp::input::process(full_command);
    else
        samp::input::send_command("{}", full_command);

    return false;
}

auto plugin::misc::features::swap_layout::on_event(const samp::event_info& event) -> bool {
    bool use_feature = (*configuration)["misc"]["swap_layout"];

    if (use_feature && event == samp::event_type::outgoing_rpc && event == samp::event_id::send_chat)
        return on_send_chat(event.create<samp::event_id::send_chat, samp::event_type::outgoing_rpc>());

    return true;
}
