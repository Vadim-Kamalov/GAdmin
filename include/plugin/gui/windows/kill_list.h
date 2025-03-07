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

class kill_list : public window {
private:
    struct entry {
        struct side {
            samp::player player;
            std::optional<types::color> color;
            types::color get_color();
        }; // struct side

        side left;
        std::optional<side> right;
        std::chrono::system_clock::time_point time;
        std::string reason;
        
        std::chrono::steady_clock::time_point alpha_time;
        float alpha = 1.00;
   
        std::string get_formatted_time() const;
        float compute_width(ImFont* bold_font, ImFont* regular_font, bool with_time) const;
    }; // struct entry
private:
    static constexpr std::chrono::milliseconds push_animation_duration = 300ms;
    static constexpr std::chrono::milliseconds alpha_change_duration = 300ms;
    static constexpr std::uint8_t text_border_size = 1;

    types::not_null<gui_initializer*> child;
    
    ImFont *bold_font, *regular_font;
    ImVec2 window_size = { 0, 0 };
    
    std::deque<entry> entries;
    std::chrono::steady_clock::time_point time_pushed;

    ImVec2 get_window_size(bool with_time) const;
    bool on_player_death_notification(const samp::event<samp::event_id::player_death_notification>& notification);
public:
    constexpr types::zstring_t get_id() const override;

    void render() override;
    bool on_event(const samp::event_info& event) override;

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit kill_list(types::not_null<gui_initializer*> child);
}; // class kill_list : public window

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::kill_list::get_id() const {
    return "windows::kill_list";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_KILL_LIST_H
