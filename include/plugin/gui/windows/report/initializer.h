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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_INITIALIZER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_INITIALIZER_H

#include "plugin/gui/windows/report/frames/frame.h"
#include "plugin/gui/windows/report/network.h"
#include "plugin/gui/base/window.h"
#include "plugin/gui/animation.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <chrono>
#include <array>
#include <imgui.h>

using namespace std::chrono_literals;

namespace plugin::gui::windows::report {

///  Controls for the report window. Manages parameters for all frames and the window itself.
class window_controls final {
private:
    types::not_null<initializer*> child;
public:
    /// Details of the current report frame.
    struct current_report_frame_details_t final {
        /// Flag that will set focus to the input text if set to true.
        bool focus_answer_input = false;

        /// Content of the answer input.
        std::string answer_input = "";
    } current_report_frame_details;

    /// Details of the whole window.
    struct initializer_details_t final {
        /// Currently selected frame by the user.
        frame current_frame = frame::current_report;

        /// Information about the animation of switching between frames.
        animation::switch_info<frame, 150, 300> switch_info;

        /// Window alpha.
        std::uint8_t window_alpha = 0.0f;

        /// Construct the structure.
        explicit initializer_details_t()
            : switch_info(current_frame) {}
    } initializer_details;

    /// Execute the frame change animation and set the current frame to the specified one.
    ///
    /// @param new_frame[in] New frame to set.
    auto go_to_frame(frame new_frame) -> void;

    /// Set the text of the answer input with the optional focus into it.
    ///
    /// @param text[in]  New text of the answer input.
    /// @param focus[in] Whether the answer input should be focused. 
    auto set_answer_input_text(const std::string_view& text, bool focus = false) -> void;

    /// Construct the window controls.
    ///
    /// @param child[in] Valid pointer to the report initializer.
    explicit window_controls(types::not_null<initializer*> child)
        : child(child) {}
}; // class window_controls final

// Entry point for rendering the report window which is responsible for
// the rendering selected frame and sending events to `report::network`.
class initializer final : public window {
private:
    std::array<basic_frame_ptr_t, frame_count> frames;

    auto render_menu() -> void;
public:
    window_controls controls; ///< Window's controls.
    report::network network;  ///< Window's network part.

    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto on_event(const samp::event_info& event) -> bool override;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;

    auto render() -> void override;

    /// Construct the window.
    ///
    /// @param child[in] GUI initializer.
    explicit initializer(types::not_null<gui_initializer*> child);
}; // class initializer final : public window

/// Create report window instance.
///
/// @param child[in] GUI initializer.
/// @return          Unique pointer to window.
auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

} // namespace plugin::gui::windows::report

inline auto plugin::gui::windows::report::initializer::get_id() const -> types::zstring_t {
    return "windows::report::initializer";
}

inline auto plugin::gui::windows::report::initializer::get_name() const -> types::zstring_t {
    return "Улучшенный репорт";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_INITIALIZER_H
