#ifndef GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H
#define GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H

#include "plugin/samp/events/player_death_notification.h"
#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/player.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include <deque>
#include <optional>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

class kill_list final : public window {
private:
    static constexpr float bold_font_size = 18;
    static constexpr float regular_font_size = 16;
    static constexpr std::chrono::milliseconds push_animation_duration = 300ms;
    static constexpr std::chrono::milliseconds alpha_change_duration = 300ms;
    static constexpr std::uint8_t text_border_size = 1;

    struct entry final {
        struct side final {
            samp::player player;
            std::optional<types::color> color;
            auto get_color() -> types::color;
        }; // struct side final

        side left;
        std::optional<side> right;
        std::chrono::system_clock::time_point time;
        std::string reason;
        
        std::chrono::steady_clock::time_point alpha_time;
        float alpha = 1.00;
   
        auto get_formatted_time() const -> std::string;
        auto compute_width(ImFont* bold_font, ImFont* regular_font, bool with_time) const -> float;
    }; // struct entry final

    ImFont *bold_font, *regular_font;
    ImVec2 window_size = { 0, 0 };
    
    std::deque<entry> entries;
    std::chrono::steady_clock::time_point time_pushed;

    auto get_window_size(bool with_time) const -> ImVec2;
    auto on_player_death_notification(const samp::event<samp::event_id::player_death_notification>& notification) -> bool;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;

    explicit kill_list(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class kill_list : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::kill_list::get_id() const -> types::zstring_t {
    return "windows::kill_list";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H
