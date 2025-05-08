#ifndef GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows {

class admins : public window {
private:
    types::not_null<gui_initializer*> child;
    ImFont *entry_font, *title_font;

    struct entry_t {
        std::string text;
        types::color color;
        float width;
    }; // struct entry_t

    struct information_t {
        float width;
        float content_height;
        std::string title;
        std::vector<entry_t> entries;
    }; // struct information_t

    information_t get_window_information() const;
public:
    constexpr types::zstring_t get_id() const override;
    
    void render() override;
    
    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit admins(types::not_null<gui_initializer*> child);
}; // class admins : public window

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::admins::get_id() const {
    return "windows::admins";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
