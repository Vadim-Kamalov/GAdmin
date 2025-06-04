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
    struct entry final {
        samp::player player;
        types::color player_color, message_color;
        std::string message, time;
        std::chrono::steady_clock::time_point steady_time;
    }; // struct entry final
private:
    ImFont* regular;
    ImFont* bold;

    std::deque<entry> entries;

    auto compute_window_size() const -> ImVec2;
    auto compute_entry_size(const entry& entry) const -> ImVec2;
    auto on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event) -> bool;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    explicit far_chat(types::not_null<gui_initializer*> child)
        : window(child),
          regular((*child->fonts->regular)[16]),
          bold((*child->fonts->bold)[18]) {}
private:
    static constexpr float spacing_x = 5;
    static constexpr std::size_t text_border_size = 1;
}; // class far_chat final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::far_chat::get_id() const -> types::zstring_t {
    return "windows::far_chat";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
