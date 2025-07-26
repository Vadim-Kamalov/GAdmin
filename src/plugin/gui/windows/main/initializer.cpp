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
#include "plugin/gui/gui.h"
#include "plugin/game/game.h"
#include <utility>

auto plugin::gui::windows::main::initializer::render_active_frame() -> void {
    frames[std::to_underlying(active_frame)]->render();
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

auto plugin::gui::windows::main::initializer::render() -> void {
    screen_size = game::get_screen_resolution();
    window_padding = ImGui::GetStyle().WindowPadding;

    ImGui::SetNextWindowSizeConstraints(default_window_size, { FLT_MAX, FLT_MAX });
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
    ImGui::Begin(get_id(), nullptr, window_flags);
    {
        window_size = ImGui::GetWindowSize();
        window_pos = ImGui::GetWindowPos();
        
        auto& frame_selector = widgets::frame_selector::instance(this);
        ImU32 child_bg_color = ImGui::GetColorU32(ImGuiCol_ChildBg);
        ImU32 window_bg_color = ImGui::GetColorU32(ImGuiCol_WindowBg);

        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_items_alpha / 255.0f);
        {
            ImGui::SetCursorPosX(frame_selector.state_width.first);
            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, window_padding);
            ImGui::PushStyleColor(ImGuiCol_ChildBg, window_bg_color);
            ImGui::BeginChild("windows::main::active_frame", { 0, 0 }, ImGuiChildFlags_AlwaysUseWindowPadding, window_flags);
            {
                ImGui::PushStyleColor(ImGuiCol_ChildBg, child_bg_color);
                {
                    render_active_frame();
                }
                ImGui::PopStyleColor();
            }
            ImGui::EndChild();
            ImGui::PopStyleVar();
            ImGui::PopStyleColor();
            frame_selector.render();
        }
        ImGui::PopStyleVar();
    }
    ImGui::End();
    ImGui::PopStyleVar();
    handle_window_moving();
}

plugin::gui::windows::main::initializer::initializer(types::not_null<gui_initializer*> child)
    : window(child, get_id())
{
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
