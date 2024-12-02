#include "plugin/gui/windows/main.h"
#include "plugin/game/game.h"
#include "plugin/log.h"
#include <imgui.h>
#include <windows.h>

constexpr const char*
plugin::gui::windows::Main::get_id() const {
    return "windows::Main";
}

void
plugin::gui::windows::Main::render() {
    auto [size_x, size_y] = game::get_screen_resolution();

    ImGui::SetNextWindowPos(ImVec2(size_x / 2, size_y / 2), ImGuiCond_FirstUseEver, ImVec2(0.5, 0.5));
    ImGui::SetNextWindowSize(ImVec2(700, 455));
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration);
    {
        ImGui::Text("Hello, world!");
    }
    ImGui::End();
}

bool
plugin::gui::windows::Main::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (message == WM_KEYUP && wparam == 0x5A /* VK_Z */) {
        child->switch_cursor();
        return false;
    }

    return true;
}

plugin::gui::windows::Main::Main(utils::not_null<GraphicalUserInterface*> child) : child(child) {
    log::info("window \"{}\" initialized", get_id());
}

plugin::gui::WindowRef
plugin::gui::windows::main(utils::not_null<GraphicalUserInterface*> child) noexcept {
    return std::make_unique<Main>(child);
}
