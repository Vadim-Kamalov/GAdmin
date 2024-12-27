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
    constexpr const char* get_id() const override { return "windows::admins"; }
    
    void render() override;
    
    static window_ptr create(utils::not_null<gui_initializer*> child) noexcept;
    explicit admins(utils::not_null<gui_initializer*> child);
}; // class admins : public window

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
