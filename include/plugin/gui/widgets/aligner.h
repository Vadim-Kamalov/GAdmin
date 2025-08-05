#ifndef GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H
#define GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H

#include <nlohmann/json.hpp>
#include <imgui.h>

namespace plugin::gui::widgets {

class aligner final {
public:
    enum class mode_t { left, center, right };
private:
    mode_t mode = mode_t::left;
    float item_width = 0.0f;
public:
    auto align_next_item(float start = ImGui::GetStyle().WindowPadding.x) const -> void;
    
    explicit aligner(const mode_t& mode, float item_width)
        : mode(mode), item_width(item_width) {}
    
    aligner() = default;
}; // class aligner final

NLOHMANN_JSON_SERIALIZE_ENUM(aligner::mode_t, {
    { aligner::mode_t::left, "left" },
    { aligner::mode_t::center, "center" },
    { aligner::mode_t::right, "right" }
}) // NLOHMANN_JSON_SERIALIZE_ENUM(aligner::mode_t, { ... })

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_ALIGNER_H
