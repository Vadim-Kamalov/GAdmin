/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2024-2025 The Contributors.
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
///
/// @file include/plugin/gui/widgets/search.h
/// @details Provides functionality for searching in the GUI.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
#define GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H

#include <format>
#include <string>

namespace plugin::gui::widgets {

/// @class search
/// @brief Represents a search widget in the GUI.
class search final {
private:
    std::string id = "";
    std::string buffer = "";
public:
    /// @brief Renders the search widget.
    /// @param width The width of the search widget.
    /// @param placeholder The placeholder text for the search widget.
    auto render(float width = 0, const std::string_view& placeholder = "") -> void;
    
    /// @brief Clears current buffer of the search widget.
    auto clear() -> void;

    /// @brief Checks if the search buffer contains a specific text.
    /// @param text The text to check for.
    /// @return True if the search buffer contains the text, false otherwise
    auto contains(const std::string_view& text) const -> bool;

    /// @brief Checks if the search buffer is empty.
    /// @return True if the search buffer is empty, false otherwise.
    auto empty() const -> bool;

    /// @brief Checks if the search buffer contains formatted text.
    /// @tparam Args The types of the arguments.
    /// @param fmt The format string.
    /// @param args The arguments to format.
    /// @return True if the search buffer contains the formatted text, false otherwise.
    template<typename... Args>
    auto contains(std::format_string<Args...> fmt, Args&&... args) const -> bool;

    /// @brief Constructor for the search widget.
    /// @param id Search widget's ID.
    explicit search(const std::string_view& id)
        : id(std::move(id)) {}
}; // class search final

} // namespace plugin::gui::widgets

template<typename... Args>
auto plugin::gui::widgets::search::contains(std::format_string<Args...> fmt, Args&&... args) const -> bool {
    return contains(std::format(fmt, std::forward<Args>(args)...));
}


#endif // GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
