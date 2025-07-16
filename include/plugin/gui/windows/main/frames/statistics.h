#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::windows::main::frames {

class statistics final : public basic_frame {
public:
    types::not_null<initializer*> child;

    auto render() -> void override;

    explicit statistics(types::not_null<initializer*> child)
        : child(child) {}
}; // class statistics final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_STATISTICS_H
