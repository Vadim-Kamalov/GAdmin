#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/animation.h"
#include <algorithm>
#include <sstream>

std::string
plugin::gui::widgets::hint::get_text_before_hashtag() const {
    if (std::size_t pos = label.find("##"); pos != std::string::npos)
        return label.substr(0, pos);
    
    return label;
}

void
plugin::gui::widgets::hint::default_renderer() const {
    std::istringstream stream(get_text_before_hashtag());

    for (std::string line; std::getline(stream, line);) {
        ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize(line.c_str()).x) / 2);
        ImGui::TextUnformatted(line.c_str());
    }
}

void
plugin::gui::widgets::hint::render_hint(float alpha) const {
    ImVec2 size = ImGui::GetItemRectSize();
    ImVec2 pos = ImGui::GetCursorScreenPos();
    ImVec2 center = { pos.x - size.x / 2, pos.y + size.y / 2 - alpha * 4 + 10 };
    
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, alpha);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 8, 8 });
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 6);
    ImGui::PushStyleColor(ImGuiCol_PopupBg, color);
    ImGui::PushStyleColor(ImGuiCol_Text, animation::get_contrast_color(ImGui::ColorConvertU32ToFloat4(color)));
    {
        ImGui::SetNextWindowPos({ center.x, center.y - size.y - 3 }, ImGuiCond_Always, { 0.5, 1 });
        ImGui::SetNextWindowSize({ pool[label].width, -1 }, ImGuiCond_Always);
        ImGui::Begin(label.c_str(), nullptr, ImGuiWindowFlags_Tooltip | ImGuiWindowFlags_NoDecoration);
        {
            ImGui::BeginGroup();
            {
                renderer();
            }
            ImGui::EndGroup();
            pool[label].width = ImGui::GetItemRectSize().x + ImGui::GetStyle().WindowPadding.x * 2;
        }
        ImGui::End();
    }
    ImGui::PopStyleVar(3);
    ImGui::PopStyleColor(2);

    ImVec2 a = { center.x - 10, center.y - size.y - 4 };
    ImVec2 b = { center.x + 10, center.y - size.y - 4 };
    ImVec2 c = { center.x, center.y - size.y + 3 };

    ImDrawList* draw_list = ImGui::GetForegroundDrawList();
    std::uint8_t normal_alpha = alpha * 255;
    std::uint32_t border_color = animation::get_alpha_changed_color(
        ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Border]), normal_alpha);
    
    draw_list->Flags = ImDrawListFlags_AntiAliasedLines * 3;
    draw_list->AddTriangleFilled(a, b, c, animation::get_alpha_changed_color(color, normal_alpha));
    draw_list->AddLine(a, c, border_color);
    draw_list->AddLine({ b.x - 1, b.y }, { c.x - 1, c.y }, border_color);
}

void
plugin::gui::widgets::hint::render() {
    bool hovered = condition();
    auto now = std::chrono::steady_clock::now();
    ImVec2 pos = ImGui::GetCursorPos();
    bool show = true;

    for (const auto& [ id, hint ] : pool) {
        if (id != label && now - hint.time <= show_hide_duration) {
            show = false;
            break;
        }
    }

    if (!pool.contains(label))
        pool[label] = { 0, false, {} }; 

    configuration& it = pool[label];

    ImGui::SameLine(0, 0);

    if (show) {
        if (it.opened != hovered) {
            it.opened = hovered;
            it.time = now;
        }

        auto between = std::chrono::duration_cast<std::chrono::milliseconds>(now - it.time).count();
        auto show_hide_duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(show_hide_duration).count();
        
        if (it.width == 0) {
            render_hint(0);
            it.time = now;
        } else if (between <= show_hide_duration_ms) {
            render_hint(std::clamp((hovered) ? static_cast<float>(between) / show_hide_duration_ms
                        : 1.0f - static_cast<float>(between) / show_hide_duration_ms, 0.0f, 1.0f));
        } else if (hovered) {
            render_hint(1);
        }
    }

    ImGui::SetCursorPos(pos);
}
