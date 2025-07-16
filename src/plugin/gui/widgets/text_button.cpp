#include "plugin/gui/widgets/text_button.h"
#include "plugin/gui/animation.h"
#include "plugin/string_utils.h"
#include <imgui.h>

auto plugin::gui::widgets::text_button::render() const -> bool {
    configuration_t& it = pool[label];
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 pos = ImGui::GetCursorScreenPos();

    ImGui::TextUnformatted(string_utils::truncate_until_hashtag(label).c_str());
    it.hover_info.update();

    it.alpha = animation::bring_to(it.alpha, static_cast<float>(it.hover_info.state),
                                   it.hover_info.time, animation_duration);

    std::uint32_t color = ImGui::GetColorU32(ImGuiCol_Text);

    if (!it.hover_info.state)
        color = (color & 0x00FFFFFF) | (static_cast<std::uint32_t>(it.alpha * 255.0f) << 24);

    ImVec2 size = ImGui::GetItemRectSize();
    float max = size.x / 2.0f;
    float mid = pos.x + max;
    float y = pos.y + size.y + line_height;

    draw_list->AddLine({ mid, y }, { mid + (max * it.alpha), y }, color, line_height);
    draw_list->AddLine({ mid, y }, { mid - (max * it.alpha), y }, color, line_height);

    return ImGui::IsItemClicked();
}

plugin::gui::widgets::text_button::text_button(const std::string_view& label_view)
    : label(std::move(label_view))
{
    if (pool.contains(label))
        return;

    pool[label] = {};
}
