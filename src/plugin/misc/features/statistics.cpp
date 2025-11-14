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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/misc/features/statistics.h"
#include "plugin/types/u8regex.h"
#include "plugin/types/string_iterator.h"
#include "plugin/server/user.h"
#include "plugin/samp/core/user.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include <fstream>

std::filesystem::path
plugin::misc::features::statistics_updater::file_path =
    std::filesystem::current_path() / "gadmin" / "configuration" / "statistics.dat";

auto plugin::misc::statistics_t::date_t::operator==(const date_t& other) const -> bool {
    return year == other.year && month == other.month && day == other.day;
}

auto plugin::misc::statistics_t::date_t::today() noexcept -> date_t {
    auto now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    auto now_tm = *std::localtime(&now_time_t);

    std::uint8_t year = now_tm.tm_year - 100;
    std::uint8_t month = now_tm.tm_mon + 1;
    std::uint8_t day = now_tm.tm_mday;

    return { year, month, day };
}

auto plugin::misc::statistics_t::range_t::operator==(const range_t& other) const -> bool {
    return first == other.first && second == other.second;
}

auto plugin::misc::statistics_t::range_t::current_hours() noexcept -> range_t {
    auto now = std::chrono::system_clock::now();
    std::time_t time = std::chrono::system_clock::to_time_t(now);
    
    std::uint8_t current_hour = std::localtime(&time)->tm_hour;
    std::uint8_t next_hour = (current_hour + 1) % 24;

    return { current_hour, next_hour };
}

auto plugin::misc::statistics_t::date_entry_t::increment_value_at(const entry_type& entry, const range_t& range) -> void {
    entry_t& needed_entry = entries[std::to_underlying(entry)];

    if (auto it = std::ranges::find(needed_entry, range, &value_t::range); it != needed_entry.end()) {
        it->value++;
        return;
    }

    needed_entry.push_back({ range, 1 });
}

auto plugin::misc::statistics_t::read_date(std::ifstream& file, date_t& output) -> bool {
    return read_value(file, output.year)
        && read_value(file, output.month)
        && read_value(file, output.day);
}

auto plugin::misc::statistics_t::read_value(std::ifstream& file, value_t& output) -> bool {
    return read_value(file, output.range.first)
        && read_value(file, output.range.second)
        && read_value(file, output.value);
}

auto plugin::misc::statistics_t::write_date(std::ofstream& file, const date_t& date) -> bool {
    return write_value(file, date.year)
        && write_value(file, date.month)
        && write_value(file, date.day);
}

auto plugin::misc::statistics_t::write_value(std::ofstream& file, const value_t& value) -> bool {
    return write_value(file, value.range.first)
        && write_value(file, value.range.second)
        && write_value(file, value.value);
}

auto plugin::misc::statistics_t::read(const std::filesystem::path& path) -> void {
    std::ifstream file(path, std::ios::binary);
    
    if (!file) {
        log::error("statistics_t::read [with path = \"{}\"]: std::ifstream::ifstream(...)", path.string());
        return;
    }

    date_entries.clear();

    while (file.peek() != EOF) {
        std::uint8_t opcode = 0xFF;

        if (!read_value(file, opcode) || opcode != OPCODE_DATE) {
            log::error("statistics_t::read: failed to read OPCODE_DATE");
            break;
        }

        date_entry_t date_entry;
        std::uint8_t value_count = 0;

        if (!read_date(file, date_entry.date)) {
            log::error("statistics_t::read: failed to read date_t");
            return;
        }

        while (file.peek() & OPCODE_ENTRY && read_value(file, opcode)) {
            if (!read_value(file, value_count)) {
                log::error("statistics_t::read: failed to read OPCODE_ENTRY (value_count)");
                return;
            }

            for (int i = 0; i < value_count; i++) {
                value_t value;

                if (!read_value(file, value)) {
                    log::error("statistics_t::read: failed to read value_t");
                    return;
                }

                date_entry.entries[(opcode >> 1)].push_back(value);
            }
        }

        date_entries.push_back(std::move(date_entry));
    }
}

auto plugin::misc::statistics_t::write(const std::filesystem::path& path) -> void {
    std::ofstream file(path, std::ios::binary);
    
    if (!file) {
        log::error("statistics_t::write [with path = \"{}\"]: std::ofstream::ofstream(...)", path.string());
        return;
    }

    for (const auto& entry : date_entries) {
        if (!write_value(file, OPCODE_DATE) || !write_date(file, entry.date)) {
            log::error("statistics_t::write: failed to write OPCODE_DATE");
            return;
        }

        for (std::size_t type = 0; type < entry.entries.size(); type++) {
            if (entry.entries[type].empty())
                continue;

            std::uint8_t opcode = (static_cast<std::uint8_t>(type) << 1) | OPCODE_ENTRY;
            std::uint8_t size = entry.entries[type].size();

            if (!write_value(file, opcode) || !write_value(file, size)) {
                log::error("statistics_t::write: failed to write OPCODE_ENTRY");
                return;
            }

            for (const auto& value : entry.entries[type]) {
                if (!write_value(file, value)) {
                    log::error("statistics_t::write: failed to write value_t");
                    return;
                }
            }
        }
    }
}

