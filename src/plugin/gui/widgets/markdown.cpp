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

#include "plugin/gui/widgets/markdown.h"
#include <windows.h>

auto plugin::gui::widgets::markdown::link_callback(ImGui::MarkdownLinkCallbackData data) noexcept -> void {
    if (data.isImage)
        return;

    std::string url(data.link, data.linkLength);
    ShellExecuteA(nullptr, "open", url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
}

auto plugin::gui::widgets::markdown::render() const -> void {
    markdown_config.linkCallback = link_callback;
    markdown_config.headingFormats[0] = { font, 26, false };
    markdown_config.headingFormats[1] = { font, 22, false };
    markdown_config.headingFormats[2] = { font, 20, false };

    ImGui::Markdown(text.c_str(), text.length(), markdown_config);
}
