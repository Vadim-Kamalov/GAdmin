#ifndef GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/events/player_chat_bubble.h"
#include "plugin/samp/player.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <deque>

namespace plugin::gui::windows {

class far_chat final : public window {
private:
    static constexpr float title_font_size = 20;
    static constexpr float common_font_size = 18;
    static constexpr std::size_t text_border_size = 1;
    static constexpr types::zstring_t title_text = "Дальний чат";

    struct entry_t final {
        samp::player player;
        types::color player_color, message_color;
        std::string message, time;
        std::chrono::steady_clock::time_point steady_time;
    }; // struct entry_t final

    ImFont* regular_font = nullptr;
    ImFont* bold_font = nullptr;

    std::deque<entry_t> entries;

    auto get_render_safe_color(const types::color& color) const -> types::color;
    auto is_duplicate_entry(const std::string_view& message, std::uint16_t player_id, std::chrono::milliseconds delay) const -> bool;
    auto on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event) -> bool;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    explicit far_chat(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          regular_font(child->fonts->regular),
          bold_font(child->fonts->bold) {}
}; // class far_chat final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::far_chat::get_id() const -> types::zstring_t {
    return "windows::far_chat";
}

inline auto plugin::gui::windows::far_chat::get_name() const -> types::zstring_t {
    return "Дальний чат";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
