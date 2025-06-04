#include "plugin/gui/windows/far_chat.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include <ctime>

auto plugin::gui::windows::far_chat::compute_window_size() const -> ImVec2 {
    auto window_configuration = (*configuration)["windows"]["far_chat"];
    std::size_t max_count = window_configuration["max_count"];

    ImVec2 padding = ImGui::GetStyle().WindowPadding;
    ImVec2 size = { 0, padding.y * 2 };

    for (int i = 0; i < std::min(max_count, entries.size()); i++) {
        ImVec2 entry_size = compute_entry_size(entries[i]);

        size.y += entry_size.y;

        if (entry_size.x > size.x)
            size.x = entry_size.x;

        if (i > 0)
            size.y += ImGui::GetStyle().ItemSpacing.y;
    }

    return { size.x + padding.x * 2, size.y };
}

auto plugin::gui::windows::far_chat::compute_entry_size(const entry& entry) const -> ImVec2 {
    auto window_configuration = (*configuration)["windows"]["far_chat"];
    ImVec2 size = { 0, bold->FontSize + text_border_size };

    size.x += bold->CalcTextSizeA(bold->FontSize, FLT_MAX, 0,
        std::format("{}[{}]:", entry.player.nickname, entry.player.id).c_str()).x + spacing_x;

    size.x += regular->CalcTextSizeA(regular->FontSize, FLT_MAX, 0, entry.message.c_str()).x;

    if (window_configuration["show_time"])
        size.x += bold->CalcTextSizeA(bold->FontSize, FLT_MAX, 0, entry.time.c_str()).x + spacing_x;

    return size;
}

auto plugin::gui::windows::far_chat::on_player_chat_bubble(const samp::event<samp::event_id::player_chat_bubble>& event) -> bool {
    auto window_configuration = (*configuration)["windows"]["far_chat"];

    if (!window_configuration["use"])
        return true;

    if (event.color == 0xFF8054E7 && event.message[0] != '*')
        return true;
    
    samp::player player(event.player_id);

    if (!player)
        return true;

    auto now = std::chrono::steady_clock::now();

    if (!entries.empty()) {
        long duplicates_delay_ms = window_configuration["duplicates_delay_ms"];
        entry last = entries.back();

        if (now - last.steady_time <= std::chrono::milliseconds(duplicates_delay_ms) &&
            last.message == event.message &&
            last.player.id == event.player_id)
        {
            return true;
        }
    }

    std::string time = "";
    {
        auto now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
        std::tm tm = *std::localtime(&now_time_t);
        time = std::format("[{:02}:{:02}:{:02}]", tm.tm_hour, tm.tm_min, tm.tm_sec);
    }

    types::color default_color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
    types::color player_color = player.get_color(), message_color = event.color;
    {
        if (message_color == 0xFFFFFFFF || message_color == 0)
            message_color = default_color;
    
        if (player_color  == 0xFFFFFFFF || player_color == 0)
            player_color = default_color;
    }

    entries.push_back({ samp::player(event.player_id), player_color, message_color,
                        event.message, time, now });
    
    if (entries.size() == window_configuration["max_count"].get<std::size_t>() + 1)
        entries.pop_front();

    return true;
}

auto plugin::gui::windows::far_chat::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::incoming_rpc && event == samp::event_id::player_chat_bubble)
        return on_player_chat_bubble(event.create<samp::event_id::player_chat_bubble>());

    return true;
}

auto plugin::gui::windows::far_chat::render() -> void {
    auto window_configuration = (*configuration)["windows"]["far_chat"];

    if (!window_configuration["use"] || !server::user::is_on_alogin())
        return;
    
    ImVec2 window_size = compute_window_size();

    ImGui::SetNextWindowSize(window_size);
    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoDecoration);
    {
        for (const auto& entry : entries) {
            ImVec2 pos = { ImGui::GetStyle().WindowPadding.x, ImGui::GetCursorPosY() };
            ImVec2 entry_size = compute_entry_size(entry);

            if (std::string align = window_configuration["align"]; align != "left")
                pos.x = (align == "right") ? window_size.x - entry_size.x - pos.x : (window_size.y - entry_size.x) / 2;

            ImGui::SetCursorPosX(pos.x);
            ImGui::BeginGroup();
            {
                if (window_configuration["show_time"]) {
                    widgets::text(bold, text_border_size, "{}", entry.time);
                    ImGui::SameLine(0, 5);
                }
                
                if (window_configuration["clist_color"])
                    ImGui::PushStyleColor(ImGuiCol_Text, *entry.player_color);

                widgets::text(bold, text_border_size, "{}[{}]:", entry.player.nickname, entry.player.id);
                ImGui::SameLine(0, 5);

                if (window_configuration["clist_color"])
                    ImGui::PopStyleColor();

                ImGui::PushStyleColor(ImGuiCol_Text, *entry.message_color);
                {
                    ImGui::SetCursorPosY(pos.y + 2);
                    widgets::text(regular, text_border_size, "{}", entry.message);
                }
                ImGui::PopStyleColor();
            }
            ImGui::EndGroup();
        }
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::far_chat::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<far_chat>(child);
}
