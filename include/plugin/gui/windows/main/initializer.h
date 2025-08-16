#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H

#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/base/window.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <imgui.h>

namespace plugin::gui::windows::main {

class initializer final : public window {
private:
    std::array<frame_ptr_t, frames_count> frames;
    bool moving_window = false;

    auto render_active_frame() -> void;
    auto handle_window_moving() -> void;
public:
    static constexpr ImVec2 default_window_size = { 800, 500 };

    frame active_frame = frame::home;
    std::pair<float, float> screen_size;
    
    ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoTitleBar;
    std::uint8_t window_items_alpha = 255;
    ImVec2 window_padding = { 0, 0 };
    ImVec2 window_pos = { 0, 0 };
    ImVec2 window_size = default_window_size;

    inline auto get_id() const -> types::zstring_t override;

    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    explicit initializer(types::not_null<gui_initializer*> child);
}; // class initializer final : public window

auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

} // namespace plugin::gui::windows::main

inline auto plugin::gui::windows::main::initializer::get_id() const -> types::zstring_t {
    return "windows::main::initializer";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_INITIALIZER_H
