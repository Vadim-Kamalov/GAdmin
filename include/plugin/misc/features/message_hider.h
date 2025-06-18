#ifndef GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H
#define GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/types/color.h"
#include <unordered_map>
#include <variant>

namespace plugin::misc::features {

class message_hider final : public feature {
private:
    struct text_to_find final {
        std::string start;
        std::optional<std::string> continuation;
        bool skip_nickname_after_start = false;
    }; // struct text_to_find final
    
    using message_to_hide_t = std::variant<text_to_find, types::color>;

    static std::unordered_map<std::string, std::vector<message_to_hide_t>> messages;
    bool skip_next_message = false;

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class message_hider final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_MESSAGE_HIDER_H
