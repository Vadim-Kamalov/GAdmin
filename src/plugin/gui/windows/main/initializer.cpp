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

auto plugin::gui::windows::main::initializer::render() -> void {
    screen_size = game::get_screen_resolution();
    window_padding = ImGui::GetStyle().WindowPadding;

    ImGui::SetNextWindowSizeConstraints(default_window_size, { FLT_MAX, FLT_MAX });
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
    ImGui::Begin(get_id(), nullptr, window_flags);
    {
        window_size = ImGui::GetWindowSize();
        
        auto& frame_selector = widgets::frame_selector::instance(this);

        ImGui::SetCursorPos({ frame_selector.state_width.first + window_padding.x, window_padding.y });
        ImGui::BeginGroup();
        {
            render_active_frame();
        }
        ImGui::EndGroup();

        frame_selector.render();
    }
    ImGui::End();
    ImGui::PopStyleVar();
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
