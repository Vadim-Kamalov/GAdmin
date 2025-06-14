#ifndef GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows {

class admins final : public window {
private:
    static constexpr float title_font_size = 18;
    static constexpr float entry_font_size = 16;

    ImFont* title_font;
    ImFont* entry_font;

    struct entry_t final {
        std::string text;
        types::color color;
        float width;
    }; // struct entry_t

    struct information_t final {
        float width;
        float content_height;
        std::string title;
        std::vector<entry_t> entries;
    }; // struct information_t final

    auto get_window_information() const -> information_t;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    
    auto render() -> void override;

    explicit admins(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          title_font(child->fonts->bold),
          entry_font(child->fonts->regular) {}
}; // class admins final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::admins::get_id() const -> types::zstring_t {
    return "windows::admins";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
