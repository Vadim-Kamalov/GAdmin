#ifndef GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class Admins : public Window {
private:
    GraphicalUserInterface* child;
public:
    constexpr const char* get_id() const override;
    void render() override;

    explicit Admins(utils::not_null<GraphicalUserInterface*> child);
}; // class Admins : public Window

WindowRef admins(utils::not_null<GraphicalUserInterface*> child) noexcept;

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_ADMINS_H
