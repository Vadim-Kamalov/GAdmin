#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

class home final : public basic_frame {
public:
    types::not_null<initializer*> child;

    auto render() -> void override;

    explicit home(types::not_null<initializer*> child)
        : child(child) {}
}; // class home final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
