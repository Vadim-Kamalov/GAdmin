#include "plugin/gui/widgets/joystick.h"
#include "plugin/gui/animation.h"
#include "plugin/utils.h"

using namespace std::chrono_literals;

void
plugin::gui::widgets::joystick::update(std::uint16_t x, std::uint16_t y) {
    auto now = std::chrono::steady_clock::now();

    if (now - time < 100ms)
        return;

    time = now;
    old = current;
    current.x = (x == 0) ? 0 : ((x > 128) ? x - 0xFFFF : x);
    current.y = (y == 0) ? 0 : ((y > 128) ? y - 0xFFFF : y);
}

void
plugin::gui::widgets::joystick::render() const {
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    utils::color_abgr_t color = ImGui::GetColorU32(ImGuiCol_FrameBg);
    utils::color_abgr_t background = animation::get_alpha_changed_color(color, 76);

    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImVec2 center = { pos.x + radius, pos.y + radius };

    draw_list->AddCircleFilled(center, radius, background, 0x30);
    draw_list->AddCircle(center, radius, color, 0x30, ImGui::GetStyle().FrameBorderSize);
    
    float x = 0, y = 0;

    if (animation::is_time_available(time)) {
        x = animation::bring_to((old.x / 100) * 13.5f, (current.x / 100) * 13.5f, time, 100ms);
        y = animation::bring_to((old.y / 100) * 13.5f, (current.y / 100) * 13.5f, time, 100ms);
    }

    draw_list->AddCircleFilled({ center.x + x, center.y + y }, dot_radius, color, 0xF);

    ImGui::Dummy({ radius * 2, radius * 2 });
}
