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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
#define GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H

#include <format>
#include <string>

namespace plugin::gui::widgets {

/// Represents a search widget in the GUI.
class search final {
private:
    std::string id = "";
    std::string buffer = "";
public:
    /// Renders the search widget.
    /// 
    /// @param width[in]       Width of the input text, used in widget.
    /// @param placeholder[in] Placeholder text for `ImGui::InputTextWithHint`.
    auto render(float width = 0, const std::string_view& placeholder = "") -> void;
    
    /// Clear current buffer.
    auto clear() -> void;

    /// Check if the search's buffer contains a specific text.
    /// 
    /// @param text[in] Text to check for.
    /// @return         True if the search's buffer contains the text.
    auto contains(const std::string_view& text) const -> bool;

    /// Check if the search's buffer is empty.
    /// 
    /// @return True if the search buffer is empty.
    auto empty() const -> bool;

    /// Check if the search's buffer contains formatted text.
    /// 
    /// @tparam Args    Types of the arguments.
    /// @param fmt[in]  Format string.
    /// @param args[in] Arguments to format.
    /// @return         True if the search's buffer contains the text.
    template<typename... Args>
    auto contains(std::format_string<Args...> fmt, Args&&... args) const -> bool;

    /// Get search's buffer.
    /// 
    /// @return Current buffer.
    auto get_text() const -> std::string;

    /// Set text in the search's buffer.
    ///
    /// @param text[in] New text to be set.
    auto set_text(const std::string_view& text) -> void;

    /// Construct widget.
    ///
    /// @param id[in] Widget's ID.
    explicit search(const std::string_view& id)
        : id(std::move(id)) {}
}; // class search final

} // namespace plugin::gui::widgets

template<typename... Args>
auto plugin::gui::widgets::search::contains(std::format_string<Args...> fmt, Args&&... args) const -> bool {
    return contains(std::format(fmt, std::forward<Args>(args)...));
}

#endif // GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
