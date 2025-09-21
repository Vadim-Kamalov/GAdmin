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

#ifndef GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
#define GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/widgets/keycap.h"
#include "plugin/gui/gui.h"
#include "plugin/server/spectator.h"
#include "plugin/samp/events/synchronization.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include <imgui.h>
#include <vector>

namespace plugin::gui::windows {

/// Window for displaying spectator keys.
///
/// Shows current state of synchronization keys in spectator mode.
/// Provides visual representation of pressed keys with keycaps.
class spectator_keys final : public window {
private:
    static constexpr float keycap_height = 35;

    template<samp::synchronization_key key>
    static constexpr auto make_keycap(const ImVec2& size = { keycap_height, keycap_height }) noexcept -> widgets::keycap;
    
    static auto get_keycaps(const samp::synchronization_type& type) noexcept -> std::vector<widgets::keycap>;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit spectator_keys(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class spectator_keys : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::spectator_keys::get_id() const -> types::zstring_t {
    return "windows::spectator_keys";
}

inline auto plugin::gui::windows::spectator_keys::get_name() const -> types::zstring_t {
    return "Клавиши в /sp";
}

template<plugin::samp::synchronization_key key>
constexpr auto plugin::gui::windows::spectator_keys::make_keycap(const ImVec2& size)
    noexcept -> widgets::keycap
{
    constexpr std::string_view name = samp::synchronization_key_names[std::to_underlying(key)];
    return widgets::keycap(name, size, server::spectator::get_key_state(key));
}

#endif // GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
