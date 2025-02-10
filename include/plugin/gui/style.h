#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include "plugin/types/color.h"

namespace plugin::gui {

struct accent_colors_t {
    types::color green = 0xFFA1E3A6;
    types::color red = 0xFFA88BF3;
    types::color yellow = 0xFFAEE2F9;
}; // struct accent_colors_t

class style {
public:
    static inline accent_colors_t accent_colors;
    static void apply() noexcept;
}; // class style

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_STYLE_H
