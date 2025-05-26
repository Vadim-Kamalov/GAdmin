#include "plugin/misc/features/short_commands.h"
#include "plugin/types/string_iterator.h"
#include "plugin/plugin.h"

bool
plugin::misc::features::short_commands::on_send_command(const samp::out_event<samp::event_id::send_command>& event) const {
    auto feature_configuration = (*configuration)["misc"]["short_commands"];

    if (!feature_configuration["use"])
        return true;

    types::string_iterator iterator(event.command, 1);
    
    std::string command_name = iterator.collect([](unsigned char c) { return !std::isspace(c); });
    std::string command_parameters = iterator.collect([](auto) { return true; });

    for (const auto& [ key, value ] : feature_configuration["commands"].items()) {
        if (key != command_name)
            continue;

        std::string new_command = value;
        std::size_t start_pos = 0;

        while ((start_pos = new_command.find("{}", start_pos)) != std::string::npos) {
            new_command.replace(start_pos, 2, command_parameters);
            start_pos += command_parameters.length();
        }

        event.write_command('/' + new_command);

        return true;
    }

    return true;
}

bool
plugin::misc::features::short_commands::on_event(const samp::event_info& event) {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    return true;
}
