#ifndef GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class admins : public window {
private:
    utils::not_null<gui_initializer*> child;
public:
    constexpr utils::zstring_t get_id() const override;
    
    void render() override;
    
    static window_ptr_t create(utils::not_null<gui_initializer*> child) noexcept;
    explicit admins(utils::not_null<gui_initializer*> child);
}; // class admins : public window

} // namespace plugin::gui::windows

constexpr plugin::utils::zstring_t
plugin::gui::windows::admins::get_id() const {
    return "windows::admins";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
