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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <filesystem>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

/// Window for displaying release information.
///
/// Shows information about plugin releases including version, changelog
/// and download statistics. Supports animated display and closing.
class release_information final : public window {
private:
    static constexpr float bold_font_size = 24;
    static constexpr float regular_font_size = 18;

    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static std::filesystem::path file_path;

    struct parsed_information_t final {
        std::string date_created;
        std::string old_tag_name;
        std::string tag_name;
        std::string name;
        std::string body;
        std::size_t file_size;
        std::size_t download_count;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(parsed_information_t, date_created, tag_name,
                                       old_tag_name, name, body, file_size, download_count);
    }; // struct parsed_information_t final

    std::uint8_t window_alpha = 255, background_alpha = 128;
    std::chrono::steady_clock::time_point time;
    bool closing = false;

    ImFont *bold_font, *regular_font;
    std::optional<parsed_information_t> parsed_information;

    auto render_title() const -> void;
    auto close_window() -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit release_information(types::not_null<gui_initializer*> child);
}; // class release_information final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::release_information::get_id() const -> types::zstring_t {
    return "windows::release_information";
}

inline auto plugin::gui::windows::release_information::get_name() const -> types::zstring_t {
    return "Информация о релизе";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H
