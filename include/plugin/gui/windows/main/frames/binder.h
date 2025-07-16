#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

class binder final : public basic_frame {
public:
    types::not_null<initializer*> child;

    auto render() -> void override;

    explicit binder(types::not_null<initializer*> child)
        : child(child) {}
}; // class binder final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_BINDER_H
