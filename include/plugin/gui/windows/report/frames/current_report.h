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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_CURRENT_REPORT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_CURRENT_REPORT_H

#include "plugin/gui/windows/report/frames/frame.h"
#include "plugin/gui/windows/report/initializer.h"
#include "plugin/gui/gui.h"
#include <chrono>
#include <deque>

namespace plugin::gui::windows::report::frames {

/// Frame of the current report. Contains the answer input,
/// buttons for inserting text into the input, and action
/// buttons that perform specific actions on click.
///
/// The answer input supports up to three lines of text: if
/// multiple lines are provided, the remaining lines are sent
/// via /ans, while the first line is sent via the /report dialog.
class current_report final : public basic_frame {
private:
    static constexpr float nickname_font_size = 24;
    static constexpr float id_font_size = 18;
    static constexpr float icon_font_size = 24;

    static constexpr float max_insert_buttons_count_on_line = 3;

    struct action_button final {
        std::string label;
        std::function<void()> callback;
        bool requires_alogin;
    }; // struct action_button final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    ImFont* icon_font = nullptr;

    bool hint_active = false;

    std::chrono::steady_clock::time_point time_hint_active;
    float left_group_width = 0.0f;

    auto hint_renderer() -> void;
    auto get_report_active_time() const -> std::string;
    auto verify_user_input() -> bool;

    auto block_report_button_callback() -> void;
    auto send_dialog_action_with_input_check(network::dialog_action action) -> void;
    auto get_action_buttons() -> std::deque<action_button>;

    auto render_title(const ImVec2& item_spacing) const -> void;
    auto render_insert_buttons(const ImVec2& item_spacing) -> void;
    auto render_action_buttons(const ImVec2& item_spacing) -> void;
    auto render_multiline_input_hint(const std::string& hint) const -> void;
    auto render_inputs(const ImVec2& item_spacing) -> void;
public:
    inline auto get_label_for_admin() const -> types::zstring_t override;
    inline auto get_label_for_helper() const -> types::zstring_t override;
    inline auto is_enabled() const -> bool override;

    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the report initializer class.
    explicit current_report(types::not_null<initializer*> child)
        : basic_frame(child),
          bold_font(child->child->fonts->bold),
          regular_font(child->child->fonts->regular),
          icon_font(child->child->fonts->icon) {}
}; // class current_report final : public basic_frame

} // namespace plugin::gui::windows::report::frames
    
inline auto plugin::gui::windows::report::frames::current_report::get_label_for_admin() const
    -> types::zstring_t
{
    return "Текущий репорт";
}

inline auto plugin::gui::windows::report::frames::current_report::get_label_for_helper() const
    -> types::zstring_t
{
    return "Текущий вопрос";
}

inline auto plugin::gui::windows::report::frames::current_report::is_enabled() const -> bool {
    return true;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_CURRENT_REPORT_H
