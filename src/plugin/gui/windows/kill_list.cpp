#include "plugin/gui/windows/kill_list.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/animation.h"
#include "plugin/plugin.h"
#include "plugin/log.h"

plugin::types::color
plugin::gui::windows::kill_list::entry::player::get_color() {
    if (color.has_value())
        return *color;

    if ((*configuration)["windows"]["kill_list"]["clist_color"].get<bool>()) {
        if (auto it = samp::player_pool::get_remote_player(id); it.has_value() && it->is_available()) {
            types::color new_color = it->get_color();
            if (new_color != 0 && new_color != 0xFFFFFFFF) {
                color = new_color;
                return *color;
            }
        }
    }

    color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);

    return *color;
}

std::string
plugin::gui::windows::kill_list::entry::get_formatted_time() const {
    auto time_t = std::chrono::system_clock::to_time_t(time);
    auto local_time = std::localtime(&time_t);
    return std::format("[{:02}:{:02}:{:02}]", local_time->tm_hour, local_time->tm_min, local_time->tm_sec);
}

float
plugin::gui::windows::kill_list::entry::compute_width(ImFont* bold_font, ImFont* regular_font, bool with_time) const {
    float width = 0;

    if (with_time)
        width = bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0, get_formatted_time().c_str()).x + 5;

    width += bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0, std::format("{}[{}]", left.nickname, left.id).c_str()).x
        + regular_font->CalcTextSizeA(regular_font->FontSize, FLT_MAX, 0, reason.c_str()).x + 10;

    if (right.has_value())
        width += bold_font->CalcTextSizeA(bold_font->FontSize, FLT_MAX, 0, std::format("{}[{}]", right->nickname, right->id).c_str()).x + 5;

    return width;
}

ImVec2
plugin::gui::windows::kill_list::get_window_size(bool with_time) const {
    std::size_t max_count = (*configuration)["windows"]["kill_list"]["max_count"];
    ImVec2 window_padding = ImGui::GetStyle().WindowPadding;
    ImVec2 size = { 0, window_padding.y * 2 };

    for (int i = 0; i < std::min(max_count, entries.size()); i++) {
        if (float width = entries[i].compute_width(bold_font, regular_font, with_time); width > size.x)
            size.x = width;
        
        size.y += bold_font->FontSize + text_border_size;

        if (i > 0)
            size.y += ImGui::GetStyle().ItemSpacing.y;
    }

    return { size.x + window_padding.x * 2, size.y };
}

bool
plugin::gui::windows::kill_list::on_player_death_notification(const samp::player_death_notification& notification) {
    auto left_nickname = samp::player_pool::get_nickname(notification.killed_id);
    auto window_configuration = (*configuration)["windows"]["kill_list"];
    std::size_t max_count = window_configuration["max_count"];

    if (!left_nickname)
        return true;

    entry::player left = { *left_nickname, notification.killed_id };
    std::optional<entry::player> right;

    if (notification.killer_id != 0xFFFF) {
        if (auto right_nickname = samp::player_pool::get_nickname(notification.killer_id)) {
            entry::player temp(left);
            left = { *right_nickname, notification.killer_id };
            right = temp; 
        } else
            return true;
    }

    entries.push_back({
        .left = left,
        .right = right,
        .time = std::chrono::system_clock::now(),
        .reason = notification.get_reason(),
        .alpha_time = std::chrono::steady_clock::now(),
        .alpha = static_cast<float>(entries.size() + 1 >= max_count)
    });

    if (entries.size() == max_count + 1)
        entries.pop_front();

    time_pushed = std::chrono::steady_clock::now();

    return true;
}

bool
plugin::gui::windows::kill_list::on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream) {
    if (type == samp::event_type::incoming_rpc && id == samp::player_death_notification::event_id)
        return on_player_death_notification(samp::player_death_notification(stream));

    return true;
}

void
plugin::gui::windows::kill_list::render() {
    auto window_configuration = (*configuration)["windows"]["kill_list"];
    bool show_time = window_configuration["show_time"];
    std::size_t max_count = window_configuration["max_count"];

    if (!window_configuration["use"] || entries.empty())
        return;

    ImGui::SetNextWindowSize(get_window_size(show_time));
    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration);
    {
        for (auto& entry : entries) {
            float width = entry.compute_width(bold_font, regular_font, show_time);
            float pos_x = ImGui::GetStyle().WindowPadding.x, pos_y = ImGui::GetCursorPosY();

            if (entry.alpha != 1.0f)
                entry.alpha = animation::bring_to(entry.alpha, 1.0f, entry.alpha_time, alpha_change_duration);

            if (std::string align = window_configuration["align"]; align != "left")
                pos_x = (align == "right") ? ImGui::GetWindowWidth() - width - pos_x: (ImGui::GetWindowWidth() - width) / 2;

            ImGui::SetCursorPosX(pos_x);
            ImGui::PushStyleVar(ImGuiStyleVar_Alpha, entry.alpha);
            ImGui::BeginGroup();
            {
                widgets::text(bold_font, text_border_size, "{}", entry.get_formatted_time());
                ImGui::SameLine(0, 5);
                ImGui::PushStyleColor(ImGuiCol_Text, *entry.left.get_color());
                {
                    widgets::text(bold_font, text_border_size, "{}[{}]", entry.left.nickname, entry.left.id);
                }
                ImGui::PopStyleColor();
                
                ImGui::SameLine(0, 5);
                ImGui::SetCursorPosY(pos_y + 2);
                widgets::text(regular_font, text_border_size, "{}", entry.reason);
                
                if (entry.right.has_value()) {
                    ImGui::SameLine(0, 5);
                    ImGui::SetCursorPosY(pos_y);
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.right->get_color());
                    {
                        widgets::text(bold_font, text_border_size, "{}[{}]", entry.right->nickname, entry.right->id);
                    }
                    ImGui::PopStyleColor();
                }
            }
            ImGui::EndGroup();
            ImGui::PopStyleVar();
        }
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

plugin::gui::window_ptr_t
plugin::gui::windows::kill_list::create(utils::not_null<gui_initializer*> child) noexcept {
    return std::make_unique<kill_list>(child);
}

plugin::gui::windows::kill_list::kill_list(utils::not_null<gui_initializer*> child)
    : child(child),
      bold_font((*child->fonts->bold)[18]),
      regular_font((*child->fonts->regular)[16])
{
    log::info("window \"windows::kill_list\" initialized");
}
