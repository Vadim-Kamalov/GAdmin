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

class vehicle_selection final : public window {
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr float create_button_height = 30;

    struct entry final {
        std::string name;
        std::uint16_t id;
    }; // struct entry final

    widgets::search search_bar = widgets::search(get_id());

    int colors[2] = { 0, 0 };
    bool closing = false, active = false, focus = false;
    std::uint8_t background_alpha = 0, window_alpha = 0;
    std::chrono::steady_clock::time_point time;

    auto on_send_command(const samp::out_event<samp::event_id::send_command>& event) -> bool;
    auto get_filtered_entries() -> std::vector<entry>;
    
    auto open_window() -> void;
    auto close_window() -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    auto on_event(const samp::event_info& event) -> bool override;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto render() -> void override;

    explicit vehicle_selection(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class vehicle_selection final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::vehicle_selection::get_id() const -> types::zstring_t {
    return "windows::vehicle_selection";
}

inline auto plugin::gui::windows::vehicle_selection::get_name() const -> types::zstring_t {
    return "Спавн машин (/veh)";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_VEHICLE_SELECTION_H
