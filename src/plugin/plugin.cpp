#include "plugin/plugin.h"
#include "plugin/encoding.h"
#include "plugin/filesystem.h"
#include "plugin/log.h"
#include <imgui.h>
#include <format>
#include <windows.h>

plugin::samp::EventHandler plugin::Plugin::event_handler;

void
plugin::Plugin::on_log_message(const std::string_view& message) {
    std::lock_guard<std::mutex> lock(log_mutex);
    log_file_stream << message << std::endl;
}

bool
plugin::Plugin::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) {
    if (type == samp::EventType::IncomingRPC && id == 93) {
        std::uint32_t color = bit_stream->read<std::uint32_t>();
        std::string text = encoding::to_utf8(bit_stream->read_string(bit_stream->read<std::uint32_t>()));
        
        last_message = std::format("color: {}, text: {}", color, text);
        
        return false;
    }

    return true;
}

void
plugin::Plugin::on_render_initialize() {
    log::info("render initialized");

    ImGui::GetIO().IniFilename = nullptr; 
    ImGui::GetIO().Fonts->AddFontFromFileTTF(std::format("{}\\Fonts\\Arialbd.TTF", getenv("WINDIR")).c_str(), 14, nullptr,
                                             ImGui::GetIO().Fonts->GetGlyphRangesCyrillic());
}

void
plugin::Plugin::on_frame() {
    ImGui::Begin("Hello, world!");
    {
        ImGui::Text("%s", last_message.c_str());
    }
    ImGui::End();
}

bool
plugin::Plugin::on_message(unsigned int message, WPARAM wparam, LPARAM lparam) {
    return true;
}

void
plugin::Plugin::main_loop() {
    event_handler.initialize();
}

plugin::Plugin::Plugin() {
    using namespace std::placeholders;

    std::filesystem::path log_path = filesystem::get_path("GAdmin", ".log");
    {
        std::ofstream(log_path, std::ios::trunc).close();
        log_file_stream.open(log_path, std::ios::app);
        log::set_handler(std::bind(&Plugin::on_log_message, this, _1));
    }

    event_handler.attach(std::bind(&Plugin::on_event, this, _1, _2, _3));

    log::info("GAdmin v" PROJECT_VERSION " loaded. Copyright (C) 2023-2024 The Contributors");
}

plugin::Plugin::~Plugin() {
    log::info("plugin terminated");

    if (log_file_stream.is_open())
        log_file_stream.close();
}
