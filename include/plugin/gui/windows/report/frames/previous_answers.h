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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_PREVIOUS_ANSWERS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_PREVIOUS_ANSWERS_H

#include "plugin/gui/windows/report/frames/frame.h"
#include "plugin/gui/windows/report/initializer.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/gui.h"
#include <optional>
#include <chrono>
#include <vector>

using namespace std::chrono_literals;

namespace plugin::gui::windows::report::frames {

/// Frame containing all answers registered in the session. Displays
/// a menu of all answers and those sent for the report sender. When
/// an entry is clicked, detailed information is displayed in another
/// menu, where the user can copy the answer text or insert it into
/// the answer input. Search functionality is supported.
class previous_answers final : public basic_frame {
private:
    struct group_item final {
        std::string from;
        std::string to;
        std::string text;
        std::chrono::system_clock::time_point time;
    }; // struct group_item final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    std::vector<group_item> answers;
    std::optional<group_item> selected_item;

    animation::switch_info<decltype(selected_item), 150, 300> switch_info;
    widgets::search search = widgets::search("frames::previous_answers::search");

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;

    auto get_selected_item_time() const -> std::string;
    auto get_answers_to_sender() const -> std::vector<group_item>;

    auto render_group_items(const std::string_view& id, const std::vector<group_item>& group_items) -> void;
    auto render_selected_item_info_hint() const -> void;
    auto render_selected_item_info_details() -> void;
    auto render_selected_item_info(const ImVec2& group_size) -> void;
public:
    inline auto get_label_for_admin() const -> types::zstring_t override;
    inline auto get_label_for_helper() const -> types::zstring_t override;

    auto is_enabled() const -> bool override;
    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the report initializer class.
    explicit previous_answers(types::not_null<initializer*> child)
        : basic_frame(child),
          bold_font(child->child->fonts->bold),
          regular_font(child->child->fonts->regular),
          switch_info(selected_item) {}
}; // class previous_answers final : public basic_frame

} // namespace plugin::gui::windows::report::frames
    
inline auto plugin::gui::windows::report::frames::previous_answers::get_label_for_admin() const
    -> types::zstring_t
{
    return "Прошлые ответы";
}

inline auto plugin::gui::windows::report::frames::previous_answers::get_label_for_helper() const
    -> types::zstring_t
{
    return "Прошлые ответы";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_PREVIOUS_ANSWERS_H
