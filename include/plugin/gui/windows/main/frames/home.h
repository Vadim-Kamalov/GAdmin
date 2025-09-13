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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/types/not_null.h"
#include "plugin/gui/gui.h"

namespace plugin::gui::windows::main::frames {

/// Represents the home frame in the main window.
class home final : public basic_frame {
private:
    static constexpr types::zstring_t links_text = "Репозиторий GitHub · Тема на форуме";
    static constexpr types::zstring_t button_text = "Открыть меню";
    static constexpr types::zstring_t legal_notice_text[2] = {
        "Copyright (C) " PROJECT_COPYRIGHT_YEARS " The Contributors",
        "Licensed under the terms of GNU General Public Licence v3 (GPLv3)"
    }; // static constexpr types::zstring_t legal_notice_text[2]

    static constexpr float lines_count = 3;
    static constexpr float button_font_size = 18;
    static constexpr float legal_notice_font_size = 18;
    static constexpr float lines_font_size = 24;
    static constexpr float top_bottom_font_size = 18;

    struct line_t final {
        struct entry_t final {
            ImFont* font;
            std::string text;
        }; // struct entry_t final

        entry_t left;
        entry_t right;
    }; // struct line_t final

    types::not_null<initializer*> child;
    std::string last_time_join = "";

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    ImFont* light_font = nullptr;

    auto convert_time(const std::time_t& time) const -> std::string;
    auto get_greeting_text() const -> std::string;

    auto render_line(const line_t& line) const -> void;
    auto render_title() const -> void;
    auto render_legal_notice() const -> void;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    explicit home(types::not_null<initializer*> child);
}; // class home final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_HOME_H
