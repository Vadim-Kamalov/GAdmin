#ifndef GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows {

class admins final : public window {
private:
    static constexpr float title_font_size = 20;
    static constexpr float entry_font_size = 18;
    static constexpr float border_size = 1;

    ImFont* title_font = nullptr;
    ImFont* entry_font = nullptr;

    struct entry_t final {
        types::color color;
        std::string text;
        widgets::aligner aligner;
    }; // struct entry_t final

    struct window_information_t final {
        bool render = false;
        std::string title;
        std::vector<entry_t> entries;
        float window_width = 0.0f;
        float scroll_area_height = 0.0f;
    }; // struct window_information_t final

    auto get_window_information() const -> window_information_t;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

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

inline auto plugin::gui::windows::admins::get_name() const -> types::zstring_t {
    return "Администрация онлайн";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
