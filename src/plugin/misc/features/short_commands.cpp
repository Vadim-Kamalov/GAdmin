#include "plugin/misc/features/short_commands.h"
#include "plugin/types/string_iterator.h"
#include "plugin/plugin.h"

auto plugin::misc::features::short_commands::on_send_command(const samp::out_event<samp::event_id::send_command>& event) const
    -> bool
{
    auto& feature_configuration = (*configuration)["misc"]["short_commands"];

    if (!feature_configuration["use"])
        return true;

    types::string_iterator iterator(event.command, 1);
    
    std::string command_name = iterator.collect([](unsigned char c) { return !std::isspace(c); });
    std::string command_parameters = iterator.collect([](auto) { return true; });

    for (const auto& object : feature_configuration["commands"]) {
        std::string command = object["command"];

        if (command != command_name)
            continue;
        
        std::string replacement = object["replacement"];
        std::size_t start_pos = 0;

        while ((start_pos = replacement.find("{}", start_pos)) != std::string::npos) {
            replacement.replace(start_pos, 2, command_parameters);
            start_pos += command_parameters.length();
        }

        event.write_command('/' + replacement);

        return true;
    }

    return true;
}

auto plugin::misc::features::short_commands::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    return true;
}
