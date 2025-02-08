#include "plugin/gui/windows/notify.h"
#include "plugin/game/game.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/animation.h"
#include "plugin/plugin.h"

bool
plugin::gui::windows::notify::on_send_notification(notification& notification) {
    auto window_configuration = (*configuration)["windows"]["notify"];
    std::size_t max_count = window_configuration["max_count"];

    if (gui::notify::notifications_count() >= max_count)
        return false;

    float start_pos_x = (window_configuration["align"] == "left") ? -notification_size[0] : notification_size[0];

    notification.backend = notification::backend_t { start_pos_x }; 
    height += notification_size[1] + padding;

    return true;
}

ImVec2
plugin::gui::windows::notify::get_buttons_max_size(ImFont* font, const notification::buttons_t& buttons) const {
    ImVec2 first_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, buttons.first.name.c_str());
    ImVec2 second_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, buttons.second.name.c_str());

    if (second_size.x > first_size.x)
        first_size = second_size;

    return first_size;
}

void
plugin::gui::windows::notify::render_notification(notification& item) const {
    ImVec2 cursor_pos = ImGui::GetCursorScreenPos();
    ImU32 text_color = ImGui::GetColorU32(ImGuiCol_Text);
    ImFont *icon = (*child->fonts->icon)[24], *bold = (*child->fonts->bold)[18], *regular = (*child->fonts->regular)[16];
    ImDrawList* draw_list = ImGui::GetForegroundDrawList();

    draw_list->AddRectFilled(cursor_pos, { cursor_pos.x + notification_size[0], cursor_pos.y + notification_size[1] },
                             ImGui::GetColorU32(ImGuiCol_WindowBg), ImGui::GetStyle().ChildRounding);

    ImVec2 icon_size = icon->CalcTextSizeA(icon->FontSize, FLT_MAX, 0, item.icon);
    ImVec2 icon_pos = { cursor_pos.x + 12, cursor_pos.y + (notification_size[1] - icon_size.y) / 2 };

    draw_list->AddText(icon, icon->FontSize, icon_pos, text_color, item.icon);

    ImVec2 buttons_size = { 0, 0 };
    ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
    float wrap_width = notification_size[0] - icon_size.x - 22;

    if (item.buttons.has_value()) {
        buttons_size = get_buttons_max_size(regular, *item.buttons);
        wrap_width -= buttons_size.x + item_spacing.x * 2 + 10;
    }

    ImVec2 title_size = bold->CalcTextSizeA(bold->FontSize, FLT_MAX, 0, item.title.c_str());
    ImVec2 description_size = regular->CalcTextSizeA(regular->FontSize, FLT_MAX, wrap_width, item.description.c_str());
    ImVec2 group_pos = { icon_pos.x + icon_size.x + 10, cursor_pos.y + (notification_size[1] - title_size.y - description_size.y - item_spacing.y) / 2 };

    draw_list->AddText(bold, bold->FontSize, group_pos, text_color, item.title.c_str());
    draw_list->AddText(regular, regular->FontSize, { group_pos.x, group_pos.y + title_size.y + item_spacing.y },
                       text_color, item.description.c_str(), nullptr, wrap_width);

    if (item.buttons.has_value()) {
        ImVec2 start = { cursor_pos.x + notification_size[0] - item_spacing.x - buttons_size.x - 10, 
                         cursor_pos.y + (notification_size[1] - buttons_size.y * 2) / 2 - item_spacing.y };
        
        render_button(start, regular, item, item.buttons->first);
        render_button({ start.x, start.y + buttons_size.y + item_spacing.y }, regular, item, item.buttons->second);
    }

    ImGui::Dummy({ notification_size[0], notification_size[1] });
}

