#include "plugin/plugin.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/filesystem.h"
#include "plugin/samp/samp.h"
#include "plugin/configuration.h"
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

void
plugin::Plugin::on_render_initialize() {
    log::info("render initialized");

    gui = std::make_unique<GraphicalUserInterface>();

    ImGui::GetIO().IniFilename = nullptr; 
    ImGui::GetIO().Fonts->AddFontFromFileTTF(std::format("{}\\Fonts\\Arialbd.TTF", getenv("WINDIR")).c_str(), 14, nullptr,
                                             ImGui::GetIO().Fonts->GetGlyphRangesCyrillic());
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

    if (strcmp(samp::net_game::get_host_address(), configuration::server_host_name) != 0) {
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
    
    if (samp::get_base() && samp::net_game::instance() && !samp_initialized) {
        on_samp_initialize();
        samp_initialized = true;
    }
}

plugin::Plugin::Plugin() {
    using namespace std::placeholders;

    std::filesystem::path log_path = filesystem::get_path("GAdmin", ".log");
    {
        std::ofstream(log_path, std::ios::trunc).close();
        log_file_stream.open(log_path, std::ios::app);
        log::set_handler(std::bind(&Plugin::on_log_message, this, _1, _2));
    }

    event_handler = std::make_unique<samp::EventHandler>();
    event_handler->attach(std::bind(&Plugin::on_event, this, _1, _2, _3));

    log::info("GAdmin v" PROJECT_VERSION " loaded. Copyright (C) 2023-2024 The Contributors");
}

plugin::Plugin::~Plugin() {
    log::info("plugin terminated");

    event_handler.reset(nullptr);

    if (log_file_stream.is_open())
        log_file_stream.close();
}
