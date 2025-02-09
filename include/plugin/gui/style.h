#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include "plugin/utils.h"

namespace plugin::gui {

struct accent_colors_t {
    utils::color_abgr_t green = 0xFFA1E3A6;
    utils::color_abgr_t red = 0xFFA88BF3;
    utils::color_abgr_t yellow = 0xFFAEE2F9;
}; // struct accent_colors_t

class style {
public:
    static inline accent_colors_t accent_colors;
    static void apply() noexcept;
}; // class style

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_STYLE_H
