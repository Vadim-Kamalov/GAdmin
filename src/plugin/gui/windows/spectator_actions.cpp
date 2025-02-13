#include "plugin/gui/windows/spectator_actions.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/core/menu.h"
#include "plugin/server/binder.h"
#include "plugin/server/spectator.h"
#include "plugin/log.h"
#include "plugin/plugin.h"

void
plugin::gui::windows::to_json(nlohmann::json& json, const spectator_actions::button& button) {
    json["use"] = button.use;
    json["name"] = button.name;

    if (std::holds_alternative<int>(button.action))
        json["action"] = std::get<int>(button.action);
    else
        json["action"] = std::get<std::string>(button.action);
}

void
plugin::gui::windows::from_json(const nlohmann::json& json, spectator_actions::button& button) {
    button.use = json["use"];
    button.name = json["name"];

    if (json["action"].is_number())
        button.action = json["action"].get<int>();
    else if (json["action"].is_string())
        button.action = json["action"].get<std::string>();
}

void
plugin::gui::windows::spectator_actions::render() {
    auto window_configuration = (*configuration)["windows"]["spectator_actions"];

    if (!server::spectator::is_active() || !window_configuration["use"])
        return;

    server::spectator_information information = server::spectator::get_information();

    std::string left_information = std::format("{}", server::spectator::platform);
    std::string center_information = std::format("Скорость: {} / {} · Оружие: {} · Здоровье: {} · Пинг: {}",
                                                 information.move_speed_current, information.move_speed_max,
                                                 information.weapon, information.health, information.ping);

    ImGui::SetNextWindowSizeConstraints({ 700, 120 }, { FLT_MAX, FLT_MAX });
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        ImGui::BeginGroup();
        {
            child->fonts->bold->push(16);
            {
                ImGui::TextUnformatted(std::format("{}[{}]", server::spectator::nickname, server::spectator::id).c_str());
            }
            ImGui::PopFont();
            child->fonts->regular->push(16);
            {
                ImGui::SameLine((ImGui::GetWindowWidth() - ImGui::CalcTextSize(center_information.c_str()).x) / 2);
                ImGui::TextUnformatted(center_information.c_str());
            }
            ImGui::PopFont();
            child->fonts->bold->push(16);
            {
                ImGui::SameLine();
                ImGui::SetCursorPosX(ImGui::GetWindowWidth() - ImGui::CalcTextSize(left_information.c_str()).x - ImGui::GetStyle().WindowPadding.x);
                ImGui::TextUnformatted(left_information.c_str());
            }
            ImGui::PopFont();
        }
        ImGui::EndGroup();
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() - ImGui::GetStyle().ItemSpacing.y + ImGui::GetStyle().WindowPadding.y);
        ImGui::BeginGroup();
        {
            std::vector<button> buttons = window_configuration["buttons"];
            bool show_corner_buttons = window_configuration["show_corner_buttons"];

            int size = std::count_if(buttons.begin(), buttons.end(), [](button it) { return it.use; });
            bool has_tall_button = size % 2 != 0;
            int offset_corner_buttons = static_cast<int>(show_corner_buttons) + static_cast<int>(has_tall_button);
            int buttons_on_line = size / 2;

            ImVec2 spacing = ImGui::GetStyle().ItemSpacing;
            float padding = ImGui::GetStyle().WindowPadding.x * 2;
            float button_height = (ImGui::GetWindowHeight() - ImGui::GetCursorPosY() - ImGui::GetStyle().WindowPadding.y - spacing.y) / 2;
            float tall_button_height = button_height * 2 + spacing.y;
            float button_width = (ImGui::GetWindowWidth() - padding - std::max<int>(0, buttons_on_line + offset_corner_buttons - 1) 
                    * spacing.x) / (buttons_on_line + offset_corner_buttons);

            if (show_corner_buttons) {
                child->fonts->icon->push(24);
                {
                    auto button = widgets::button(ICON_CHEVRON_LEFT "##windows::spectator_actions", { button_width / 2, tall_button_height })
                        .with_draw_flags(ImDrawFlags_RoundCornersLeft);

                    if (button.render())
                        server::spectator::send_menu_option<server::spectator::menu_option::back>();
                }
                ImGui::PopFont();
                ImGui::SameLine();
            }
            
            ImGui::BeginGroup();
            {
                if (size > 0) {
                    float first_line_pos_y = ImGui::GetCursorPosY();
                    int active_button_count = 0;

                    child->fonts->regular->push(15);
                    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 0);
                    ImGui::BeginGroup();
                    {
                        for (const auto& [ index, button ] : buttons | std::views::enumerate) {
                            if (!button.use)
                                continue;

                            bool tall_button = ++active_button_count == size && has_tall_button;

                            if (tall_button)
                                ImGui::SetCursorPosY(first_line_pos_y);

                            if (widgets::button(button.name, { button_width, (tall_button) ? tall_button_height : button_height }).render()) {
                                if (std::holds_alternative<int>(button.action)) {
                                    samp::menu::select(std::get<int>(button.action));
                                } else {
                                    server::binder::evaluate(std::get<std::string>(button.action));
                                }
                            }
                       
                            if (!tall_button && size >= 2 && active_button_count != buttons_on_line)
                                ImGui::SameLine();
                        }
                    }
                    ImGui::EndGroup();
                    ImGui::PopStyleVar();
                    ImGui::PopFont();
                }
            }
            ImGui::EndGroup();
            
            if (show_corner_buttons) {
                ImGui::SameLine();
                child->fonts->icon->push(24);
                {
                    auto button = widgets::button(ICON_CHEVRON_RIGHT "##windows::spectator_actions", { button_width / 2, tall_button_height })
                        .with_draw_flags(ImDrawFlags_RoundCornersRight);
                    
                    if (button.render())
                        server::spectator::send_menu_option<server::spectator::menu_option::next>();
                }
                ImGui::PopFont();
            }
        }
        ImGui::EndGroup();
    }
    ImGui::End();
}

plugin::gui::window_ptr_t
plugin::gui::windows::spectator_actions::create(types::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<spectator_actions>(child);
}

plugin::gui::windows::spectator_actions::spectator_actions(types::not_null<gui_initializer*> child) : child(child) {
    log::info("window \"windows::spectator_actions\" initialized");
}
