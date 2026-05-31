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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_GPS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_GPS_H

#include "plugin/gui/windows/report/frames/frame.h"
#include "plugin/gui/windows/report/initializer.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/animation.h"
#include <nlohmann/json.hpp>
#include <memory>

namespace plugin::gui::windows::report::frames {

// The GPS frame. Contains all entries that the user can click
// to insert into the answer input. Search functionality is supported.
class gps final : public basic_frame {
private:
    struct node_t final {
        std::string key;
        nlohmann::ordered_json* current;
        std::shared_ptr<node_t> previous;

        auto get_path() const -> std::string;
    }; // struct node_t final

    ImFont* bold_font = nullptr;
    nlohmann::ordered_json list;
    std::shared_ptr<node_t> current_node;

    animation::switch_info<decltype(current_node), 150, 300> switch_info;
    widgets::search search = widgets::search("frames::gps::search");

    auto write_filtered_entries(std::vector<std::string>& entries,
                                nlohmann::ordered_json& current,
                                std::string current_path = "") const -> void;

    auto render_search_entries() -> void;
    auto render_nodes() -> void;
public:
    inline auto get_label_for_admin() const -> types::zstring_t override;
    inline auto get_label_for_helper() const -> types::zstring_t override;

    auto is_enabled() const -> bool override;
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the report initializer class.
    explicit gps(types::not_null<initializer*> child);
}; // class gps final : public basic_frame

} // namespace plugin::gui::windows::report::frames
    
inline auto plugin::gui::windows::report::frames::gps::get_label_for_admin() const
    -> types::zstring_t
{
    return "GPS";
}

inline auto plugin::gui::windows::report::frames::gps::get_label_for_helper() const
    -> types::zstring_t
{
    return "GPS";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_FRAMES_GPS_H
