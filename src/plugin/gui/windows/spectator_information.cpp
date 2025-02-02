#include "plugin/gui/windows/spectator_information.h"
#include "plugin/game/vehicle.h"
#include "plugin/gui/style.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/plugin.h"
#include "plugin/samp/core/vehicle.h"
#include "plugin/samp/core/vehicle_pool.h"
#include "plugin/server/admins.h"
#include "plugin/server/spectator.h"
#include "plugin/samp/core/input.h"
#include <algorithm>
#include <regex>
#include <spanstream>
#include <string>

void
plugin::gui::windows::spectator_information::vehicles_custom_renderer(const std::string_view& value, std::uint32_t color) const {
    ImFont* font = (*child->fonts->regular)[16];
    
    if (value == "Отсутствует")
        return render_centered_text(value, font, ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);

    ImGui::BeginGroup();
    {
        render_centered_text(value, font, ImGui::ColorConvertU32ToFloat4(color));

        ImVec2 start = ImGui::GetItemRectMin(), end = ImGui::GetItemRectMax();
        ImDrawList* draw_list = ImGui::GetWindowDrawList();
    
        std::ispanstream stream(value);
        std::string vehicle_id;
    
        float current_pos_x = start.x;
        float space_width = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, " ").x;

        while (std::getline(stream, vehicle_id, ' ')) {
            ImVec2 size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, vehicle_id.c_str());
            ImVec2 line_start = { current_pos_x, end.y }, line_end = { current_pos_x + size.x, end.y + 2 };

            if (ImGui::IsMouseHoveringRect({ line_start.x, start.y }, line_end)) {
                draw_list->AddRectFilled(line_start, line_end, color);
                if (ImGui::IsMouseClicked(ImGuiMouseButton_Left))
                    samp::input::send_command("/getbuycar {}", vehicle_id);
            } 

            current_pos_x += size.x + space_width;
        }
    }
    ImGui::EndGroup();
    widgets::hint::render_as_guide("Нажмите на ID машины чтобы телепортировать ее.");
}

void
plugin::gui::windows::spectator_information::vehicle_information_custom_renderer(const std::string_view&, std::uint32_t) const {
    ImFont* font = (*child->fonts->regular)[16];
    samp::vehicle vehicle = server::spectator::player.get_vehicle();

    if (!vehicle.is_available())
        return render_centered_text("Недоступно", font, ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);

    std::string engine = "Заглушен", doors = "Открыты";
    ImVec4 engine_color = ImGui::ColorConvertU32ToFloat4(style::accent_colors.red);
    ImVec4 doors_color = ImGui::ColorConvertU32ToFloat4(style::accent_colors.green);
    ImVec2 text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, std::format("{} / {}", engine, doors).c_str());

    if (vehicle.is_engine_active()) {
        engine = "Заведен";
        engine_color = ImGui::ColorConvertU32ToFloat4(style::accent_colors.green);
    }

    if (vehicle.is_locked()) {
        doors = "Закрыты";
        doors_color = ImGui::ColorConvertU32ToFloat4(style::accent_colors.red);
    }

    ImGui::SetCursorPosX((ImGui::GetCursorPosX() + (ImGui::GetContentRegionAvail().x / 2)) - text_size.x / 2);
    ImGui::PushFont(font);
    {
        ImGui::TextColored(engine_color, "%s", engine.c_str());
        ImGui::SameLine(0, 0);
        ImGui::TextUnformatted(" / ");
        ImGui::SameLine(0, 0);
        ImGui::TextColored(doors_color, "%s", doors.c_str());
    }
    ImGui::PopFont();
}

void
plugin::gui::windows::spectator_information::render_centered_text(const std::string_view& value, ImFont* font, const ImVec4& color) const {
    std::string text(value);

    text.erase(0, text.find_first_not_of(' '));
    text.erase(text.find_last_not_of(' ') + 1);

    ImVec2 size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, text.c_str());
    float column_width = ImGui::GetContentRegionAvail().x;

    if (size.x >= column_width && column_width >= min_wrap_width && text.find(' ') != std::string::npos) {
        std::string original(text);

        while (size.x >= column_width) {
            std::smatch match;

            if (!std::regex_search(text, match, std::regex("(.*?)\\S+\\s*$")))
                return;

            text = match[1].str();
            size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, text.c_str());
        }

        render_centered_text(text, font);
        render_centered_text(original.substr(text.length()), font);

        return;
    }

    ImGui::SetCursorPosX((ImGui::GetCursorPosX() + (column_width / 2)) - size.x / 2);
    ImGui::PushFont(font);
    {
        ImGui::TextColored(color, "%s", text.c_str());
    }
    ImGui::PopFont();
}

void
plugin::gui::windows::spectator_information::nickname_custom_renderer(const std::string_view& text, std::uint32_t color) const {
    std::vector<server::admin>& admins = server::admins::list;

    bool spectating_administrator = std::find_if(admins.begin(), admins.end(), [=](server::admin it) {
        return it.id == server::spectator::id;
    }) != admins.end();

    render_centered_text(text, (*child->fonts->regular)[16], ImGui::ColorConvertU32ToFloat4(
        (spectating_administrator) ? style::accent_colors.red : color));
    
    widgets::hint::render_as_guide("Красный цвет означает, что вы следите\nза администратором.", spectating_administrator);
}

