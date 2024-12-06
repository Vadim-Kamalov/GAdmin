#include "plugin/gui/gui.h"
#include "plugin/gui/style.h"
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
plugin::GraphicalUserInterface::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (message == WM_KEYDOWN && wparam == VK_ESCAPE && is_cursor_active()) {
        disable_cursor();
        return false;
    }

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
    Style::apply();

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
    
    if (cursor_last_x != -1 && cursor_last_y != -1)
        SetCursorPos(cursor_last_x, cursor_last_y);

    cursor_active = true;
}

void
plugin::GraphicalUserInterface::disable_cursor() {
    game::cursor::set_status(false);

    POINT cursor_pos;
    {
        GetCursorPos(&cursor_pos);
        cursor_last_x = cursor_pos.x;
        cursor_last_y = cursor_pos.y;
    }

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
