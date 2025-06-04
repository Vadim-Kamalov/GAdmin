#ifndef GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H
#define GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H

#include "plugin/samp/events/server_message.h"
#include "plugin/misc/base/feature.h"
#include "plugin/types/color.h"
#include <nlohmann/json.hpp>
#include <deque>
#include <thread>
#include <vector>

namespace plugin::misc {
namespace features {

class nickname_colors final : public feature {
public:
    struct entry_t final {
        std::string nickname;
        std::vector<types::color> colors;
    }; // struct entry_t final
    
    static inline std::deque<entry_t> entries;
private:
    std::jthread downloader_thread;

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
    auto append_entries(nlohmann::json& object) -> void;
public:
    auto on_event(const samp::event_info& event) -> bool override;

    explicit nickname_colors();
    ~nickname_colors() noexcept;
}; // class nickname_colors final : public feature

} // namespace features

auto get_nickname_colors() noexcept -> std::deque<features::nickname_colors::entry_t>&;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H
