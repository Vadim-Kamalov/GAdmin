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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only
///
/// @file include/plugin/gui/widgets/markdown.h
/// @details Provides functionality for rendering text in Markdown format.

#ifndef GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H
#define GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H

#include <imgui.h>
#include <imgui_markdown.h>
#include <string>
#include "plugin/types/not_null.h"

namespace plugin::gui::widgets {

/// @class markdown
/// @brief Helper class for rendering text in Markdown format.
class markdown final {
private:
    static inline ImGui::MarkdownConfig markdown_config;
    
    std::string text;
    types::not_null<ImFont*> font;
    
    static auto link_callback(ImGui::MarkdownLinkCallbackData data) noexcept -> void; 
public:
    /// @brief Render text in Markdown format.
    auto render() const -> void;

    /// @brief Constructor for the markdown class.
    /// @param text Text to be rendered.
    /// @param font Font for headings (`#`, `##` and `###`) and text wrapped in double-star (`**<text>**`).
    explicit markdown(const std::string_view& text, types::not_null<ImFont*> font = ImGui::GetFont())
        : text(std::move(text)), font(font) {}
}; // class markdown final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H
