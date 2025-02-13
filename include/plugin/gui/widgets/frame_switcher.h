#ifndef GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
#define GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H

#include "plugin/gui/windows/main.h"
#include "plugin/types/not_null.h"

namespace plugin::gui::widgets {

void frame_switcher(const windows::main::frame& frame, types::not_null<windows::main*> child);

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_FRAME_SWITCHER_H
