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

class nickname_colors : public feature {
public:
    struct entry_t {
        std::string nickname;
        std::vector<types::color> colors;
    }; // struct entry_t
    
    static inline std::deque<entry_t> entries;
private:
    std::jthread downloader_thread;

    bool on_server_message(const samp::event<samp::event_id::server_message>& message);
    void append_entries(nlohmann::json& object);
public:
    bool on_event(const samp::event_info& event) override;

    explicit nickname_colors();
    ~nickname_colors() noexcept;
}; // class nickname_colors : public feature

} // namespace features

std::deque<features::nickname_colors::entry_t>& get_nickname_colors() noexcept;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_FEATURES_NICKNAME_COLORS_H
