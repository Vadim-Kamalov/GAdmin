#ifndef GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H
#define GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include <chrono>
#include <nlohmann/json.hpp>
#include <filesystem>
#include <utility>
#include <vector>

namespace plugin::misc {

struct statistics_t final {
    struct item_t final {
        std::pair<std::uint8_t, std::uint8_t> range;
        std::uint16_t value;
        
        friend auto to_json(nlohmann::json& json, const item_t& item) -> void {
            std::uint16_t range_joined = (item.range.second << 8) | item.range.first;
            std::uint32_t item_joined = (static_cast<std::uint32_t>(item.value) << 16) | range_joined;
            json = item_joined;
        }

        friend auto from_json(const nlohmann::json& json, item_t& item) -> void {
            std::uint32_t item_joined = json;
            std::uint16_t range_joined = item_joined & 0xFFFF;
            std::uint16_t value = item_joined >> 16;

            item.range = std::make_pair(range_joined & 0xFF, range_joined >> 8);
            item.value = value;
        }
    }; // struct item_t final

    struct value_t final {
        std::vector<item_t> items;

        auto get_current_hour_item() -> item_t&;

        friend auto to_json(nlohmann::json& json, const value_t& value) -> void {
            json = value.items;
        }
        
        friend auto from_json(const nlohmann::json& json, value_t& value) -> void {
            value.items = json;
        }
    }; // struct value_t final

    struct entry_t final {
        std::uint8_t day;
        std::uint8_t month;
        std::uint8_t year;

        value_t time;
        value_t time_on_alogin;
        value_t answer;
        value_t a_chat_message;
        value_t ban;
        value_t pk;
        value_t ck;
        value_t warn;
        value_t kick;
        value_t mute;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(entry_t, day, month, year, time, time_on_alogin,
                                       answer, a_chat_message, ban, pk, ck, warn, kick, mute);
    }; // struct entry_t final

    std::vector<entry_t> entries;

    auto get_today_entry() -> entry_t&;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(statistics_t, entries);
}; // struct statistics final

static inline statistics_t statistics;

namespace features {

class statistics_updater final : public feature {
private:
    enum class found_message_type : std::uint8_t {
        none,
        a_chat_message,
        answer,
        ban,
        pk,
        ck,
        warn,
        kick,
        mute
    }; // enum class found_message_type : std::uint8_t

    static std::filesystem::path file_path;
    std::chrono::steady_clock::time_point time_updated;

    auto save_statistics() const noexcept -> void;
    auto read_statistics() const -> void;
    auto try_increment_punishment(const std::string_view& punisment_text) const -> void;
    auto increment_statistics_by_type(const found_message_type& type) const -> void;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
    auto main_loop() -> void override;

    explicit statistics_updater();
    ~statistics_updater() noexcept;
}; // class statistics_updater final : public feature

} // namespace features
} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H
