#include "plugin/gui/windows/vehicle_selection.h"
#include "plugin/game/vehicle.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/plugin.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep
#include "plugin/game/game.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/server/user.h"
#include <ranges>
#include <ctre.hpp>

auto plugin::gui::windows::vehicle_selection::on_send_command(const samp::out_event<samp::event_id::send_command>& event)
    -> bool
{
    static constexpr ctll::fixed_string command_pattern = "/veh\\s*";

    auto window_configuration = (*configuration)["windows"]["vehicle_selection"];

    if (!window_configuration["use"] || !server::user::is_on_alogin() || !ctre::match<command_pattern>(event.command))
        return true;

    if (active)
        close_window();
    else 
        open_window();

    return false;
}

auto plugin::gui::windows::vehicle_selection::get_filtered_entries() -> std::vector<entry> {
    std::vector<entry> entries;

    if (!search_bar.empty()) {
        for (const auto& [ index, name ] : game::vehicle_names | std::views::enumerate) {
            std::uint16_t id = game::min_vehicle_id + index;

            if (!search_bar.contains("{}[ID: {}]", name, id))
                continue;

            entries.push_back({ name, id });
        }

        if (entries.size() == 1 && ImGui::IsKeyPressed(ImGuiKey_Enter)) {
            samp::input::send_command("/veh {} {} {}", entries[0].id, colors[0], colors[1]);
            close_window();
        }
    }

    return entries;
}

auto plugin::gui::windows::vehicle_selection::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    return true;
}

auto plugin::gui::windows::vehicle_selection::on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool {
    if (message == WM_KEYUP && wparam == VK_ESCAPE && active) {
        close_window();
        return false;
    }

    return true;
}