auto plugin::misc::statistics_t::get_today_entry() -> date_entry_t& {
    if (auto it = std::ranges::find(date_entries, date_t::today(), &date_entry_t::date); it != date_entries.end())
        return *it;

    date_entries.push_back({ .date = date_t::today() });

    return date_entries.back();
}

auto plugin::misc::features::statistics_updater::try_increment_punishment(const std::string_view& punisment_text) const -> void {
    static const std::vector<std::pair<statistics_t::entry_type, std::string>> message_types = {
        { statistics_t::entry_type::mute, "заблокировал OOC" },
        { statistics_t::entry_type::mute, "заблокировал IC" },
        { statistics_t::entry_type::warn, "выдал предупреждение" },
        { statistics_t::entry_type::ban, "заблокировал" },
        { statistics_t::entry_type::kick, "отсоединил" },
        { statistics_t::entry_type::pk, "установил <Player Kill>" },
        { statistics_t::entry_type::ck, "установил <Character Kill>" }
    }; // static const std::vector<std::pair<found_message_type, std::string>> message_types

    types::string_iterator iterator(punisment_text);
    std::string user_ooc_nickname = (*configuration)["user"]["nickname"];
    std::string possible_request_nickname = "// " + user_ooc_nickname;
    std::string sender_nickname = iterator.collect([](unsigned char c) { return !std::isspace(c); });

    if (sender_nickname != user_ooc_nickname && !punisment_text.ends_with(possible_request_nickname))
        return;

    iterator.skip(::isspace);

    std::string remaining = iterator.remaining();

    for (const auto& message_type : message_types) {
        if (remaining.starts_with(message_type.second)) {
            statistics.get_today_entry().increment_value_at(message_type.first, statistics_t::range_t::current_hours());
            return;
        }
    }
}

auto plugin::misc::features::statistics_updater::on_server_message(const samp::event<samp::event_id::server_message>& message) const
    -> bool
{
    static constexpr ctll::fixed_string a_chat_message_pattern = R"(^\[A\d\] \S+\[(\d+)\]:)";
    static constexpr ctll::fixed_string answer_pattern = R"(^\[A\] \S+\[(\d+)\] ответил \S+\[\d+\]:)";

    std::uint16_t found_id = 0xFFFF;
    auto found = statistics_t::entry_type::none;

    if (auto [ whole, id ] = ctre::search<a_chat_message_pattern>(message.text); whole) {
        found_id = std::stoul(id.str());
        found = statistics_t::entry_type::a_chat_message;
    } else if (auto matches = types::u8regex::search<answer_pattern>(message.text)) {
        found_id = std::stoul(matches.get_string<1>());
        found = statistics_t::entry_type::answer;
    }

    if (found_id == samp::user::get_id()) {
        statistics.get_today_entry().increment_value_at(found, statistics_t::range_t::current_hours());
        return true;
    }

    std::string start = "Администратор ";

    if (!message.text.compare(0, start.length(), start) && message.color == 0xAA4763FF) {
        try_increment_punishment(message.text.substr(start.length()));
        return true;
    }

    return true;
}

auto plugin::misc::features::statistics_updater::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc && event == samp::event_id::server_message)
        return on_server_message(event.create<samp::event_id::server_message>());

    return true;
}

auto plugin::misc::features::statistics_updater::main_loop() -> void {
    using namespace std::chrono_literals;

    auto now = std::chrono::steady_clock::now();

    if (now - time_updated < 1s || game::is_menu_opened())
        return;

    statistics_t::date_entry_t& today_entry = statistics.get_today_entry();
    statistics_t::range_t current_hours = statistics_t::range_t::current_hours();
    time_updated = now;
    
    if (server::user::is_on_alogin())
        today_entry.increment_value_at(statistics_t::entry_type::time_on_alogin, current_hours);
   
    today_entry.increment_value_at(statistics_t::entry_type::total_time, current_hours);
}

plugin::misc::features::statistics_updater::statistics_updater() {
    if (!std::filesystem::exists(file_path))
        return;

    statistics.read(file_path);
}

plugin::misc::features::statistics_updater::~statistics_updater() noexcept {
    statistics.write(file_path);
}
