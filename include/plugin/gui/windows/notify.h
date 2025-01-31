#ifndef GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
#define GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/notify.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class notify : public window {
private:
    utils::not_null<gui_initializer*> child;
    float height = 0;

    bool on_send_notification(notification& notification);
    ImVec2 get_buttons_max_size(ImFont* font, const notification::buttons_t& buttons) const;
    void render_notification(notification& item) const;
    void render_button(const ImVec2& pos, ImFont* font, notification& notification, notification::button& button) const;
public:
    constexpr utils::zstring_t get_id() const override;

    void render() override;

    static window_ptr_t create(utils::not_null<gui_initializer*> child) noexcept;
    explicit notify(utils::not_null<gui_initializer*> child);
private:
    static constexpr float notification_size[2] = { 400, 70 };
    static constexpr float padding = 10;
}; // class notify : public window

} // namespace plugin::gui::windows

constexpr plugin::utils::zstring_t
plugin::gui::windows::notify::get_id() const {
    return "windows::notify";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
