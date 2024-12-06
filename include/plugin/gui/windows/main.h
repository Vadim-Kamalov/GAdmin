#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class Main : public Window {
private:
    utils::not_null<GraphicalUserInterface*> child;
public:
    constexpr const char* get_id() const override;

    void render() override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    
    explicit Main(utils::not_null<GraphicalUserInterface*> child);
}; // class Main : public Window

WindowRef main(utils::not_null<GraphicalUserInterface*> child) noexcept;

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
