#include "plugin/gui/windows/main/widgets/frame_selector.h"
#include "plugin/gui/windows/main/widgets/frame_selector_toggle.h"
#include "plugin/gui/windows/main/widgets/frame_switcher.h"
#include "plugin/gui/windows/main/frames/frames.h"
#include "plugin/gui/widgets/text.h"

auto plugin::gui::windows::main::widgets::frame_selector::compute_width_on_state(bool state) const -> float {
    return (default_percentage_on_state[state] * child->window_size.x) / 100.0f;
}

auto plugin::gui::windows::main::widgets::frame_selector::update_state_width() -> void {
    state_width = { compute_width_on_state(false), compute_width_on_state(true) };
}

auto plugin::gui::windows::main::widgets::frame_selector::render_title() const -> void {
    ImVec2 title_size = bold_font->CalcTextSizeA(title_font_size, FLT_MAX, 0, "GAdmin");
    ImVec2 version_size = regular_font->CalcTextSizeA(version_font_size, FLT_MAX, 0, "v" PROJECT_VERSION);

    ImGui::SetCursorPos({ (state_width.second - title_size.x - version_size.x - 5) / 2 + ImGui::GetStyle().WindowPadding.x,
                          (state_width.first - std::max(title_size.y, version_size.y)) / 2 });

    ImGui::BeginGroup();
    {
        gui::widgets::text(bold_font, title_font_size, 0, "GAdmin");
        ImGui::SameLine(0, 5);
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 4);
        gui::widgets::text(regular_font, version_font_size, 0, "v" PROJECT_VERSION);
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::widgets::frame_selector::render_frame_switchers() -> void {
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, { 5, 5 });
    ImGui::SetCursorPos({ 0, state_width.first + ImGui::GetStyle().ItemSpacing.x });
    ImGui::BeginGroup();
    {
        for (std::uint8_t frame_index = 0; frame_index < frames_count; frame_index++)
            widgets::frame_switcher::get_from_pool(this, static_cast<frame>(frame_index))->render();
    }
    ImGui::EndGroup();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::main::widgets::frame_selector::render_missing_rect() const -> void {
    ImVec2 rect_min = ImGui::GetItemRectMin();
    ImVec2 rect_max = ImGui::GetItemRectMax();
    
    ImGui::GetWindowDrawList()->AddRectFilled({ rect_max.x - ImGui::GetStyle().ChildRounding, rect_min.y },
                                              rect_max, ImGui::GetColorU32(ImGuiCol_ChildBg));
}

auto plugin::gui::windows::main::widgets::frame_selector::render() -> void {
    ImGuiWindowFlags window_flags = child->window_flags;
    std::uint8_t pop_times = 2;

    if (state)
        window_flags &= ~ImGuiWindowFlags_NoInputs;

    update_state_width();
    ImGui::PushStyleVar(ImGuiStyleVar_ChildBorderSize, 0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 10, 10 });
    
    if (state || width != ((state) ? state_width.second : state_width.first)) {
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, child->window_alpha / 255.0f);
        pop_times++;
    }

    ImGui::SetCursorPosY(0);
    ImGui::BeginChild("windows::main::menu", { width, child->window_size.y }, ImGuiChildFlags_Borders, window_flags);
    {
        ImGui::SetCursorPos({ 0, 0 });
        widgets::frame_selector_toggle::instance(this).render();
        ImGui::SetCursorPos({ state_width.first + ImGui::GetStyle().ItemSpacing.x, ImGui::GetStyle().WindowPadding.y });
        ImGui::BeginGroup();
        {
            render_title(); 
            render_frame_switchers();
        }
        ImGui::EndGroup();
    }
    ImGui::EndChild();
    ImGui::PopStyleVar(pop_times);
    render_missing_rect();
}
