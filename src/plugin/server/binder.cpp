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

#include "plugin/server/binder.h"
#include "plugin/samp/core/user.h"
#include <spanstream>
#include <sstream>

auto plugin::server::binder::process_variable_body(const std::string_view& input) -> std::string {
    if (input.empty() || !std::isalpha(input[0]))
        return "";
    
    std::string variable_name = "";
    std::size_t index = 0;

    while (index < input.length() && (std::isalpha(input[index]) || input[index] == '_'))
        variable_name.push_back(input[index++]);

    auto it = std::find_if(variables.begin(), variables.end(), [variable_name](const variable_t& variable) {
        return variable.name == variable_name;
    });

    if (it == variables.end())
        return "";

    while (index < input.length() && std::isspace(input[index]))
        index++;

    if (index >= input.length() || input[index] != ',')
        return it->callback({});

    std::vector<std::string> params;
    std::ispanstream stream(input.substr(++index));
    
    for (std::string param; std::getline(stream, param, ',');) {
        param.erase(0, param.find_first_not_of(' '));
        param.erase(param.find_last_not_of(' ') + 1);
        params.push_back(param);
    }
 
    return it->callback(params);
}

auto plugin::server::binder::process(const std::string_view& input) -> std::string {
    std::string result;
    std::size_t index = 0;

    while (index < input.length()) {
        if (input.substr(index, 3) == "${{") {
            std::string buffer;
            std::size_t start = index;
            bool valid_variable = true;
            
            index += 3;

            while (true) {
                if (index >= input.length()) {
                    index = start + 3;
                    valid_variable = false;
                    break;
                }
            
                if (input.substr(index, 2) == "}}") {
                    index += 2;
                    break;
                }

                buffer.push_back(input[index++]);
            }

            if (!valid_variable)
                continue;

            buffer.erase(0, buffer.find_first_not_of(' '));
            buffer.erase(buffer.find_last_not_of(' ') + 1);
            result.append(process_variable_body(buffer));
        
            continue;
        }

        result.push_back(input[index++]);
    }

    return result;
}

auto plugin::server::binder::evaluate_single_line(const std::string_view& input) -> void {
    if (input.empty())
        return samp::user::send_message("");

    switch (input[0]) {
        case '^':
            samp::input::open();
            samp::input::set_text(input.substr(1));
            return;
        case '/': {
            std::string command = "";
            std::size_t index = 1;

            while (index < input.length() && !std::isspace(input[index]))
                command.push_back(input[index++]);

            if (samp::input::is_command_defined(command))
                return samp::input::process(command);

            break;
        }
    }

    samp::user::send_message("{}", input);
}

auto plugin::server::binder::evaluate(const std::string_view& input) -> void {
    if (input.empty())
        return;

    if (!input.contains('\n'))
        return evaluate_single_line(process(input));

    std::istringstream stream(process(input));
    auto now = std::chrono::steady_clock::now();

    for (std::string line; std::getline(stream, line);) {
        messages.push_back({ line, now });
        now += std::chrono::milliseconds(SERVER_COMMAND_DELAY_MS);
    }
}

auto plugin::server::binder::main_loop() -> void {
    for (auto it = messages.begin(); it != messages.end();) {
        if (std::chrono::steady_clock::now() >= it->time) {
            evaluate_single_line(process(it->text));
            it = messages.erase(it);
            continue;
        }

        it++;
    }
}
