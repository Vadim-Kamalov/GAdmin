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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

/// Window for managing user notes.
///
/// Provides interface for creating, editing and displaying user notes.
/// Supports note alignment, text size customization and visibility toggling.
class notes final : public window {
public:
    /// Represents configuration of the user note.
    struct note_t final {
        std::string title = "Заметка";                                        ///< Note title.
        std::string text = "";                                                ///< Note text.
        widgets::aligner::mode_t align_mode = widgets::aligner::mode_t::left; ///< Note align mode (for both text and title).
        float text_size = 18.0f;                                              ///< Note text size.
        float title_size = 20.0f;                                             ///< Note title size.
        bool visible = true;                                                  ///< Note visivility state.

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(note_t, title, text, align_mode, text_size,
                                       title_size, visible);
    }; // struct note_t final
private:
    static constexpr float text_border_size = 1;

    struct note_information_t final {
        float width = 0.0f;
        std::string processed_text;
        widgets::aligner title_aligner;
        widgets::aligner::mode_t align_mode;
    }; // struct note_information_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_note_information(const note_t& note) const -> note_information_t;
    auto render_note(const note_t& note, const std::string& id) const -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
    inline auto without_background() const -> bool override;

    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit notes(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class notes final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::notes::get_id() const -> types::zstring_t {
    return "windows::notes";
}

inline auto plugin::gui::windows::notes::get_name() const -> types::zstring_t {
    return "Заметки";
}

inline auto plugin::gui::windows::notes::without_background() const -> bool {
    return true;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H
