#include "plugin/gui/windows/admins.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/server/admins.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include "plugin/log.h"

void
plugin::gui::windows::admins::render() {
    if (!server::user::is_on_alogin())
        return;

    auto window_configuration = (*configuration)["windows"]["admins"];
    
    std::string sort_option = window_configuration["sort_by"];
    std::vector<server::admin> admins_sorted = server::admins::list;

    if (!server::admin::sort(admins_sorted, sort_option)) {
        stop_render();
        return;
    }

    std::string title = "Список администраторов";
    std::vector<std::pair<float, std::string>> admins(admins_sorted.size());

    if (window_configuration["show_count"])
        std::format_to(std::back_inserter(title), " (всего: {})", admins_sorted.size());

    ImFont *admin_entry_font = (*child->fonts->regular)[16], *title_font = (*child->fonts->bold)[18];
    float window_width = title_font->CalcTextSizeA(title_font->FontSize, FLT_MAX, 0, title.c_str()).x + ImGui::GetStyle().WindowPadding.x * 2;
    float entry_height = 0;

    for (std::size_t i = 0; i < admins_sorted.size(); i++) {
        std::string text = admins_sorted[i].nickname;

        if (window_configuration["show_level"])
            text = std::format("[LVL: {}] {}", admins_sorted[i].level, admins_sorted[i].nickname);

        if (window_configuration["show_id"])
            std::format_to(std::back_inserter(text), "[{}]", admins_sorted[i].id);

        ImVec2 text_size = admin_entry_font->CalcTextSizeA(admin_entry_font->FontSize, FLT_MAX, 0, text.c_str());
        float width = text_size.x + ImGui::GetStyle().WindowPadding.x * 2;
    
        if (entry_height == 0)
            entry_height = text_size.y;

        if (window_width < width)
            window_width = width;
        
        admins[i] = std::make_pair(text_size.x, text);
    }

    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::SetNextWindowSize({ window_width, 0 });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize);
    {
        if (window_configuration["show_title"])
            widgets::text(title_font, 1, "{}", title);

        std::size_t show_scrollbar_on = window_configuration["show_scrollbar_on"];
        ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
        float content_height = entry_height * show_scrollbar_on + entry_height + ImGui::GetStyle().ItemSpacing.y
            * show_scrollbar_on - window_padding.y;

        ImGui::PushStyleColor(ImGuiCol_ScrollbarBg, { 0, 0, 0, 0 });
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
        ImGui::SetNextWindowBgAlpha(0);
        ImGui::SetCursorPosX(0);
        ImGui::BeginChild("windows::admins::content", { ImGui::GetWindowWidth(), content_height }, false);
        {
            for (const auto& [width, text] : admins) {
                float pos_x = window_padding.x;

                if (std::string align = window_configuration["align"]; align != "left")
                    pos_x = (align == "right") ? ImGui::GetContentRegionAvail().x - width 
                        : (ImGui::GetContentRegionAvail().x - width) / 2;
                
                ImGui::SetCursorPosX(pos_x);
                widgets::text(admin_entry_font, 1, "{}", text);
            }
        }
        ImGui::EndChild();
        ImGui::PopStyleColor();
        ImGui::PopStyleVar();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

plugin::gui::windows::admins::admins(utils::not_null<gui_initializer*> child) : child(child) {
    log::info("window \"windows::admins\" initialized");
}

plugin::gui::window_ptr
plugin::gui::windows::admins::create(utils::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<admins>(child);
}
