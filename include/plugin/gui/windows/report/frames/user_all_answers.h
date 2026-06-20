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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_USER_ALL_ANSWERS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_USER_ALL_ANSWERS_H

#include "plugin/gui/windows/report/frames/frame.h"
#include "plugin/gui/windows/report/initializer.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/gui.h"
#include <nlohmann/json.hpp>
#include <optional>
#include <chrono>
#include <vector>

namespace plugin::gui::windows::report {

/// Structure for saved user answers, with JSON parsing support.
struct user_answer final {
    std::string nickname; ///< Nickname of the player to whom the answer is dedicated.
    std::string answer;   ///< Text of the answer.
    std::string time;     ///< Time when the answer was sent.
   
    /// Optional question of the player. Available only when the answer is sent to the report sender.
    std::string optional_question = "";

    NLOHMANN_DEFINE_TYPE_INTRUSIVE_WITH_DEFAULT(user_answer, nickname, answer,
                                                time, optional_question);
}; // struct user_answer final

namespace frames {

// Frame of all saved user answers or closed reports. When an entry is clicked, it displays details:
// player nickname, answer text, timestamp, and the question text (if present). Search functionality
// is supported.
class user_all_answers final : public basic_frame {
private:
    ImFont* bold_font = nullptr;

    widgets::search search = widgets::search("frames::user_all_answers::search");

    std::optional<user_answer> selected_user_answer;
    animation::switch_info<decltype(selected_user_answer), 150, 300> switch_info;

    auto on_server_message(const samp::event<samp::event_id::server_message>& message) -> bool;

    auto send_selected_user_answer_to_chat() const -> void;

    auto render_user_answers() -> void;
    auto render_selected_user_answer_hint() const -> void;
    auto render_inputs(const ImVec2& input_size) -> void;
    auto render_selected_user_answer(const ImVec2& item_spacing) -> void;
public:
    inline auto get_label_for_admin() const -> types::zstring_t override;
    inline auto get_label_for_helper() const -> types::zstring_t override;

    auto is_enabled() const -> bool override;
    auto render() -> void override;
    auto on_event(const samp::event_info& event) -> bool override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the report initializer class.
    explicit user_all_answers(types::not_null<initializer*> child)
        : basic_frame(child),
          bold_font(child->child->fonts->bold),
          switch_info(selected_user_answer) {}
}; // class user_all_answers final : public basic_frame

} // namespace frames
} // namespace plugin::gui::windows::report
    
inline auto plugin::gui::windows::report::frames::user_all_answers::get_label_for_admin() const
    -> types::zstring_t
{
    return "Ваши ответы";
}

inline auto plugin::gui::windows::report::frames::user_all_answers::get_label_for_helper() const
    -> types::zstring_t
{
    return "Ваши ответы";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_USER_ALL_ANSWERS_H
