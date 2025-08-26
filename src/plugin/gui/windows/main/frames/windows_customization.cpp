#include "plugin/gui/windows/main/frames/windows_customization.h"
#include "plugin/gui/style.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/gui.h"
#include "plugin/plugin.h"
#include <common/network.h>
#include <unordered_map>
#include <ranges>

auto plugin::gui::windows::main::frames::windows_customization::get_windows_customization() -> nlohmann::json& {
    return (*configuration)["internal"]["windows_customization"];
}

auto plugin::gui::windows::main::frames::windows_customization::render_color_edit(types::zstring_t label, const std::string& id,
                                                                                  nlohmann::json& setter) const -> void
{
    static std::unordered_map<std::string, ImVec4> color_pool;

    if (!color_pool.contains(id))
        color_pool[id] = ImGui::ColorConvertU32ToFloat4(*setter.get<types::color>());

    ImGui::BeginGroup();
    {
        ImVec4& selected_color = color_pool[id];

        if (ImGui::ColorEdit4(("##" + id).c_str(), reinterpret_cast<float*>(&selected_color), ImGuiColorEditFlags_NoInputs)) {
            get_windows_customization() = nlohmann::json::object();
            setter = types::color(ImGui::ColorConvertFloat4ToU32(selected_color));
            style::apply_theme(style::get_saved_theme());
        }

        ImGui::SameLine();
        ImGui::TextUnformatted(label);
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::frames::windows_customization::render_accent_color_edit(types::zstring_t label,
                                                                                         const std::string& id) const -> void
{
    render_color_edit(label, id, style::get_saved_theme()["accent_colors"][id]);
}

auto plugin::gui::windows::main::frames::windows_customization::render_interface_color_edit(types::zstring_t label, const std::string& id,
                                                                                            std::size_t index) const -> void
{
    render_color_edit(label, id + std::to_string(index), style::get_saved_theme()["interface_colors"][id][index]);
}

auto plugin::gui::windows::main::frames::windows_customization::render_global_theme_frame() -> void {
    gui::widgets::text(bold_font, common_font_size, 0, "Акцентные цвета");
    ImGui::BeginGroup();
    {
        render_accent_color_edit("Красный", "red");
        render_accent_color_edit("Зеленый", "green");
        render_accent_color_edit("Желтый", "yellow");
    }
    ImGui::EndGroup();
    gui::widgets::text(bold_font, common_font_size, 0, "Цвет фона");
    ImGui::BeginGroup();
    {
        render_interface_color_edit("Основной", "surface", 0);
        render_interface_color_edit("Дополнительный", "surface", 1);
    }
    ImGui::EndGroup();
    gui::widgets::text(bold_font, common_font_size, 0, "Цвет наложения");
    ImGui::BeginGroup();
    {
        render_interface_color_edit("Основной", "overlay", 0);
        render_interface_color_edit("При наведении", "overlay", 1);
        render_interface_color_edit("Активный", "overlay", 2);
    }
    ImGui::EndGroup();
    gui::widgets::text(bold_font, common_font_size, 0, "Цвет текста");
    ImGui::BeginGroup();
    {
        render_interface_color_edit("Основной", "text", 0);
        render_interface_color_edit("Дополнительный", "text", 1);
    }
    ImGui::EndGroup();

    if (gui::widgets::button("Открыть каталог тем##frames::windows_customization", ImGui::GetContentRegionAvail())
            .render() && !user_themes.empty())
    {
        popup.open();
    }
}

auto plugin::gui::windows::main::frames::windows_customization::update_color_edit_values(const std::string_view& id, std::size_t index,
                                                                                         const ImVec4& value) const -> void
{
    nlohmann::json& entry = get_windows_customization()[id][index];
    entry[0] = value.x;
    entry[1] = value.y;
    entry[2] = value.z;
    entry[3] = value.w;
}

auto plugin::gui::windows::main::frames::windows_customization::get_color_edit_values(const std::string_view& id, std::size_t index) const
    -> ImVec4
{
    nlohmann::json& window_values = get_windows_customization()[id];

    if (!window_values.is_array()) {
        window_values = nlohmann::json::array();
        for (const auto& color_index : style::used_colors) {
            ImVec4 color = ImGui::GetStyle().Colors[color_index];
            window_values.push_back(nlohmann::json::array({ color.x, color.y, color.z, color.w }));
        }
    }

    nlohmann::json& entry = window_values[index];
    ImVec4 output = { entry[0], entry[1], entry[2], entry[3] };

    return output;
}

auto plugin::gui::windows::main::frames::windows_customization::paste_settings(const std::string_view& id) const -> void {
    if (copied_id.empty())
        return;

    nlohmann::json& windows_customization = get_windows_customization();
    nlohmann::json source = windows_customization[copied_id];

    windows_customization[id] = source;
}

auto plugin::gui::windows::main::frames::windows_customization::reset_settings(const std::string_view& id) const -> void {
    for (const auto& [ index, color_index ] : style::used_colors | std::views::enumerate)
        update_color_edit_values(id, index, style::get_global_color(color_index));
}

auto plugin::gui::windows::main::frames::windows_customization::apply_settings_for_all(const std::string_view& id) const -> void {
    nlohmann::json& windows_customization = get_windows_customization();
    nlohmann::json source = windows_customization[id];

    for (auto& window : windows_customization)
        window = source;
}

auto plugin::gui::windows::main::frames::windows_customization::render_window_customization_buttons(const std::string_view& id, const ImVec2& button_size)
    -> void
{
    if (gui::widgets::button(std::format("Скопировать настройки##{}", id), button_size).with_draw_flags(ImDrawFlags_RoundCornersTopLeft).render())
        copied_id = id;

    ImGui::SameLine();
    ImGui::BeginGroup();
    {
        if (gui::widgets::button(std::format("Вставить настройки##{}", id), button_size).with_draw_flags(ImDrawFlags_RoundCornersTopRight).render())
            paste_settings(id);
        
        gui::widgets::hint("Настройки не скопированы, чтобы их применять", style::get_current_accent_colors().red)
            .with_condition([this]{ return copied_id.empty() && ImGui::IsItemHovered(); })
            .render();
    }
    ImGui::EndGroup();

    if (gui::widgets::button(std::format("Сбросить настройки##{}", id), button_size).with_draw_flags(ImDrawFlags_RoundCornersBottomLeft).render())
        reset_settings(id);

    ImGui::SameLine();

    if (gui::widgets::button(std::format("Применить для всех окон##{}", id), button_size)
            .with_draw_flags(ImDrawFlags_RoundCornersBottomRight)
            .render())
    {
        apply_settings_for_all(id);
    }
}

auto plugin::gui::windows::main::frames::windows_customization::render_window_customization(const std::string_view& id) -> void {
    ImVec2 region_avail = ImGui::GetContentRegionAvail();
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 button_size = { (region_avail.x - item_spacing.x) / 2.0f, buttons_height };

    ImGui::BeginChild("scrollable_area", { region_avail.x, region_avail.y - (buttons_height + item_spacing.y) * 2 },
                      ImGuiChildFlags_None, child->window_flags | ImGuiWindowFlags_NoBackground);
    {
        ImGuiListClipper clipper;

        clipper.Begin(style::colors_placeholders.size());

        while (clipper.Step()) {
            for (int index = clipper.DisplayStart; index < clipper.DisplayEnd; index++) {
                std::string label = std::format("##{}:{}", id, index);
                ImVec4 value = get_color_edit_values(id, index);

                if (ImGui::ColorEdit4(label.c_str(), reinterpret_cast<float*>(&value), ImGuiColorEditFlags_NoInputs))
                    update_color_edit_values(id, index, value);
            
                ImGui::SameLine();
                ImGui::TextUnformatted(style::colors_placeholders[index].c_str());
            }
        }
    }
    ImGui::EndChild();
    render_window_customization_buttons(id, button_size);
}

auto plugin::gui::windows::main::frames::windows_customization::write_user_themes() -> void {
    std::string user_themes_content = common::network::fetch_file_content(PROJECT_DATABASE "/user-themes.json", network_thread.get_stop_token());

    if (user_themes_content.empty()) {
        log::warn("failed to fetch PROJECT_DATABASE \"/user-themes.json\"");
        return;
    }

    user_themes = nlohmann::json::parse(user_themes_content);
}

auto plugin::gui::windows::main::frames::windows_customization::popup_renderer() -> void {
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImU32 color = ImGui::GetColorU32(ImGuiCol_Text);

    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    ImVec2 frame_padding = ImGui::GetStyle().FramePadding;
    float button_height = common_font_size * 2 + item_spacing.y + frame_padding.y * 2;
    
    float name_placeholder_width = bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, "Название:").x;
    float author_placeholder_width = bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, "Автор:").x;
    
    gui::widgets::text(bold_font, title_font_size, 0, "Каталог тем");
    
    for (const auto& user_theme : user_themes) {
        ImVec2 button_size = { name_placeholder_width + item_spacing.x +
            regular_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, user_theme.name.c_str()).x, button_height };

        float new_line_text_width = author_placeholder_width + item_spacing.x +
            regular_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, user_theme.author.c_str()).x;

        if (button_size.x < new_line_text_width)
            button_size.x = new_line_text_width;

        button_size.x = std::max<float>(button_size.x + frame_padding.x * 2, ImGui::GetContentRegionAvail().x);

        if (gui::widgets::button("", "user_theme:" + user_theme.name, button_size).render()) {
            nlohmann::json& saved_theme = style::get_saved_theme();

            get_windows_customization() = nlohmann::json::object();
            saved_theme = user_theme.theme;

            style::apply_theme(saved_theme);
        }

        ImVec2 start = ImGui::GetItemRectMin();
        ImVec2 pos = { start.x + frame_padding.x, start.y + frame_padding.y };

        draw_list->AddText(bold_font, common_font_size, pos, color, "Название:");
        pos.x += item_spacing.x + name_placeholder_width;
        draw_list->AddText(regular_font, common_font_size, pos, color, user_theme.name.c_str());
        pos = { start.x + frame_padding.x, start.y + common_font_size + item_spacing.x };
        draw_list->AddText(bold_font, common_font_size, pos, color, "Автор:");
        pos.x += item_spacing.x + author_placeholder_width;
        draw_list->AddText(regular_font, common_font_size, pos, color, user_theme.author.c_str());
    }
}

auto plugin::gui::windows::main::frames::windows_customization::frame_renderer(std::string& label, std::any& payload) -> void {
    std::string window_id = std::any_cast<std::string>(payload);
    
    gui::widgets::text(bold_font, title_font_size, 0, "{}", label);
    ImGui::PushFont(regular_font, common_font_size);
    {
        if (window_id == "internal:global_theme")
            render_global_theme_frame();
        else
            render_window_customization(window_id);
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::windows_customization::render() -> void {
    if (submenu.get_total_entries() == 1)
        for (const auto& window : child->child->registered_windows)
            submenu.add_entry(window->get_name(), std::string(window->get_id()));

    popup.render(child);
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

plugin::gui::windows::main::frames::windows_customization::windows_customization(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

    popup.set_renderer(std::bind(&windows_customization::popup_renderer, this));
    submenu.set_frame_renderer(std::bind(&windows_customization::frame_renderer, this, _1, _2));
    submenu.add_entry("Общая тема", std::string("internal:global_theme"));
    
    network_thread = std::jthread(std::bind_front(&windows_customization::write_user_themes, this));
}
