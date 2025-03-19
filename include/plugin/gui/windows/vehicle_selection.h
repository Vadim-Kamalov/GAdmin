#ifndef GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/gui/gui.h"

using namespace std::chrono_literals;

namespace plugin::gui::windows {

class vehicle_selection : public window {
private:
    struct entry {
        std::string name;
        std::uint16_t id;
    }; // struct entry
private:
    widgets::search search_bar = widgets::search(get_id());
    types::not_null<gui_initializer*> child;

    int colors[2] = { 0, 0 };
    bool closing = false, active = false, focus = false;
    std::uint8_t background_alpha = 0, window_alpha = 0;
    std::chrono::steady_clock::time_point time;

    bool on_send_command(const samp::out_event<samp::event_id::send_command>& event);
    std::vector<entry> get_filtered_entries();
public:
    constexpr types::zstring_t get_id() const override;

    bool on_event(const samp::event_info& event) override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    void render() override;

    void open_window();
    void close_window();

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit vehicle_selection(types::not_null<gui_initializer*> child);
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr float create_button_height = 30;
}; // class vehicle_selection : public window

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::vehicle_selection::get_id() const {
    return "windows::vehicle_selection";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H
