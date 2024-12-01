#include "plugin/gui/windows/main.h"
#include "plugin/samp/core/chat.h"
#include "plugin/log.h"
#include <imgui.h>

constexpr const char*
plugin::gui::windows::Main::get_id() const {
    return "windows::Main";
}

void
plugin::gui::windows::Main::render() {
    ImGui::Begin(get_id());
    {
        if (ImGui::Button("Send") && samp::chat::instance())
            samp::chat::add_message(0xFFFFFFFF, "Привет, {}", "мир");
    }
    ImGui::End();
}

bool
plugin::gui::windows::Main::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    return true;
}

plugin::gui::windows::Main::Main() {
    log::info("window \"{}\" initialized", get_id());
}

plugin::utils::not_null<plugin::gui::WindowRef>
plugin::gui::windows::main() noexcept {
    return std::make_shared<Main>();
}
