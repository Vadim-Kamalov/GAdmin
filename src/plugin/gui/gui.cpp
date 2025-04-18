#include "plugin/gui/gui.h"
#include "plugin/gui/style.h"
#include "plugin/game/cursor.h"
#include "plugin/game/game.h"
#include "plugin/gui/windows/admins.h"
#include "plugin/gui/windows/far_chat.h"
#include "plugin/gui/windows/kill_list.h"
#include "plugin/gui/windows/main.h"
#include "plugin/gui/windows/notify.h"
#include "plugin/gui/windows/players_nearby.h"
#include "plugin/gui/windows/spectator_information.h"
#include "plugin/gui/windows/spectator_actions.h"
#include "plugin/gui/windows/spectator_keys.h"
#include "plugin/gui/windows/vehicle_selection.h"
#include "plugin/gui/windows/command_requester.h"
#include "plugin/gui/windows/report.h"
#include <windows.h>
#include <imgui.h>

bool
plugin::gui_initializer::on_event(const samp::event_info& event) const {
    for (const auto& window : registered_windows) {
        event.stream->reset_read_pointer();
        if (!window->on_event(event))
            return false;
    }

    return true;
}

bool
plugin::gui_initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (ImGui::GetCurrentContext() == nullptr)
        return true;

    // Events to the game or SA:MP will not be sent when the user is typing something in ImGui's inputs.
    // Here, we only check `WantTextInput` and not `WantCaptureMouse || WantCaptureKeyboard`, because there
    // are some cases when the game will not receive some event (e.g. release of key or mouse button) event.
    if (ImGui::GetIO().WantTextInput && message != WM_KEYUP && message != WM_SYSKEYUP)
        return false;

    if (!hotkey_handler->on_event(message, wparam, lparam))
        return false;

    for (const auto& window : registered_windows)
        if (!window->on_event(message, wparam, lparam))
            return false;
    
    if (message == WM_KEYDOWN && wparam == VK_ESCAPE && is_cursor_active()) {
        disable_cursor();
        return false;
    }
    
    return true;
}

void
plugin::gui_initializer::on_samp_initialize() {
    for (const auto& window : registered_windows)
        window->on_samp_initialize();
}

bool
plugin::gui_initializer::can_initialize_render() const {
    return fonts->available();
}

void
plugin::gui_initializer::on_initialize() {
    using namespace gui;
    
    ImGui::GetIO().IniFilename = nullptr; 
    fonts->initialize();
    style::apply();

    hotkey_handler->add(hotkey("Переключить курсор", key_bind({ 'B', 0 }))
            .with_callback([&](hotkey&) { switch_cursor(); }));

    registered_windows.push_back(windows::main::create(this));
    registered_windows.push_back(windows::admins::create(this));
    registered_windows.push_back(windows::notify::create(this));
    registered_windows.push_back(windows::spectator_information::create(this));
    registered_windows.push_back(windows::spectator_actions::create(this));
    registered_windows.push_back(windows::spectator_keys::create(this));
    registered_windows.push_back(windows::kill_list::create(this));
    registered_windows.push_back(windows::far_chat::create(this));
    registered_windows.push_back(windows::players_nearby::create(this));
    registered_windows.push_back(windows::vehicle_selection::create(this));
    registered_windows.push_back(windows::command_requester::create(this));
    registered_windows.push_back(windows::report::create(this));
}

void
plugin::gui_initializer::render() const {
    for (const auto& window : registered_windows) {
        if (!window->can_render() || (game::is_menu_opened() && !window->render_on_game_paused()))
            continue;

        window->render();
    }
}

void
plugin::gui_initializer::main_loop() {
    hotkey_handler->main_loop();
}

bool
plugin::gui_initializer::is_cursor_active() const {
    return GetCursor() != nullptr;
}

void
plugin::gui_initializer::enable_cursor() {
    game::cursor::set_status(true);
    
    if (cursor_last_x != -1 && cursor_last_y != -1)
        SetCursorPos(cursor_last_x, cursor_last_y);

    cursor_active = true;
}

void
plugin::gui_initializer::disable_cursor() {
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
plugin::gui_initializer::switch_cursor() {
    if (cursor_active)
        disable_cursor();
    else
        enable_cursor();
}

plugin::gui_initializer::gui_initializer() {
    fonts = std::make_unique<gui::fonts_initializer>();
    hotkey_handler = std::make_unique<gui::hotkey_handler>(this);
}

plugin::gui_initializer::~gui_initializer() noexcept {
    fonts.reset(nullptr);
}
