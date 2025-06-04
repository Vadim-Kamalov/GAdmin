#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include "plugin/types/color.h"

namespace plugin::gui {

struct accent_colors_t final {
    types::color green = 0xFFA1E3A6;
    types::color red = 0xFFA88BF3;
    types::color yellow = 0xFFAEE2F9;
}; // struct accent_colors_t final

class style final {
public:
    static inline accent_colors_t accent_colors;
    static auto apply() noexcept -> void;
}; // class style final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_STYLE_H
