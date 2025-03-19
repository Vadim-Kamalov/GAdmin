#include "plugin/gui/widgets/search.h"
#include "plugin/string_utils.h"
#include <cstdlib>
#include <imgui.h>
#include <misc/cpp/imgui_stdlib.h>

void
plugin::gui::widgets::search::render(float width, const std::string_view& placeholder) {
    if (width != 0)
        ImGui::SetNextItemWidth(width);

    ImGui::InputTextWithHint(("##" + id).c_str(), std::string(placeholder).c_str(), &buffer);
}

void
plugin::gui::widgets::search::clear() {
    buffer.clear();
}

bool
plugin::gui::widgets::search::contains(std::string text) const {
    if (empty())
        return true;

    std::string text_lower = string_utils::to_lowercase(text);
    std::string buffer_lower = string_utils::to_lowercase(buffer);

    return text_lower.contains(buffer_lower);
}

bool
plugin::gui::widgets::search::empty() const {
    return buffer.empty();
}
