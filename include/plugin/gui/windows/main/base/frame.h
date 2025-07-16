#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H

#include <memory>

namespace plugin::gui::windows::main {

class basic_frame {
public:
    virtual ~basic_frame() = default;
    virtual auto render() -> void = 0;
}; // class basic_frame

using frame_ptr_t = std::unique_ptr<basic_frame>;

} // namespace plugin::gui::windows::main

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_BASE_FRAME_H
