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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/binder_variables_popup.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows::main::frames {

/// Represents the notes frame in the main window.
class notes final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float buttons_height = 30;

    types::not_null<initializer*> child;
    widgets::binder_variables_popup popup;
    widgets::submenu submenu = widgets::submenu("Заметки##frames::notes");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto render_align_setting(nlohmann::json& value) const -> void;
    auto render_editable_title(std::string& frame_label, std::string& value) const -> void;
    auto render_font_setting(const std::string& label, double& value) const -> void;

    auto on_entry_destroyed(std::size_t index) -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
    auto add_callback() -> void;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit notes(types::not_null<initializer*> child);
}; // class notes final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H
