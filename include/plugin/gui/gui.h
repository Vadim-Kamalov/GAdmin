/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

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
using set_cursor_mode_t = int(__thiscall*)(std::uintptr_t, int, int);

} // namespace signatures

/// GUI initialization and management class.
class gui_initializer final {
private:
    static types::versioned_address_container<std::uintptr_t> input_handler_address;
    static types::versioned_address_container<std::uintptr_t> set_cursor_mode_address;

    static inline kthook::kthook_simple<signatures::input_handler_t> input_handler_hook;
    static inline kthook::kthook_simple<signatures::set_cursor_mode_t> set_cursor_mode_hook;

    int cursor_last_x = -1;
    int cursor_last_y = -1;

    bool cursor_state_intercepted = false;
    bool cursor_active = false;

    static auto input_handler_hooked(const decltype(input_handler_hook)& hook, unsigned int char_code) -> bool;

    auto set_cursor_mode_hooked(const decltype(set_cursor_mode_hook)& hook, std::uintptr_t game,
                                int mode, int immediately_hide) -> int;

    auto push_window_customization(const std::string_view& id) const -> std::uint8_t;
    auto pop_window_customization(std::uint8_t times) const -> void;
public:
    /// Currently registered windows.
    std::deque<gui::window_ptr_t> registered_windows;

    /// Available fonts.
    std::unique_ptr<gui::fonts_initializer> fonts;
    
    /// Hotkey handler.
    std::unique_ptr<gui::hotkey_handler> hotkey_handler;

    /// Process SA:MP event.
    /// 
    /// @param event[in] SA-MP event information.
    /// @return          Whether the event should continue processing.
    auto on_event(const samp::event_info& event) const -> bool;

    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Process SA:MP initializing. Can be called only once since the plugin initialization.
    auto on_samp_initialize() -> void;
    
    /// Check if can initializer render ensuring fonts availability.
    ///
    /// @return True if can initialize render.
    auto can_initialize_render() const -> bool;

    /// Initialize render-related components.
    auto on_initialize() -> void;

    /// Process frame and render elements. Must be called each frame!
    auto render() const -> void;

    /// Main loop.
    auto main_loop() -> void;

    /// Check if cursor is active.
    ///
    /// @return True if cursor is active.
    auto is_cursor_active() const -> bool;

    /// Set cursor position to the screen center.
    auto center_cursor() -> void;

    /// Enable cursor.
    auto enable_cursor() -> void;
    
    /// Disable cursor.
    auto disable_cursor() -> void;

    /// Switch cursor.
    auto switch_cursor() -> void;

    /// Construct GUI initializer.
    explicit gui_initializer();
}; // class gui_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_GUI_H
