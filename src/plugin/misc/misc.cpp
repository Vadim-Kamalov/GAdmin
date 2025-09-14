#include "plugin/misc/misc.h"
#include "plugin/misc/features/auto_aa_command.h"
#include "plugin/misc/features/auto_alogin.h"
#include "plugin/misc/features/auto_alogout.h"
#include "plugin/misc/features/auto_login.h"
#include "plugin/misc/features/death_notify_in_chat.h"
#include "plugin/misc/features/display_id_in_chat.h"
#include "plugin/misc/features/fish_eye.h"
#include "plugin/misc/features/fixes.h"
#include "plugin/misc/features/hide_addresses.h"
#include "plugin/misc/features/information_render.h"
#include "plugin/misc/features/mentions.h"
#include "plugin/misc/features/nickname_colors.h"
#include "plugin/misc/features/report_one_color.h"
#include "plugin/misc/features/short_commands.h"
#include "plugin/misc/features/statistics.h"
#include "plugin/misc/features/message_hider.h"
#include "plugin/log.h"
#include <memory>

auto plugin::misc::initializer::on_event(const samp::event_info& event) -> bool {
    for (const auto& feature : features) {
        event.stream->reset_read_pointer();
        if (!feature->on_event(event))
            return false;
    }

    return true;
}

auto plugin::misc::initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    for (const auto& feature : features)
        if (!feature->on_event(message, wparam, lparam))
            return false;

    return true;
}

auto plugin::misc::initializer::on_alogin_new_state(bool state) -> void {
    for (const auto& feature : features)
        feature->on_alogin_new_state(state);
}

auto plugin::misc::initializer::render(types::not_null<gui_initializer*> child) -> void {
    for (const auto& feature : features)
        feature->render(child);
}

auto plugin::misc::initializer::main_loop() -> void {
    for (const auto& feature : features)
        feature->main_loop();
}

auto plugin::misc::initializer::on_samp_initialize() -> void {
    for (const auto& feature : features)
        feature->on_samp_initialize();
}

plugin::misc::initializer::initializer() {
    features.push_back(std::make_unique<features::auto_login>());
    features.push_back(std::make_unique<features::auto_alogin>());
    features.push_back(std::make_unique<features::nickname_colors>());
    features.push_back(std::make_unique<features::auto_aa_command>());
    features.push_back(std::make_unique<features::hide_addresses>());
    features.push_back(std::make_unique<features::display_id_in_chat>());
    features.push_back(std::make_unique<features::fixes>());
    features.push_back(std::make_unique<features::mentions>());
    features.push_back(std::make_unique<features::report_one_color>());
    features.push_back(std::make_unique<features::death_notify_in_chat>());
    features.push_back(std::make_unique<features::short_commands>());
    features.push_back(std::make_unique<features::fish_eye>());
    features.push_back(std::make_unique<features::statistics_updater>());
    features.push_back(std::make_unique<features::information_render>());
    features.push_back(std::make_unique<features::message_hider>());
    features.push_back(std::make_unique<features::auto_alogout>());

    log::info("misc::initializer initialized");
}