auto plugin::gui::windows::vehicle_selection::render() -> void {
    if (!active)
        return;

    auto [size_x, size_y] = game::get_screen_resolution();

    background_alpha = animation::bring_to(background_alpha, (closing) ? 0 : 128, time, animation_duration);
    window_alpha = animation::bring_to(window_alpha, (closing) ? 0 : 255, time, animation_duration);

    if (!closing && background_alpha != 128 && !child->is_cursor_active())
        child->enable_cursor();

    if (background_alpha == 0 && closing) {
        closing = active = false;
        colors[0] = colors[1] = 0;
        search_bar.clear();
    }

    ImGui::GetBackgroundDrawList()->AddRectFilled({ 0, 0 }, { size_x, size_y }, background_alpha << 24);

    ImGui::SetNextWindowSizeConstraints({ 400, 600 }, { FLT_MAX, FLT_MAX });
    ImGui::SetNextWindowPos({ size_x / 2, size_y / 2 }, ImGuiCond_FirstUseEver, { 0.5, 0.5 });
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, window_alpha / 255.f);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        widgets::text(child->fonts->bold, 24, 0, "Выберите машину для спавна");
        ImGui::BeginGroup();
        {
            ImVec2 spacing = ImGui::GetStyle().ItemSpacing;
            ImVec2 padding = ImGui::GetStyle().WindowPadding;

            float input_height = 18 /* input font size */ + ImGui::GetStyle().FramePadding.y * 2;
            float buttons_end_x = spacing.x * 3 + input_height * 2;
            float input_width = ImGui::GetWindowWidth() / 2 - padding.x - buttons_end_x;
            float secondary_group_x = input_width + buttons_end_x;

            widgets::text(child->fonts->bold, 16, 0, "Основной цвет");
            ImGui::SameLine(secondary_group_x);
            widgets::text(child->fonts->bold, 16, 0, "Дополнительный цвет");
        
            ImGui::PushItemWidth(input_width);
            ImGui::PushFont(child->fonts->regular, 18);
            {
                for (int i = 0; i < 2; i++) {
                    ImGui::BeginGroup();
                    {
                        std::string id = std::format("windows::vehicle_selection::color_input[{}]", i);

                        widgets::button left = widgets::button("+##" + id, { input_height, input_height })
                            .with_draw_flags(ImDrawFlags_RoundCornersTopLeft | ImDrawFlags_RoundCornersBottomLeft); 

                        widgets::button right = widgets::button("-##" + id, { input_height, input_height })
                            .with_draw_flags(ImDrawFlags_RoundCornersTopRight | ImDrawFlags_RoundCornersBottomRight);

                        ImVec2 pos = ImGui::GetCursorPos();

                        if (ImGui::InputInt(("##" + id).c_str(), &colors[i], 0))
                            colors[i] = std::clamp(colors[i], 0, 255);

                        ImGui::PushFont(child->fonts->bold, 18);
                        {
                            // ImGui::SameLine() breaks Y-position of the text in the button (only): have to do this.
                            ImGui::SetCursorPos({ pos.x + input_width + ImGui::GetStyle().ItemSpacing.x, pos.y });
                            
                            if (left.render())
                                colors[i] = std::min(colors[i] + 1, 255);
                    
                            ImGui::SameLine();

                            if (right.render())
                                colors[i] = std::max(colors[i] - 1, 0);
                        }
                        ImGui::PopFont();
                    }
                    ImGui::EndGroup();

                    if (i == 0)
                        ImGui::SameLine(secondary_group_x);
                }
            }
            ImGui::PopFont();
            ImGui::PopItemWidth();
        }
        ImGui::EndGroup();

        float widgets_width = ImGui::GetWindowWidth() - ImGui::GetStyle().WindowPadding.x * 2;

        if (focus) {
            ImGui::SetKeyboardFocusHere();
            focus = false;
        }

        search_bar.render(widgets_width, "Поиск");
        
        float body_height = ImGui::GetWindowHeight() - ImGui::GetCursorPosY() - ImGui::GetStyle().WindowPadding.y
            - ImGui::GetStyle().ItemSpacing.y - create_button_height;
        
        ImGui::PushFont(child->fonts->bold, 16);
        {
            ImVec2 window_padding = ImGui::GetStyle().WindowPadding;

            ImGui::BeginChild("windows::vehicle_selection::body", { widgets_width, body_height });
            {
                ImGuiListClipper clipper;
                std::vector<entry> entries = get_filtered_entries();
                
                ImGui::SetCursorPos(window_padding);
                ImGui::BeginGroup();
                {
                    clipper.Begin((search_bar.empty()) ? game::vehicle_count + 1 : entries.size());

                    while (clipper.Step()) {
                        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                            entry item = (search_bar.empty())
                                ? entry { game::vehicle_names[i], static_cast<std::uint16_t>(game::min_vehicle_id + i) }
                                : entries[i];

                            float width = ImGui::GetContentRegionAvail().x - ImGui::GetStyle().FrameBorderSize - window_padding.x;
                            auto create_button = widgets::button(std::format("{}[ID: {}]", item.name, item.id), { width, create_button_height })
                                .with_durations({ 200ms, 0ms, 0ms });

                            if (create_button.render()) {
                                samp::input::send_command("/veh {} {} {}", item.id, colors[0], colors[1]);
                                close_window();
                            }
                        }
                    }

                    ImGui::Spacing();
                }
                ImGui::EndGroup();
            }
            ImGui::EndChild();
        
            ImVec2 create_button_size = { ImGui::GetWindowWidth() - window_padding.x * 2, create_button_height };
            auto create_button = widgets::button("Отмена##windows::vehicle_selection", create_button_size)
                .with_durations({ 200ms, 0ms, 0ms });

            if (create_button.render())
                close_window();
        }
        ImGui::PopFont();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::vehicle_selection::open_window() -> void {
    time = std::chrono::steady_clock::now();
    active = focus = true;
}

auto plugin::gui::windows::vehicle_selection::close_window() -> void {
    time = std::chrono::steady_clock::now();
    closing = true;
    child->disable_cursor();
}

auto plugin::gui::windows::vehicle_selection::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<vehicle_selection>(child);
}
