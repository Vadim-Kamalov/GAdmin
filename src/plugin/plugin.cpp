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

#include "plugin/plugin.h"
#include "plugin/exception_handler.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/events/event.h"
#include "plugin/samp/samp.h"
#include "plugin/server/admins.h"
#include "plugin/server/binder.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include <common/common.h>
#include <imgui.h>
#include <format>
#include <windows.h>

using namespace std::chrono_literals;

auto plugin::plugin_initializer::on_event(const samp::event_info& event) -> bool {
    if (!server::admins::on_event(event))
        return false;

    event.stream->reset_read_pointer();

    if (!server::user::on_event(event)) 
        return false;

    event.stream->reset_read_pointer();

    if (!server::spectator::on_event(event))
        return false;

    event.stream->reset_read_pointer();

    if (!gui->on_event(event))
        return false;

    event.stream->reset_read_pointer();

    if (!cheats_initializer->on_event(event))
        return false;

    event.stream->reset_read_pointer();

    if (!misc_initializer->on_event(event))
        return false;

    return true;
}

auto plugin::plugin_initializer::can_initialize_render() const -> bool {
    return gui->can_initialize_render();
}

auto plugin::plugin_initializer::on_render_initialize() -> void {
    gui->on_initialize();
}

auto plugin::plugin_initializer::on_frame() -> void {
    gui->render();
    cheats_initializer->render();
    misc_initializer->render(gui.get());
}

auto plugin::plugin_initializer::on_message(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    if (!gui->on_event(message, wparam, lparam) ||
        !cheats_initializer->on_event(message, wparam, lparam) ||
        !misc_initializer->on_event(message, wparam, lparam))
    {
        return false;
    }

    return true;
}

auto plugin::plugin_initializer::on_samp_initialize() -> void {
    using namespace plugin::gui;

    log::info("SA:MP {} initialized", samp::get_version());

    if (!is_connected_to_valid_server()) {
        log::fatal_without_unload("GAdmin does not support the server to which you are connected. Supported servers are listed below:");

        for (const auto& address : allowed_ip_addresses)
            log::fatal_without_unload("| {}", address);

        log::fatal("unloading the plugin");

        return;
    }

    gui->on_samp_initialize();
    misc_initializer->on_samp_initialize();

    notify::send(notification("GAdmin v" PROJECT_VERSION " успешно запущен!",
                              "Плагин инициализирован и готов для использования.",
                              ICON_INFO));
}

auto plugin::plugin_initializer::main_loop() -> void {
    static bool samp_initialized = false;
    
    event_handler->main_loop();
    configuration->save(5min);
    
    server::user::main_loop();
    server::spectator::main_loop();
    server::binder::main_loop();
    
    gui->main_loop();
    cheats_initializer->main_loop();
    misc_initializer->main_loop();

    if (samp_initialized || samp::get_base() == 0 || samp::net_game::instance_container->read() == 0)
        return;

    on_samp_initialize();
    samp_initialized = true;
}

auto plugin::plugin_initializer::initialize_event_handler() -> void {
    using namespace std::placeholders;
    
    event_handler = std::make_unique<samp::event_handler>();
    event_handler->set_callback(std::bind(&plugin_initializer::on_event, this, _1));

    log::info("plugin::samp::event_handler initialized");
}

auto plugin::plugin_initializer::create_and_initialize_files() -> void {
    try {
        std::filesystem::path game_path = common::get_game_path();
        
        std::filesystem::create_directories(game_path / "gadmin" / "resources");
        std::filesystem::create_directory(game_path / "gadmin" / "configuration");
        log::info("created (if not existed) \"gadmin / {{resources,configuration}}\" directories");
        
        configuration = std::make_unique<configuration_initializer>(game_path / "gadmin" / "configuration" / "main.mpk");
    } catch (const std::exception& e) {
        log::fatal("failed to create and initialize files: {}", e.what());
    }
}

auto plugin::plugin_initializer::is_connected_to_valid_server() noexcept -> bool {
    if (samp::net_game::instance_container->read() == 0) {
        std::string command_line = GetCommandLineA();
        return std::ranges::any_of(allowed_ip_addresses,
            [&command_line](const std::string_view& ip_address) {
                return command_line.contains(ip_address);
            });
    }

    return std::ranges::contains(allowed_ip_addresses, samp::net_game::get_host_address());
}

plugin::plugin_initializer::plugin_initializer() {
    log::info("plugin::plugin_initializer initialized");
    log::info("| GAdmin v" PROJECT_VERSION " (" COMPILE_INFO ") loaded");
    log::info("| Copyright (C) 2023-2026 The Contributors");

    std::setlocale(LC_ALL, "Russian_Russia.UTF8");
    create_and_initialize_files();
    initialize_event_handler();
    exception_handler::initialize();

    gui = std::make_unique<gui_initializer>();
    cheats_initializer = std::make_unique<cheats::initializer>(gui.get());
    misc_initializer = std::make_unique<misc::initializer>();
}
