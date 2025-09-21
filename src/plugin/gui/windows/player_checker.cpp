/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/gui/windows/player_checker.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/gui/style.h"
#include "plugin/samp/core/audio.h"
#include "plugin/samp/core/player_pool.h"
#include "plugin/samp/core/user.h"
#include "plugin/samp/events/server_connect.h"
#include "plugin/samp/events/server_quit.h"
#include "plugin/samp/events/set_player_name.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"

auto plugin::gui::windows::player_checker::entry_t::to_string() const -> std::string {
    return (id == id_none) ? nickname : std::format("{}[{}]", nickname, id);
}

auto plugin::gui::windows::player_checker::get_render_safe_color(const types::color& color) const -> types::color {
    return (color == 0xFFFFFFFF || color == 0) ? ImGui::GetColorU32(ImGuiCol_Text) : color;
}

auto plugin::gui::windows::player_checker::get_entry_width(const entry_t& entry, bool show_offline) const -> float {
    float width = bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, entry.to_string().c_str()).x
        + text_border_size * 2;

    if (show_offline) {
        std::string text = (entry.id == id_none) ? "[OFFLINE]" : "[ONLINE]";
        width += bold_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, text.c_str()).x + ImGui::GetStyle().ItemSpacing.x;
    }

    if (!entry.description.empty()) {
        std::string text = " - " + entry.description;
        width += regular_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, text.c_str()).x;
    }

    return width;
}

auto plugin::gui::windows::player_checker::get_window_information() const -> window_information_t {
    auto& window_configuration = (*configuration)["windows"]["player_checker"];
    window_information_t window_information;

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return window_information;

    widgets::aligner::mode_t align_mode = window_configuration["align"];
    bool clist_color = window_configuration["clist_color"];

    window_information.render_configuration.show_offline = window_configuration["show_offline"];
    window_information.render_configuration.show_title = window_configuration["show_title"];
    window_information.render_configuration.render = true;

    for (const auto& player : window_configuration["players"]) {
        std::string nickname = player["nickname"];

        if (nickname == samp::user::get_name())
            continue;

        auto remote_player = samp::player_pool::get_remote_player(nickname); 

        if (!remote_player && !window_information.render_configuration.show_offline)
            continue;

        entry_t entry = {
            .nickname = nickname,
            .description = player["description"],
            .nickname_color = (remote_player && clist_color)
                ? get_render_safe_color(remote_player->get_color())
                : ImGui::GetColorU32(ImGuiCol_Text),
            .id = (remote_player) ? remote_player->get_id() : id_none
        };

        float entry_width = get_entry_width(entry, window_information.render_configuration.show_offline);
        entry.aligner = widgets::aligner(align_mode, entry_width);

        if (window_information.width < entry_width)
            window_information.width = entry_width;

        window_information.entries.push_back(entry);
    }

    if (window_information.render_configuration.show_title) {
        float title_width = bold_font->CalcTextSizeA(title_font_size, FLT_MAX, 0.0f, title_text).x
            + text_border_size * 2;

        if (window_information.width < title_width)
            window_information.width = title_width;

        window_information.title_aligner = widgets::aligner(align_mode, title_width);
    }

    window_information.width += ImGui::GetStyle().WindowPadding.x * 2;

    return window_information;
}

auto plugin::gui::windows::player_checker::send_state_notification(const state_notification_t& notification) const -> void {
    if (notification.configuration.sound_notify)
        samp::audio::play_sound(samp::audio::sound_id::bell);

    if (!notification.configuration.notify)
        return;
    
    gui::notification::icon_t icon = (notification.configuration.disconnected) ? ICON_USER_CLOSE : ICON_USER_CHECK;

    std::string title = std::format("{}[{}] {}", notification.nickname, notification.id,
            (notification.configuration.disconnected) ? "отключился от сервера" : "подключился к серверу");
    
    std::string description = std::format("Теперь он {}отображается в чекере игроков.",
            (notification.configuration.disconnected) ? "не " : ""); 

    notify::send(gui::notification(title, description, icon));
}

auto plugin::gui::windows::player_checker::on_event(const samp::event_info& event) -> bool {
    auto& window_configuration = (*configuration)["windows"]["player_checker"];

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return true;

    auto& players = window_configuration["players"];

    if (players.empty())
        return true;

    state_notification_t notification = {
        .configuration = {
            .disconnected = false,
            .notify = window_configuration["notify"],
            .sound_notify = window_configuration["sound_notify"]
        }
    };

    if (event == samp::event_id::server_quit) {
        auto created_event = event.create<samp::event_id::server_quit>();
        auto nickname = samp::player_pool::get_nickname(created_event.id);

        if (!nickname)
            return true;

        notification.configuration.disconnected = true;
        notification.id = created_event.id;
        notification.nickname = *nickname;
    } else if (event == samp::event_id::server_connect) {
        auto created_event = event.create<samp::event_id::server_connect>();
        notification.nickname = created_event.nickname;
        notification.id = created_event.id;
    } else if (event == samp::event_id::set_player_name) {
        auto created_event = event.create<samp::event_id::set_player_name>();
        notification.nickname = created_event.nickname;
        notification.id = created_event.id;
    } else
        return true;

    if (std::find_if(players.begin(), players.end(), [notification](const nlohmann::json& player) {
        return player["nickname"] == notification.nickname;
    }) != players.end()) {
        send_state_notification(notification);
    }

    return true;
}

auto plugin::gui::windows::player_checker::render() -> void {
    window_information_t window_information = get_window_information();

    if (!window_information.render_configuration.render)
        return;

    auto flags = ImGuiWindowFlags_NoBackground | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoDecoration;

    ImGui::SetNextWindowSize({ window_information.width, 0.0f });
    ImGui::Begin(get_id(), nullptr, flags);
    {
        if (window_information.render_configuration.show_title) {
            window_information.title_aligner.align_next_item();
            widgets::text(bold_font, title_font_size, text_border_size, title_text);
        }

        for (const auto& entry : window_information.entries) {
            entry.aligner.align_next_item();
            ImGui::BeginGroup();
            {
                if (window_information.render_configuration.show_offline) {
                    bool connected = (entry.id != id_none);
                    types::color color = (connected) ? style::get_current_accent_colors().green : style::get_current_accent_colors().red;
                    std::string text = std::format("[{}]", (connected) ? "ONLINE" : "OFFLINE");

                    ImGui::PushStyleColor(ImGuiCol_Text, *color);
                    {
                        widgets::text(bold_font, common_font_size, text_border_size, "{}", text);
                        ImGui::SameLine();
                    }
                    ImGui::PopStyleColor();
                }

                ImGui::PushStyleColor(ImGuiCol_Text, *entry.nickname_color);
                {
                    widgets::text(bold_font, common_font_size, text_border_size, "{}", entry.to_string());
                }
                ImGui::PopStyleColor();

                if (!entry.description.empty()) {
                    ImGui::SameLine(0.0f, 0.0f);
                    widgets::text(regular_font, common_font_size, text_border_size, " - {}", entry.description);
                }
            }
            ImGui::EndGroup();
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::player_checker::create(types::not_null<gui_initializer*> child)
    noexcept -> window_ptr_t
{
    return std::make_unique<player_checker>(child);
}
