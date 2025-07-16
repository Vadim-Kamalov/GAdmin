#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

class key_binds final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;

    static constexpr ImVec2 buttons_size_percentage = {
        (hotkey::default_button_size.x * 100) / initializer::default_window_size.x, ///< ~14.29
        (hotkey::default_button_size.y * 100) / initializer::default_window_size.y, ///< ~6.6
    }; // static constexpr ImVec2 button_size_percentage

    ImVec2 buttons_size;
    types::not_null<initializer*> child;
    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_buttons_size() -> ImVec2;
public:
    auto render() -> void override;

    explicit key_binds(types::not_null<initializer*> child)
        : child(child),
          bold_font(child->child->fonts->bold),
          regular_font(child->child->fonts->regular) {}
}; // class key_binds final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_KEY_BINDS_H
