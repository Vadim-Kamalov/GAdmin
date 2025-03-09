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

class far_chat : public window {
private:
    struct entry {
        samp::player player;
        types::color player_color, message_color;
        std::string message, time;
        std::chrono::steady_clock::time_point steady_time;
    }; // struct entry
private:
    ImFont *regular, *bold;

    types::not_null<gui_initializer*> child;
    std::deque<entry> entries;

    ImVec2 compute_window_size() const;
    ImVec2 compute_entry_size(const entry& entry) const;

    bool on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event);
public:
    constexpr types::zstring_t get_id() const override;

    bool on_event(const samp::event_info& event) override;
    void render() override;

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit far_chat(types::not_null<gui_initializer*> child);
private:
    static constexpr float spacing_x = 5;
    static constexpr std::size_t text_border_size = 1;
}; // class far_chat : public window

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::far_chat::get_id() const {
    return "windows::far_chat";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_FAR_CHAT_H
