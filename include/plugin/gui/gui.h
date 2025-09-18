#ifndef GADMIN_PLUGIN_GUI_H
#define GADMIN_PLUGIN_GUI_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/fonts.h"
#include "plugin/gui/hotkey.h"
#include "plugin/types/address.h"
#include <minwindef.h>
#include <kthook/kthook.hpp>

namespace plugin {
namespace signatures {

using input_handler_t = bool(__cdecl*)(unsigned int);

} // namespace signatures

class gui_initializer final {
private:
    static types::versioned_address_container<std::uintptr_t> input_handler_address;
    static inline kthook::kthook_simple<signatures::input_handler_t> input_handler_hook;

    int cursor_last_x = -1;
    int cursor_last_y = -1;
    bool cursor_active = false;

    static auto input_handler_hooked(const decltype(input_handler_hook)& hook, unsigned int char_code) -> bool;
    auto push_window_customization(const std::string_view& id) const -> std::uint8_t;
    auto pop_window_customization(std::uint8_t times) const -> void;
public:
    std::deque<gui::window_ptr_t> registered_windows;
    std::unique_ptr<gui::fonts_initializer> fonts;
    std::unique_ptr<gui::hotkey_handler> hotkey_handler;

    auto on_event(const samp::event_info& event) const -> bool;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;
    
    auto on_samp_initialize() -> void;
    auto can_initialize_render() const -> bool;
    auto on_initialize() -> void;
    auto render() const -> void;
    auto main_loop() -> void;

    auto is_cursor_active() const -> bool;
    auto center_cursor() -> void;
    auto enable_cursor() -> void;
    auto disable_cursor() -> void;
    auto switch_cursor() -> void;

    explicit gui_initializer();
}; // class gui_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_GUI_H