void
plugin::gui::windows::notify::render_button(const ImVec2& pos, ImFont* font, notification& notification, notification::button& button) const {
    if (!button.backend.has_value()) {
        notification::button::backend_t backend;
        backend.color = backend.colors.text;
        button.backend = backend;
    }

    ImDrawList* draw_list = ImGui::GetForegroundDrawList();
    ImVec2 text_size = font->CalcTextSizeA(font->FontSize, FLT_MAX, 0, button.name.c_str());
    bool hovering = ImGui::IsMouseHoveringRect(pos, { pos.x + text_size.x, pos.y + text_size.y });
    auto now = std::chrono::steady_clock::now();

    draw_list->AddText(font, font->FontSize, pos, ImGui::ColorConvertFloat4ToU32(button.backend->color), button.name.c_str());

    if (hovering && ImGui::IsMouseClicked(ImGuiMouseButton_Left)) {
        button.backend->time[0] = button.backend->clicked_time = now;
        button.backend->time[1] = now + button.backend->clicked_duration;
        button.callback(notification);
    }

    if (now - button.backend->time[0] <= button.backend->hovered_duration) {
        button.backend->color = animation::bring_to(button.backend->color, button.backend->colors.clicked,
                                                    button.backend->time[0], button.backend->hovered_duration);
        return;
    }

    button.backend->hovered_state_current = hovering || now - button.backend->time[1] < 0ms;

    if (button.backend->hovered_state_current != button.backend->hovered_state_previous) {
        button.backend->hovered_state_previous = button.backend->hovered_state_current;
        button.backend->hovered_time = now;
    }

    button.backend->color = animation::bring_to(button.backend->color, (button.backend->hovered_state_current)
        ? button.backend->colors.hovered : button.backend->colors.text, button.backend->hovered_time, button.backend->hovered_duration);
}

void
plugin::gui::windows::notify::render() {
    auto window_configuration = (*configuration)["windows"]["notify"];

    if (!gui::notify::has_notifications() || !window_configuration["use"])
        return;

    auto [size_x, size_y] = game::get_screen_resolution();
    std::string align = window_configuration["align"];

    ImGui::SetNextWindowPos({ ((align == "left") ? 0 : size_x - notification_size[0]) - padding, size_y - height - padding });
    ImGui::SetNextWindowSize({ notification_size[0] + padding, height }, ImGuiCond_FirstUseEver);

    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_AlwaysAutoResize);
    {
        std::vector<notification>& notifications = gui::notify::get_notifications();
        for (auto it = notifications.rbegin(); it != notifications.rend();) {
            float start_pos_x = (align == "left") ? -notification_size[0] : notification_size[0];
            float end_pos_x = (align == "left") ? padding * 2 : 0;
            auto now = std::chrono::steady_clock::now();
            
            it->backend->cursor_pos_x = animation::bring_to(it->backend->cursor_pos_x, end_pos_x, it->time_sended, it->backend->open_close_duration);
            
            if (!it->condition() && it->backend->cursor_pos_x == end_pos_x && now - it->time_sended <= it->duration)
                it->time_sended = now - it->duration;

            if (now - it->time_sended >= it->duration) {
                auto time = it->time_sended + it->duration; 
                
                it->backend->cursor_pos_x = animation::bring_to(it->backend->cursor_pos_x, start_pos_x, time, it->backend->open_close_duration);
                
                if (it->backend->cursor_pos_x == start_pos_x) {
                    float new_height = (gui::notify::notifications_count() - 1) * (notification_size[1] + padding); 
                    auto new_time = time + it->backend->open_close_duration;

                    height = animation::bring_to(height, new_height, time + it->backend->open_close_duration, it->backend->drop_duration);
                    
                    if (height == new_height) {
                        it = static_cast<decltype(it)>(notifications.erase(std::next(it).base()));
                        continue;
                    }
                }
            }

            ImGui::SetCursorPos({ it->backend->cursor_pos_x, ImGui::GetCursorPosY() - ImGui::GetStyle().ItemSpacing.y + padding });
            render_notification(*it);
        
            it++;
        }
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

plugin::gui::window_ptr_t
plugin::gui::windows::notify::create(utils::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<notify>(child);
}

plugin::gui::windows::notify::notify(utils::not_null<gui_initializer*> child) : child(child) {
    log::info("window \"windows::notify\" initialized");
    gui::notify::set_callback(std::bind(&notify::on_send_notification, this, std::placeholders::_1));
}
