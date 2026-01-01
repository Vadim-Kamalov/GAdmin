/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows {

/// Window for spectator actions.
///
/// Provides interface for configuring actions available in spectator mode.
/// Supports customizable buttons with different action types.
class spectator_actions final : public window {
public:
    /// Button configuration structure for the JSON interface.
    struct button final {
        /// Whether need to render this button.
        bool use;

        /// Button name.
        std::string name;
        
        /// Button action on click: evaluate binder's string or send action to the spectator menu.
        std::variant<std::string, int> action;
    }; // struct button final
    
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
    explicit spectator_actions(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class spectator_actions final : public window

auto to_json(nlohmann::json& json, const spectator_actions::button& button) -> void;
auto from_json(const nlohmann::json& json, spectator_actions::button& button) -> void;

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::spectator_actions::get_id() const -> types::zstring_t {
    return "windows::spectator_actions";
}

inline auto plugin::gui::windows::spectator_actions::get_name() const -> types::zstring_t {
    return "Действия в /sp";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
