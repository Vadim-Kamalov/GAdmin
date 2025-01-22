#ifndef GADMIN_PLUGIN_GUI_STYLE_H
#define GADMIN_PLUGIN_GUI_STYLE_H

#include <cstdint>

namespace plugin::gui {

struct accent_colors_t {
    std::uint32_t green = 0xFFA1E3A6;
    std::uint32_t red = 0xFFA88BF3;
    std::uint32_t yellow = 0xFFAEE2F9;
}; // struct accent_colors_t

class style {
public:
    static inline accent_colors_t accent_colors;
    static void apply() noexcept;
}; // class style

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_STYLE_H
