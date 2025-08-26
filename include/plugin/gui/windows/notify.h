#ifndef GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
#define GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/notify.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows {

class notify final : public window {
private:
    static constexpr float icon_font_size = 24;
    static constexpr float bold_font_size = 18;
    static constexpr float regular_font_size = 16;

    float height = 0;

    auto on_send_notification(notification& notification) -> bool;
    auto get_buttons_max_size(ImFont* font, float font_size, const notification::buttons_t& buttons) const -> ImVec2;
    
    auto render_button(const ImVec2& pos, ImFont* font, float font_size, notification& notification,
                       notification::button& button) const -> void;
    
    auto render_notification(notification& item) const -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
 
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    auto render() -> void override;

    explicit notify(types::not_null<gui_initializer*> child);
private:
    static constexpr float notification_size[2] = { 400, 70 };
    static constexpr float padding = 10;
}; // class notify final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::notify::get_id() const -> types::zstring_t {
    return "windows::notify";
}

inline auto plugin::gui::windows::notify::get_name() const -> types::zstring_t {
    return "Оповещения";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_NOTIFY_H
