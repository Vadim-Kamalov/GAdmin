#include "plugin/gui/windows/main/frames/server_information.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/gui.h"
#include <imgui_internal.h>

static constexpr std::uint8_t information_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../../../../../embed/server_information.mpk"
#else
#embed "../../../../../../embed/server_information.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t information_bytes[]

auto plugin::gui::windows::main::frames::server_information::get_filtered_map(const gui::widgets::search& search, const nlohmann::json& config)
    -> std::vector<std::array<std::string, 2>>
{
    std::vector<std::array<std::string, 2>> output;

    for (const auto& row : config) {
        std::string key = row[0];
        std::string value = row[1];

        if (!search.contains("{} {}", key, value))
            continue;

        output.push_back({ key, value });
    } 

    return output;
}

auto plugin::gui::windows::main::frames::server_information::handle_row_controls(const std::string& text_to_copy) const -> void {
    ImGuiTable* table = ImGui::GetCurrentContext()->CurrentTable;

    // If we don't jump to the last column it will fail to calculate the rect size
    // Just in case we didn't render enough columns
    ImGui::TableSetColumnIndex(table->Columns.size() - 1);

    ImRect row_rect = { table->WorkRect.Min.x, table->RowPosY1, table->WorkRect.Max.x, table->RowPosY2 };
    row_rect.ClipWith(table->BgClipRect);

    if (!ImGui::IsMouseHoveringRect(row_rect.Min, row_rect.Max, false) || !ImGui::IsWindowHovered() || ImGui::IsAnyItemHovered())
        return;

    table->RowBgColor[1] = ImGui::GetColorU32(ImGuiCol_Border);

    if (!ImGui::IsMouseReleased(ImGuiMouseButton_Left))
        return;

    ImGui::SetClipboardText(text_to_copy.c_str());
    gui::notify::send(gui::notification("Текст скопирован", "Информация об оружии успешно скопирована!", ICON_COPY));
}

auto plugin::gui::windows::main::frames::server_information::render_complex_table(const std::string& id, const nlohmann::json& config) const
    -> void
{
    auto flags = ImGuiTableFlags_ScrollY | ImGuiTableFlags_Borders | ImGuiTableFlags_Resizable;

    ImGui::PushFont(bold_font, common_font_size);
    {
        if (ImGui::BeginTable(id.c_str(), config["heading"].size(), flags)) {
            for (const auto& item : config["heading"]) {
                std::string label = item["label"];
                float width = item["width"];
                ImGui::TableSetupColumn(label.c_str(), ImGuiTableColumnFlags_WidthStretch, width);
            }
        
            ImGui::TableSetupScrollFreeze(0, 1);
            ImGui::TableHeadersRow();

            for (const auto& row : config["rows"]) {
                for (std::string column : row["items"]) {
                    ImGui::TableNextColumn();
                    gui::widgets::text(regular_font, common_font_size, 0, "{}", column);
                }

                handle_row_controls(row["copy"]);
            }
            ImGui::EndTable();
        }
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::server_information::render_map(const std::string& id, const nlohmann::json& config) const
    -> void
{
    static gui::widgets::search search("frames::server_information::search");

    float region_avail_x = ImGui::GetContentRegionAvail().x;
    ImVec2 column_size = { region_avail_x / 2.0f, ImGui::GetStyle().FramePadding.y * 2 + common_font_size };

    search.render(region_avail_x, "Поиск");

    ImGui::BeginChild(id.c_str(), { 0, 0 }, ImGuiChildFlags_None, child->window_flags);
    ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, { 0, 0 });
    {
        auto filtered_map = get_filtered_map(search, config);
        ImGuiListClipper clipper;

        clipper.Begin(filtered_map.size());

        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                ImGui::BeginGroup();
                {
                    for (std::size_t column_index = 0; column_index < 2; column_index++) {
                        ImGui::Dummy(column_size);
                        ImGui::PushFont((column_index == 0) ? bold_font : regular_font, common_font_size);
                        {
                            std::string text = filtered_map[i][column_index];

                            ImVec2 start = ImGui::GetItemRectMin();
                            ImVec2 pos = { start.x + (column_size.x - ImGui::CalcTextSize(text.c_str()).x) / 2.0f,
                                           start.y + ImGui::GetStyle().FramePadding.y };

                            ImGui::GetWindowDrawList()->AddText(pos, ImGui::GetColorU32(ImGuiCol_Text), text.c_str());
                        }
                        ImGui::PopFont();
                        ImGui::SameLine(0.0f, 0.0f);
                    }
                }
                ImGui::EndGroup();
            }
        }
    }
    ImGui::PopStyleVar();
    ImGui::EndChild();
}

auto plugin::gui::windows::main::frames::server_information::frame_renderer(std::string& label, std::any& payload) -> void {
    frame_payload_t data = std::any_cast<frame_payload_t>(payload);

    gui::widgets::text(bold_font, title_font_size, 0, "{}", label);

    switch (data.type) {
        case item_type::complex_table:
            render_complex_table(label, data.config);
            break;
        case item_type::map:
            render_map(label, data.config);
            break;
    }
}

auto plugin::gui::windows::main::frames::server_information::render() -> void {
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

plugin::gui::windows::main::frames::server_information::server_information(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

#ifdef USE_EMBEDDED_MESSAGE_PACK
    information = nlohmann::json::from_msgpack(information_bytes);
#else
    information  = nlohmann::json::parse(information_bytes);
#endif // USE_EMBEDDED_MESSAGE_PACK

    submenu.set_frame_renderer(std::bind(&server_information::frame_renderer, this, _1, _2));
    
    for (auto& item : information)
        submenu.add_entry(item["_title"].get<std::string>(),
                          std::make_any<frame_payload_t>(item["_type"].get<item_type>(), item["_config"]));
}
