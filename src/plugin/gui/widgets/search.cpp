#include "plugin/gui/widgets/search.h"
#include "plugin/string_utils.h"
#include <imgui.h>
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::widgets::search::render(float width, const std::string_view& placeholder) -> void {
    if (width != 0)
        ImGui::SetNextItemWidth(width);

    ImGui::InputTextWithHint(("##" + id).c_str(), std::string(placeholder).c_str(), &buffer);
}

auto plugin::gui::widgets::search::clear() -> void {
    buffer.clear();
}

auto plugin::gui::widgets::search::contains(const std::string_view& text) const -> bool {
    if (empty())
        return true;

    std::string text_lower = string_utils::to_lowercase(text);
    std::string buffer_lower = string_utils::to_lowercase(buffer);

    return text_lower.contains(buffer_lower);
}

auto plugin::gui::widgets::search::empty() const -> bool {
    return buffer.empty();
}

auto plugin::gui::widgets::search::get_text() const -> std::string {
    return buffer;
}

auto plugin::gui::widgets::search::set_text(const std::string_view& text) -> void {
    buffer = text;
}
