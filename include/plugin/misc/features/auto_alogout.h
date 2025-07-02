#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H

#include "plugin/misc/base/feature.h"
#include <chrono>
#include <cstdint>

using namespace std::chrono_literals;

namespace plugin::misc::features {

class auto_alogout final : public feature {
private:
    static constexpr std::uint16_t security_icon = 32518;

    bool game_focused = true;
    bool sent_warning_notification = false;
    
    std::chrono::steady_clock::time_point time_updated;
    std::chrono::seconds seconds_inactive = 0s;

    auto send_shell_notification(const std::string& text) const -> void;
    auto set_background_work_state(bool state) const -> void;
public:
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto on_alogin_new_state(bool state) -> void override;
    auto main_loop() -> void override;

    ~auto_alogout() noexcept;
}; // class auto_alogout final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGOUT_H
