#include "plugin/gui/gui.h"
#include "plugin/game/cursor.h"
#include "plugin/game/game.h"
#include "plugin/gui/windows/main.h"
#include <windows.h>
#include <imgui.h>

bool
plugin::GraphicalUserInterface::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) const {
    for (const auto& window : registered_windows) {
        bit_stream->reset_read_pointer();
        if (!window->on_event(type, id, bit_stream))
            return false;
    }

    return true;
}

bool
plugin::GraphicalUserInterface::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) const {
    for (const auto& window : registered_windows)
        if (!window->on_event(message, wparam, lparam))
            return false;

    return true;
}

void
plugin::GraphicalUserInterface::on_samp_initialize() const {
    for (const auto& window : registered_windows)
        window->on_samp_initialize();
}

bool
plugin::GraphicalUserInterface::can_initialize_render() const {
    return fonts->available();
}

void
plugin::GraphicalUserInterface::on_initialize() {
    using namespace gui;
    
    ImGui::GetIO().IniFilename = nullptr; 
    fonts->make();

    registered_windows.push_back(windows::main(this));
}

void
plugin::GraphicalUserInterface::render() const {
    bool game_paused = game::is_menu_opened();
    
    for (const auto& window : registered_windows) {
        if (game_paused && !window->render_on_game_paused())
            continue;

        window->render();
    }
}

void
plugin::GraphicalUserInterface::enable_cursor() {
    game::cursor::set_status(true);
    cursor_active = true;
}

void
plugin::GraphicalUserInterface::disable_cursor() {
    game::cursor::set_status(false);
	cursor_active = false;
}

void
plugin::GraphicalUserInterface::switch_cursor() {
    if (cursor_active)
        disable_cursor();
    else
        enable_cursor();
}

plugin::GraphicalUserInterface::GraphicalUserInterface() {
    fonts = std::make_unique<gui::Fonts>();
}

plugin::GraphicalUserInterface::~GraphicalUserInterface() {
    fonts.reset(nullptr);
}
