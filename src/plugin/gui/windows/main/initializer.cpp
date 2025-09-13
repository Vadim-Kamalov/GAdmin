#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include "plugin/gui/windows/main/frames/binder.h"
#include "plugin/gui/windows/main/frames/home.h"
#include "plugin/gui/windows/main/frames/key_binds.h"
#include "plugin/gui/windows/main/frames/logs.h"
#include "plugin/gui/windows/main/frames/notes.h"
#include "plugin/gui/windows/main/frames/player_checker.h"
#include "plugin/gui/windows/main/frames/plugin_information.h"
#include "plugin/gui/windows/main/frames/server_information.h"
#include "plugin/gui/windows/main/frames/settings.h"
#include "plugin/gui/windows/main/frames/statistics.h"
#include "plugin/gui/windows/main/frames/windows_customization.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/gui.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <utility>

auto plugin::gui::windows::main::initializer::render_active_frame() -> void {
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, (active_frame_alpha / 255.0f) * ImGui::GetStyle().Alpha);
    {
        frames[std::to_underlying(active_frame)]->render();
    }
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::main::initializer::handle_window_moving() -> void {
    if (!ImGui::IsMouseDown(ImGuiMouseButton_Left) || !(window_flags & ImGuiWindowFlags_NoMouseInputs)
        || (!moving_window && ImGui::GetIO().WantCaptureMouse))
    {
        moving_window = false;
        return;
    }
    
    ImVec2 mouse_pos = ImGui::GetMousePos();
    ImVec2 window_end = { window_pos.x + window_size.x, window_pos.y + window_size.y };

    if (!moving_window && (mouse_pos.x < window_pos.x || mouse_pos.x > window_end.x ||
        mouse_pos.y < window_pos.y || mouse_pos.y > window_end.y))       
    {
        return;
    }
    
    moving_window = true;

    ImVec2 mouse_delta = ImGui::GetIO().MouseDelta;

    if (mouse_delta.x == 0.0f && mouse_delta.y == 0.0f)
        return;

    ImGui::GetIO().WantCaptureMouse = false;
    window_pos.x += mouse_delta.x;
    window_pos.y += mouse_delta.y;

    ImGui::SetWindowPos(get_id(), window_pos);
}

auto plugin::gui::windows::main::initializer::switch_window() -> void {
    auto now = std::chrono::steady_clock::now();

    if (active) {
        time = now;
        closing = true;
        child->disable_cursor();
        return;
    }

    time = now;
    active = true;
}

auto plugin::gui::windows::main::initializer::on_send_command(const samp::out_event<samp::event_id::send_command>& event)
    -> bool
{
    std::string command = event.command;

    std::transform(command.begin(), command.end(), command.begin(), ::tolower);

    if (command.starts_with("/gadmin")) {
        switch_window();
        return false;
    }

    return true;
}

auto plugin::gui::windows::main::initializer::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command) {
        if (!on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>()))
            return false;

        event.stream->reset_read_pointer();
    }

    for (const auto& frame : frames) {
        event.stream->reset_read_pointer();
        if (!frame->on_event(event))
            return false;
    }

    return true;
}

auto plugin::gui::windows::main::initializer::on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool {
    if (message == WM_KEYUP && wparam == VK_ESCAPE && active) {
        switch_window();
        return false;
    }

    return true;
}

auto plugin::gui::windows::main::initializer::render() -> void {
    if (!active)
        return;

    window_padding = ImGui::GetStyle().WindowPadding;
    window_alpha = animation::bring_to(window_alpha, (closing) ? 0 : 255, time, animation_duration);

    if (!closing && window_alpha != 255 && !child->is_cursor_active())
        child->enable_cursor();

    if (window_alpha == 0 && closing)
        closing = active = false;

    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImGui::SetNextWindowPos({ size_x / 2.0f, size_y / 2.0f }, ImGuiCond_FirstUseEver, { 0.5f, 0.5f });
    ImGui::SetNextWindowSizeConstraints(default_window_size, { FLT_MAX, FLT_MAX });
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
    ImGui::Begin(get_id(), nullptr, window_flags);
    {
        window_size = ImGui::GetWindowSize();
        window_pos = ImGui::GetWindowPos();
        
        auto& frame_selector = widgets::frame_selector::instance(this);

        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, (window_items_alpha / 255.0f) * ImGui::GetStyle().Alpha);
        {
            ImGui::SetCursorPosX(frame_selector.state_width.first);
            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, window_padding);
            ImGui::BeginChild("windows::main::active_frame", { 0, 0 }, ImGuiChildFlags_AlwaysUseWindowPadding,
                              window_flags | ImGuiWindowFlags_NoBackground);
            {
                render_active_frame();
            }
            ImGui::EndChild();
            ImGui::PopStyleVar();
            frame_selector.render();
        }
        ImGui::PopStyleVar();
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
    handle_window_moving();
}

plugin::gui::windows::main::initializer::initializer(types::not_null<gui_initializer*> child)
    : window(child, get_id()),
      active_frame((*configuration)["internal"]["main_window_frame"])
{
    switch_hotkey = hotkey("Открыть/закрыть это окно", key_bind({ 'X', 0 }, bind_condition::always))
        .with_callback([this](auto&) { switch_window(); });

    child->hotkey_handler->add(switch_hotkey);

    frames = {
        std::make_unique<frames::home>(this),
        std::make_unique<frames::settings>(this),
        std::make_unique<frames::key_binds>(this),
        std::make_unique<frames::player_checker>(this),
        std::make_unique<frames::windows_customization>(this),
        std::make_unique<frames::logs>(this),
        std::make_unique<frames::server_information>(this),
        std::make_unique<frames::binder>(this),
        std::make_unique<frames::notes>(this),
        std::make_unique<frames::statistics>(this),
        std::make_unique<frames::plugin_information>(this),
    };
}

auto plugin::gui::windows::main::create(types::not_null<gui_initializer*> child)
    noexcept -> window_ptr_t
{
    return std::make_unique<initializer>(child);
}
