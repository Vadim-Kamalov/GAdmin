#include "plugin/gui/windows/admins.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/misc/features/nickname_colors.h"
#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include <ranges>

auto plugin::gui::windows::admins::get_window_information() const -> information_t {
    auto window_configuration = (*configuration)["windows"]["admins"];
    server::admin::sort_option sort_option = window_configuration["sort_by"];
    std::size_t show_scrollbar_on = window_configuration["show_scrollbar_on"];
    
    std::vector<server::admin> admins_sorted = server::admins::list;
    std::vector<entry_t> entries(admins_sorted.size());
    std::string title = "Список администраторов";
    {
        if (window_configuration["show_count"]) {
            std::format_to(std::back_inserter(title), " (всего: {})", admins_sorted.size());
        }   
    }
    
    server::admin::sort(admins_sorted, sort_option);

    float entry_height = 0;
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
    float window_width = title_font->CalcTextSizeA(title_font_size, FLT_MAX, 0, title.c_str()).x
        + ImGui::GetStyle().WindowPadding.x * 2;

    for (const auto& [ index, admin ] : admins_sorted | std::views::enumerate) {
        std::string text = admin.nickname;
        
        if (window_configuration["show_level"])
            text = std::format("[LVL: {}] {}", admin.level, admin.nickname);

        if (window_configuration["show_id"])
            std::format_to(std::back_inserter(text), "[{}]", admin.id);
    
        ImVec2 text_size = entry_font->CalcTextSizeA(entry_font_size, FLT_MAX, 0, text.c_str());
        float width = text_size.x + ImGui::GetStyle().WindowPadding.x * 2;
    
        if (entry_height == 0)
            entry_height = text_size.y;

        if (window_width < width)
            window_width = width;
        
        types::color color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
        
        if ((*configuration)["misc"]["nickname_colors"]) {
            auto& nickname_colors = misc::get_nickname_colors();
            if (auto it = std::find_if(nickname_colors.begin(), nickname_colors.end(), [admin](const auto& entry) {
                return entry.nickname == admin.nickname;
            }); it != nickname_colors.end()) {
                color = it->colors[0];
            }
        }

        entries[index] = { text, color, text_size.x };
    }
    
    std::size_t items = std::min(entries.size(), show_scrollbar_on);
    float content_height = entry_height * items + entry_height
        + ImGui::GetStyle().ItemSpacing.y * items - window_padding.y;

    return { window_width, content_height, title, entries };
}

auto plugin::gui::windows::admins::render() -> void {
    auto window_configuration = (*configuration)["windows"]["admins"];

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return;
  
    information_t window_information = get_window_information();
    float window_padding_x = ImGui::GetStyle().WindowPadding.x;

    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::SetNextWindowSize({ window_information.width, 0 });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize);
    {
        if (window_configuration["show_title"])
            widgets::text(title_font, title_font_size, 1, "{}", window_information.title);

        ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, { 0, 0, 0, 0 });
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
        ImGui::SetNextWindowBgAlpha(0);
        ImGui::SetCursorPosX(0);
        ImGui::BeginChild("windows::admins::content", { ImGui::GetWindowWidth(), window_information.content_height });
        {
            ImGuiListClipper clipper;

            clipper.Begin(window_information.entries.size());

            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    entry_t& entry = window_information.entries[i];
                    float pos_x = window_padding_x;

                    if (std::string align = window_configuration["align"]; align != "left")
                        pos_x = (align == "right") ? ImGui::GetContentRegionAvail().x - entry.width
                            : (ImGui::GetContentRegionAvail().x - entry.width) / 2;
                
                    ImGui::SetCursorPosX(pos_x);
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.color);
                    {
                        widgets::text(entry_font, entry_font_size, 1, "{}", entry.text);
                    }
                    ImGui::PopStyleColor();
                }
            }
        }
        ImGui::EndChild();
        ImGui::PopStyleColor();
        ImGui::PopStyleVar();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::admins::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<admins>(child);
}
