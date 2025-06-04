#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/gui/animation.h"
#include "plugin/string_utils.h"

auto plugin::gui::widgets::toggle_button::render() -> bool {
    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImDrawList* draw_list = ImGui::GetWindowDrawList();

    ImVec2 o = { 4, pos.y + (size.y / 2) };
    float a = pos.x + radius + o.x;
    float b = pos.x + size.x - radius - o.x;

    types::color active_color = ImGui::GetColorU32(ImGuiCol_FrameBgActive);
    types::color disabled_color = ImGui::GetColorU32(ImGuiCol_FrameBg);

    if (!pool.contains(label))
        pool[label] = {
            .time = {},
            .color = (state) ? active_color : disabled_color,
            .pos_x = (state) ? b : a 
        };

    auto now = std::chrono::steady_clock::now();
    configuration_t& it = pool[label];
    bool result = false;

    ImGui::BeginGroup();
    {
        if (ImGui::InvisibleButton(label.c_str(), size)) {
            it.time = now;
            state = !*state;
            result = true;
        }

        if (std::string text = string_utils::truncate_until_hashtag(label); !text.empty()) {
            ImGui::SetCursorScreenPos({ pos.x + size.x + ImGui::GetStyle().ItemSpacing.x * 2,
                                        pos.y + (size.y - ImGui::CalcTextSize(text.c_str()).y) / 2 });
            ImGui::TextUnformatted(text.c_str());
        }
    }
    ImGui::EndGroup();

    if (animation::is_time_available(it.time) && now - it.time <= duration) {
        it.color = animation::bring_to(it.color, (state) ? active_color : disabled_color, it.time, duration);
        it.pos_x = animation::bring_to(it.pos_x, (state) ? b : a, it.time, duration);
    } else {
        it.color = (state) ? active_color : disabled_color;
        it.pos_x = (state) ? b : a;
    }

    draw_list->AddRect(pos, { pos.x + size.x, pos.y + size.y }, *it.color, 10, ImDrawFlags_RoundCornersAll);
    draw_list->AddCircleFilled({ it.pos_x, o.y }, radius, *it.color, 32);

    return result;
}
