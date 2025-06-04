#include "plugin/gui/notify.h"

auto plugin::gui::notification::with_duration(std::chrono::milliseconds new_duration) -> notification& {
    duration = new_duration;
    return *this;
}

auto plugin::gui::notification::with_buttons(const button& first, const button& second) -> notification& {
    buttons = std::make_pair(first, second);
    return *this;
}

auto plugin::gui::notification::with_condition(condition_t new_condition) -> notification& {
    condition = new_condition;
    return *this;
}

auto plugin::gui::notification::remove() -> void {
    condition = []{ return false; };
}

auto plugin::gui::notify::get_notifications() noexcept -> std::list<notification>& {
    return notifications;
}

auto plugin::gui::notify::has_notifications() noexcept -> bool {
    return !notifications.empty();
}

auto plugin::gui::notify::notifications_count() noexcept -> std::size_t {
    return notifications.size();
}

auto plugin::gui::notify::send(const notification& to_send) -> void {
    notification new_notification(to_send);
    if (on_send_callback(new_notification))
        notifications.push_back(std::move(new_notification));
}

auto plugin::gui::notify::set_callback(callback_t callback) noexcept -> void {
    on_send_callback = callback;
}
