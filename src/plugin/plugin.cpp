#include "plugin/plugin.h"
#include "plugin/encoding.h"
#include <imgui.h>
#include <format>

plugin::samp::EventHandler plugin::Plugin::event_handler;

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
    event_handler.attach(std::bind(&Plugin::on_event, this, _1, _2, _3));
}

plugin::Plugin::~Plugin() {

}
