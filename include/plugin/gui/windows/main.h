#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H

#include "plugin/gui/base/window.h"
#include "plugin/utils.h"

namespace plugin::gui::windows {

class Main : public Window {
public:
    constexpr const char* get_id() const override;

    void render() override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    
    explicit Main();
}; // class Main : public Window

utils::not_null<WindowRef> main() noexcept;

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_H
