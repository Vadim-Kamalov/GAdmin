#include "plugin/plugin.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"
#include <cstring>
#include <imgui.h>
#include <format>
#include <windows.h>

void
plugin::Plugin::on_log_message(const log::Type& type, const std::string_view& message) {
    std::lock_guard<std::mutex> lock(log_mutex);
    log_file_stream << message << std::endl;

    if (type == log::Type::Fatal)
        unload();
}

bool
plugin::Plugin::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) {
    if (gui && !gui->on_event(type, id, bit_stream))
        return false;

    return true;
}

bool
plugin::Plugin::can_initialize_render() const {
    return gui->can_initialize_render();
}

void
plugin::Plugin::on_render_initialize() {
    log::info("render initialized");
    gui->on_initialize();
}

void
plugin::Plugin::on_frame() {
    gui->render();
}

bool
plugin::Plugin::on_message(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (gui && !gui->on_event(message, wparam, lparam))
        return false;
    
    return true;
}

void
plugin::Plugin::on_samp_initialize() {
    log::info("samp::net_game::instance() != nullptr: SA:MP {} initialized", samp::get_version());

    if (strcmp(samp::net_game::get_host_address(), PLUGIN_HOST_ADDRESS) != 0) {
        log::fatal("plugin works only on \"sa.gambit-rp.ru:7777\" server");
        return;
    }

    if (!gui) {
        log::fatal("failed to initialize gui->on_samp_initialize(): gui == nullptr");
        return;
    }

    gui->on_samp_initialize();
}

void
plugin::Plugin::main_loop() {
    static bool samp_initialized = false;
    
    event_handler->initialize();
    configuration->save(std::chrono::minutes(5));
    
    if (samp::get_base() && samp::net_game::instance() && !samp_initialized) {
        on_samp_initialize();
        samp_initialized = true;
    }
}

void
plugin::Plugin::initialize_logging() {
    using namespace std::placeholders;

    std::filesystem::path log_file = std::filesystem::current_path() / "gadmin.log";

    std::ofstream(log_file, std::ios::trunc).close();
    log_file_stream.open(log_file, std::ios::app);
    log::set_handler(std::bind(&Plugin::on_log_message, this, _1, _2));
}

void
plugin::Plugin::initialize_event_handler() {
    using namespace std::placeholders;
    
    event_handler = std::make_unique<samp::EventHandler>();
    event_handler->attach(std::bind(&Plugin::on_event, this, _1, _2, _3));

    log::info("plugin::samp::EventHandler initialized");
}

void
plugin::Plugin::create_and_initialize_files() {
    try {
        std::filesystem::path current_path = std::filesystem::current_path();
        
        std::filesystem::create_directories(current_path / "gadmin" / "resources");
        std::filesystem::create_directory(current_path / "gadmin" / "configuration");
        
        configuration = std::make_unique<Configuration>(current_path / "gadmin" / "configuration" / "main.json");
    } catch (const std::exception& e) {
        log::fatal("failed to create and initialize files: {}", e.what());
    }
}

plugin::Plugin::Plugin() {
    initialize_logging();

    log::info("GAdmin v" PROJECT_VERSION " loaded. Copyright (C) 2023-2024 The Contributors");
    std::filesystem::create_directories(std::filesystem::current_path() / "gadmin" / "resources");

    create_and_initialize_files();
    initialize_event_handler();

    gui = std::make_unique<GraphicalUserInterface>();
}

plugin::Plugin::~Plugin() {
    log::info("plugin terminated");

    event_handler.reset(nullptr);
    configuration.reset(nullptr);
    gui.reset(nullptr);

    if (log_file_stream.is_open())
        log_file_stream.close();
}
