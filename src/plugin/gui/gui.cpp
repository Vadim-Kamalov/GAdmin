#include "plugin/gui/gui.h"
#include "plugin/gui/style.h"
#include "plugin/game/cursor.h"
#include "plugin/game/game.h"
#include "plugin/gui/windows/admins.h"
#include "plugin/gui/windows/far_chat.h"
#include "plugin/gui/windows/interaction_area.h"
#include "plugin/gui/windows/kill_list.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/notes.h"
#include "plugin/gui/windows/notify.h"
#include "plugin/gui/windows/player_checker.h"
#include "plugin/gui/windows/players_nearby.h"
#include "plugin/gui/windows/release_information.h"
#include "plugin/gui/windows/spectator_information.h"
#include "plugin/gui/windows/spectator_actions.h"
#include "plugin/gui/windows/spectator_keys.h"
#include "plugin/gui/windows/vehicle_selection.h"
#include "plugin/gui/windows/command_requester.h"
#include "plugin/gui/windows/report.h"
#include "plugin/server/spectator.h"
#include "plugin/plugin.h"
#include <ranges>
#include <windows.h>
#include <imgui.h>

auto plugin::gui_initializer::push_window_customization(const std::string_view& id) const -> std::uint8_t {
    nlohmann::json& entries = (*configuration)["internal"]["windows_customization"][id];

    if (!entries.is_array())
        return 0;

    for (const auto& [ index, entry ] : entries | std::views::enumerate) {
        ImVec4 value = { entry[0], entry[1], entry[2], entry[3] };
        ImGui::PushStyleColor(gui::style::used_colors[index], value);
    }

    return entries.size();
}

auto plugin::gui_initializer::pop_window_customization(std::uint8_t times) const -> void {
    ImGui::PopStyleColor(times);
}

auto plugin::gui_initializer::on_event(const samp::event_info& event) const -> bool {
    for (const auto& window : registered_windows) {
        event.stream->reset_read_pointer();
        if (!window->on_event(event))
            return false;
    }

    return true;
}

auto plugin::gui_initializer::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
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

auto plugin::gui_initializer::on_samp_initialize() -> void {
    for (const auto& window : registered_windows)
        window->on_samp_initialize();
}

auto plugin::gui_initializer::can_initialize_render() const -> bool {
    return fonts->can_assign_fonts();
}

auto plugin::gui_initializer::on_initialize() -> void {
    using namespace gui;
 
    fonts->assign_fonts();
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
    registered_windows.push_back(windows::interaction_area::create(this));
    registered_windows.push_back(windows::release_information::create(this));
    registered_windows.push_back(windows::player_checker::create(this));
    registered_windows.push_back(windows::notes::create(this));
}

auto plugin::gui_initializer::render() const -> void {
    for (const auto& window : registered_windows) {
        if (!window->can_render() || (game::is_menu_opened() && !window->render_on_game_paused()))
            continue;

        std::uint8_t pop_times = push_window_customization(window->get_id());

        window->render();

        if (pop_times != 0)
            pop_window_customization(pop_times);
    }

#ifndef NDEBUG
    ImGui::ShowDebugLogWindow();
    ImGui::ShowMetricsWindow();
#endif // NDEBUG
}

auto plugin::gui_initializer::main_loop() -> void {
    hotkey_handler->main_loop();
}

auto plugin::gui_initializer::is_cursor_active() const -> bool {
    return GetCursor() != nullptr;
}

auto plugin::gui_initializer::enable_cursor() -> void {
    game::cursor::set_status(true);
    
    if (cursor_last_x != -1 && cursor_last_y != -1)
        SetCursorPos(cursor_last_x, cursor_last_y);
}

auto plugin::gui_initializer::disable_cursor() -> void {
    POINT cursor_pos;
    
    game::cursor::set_status(false);
    GetCursorPos(&cursor_pos);

    cursor_last_x = cursor_pos.x;
    cursor_last_y = cursor_pos.y;
}

auto plugin::gui_initializer::switch_cursor() -> void {
    if (is_cursor_active())
        disable_cursor();
    else
        enable_cursor();
}

plugin::gui_initializer::gui_initializer() {
    fonts = std::make_unique<gui::fonts_initializer>();
    hotkey_handler = std::make_unique<gui::hotkey_handler>(this);
    server::spectator::register_hotkeys(hotkey_handler.get());
}
