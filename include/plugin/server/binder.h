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

#ifndef GADMIN_PLUGIN_SERVER_BINDER_H
#define GADMIN_PLUGIN_SERVER_BINDER_H

#include <chrono>
#include <functional>
#include <list>
#include <string>
#include <deque>

namespace plugin::server {

/// Provides methods for processing or evaluating strings by replacing variables with their actual values.
class binder final {
private:
    struct message final {
        std::string text;
        std::chrono::steady_clock::time_point time;
    }; // struct message final

    static inline std::list<message> messages;
    static auto process_variable_body(const std::string_view& input) -> std::string;
    static auto evaluate_single_line(const std::string_view& input) -> void;
public:
    /// Callback for variable replacement. Represents a function that returns
    /// a string, with the variable's parameters passed as the first argument.
    using variable_replacement_t = std::function<std::string(const std::vector<std::string>&)>;

    /// Represents variable information.
    struct variable_t final {
        std::string name;                ///< Variable name.
        std::string description;         ///< Variable description.
        std::string parameters_info;     ///< Information about the variable's parameters.
        variable_replacement_t callback; ///< Variable replacement callback.
    }; // struct variable_t

    /// Parameters (`ARGS...`) for the `${{ SELECT, INDEX, ARGS... }}` variable.
    static inline std::vector<std::string> select_parameters;

    /// Variables registered by the plugin.
    static std::deque<variable_t> variables;

    /// Process a string containing binder variables and get a new
    /// string with the variables replaced by their actual values.
    ///
    /// @param input[in] String to process.
    /// @return          Processed string with replaced variables.
    static auto process(const std::string_view& input) -> std::string;

    /// Evaluate a string containing binder variables (which can be multiline)
    /// and sends it to the chat or pastes it into the input window.
    ///
    /// @note Prefix the string with `^` to paste it into the input window.
    ///
    /// @param input[in] String to evaluate.
    static auto evaluate(const std::string_view& input) -> void;

    /// Main loop for evaluating multiline strings.
    static auto main_loop() -> void;
}; // class binder final

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_BINDER_H
