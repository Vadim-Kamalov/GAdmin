/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/gui/windows/report/frames/gps.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/gui.h"
#include "plugin/plugin.h"
#include <algorithm>

static constexpr std::uint8_t gps_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../../../../../embed/gps.mpk"
#else
#embed "../../../../../../embed/gps.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t gps_bytes[]

auto plugin::gui::windows::report::frames::gps::node_t::get_path() const -> std::string {
    std::vector<std::string> parts;
    std::string result;

    const node_t* current = this;
    
    while (current != nullptr) {
        parts.push_back(current->key);
        current = current->previous.get();
    }

    std::reverse(parts.begin(), parts.end());

    for (const auto& part : parts) {
        if (!result.empty())
            result.append(" -> ");

        result.append(part);
    }

    return result;
}

auto plugin::gui::windows::report::frames::gps::write_filtered_entries(std::vector<std::string>& entries,
                                                                       nlohmann::ordered_json& current,
                                                                       std::string current_path) const
    -> void
{
    for (const auto& [ key, value ] : current.items()) {
        std::string new_path = (current_path.empty()) ? key : current_path + " -> " + key;

        if (!value.empty())
            write_filtered_entries(entries, value, new_path);
        else if (search.contains(new_path))
            entries.push_back(new_path);
    }
}

auto plugin::gui::windows::report::frames::gps::render_search_entries() -> void {
    std::vector<std::string> entries;
    write_filtered_entries(entries, list);

    ImGuiListClipper clipper;
    clipper.Begin(entries.size());
    
    ImGui::SetCursorPosX(0);
    ImGui::BeginChild("##search_content", { ImGui::GetWindowWidth(), ImGui::GetContentRegionAvail().y },
                      ImGuiChildFlags_AlwaysUseWindowPadding);
    {

        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                std::string& button_name = entries[i];
                ImVec2 button_size = { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() };

                if (!widgets::button(button_name, button_size).render())
                    continue;

                child->controls.set_answer_input_text("/gps -> " + button_name, true);
                child->controls.go_to_frame(frame::current_report);
            }
        }
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::report::frames::gps::render_nodes() -> void {
    ImGui::PushFont(bold_font);
    {
        ImGui::TextUnformatted((current_node == nullptr) ? "Главная" : current_node->get_path().c_str());
    }
    ImGui::PopFont();

    ImVec2 content_size = { ImGui::GetWindowWidth(), ImGui::GetContentRegionAvail().y - 
        ((current_node == nullptr) ? 0 : ImGui::GetFrameHeightWithSpacing()) };

    ImGui::SetCursorPosX(0);
    ImGui::BeginChild("##content", content_size, ImGuiChildFlags_AlwaysUseWindowPadding);
    {
        nlohmann::ordered_json* current = (current_node == nullptr) ? &list : current_node->current;

        for (const auto& [ key, value ] : current->items()) {
            ImVec2 button_size = { ImGui::GetContentRegionAvail().x, ImGui::GetFrameHeight() };

            std::string path = (current_node == nullptr) ? key : current_node->get_path();
            std::string button_label = std::format("{}##{}", key, path);

            if (!widgets::button(button_label, button_size).render())
                continue;

            if (value.empty()) {
                if (current_node != nullptr)
                    path.append(" -> " + key);

                child->controls.set_answer_input_text("/gps -> " + path, true);
                child->controls.go_to_frame(frame::current_report);

                continue;
            }

            auto new_node = std::make_shared<node_t>(node_t { key, &value, current_node });
            switch_info.handle_transition(new_node);
        }
    }
    ImGui::EndChild();

    if (current_node != nullptr && widgets::button("Назад##frames::gps", {
            ImGui::GetContentRegionAvail().x,
            ImGui::GetFrameHeight()
        }).render())
    {
        switch_info.handle_transition(current_node->previous);
    }
}

auto plugin::gui::windows::report::frames::gps::is_enabled() const -> bool {
    return (*configuration)["windows"]["report"]["enable_gps_frame"];
}

auto plugin::gui::windows::report::frames::gps::render() -> void {
    search.render(ImGui::GetContentRegionAvail().x, "Поиск");
    switch_info.handle_animation();

    ImGui::BeginChild("##gps", ImGui::GetContentRegionAvail(), ImGuiChildFlags_AlwaysUseWindowPadding);
    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, switch_info.get_alpha() * ImGui::GetStyle().Alpha);
    {
        if (search.empty())
            render_nodes();
        else
            render_search_entries();
    }
    ImGui::PopStyleVar();
    ImGui::EndChild();
}

plugin::gui::windows::report::frames::gps::gps(types::not_null<initializer*> child)
    : basic_frame(child),
      bold_font(child->child->fonts->bold),
      switch_info(current_node)
{
#ifdef USE_EMBEDDED_MESSAGE_PACK
      list = nlohmann::ordered_json::from_msgpack(gps_bytes);
#else
      list = nlohmann::ordered_json::parse(gps_bytes);
#endif // USE_EMBEDDED_MESSAGE_PACK
}
