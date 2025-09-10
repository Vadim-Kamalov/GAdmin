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


#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP

#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/types/not_null.h"
#include "plugin/server/binder.h"
#include <deque>

namespace plugin::gui::windows::main::widgets {

/// Popup widget for selecting binder variables.
///
/// Provides popup interface for selecting variables from server binder system.
/// Includes search functionality and displays available variables in scrollable list.
class binder_variables_popup final {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr ImVec2 scrollable_area_size = { 600, 400 };

    std::string parameter = "";
    std::string* inserter = nullptr;

    std::string id;
    types::not_null<initializer*> child;
    gui::widgets::search search;
    widgets::popup popup;

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_filtered_binder_variables() const -> std::deque<server::binder::variable_t>;
    auto render_variable(const server::binder::variable_t& variable) -> void;
    auto popup_renderer() -> void;
public:
    /// Render popup.
    inline auto render() -> void;

    /// Open popup.
    inline auto open() -> void;

    /// Set string inserter for selected variable.
    ///
    /// @param new_inserter[in] Pointer to string where selected variable will be inserted.
    inline auto set_inserter(std::string* new_inserter) -> void;

    /// Constructor.
    ///
    /// @param id[in]      Popup identifier.
    /// @param child[in]   GUI initializer.
    explicit binder_variables_popup(const std::string_view& id, types::not_null<initializer*> child);
}; // class binder_variables_popup final

} // namespace plugin::gui::windows::main::widgets

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::render() -> void {
    popup.render(child);
}

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::open() -> void {
    popup.open();
}

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::set_inserter(std::string* new_inserter)
    -> void
{
    inserter = new_inserter;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP
