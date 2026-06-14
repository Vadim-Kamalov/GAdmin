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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_AUTOCOMPLETION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_AUTOCOMPLETION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>
#include <optional>
#include <variant>

namespace plugin::gui::windows {

class autocompletion final : public window {
private:
    static constexpr std::size_t max_suggestions_to_render = 10;

    struct player_argument_suggestion_t final {
        std::uint16_t id;
        std::string nickname;
        std::string description;
    }; // struct player_argument_suggestion_t final

    struct suggestion_t final {
        std::string name;
        std::string description;
        std::optional<std::string> note;
    }; // struct suggestion_t final

    struct command_info_t final {
        std::string name;
    }; // struct command_info_t final

    struct argument_info_t final {
        std::string user_input;
        std::string name;
    }; // struct argument_info_t final

    using predefined_argument_t = std::function<void(std::vector<suggestion_t>& output)>;
    using predefined_arguments_t = std::unordered_map<std::string, predefined_argument_t>;
    using suggestion_info_t = std::variant<std::monostate, command_info_t, argument_info_t>;

    static auto predefined_argument_id(std::vector<suggestion_t>& output) -> void;
    static auto predefined_argument_car_id(std::vector<suggestion_t>& output) -> void;
    static auto predefined_argument_mycar_id(std::vector<suggestion_t>& output) -> void;

    auto get_suggestion_info_from_user_input() const -> suggestion_info_t;
    auto get_suggestions() -> std::vector<suggestion_t>;
    auto get_all_suggestions_for_argument(const std::string& argument_name) -> std::vector<suggestion_t>;

    auto apply_suggestion(const suggestion_t& suggestion) const -> void;
    auto render_suggestion(const suggestion_t& suggestion, float width, bool selected) const -> void;
    auto render_hint() const -> void;

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    std::vector<suggestion_t> current_suggestions;
    std::string current_input_text, old_input_text;
    std::size_t selected_suggestion_index = 0;

    bool samp_available = false;
    predefined_arguments_t predefined_arguments;
    nlohmann::json settings;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;
    inline auto without_background() const -> bool override;

    auto on_samp_initialize() -> void override;
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto render() -> void override;

    /// Create instance of the current window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    /// @return          Unique pointer to window.
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    /// Construct the window.
    ///
    /// @param child[in] Valid pointer to the GUI initializer.
    explicit autocompletion(types::not_null<gui_initializer*> child);
}; // class autocompletion final : public window

inline auto plugin::gui::windows::autocompletion::get_id() const -> types::zstring_t {
    return "windows::autocompletion";
}

inline auto plugin::gui::windows::autocompletion::get_name() const -> types::zstring_t {
    return "Автозаполнение";
}
    
inline auto plugin::gui::windows::autocompletion::without_background() const -> bool {
    return true;
}

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_AUTOCOMPLETION_H
