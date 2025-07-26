#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H

#include "plugin/types/not_null.h"
#include "plugin/gui/windows/main/initializer.h"
#include <string>
#include <chrono>
#include <functional>

using namespace std::chrono_literals;

namespace plugin::gui::windows::main::widgets {

class popup final {
public:
    using renderer_t = std::function<void()>;
private:
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr float close_button_height = 30;

    std::string id;
    renderer_t renderer = [] {};
    
    ImVec2 content_size = { 0, 0 };
    std::uint8_t window_alpha = 0;
    std::chrono::steady_clock::time_point time;
    bool active = false, closing = false;
public:
    auto open() -> void;
    auto close() -> void;
    auto set_renderer(renderer_t new_renderer) -> void;
    auto render(types::not_null<initializer*> child) -> void;

    explicit popup(const std::string_view& id)
        : id(std::move(id)) {}
}; // class popup final

} // namespace plugin::gui::windows::main::widgets

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_POPUP_H