std::string
plugin::gui::windows::spectator_information::get_time_spectated() const {
    auto duration = std::chrono::steady_clock::now() - server::spectator::last_checked;
    auto minutes = std::chrono::duration_cast<std::chrono::minutes>(duration);
    
    duration -= minutes;
    
    auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);

    return std::format("{:02}:{:02}", minutes.count(), seconds.count());
}

std::vector<plugin::gui::windows::spectator_information::row>
plugin::gui::windows::spectator_information::get_rows() const {
    using namespace std::placeholders;

    server::spectator_information information = server::spectator::get_information();
    
    samp::vehicle vehicle = server::spectator::player.get_vehicle();
    std::string vehicle_name = "Отсутствует";

    if (vehicle.is_available()) {
        std::uint16_t id = 0xFFFF;

        if (auto new_id = samp::vehicle_pool::get_id(vehicle))
            id = *new_id;

        vehicle_name = std::format("{} ({})", game::get_vehicle_name(vehicle.get_model_index()), id);
    }

    return {
        row("Игрок", std::format("{}[{}]", server::spectator::nickname, server::spectator::id),
            std::bind(&spectator_information::nickname_custom_renderer, this, _1, _2)),
        
        row("Пинг", std::to_string(information.ping), [=] {
            if (information.ping >= 130)
                return style::accent_colors.red;
            
            if (information.ping >= 80)
                return style::accent_colors.yellow;

            return style::accent_colors.green;
        }),

        row("Платформа", std::format("{}", server::spectator::platform)),
        row("Время слежки", get_time_spectated()),
        row("ID аккаунта", std::to_string(information.account_id)),
        row("Дата регистрации", information.registration_date),
        row("Наличные/банк", std::format("{} / {}", information.money_hand, information.money_bank)),
        row("Здоровье/броня", std::format("{} / {}", information.health, information.armor)),
        row("Фракция", information.fraction),
        row("Должность", information.rank),
        row("Машина(-ы)", information.vehicle, std::bind(&spectator_information::vehicles_custom_renderer, this, _1, _2)),
        row("Стадия", std::to_string(information.stage)),
        row("VIP статус", information.vip),
        row("Предупреждения", std::to_string(information.warnings)),
        row("Модульный мир", std::to_string(information.world)),

        row("Тек./макс. скорость", std::format("{} / {}", information.move_speed_current, information.move_speed_max), [=] {
            if (server::spectator::player.get_vehicle().is_available() && information.move_speed_current > information.move_speed_max)
                return style::accent_colors.red;

            return ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
        }),

        row("Выстрелы/попадания", std::format("{} / {}", information.total_shots, information.hit_shots), [=] {
            if (information.total_shots != 0 && information.total_shots == information.hit_shots)
                return style::accent_colors.red;

            return ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
        }),

        row("Машина", vehicle_name),
        row("Двигатель/двери", "", std::bind(&spectator_information::vehicle_information_custom_renderer, this, _1, _2))
    };
}

void
plugin::gui::windows::spectator_information::render() {
    auto window_configuration = (*configuration)["windows"]["spectator_information"];
    
    if (!server::spectator::is_active() || !window_configuration["use"])
        return;

    std::vector<std::string> row_order = window_configuration["row_order"];
    std::vector<row> rows = get_rows();

    for (std::size_t i = 0; i < rows.size(); i++) {
        auto user_ordered_row = std::find(row_order.begin(), row_order.end(), rows[i].label);
        auto new_index = std::distance(row_order.begin(), user_ordered_row);

        if (user_ordered_row == row_order.end()) {
            log::error("string-array in configuration[\"windows\"][\"spectator_information\"][\"row_order\"] "
                       "is corrupted: value changing is prohibited");

            stop_render();
            
            return;
        }

        std::swap(rows[new_index], rows[i]);
    }

    ImGui::SetNextWindowSizeConstraints({ 320, 0 }, { FLT_MAX, FLT_MAX });
    ImGui::PushStyleVarX(ImGuiStyleVar_WindowPadding, 0);
    ImGui::PushStyleVarY(ImGuiStyleVar_ItemSpacing, ImGui::GetStyle().ItemSpacing.y * 2);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        if (ImGui::BeginTable("windows::spectator_information::table", 2)) {
            for (auto& row : rows) {
                ImFont* label_font = (*child->fonts->bold)[16], *value_font = (*child->fonts->regular)[16];

                ImGui::TableNextRow();
                ImGui::TableSetColumnIndex(0);
                render_centered_text(row.label, label_font);
                ImGui::TableSetColumnIndex(1);

                if (row.is_custom_renderer_available())
                    row.use_custom_renderer();
                else {
                    if (row.is_updater_available() && row.value != "Отсутствует")
                        row.update_color();

                    if (row.value == "Отсутствует")
                        row.color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);

                    render_centered_text(row.value, value_font, ImGui::ColorConvertU32ToFloat4(row.color));
                }
            }
            ImGui::EndTable();
        }
    }
    ImGui::End();
    ImGui::PopStyleVar(2);
}

plugin::gui::window_ptr_t
plugin::gui::windows::spectator_information::create(utils::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<spectator_information>(child);
}

plugin::gui::windows::spectator_information::spectator_information(utils::not_null<gui_initializer*> child) 
    : child(child)
{
    log::info("window \"windows::spectator_information\" initialized");
}
