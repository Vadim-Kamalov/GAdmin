#include "plugin/gui/widgets/aligner.h"
#include <imgui.h>

auto plugin::gui::widgets::aligner::align_next_item(float start) const -> void {
    std::int32_t pos_x = start; // std::int32_t to avoid any float/double precision problems

    switch (mode) {
        case mode_t::left:
            break;
        case mode_t::center:
            pos_x = (ImGui::GetContentRegionAvail().x - item_width) / 2;
            break;
        case mode_t::right:
            pos_x = ImGui::GetContentRegionAvail().x - item_width;
            break;
    }

    ImGui::SetCursorPosX(pos_x);
}
