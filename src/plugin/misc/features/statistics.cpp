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
    std::filesystem::current_path() / "gadmin" / "configuration" / "statistics.mpk";

auto plugin::misc::statistics_t::value_t::get_current_hour_item() -> item_t& {
    std::time_t time = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::uint8_t current_hour = std::localtime(&time)->tm_hour;
    std::uint8_t next_hour = (current_hour + 1) % 24;
    auto hour_range = std::make_pair(current_hour, next_hour);

    if (auto it = std::find_if(items.begin(), items.end(), [=](const item_t& item) {
        return item.range == hour_range;
    }); it != items.end()) {
        return *it;
    }

    items.push_back({ hour_range, 0 });

    return items.back();
}

auto plugin::misc::statistics_t::get_today_entry() -> entry_t& {
    std::chrono::year_month_day ymd = std::chrono::floor<std::chrono::days>(std::chrono::system_clock::now());
    std::uint8_t day = static_cast<std::uint32_t>(ymd.day());
    std::uint8_t month = static_cast<std::uint32_t>(ymd.month());
    std::uint8_t year = static_cast<int>(ymd.year()) - 2000;

    if (auto it = std::find_if(entries.begin(), entries.end(), [=](const entry_t& entry) {
        return entry.day == day && entry.month == month && entry.year == year;
    }); it != entries.end()) {
        return *it;
    }

    entries.push_back({ day, month, year });

    return entries.back();
}

auto plugin::misc::features::statistics_updater::save_statistics() const noexcept -> void {
    if (std::ofstream file = std::ofstream(file_path, std::ios::out | std::ios::binary)) {
        std::vector<std::uint8_t> bytes = nlohmann::json::to_msgpack(statistics);
        file.write(reinterpret_cast<types::zstring_t>(bytes.data()), bytes.size());
        return;
    }
    
    log::error("failed to write configuration to \"{}\"", file_path.string());
}

auto plugin::misc::features::statistics_updater::read_statistics() const -> void {
    std::ifstream file(file_path, std::ios::binary | std::ios::ate);
    std::ifstream::pos_type pos = file.tellg();

    if (!file) {
        log::fatal("failed to get statistics from \"{}\"", file_path.string());
        return;
    }
    
    std::vector<char> bytes(pos);

    file.seekg(0, std::ios::beg);
    file.read(&bytes[0], pos);

    auto file_json = nlohmann::json::from_msgpack(bytes);

    if (file_json.is_null()) {
        log::error("statistics is corrupted in \"{}\"", file_path.string());
        return;
    }

    statistics = file_json;
}

auto plugin::misc::features::statistics_updater::try_increment_punishment(const std::string_view& punisment_text) const -> void {
    static const std::vector<std::pair<found_message_type, std::string>> message_types = {
        { found_message_type::mute, "заблокировал OOC" },
        { found_message_type::mute, "заблокировал IC" },
        { found_message_type::warn, "выдал предупреждение" },
        { found_message_type::ban, "заблокировал" },
        { found_message_type::kick, "отсоединил" },
        { found_message_type::pk, "установил <Player Kill>" },
        { found_message_type::ck, "установил <Character Kill>" }
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
            increment_statistics_by_type(message_type.first);
            return;
        }
    }
}

auto plugin::misc::features::statistics_updater::increment_statistics_by_type(const found_message_type& type) const -> void {
    if (type == found_message_type::none)
        return;

    statistics_t::entry_t& today_entry = statistics.get_today_entry();

#define FINISH_CASE(KEY) today_entry.KEY.get_current_hour_item().value++; break
    switch (type) {
        case found_message_type::a_chat_message: FINISH_CASE(a_chat_message);
        case found_message_type::answer: FINISH_CASE(answer);
        case found_message_type::ban: FINISH_CASE(ban);
        case found_message_type::pk: FINISH_CASE(pk);
        case found_message_type::ck: FINISH_CASE(ck);
        case found_message_type::warn: FINISH_CASE(warn);
        case found_message_type::kick: FINISH_CASE(kick);
        case found_message_type::mute: FINISH_CASE(mute);
        case found_message_type::none: std::unreachable();
    }
#undef FINISH_CASE
}

auto plugin::misc::features::statistics_updater::on_server_message(const samp::event<samp::event_id::server_message>& message) const
    -> bool
{
    static constexpr ctll::fixed_string a_chat_message_pattern = R"(^\[A\] \S+\[(\d+)\]:)";
    static constexpr ctll::fixed_string answer_pattern = R"(^\[A\] \S+\[(\d+)\] ответил \S+\[\d+\]:)";

    std::uint16_t found_id = 0xFFFF;
    found_message_type found = found_message_type::none;

    if (auto [ whole, id ] = ctre::search<a_chat_message_pattern>(message.text); whole) {
        found_id = std::stoul(id.str());
        found = found_message_type::a_chat_message;
    } else if (auto matches = types::u8regex::search<answer_pattern>(message.text)) {
        found_id = std::stoul(matches.get_string<1>());
        found = found_message_type::answer;
    }

    if (found_id == samp::user::get_id()) {
        increment_statistics_by_type(found);
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

    statistics_t::entry_t& today_entry = statistics.get_today_entry();
    time_updated = now;
    
    if (server::user::is_on_alogin())
        today_entry.time_on_alogin.get_current_hour_item().value++;
   
    today_entry.time.get_current_hour_item().value++;
}

plugin::misc::features::statistics_updater::statistics_updater() {
    if (std::filesystem::exists(file_path)) {
        read_statistics();
        return;
    }

    save_statistics();
}

plugin::misc::features::statistics_updater::~statistics_updater() noexcept {
    save_statistics();
}
