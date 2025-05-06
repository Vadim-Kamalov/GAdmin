#include "plugin/gui/notify.h"

plugin::gui::notification&
plugin::gui::notification::with_duration(std::chrono::milliseconds new_duration) noexcept {
    duration = new_duration;
    return *this;
}

plugin::gui::notification&
plugin::gui::notification::with_buttons(const button& first, const button& second) noexcept {
    buttons = std::make_pair(first, second);
    return *this;
}

plugin::gui::notification&
plugin::gui::notification::with_condition(condition_t new_condition) noexcept {
    condition = new_condition;
    return *this;
}

void
plugin::gui::notification::remove() noexcept {
    condition = []{ return false; };
}

std::list<plugin::gui::notification>&
plugin::gui::notify::get_notifications() noexcept {
    return notifications;
}

bool
plugin::gui::notify::has_notifications() noexcept {
    return !notifications.empty();
}

std::size_t
plugin::gui::notify::notifications_count() noexcept {
    return notifications.size();
}

void
plugin::gui::notify::send(const notification& to_send) {
    notification new_notification(to_send);
    if (on_send_callback(new_notification))
        notifications.push_back(std::move(new_notification));
}

void
plugin::gui::notify::set_callback(callback_t callback) noexcept {
    on_send_callback = callback;
}
