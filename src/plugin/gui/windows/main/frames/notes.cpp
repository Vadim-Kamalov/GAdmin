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

#include "plugin/gui/windows/main/frames/notes.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/gui/windows/notes.h"
#include "plugin/plugin.h"
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::frames::notes::render_align_setting(nlohmann::json& value) const -> void {
    static constexpr int start = std::to_underlying(gui::widgets::aligner::mode_t::left);
    static constexpr int end = std::to_underlying(gui::widgets::aligner::mode_t::right);
    static constexpr types::zstring_t placeholders[end + 1] = {
        "Выравнивание по левому краю",
        "Выравнивание по центру",
        "Выравнивание по правому краю"
    }; // static constexpr types::zstring_t placeholders[end + 1]

    gui::widgets::aligner::mode_t align_mode = value;
    int slider_value = std::to_underlying(align_mode);

    if (!ImGui::SliderInt("##align", &slider_value, start, end, placeholders[slider_value]))
        return;

    value = static_cast<gui::widgets::aligner::mode_t>(slider_value);
}

auto plugin::gui::windows::main::frames::notes::render_editable_title(std::string& frame_label, std::string& value) const -> void {
    ImU32 color = ImGui::GetColorU32(ImGuiCol_WindowBg);

    ImGui::PushStyleColor(ImGuiCol_FrameBg, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, color);
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 });
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0);
    ImGui::PushFont(bold_font, title_font_size);
    {
        if (ImGui::InputText("##title", &value))
            frame_label = value;
    }
    ImGui::PopFont();
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(3);

    gui::widgets::hint::render_as_guide("Нажмите на заголовок, чтобы его изменить");
}

auto plugin::gui::windows::main::frames::notes::render_font_setting(const std::string& label, double& value) const -> void {
    double start = 1, end = 50;
    gui::widgets::text(bold_font, common_font_size, 0, "{}", label);
    ImGui::SliderScalar(("##" + label).c_str(), ImGuiDataType_Double, &value, &start, &end, "%.2f");
}

auto plugin::gui::windows::main::frames::notes::on_entry_destroyed(std::size_t index) -> void {
    auto& notes = (*configuration)["internal"]["notes"];
    notes.erase(index);
}

auto plugin::gui::windows::main::frames::notes::frame_renderer(std::string& label, std::any&) -> void {
    nlohmann::json& notes = (*configuration)["internal"]["notes"];
    nlohmann::json& note = notes[submenu.get_current_entry_index()];
    
    ImGui::PushItemWidth(ImGui::GetContentRegionAvail().x);
    ImGui::PushFont(regular_font, common_font_size);
    {
        std::string current_string_index = std::to_string(submenu.get_current_entry_index());
        float full_width = ImGui::GetContentRegionAvail().x;

        render_editable_title(label, note["title"].get_ref<std::string&>());
        
        gui::widgets::toggle_button("Отображать##frames::notes:" + current_string_index, note["visible"].get_ref<bool&>())
            .render();
       
        render_font_setting("Размер заголовка", note["title_size"].get_ref<double&>());
        render_font_setting("Размер текста", note["text_size"].get_ref<double&>());
        render_align_setting(note["align_mode"]);
        gui::widgets::text(bold_font, common_font_size, 0, "Текст заметки");

        if (gui::widgets::button("Вставить переменную##frames::notes", { full_width, buttons_height }).render())
            popup.open();

        std::string* text = &note["text"].get_ref<std::string&>();
        float input_height = ImGui::GetContentRegionAvail().y - buttons_height - ImGui::GetStyle().ItemSpacing.y;

        popup.set_inserter(text);
        ImGui::InputTextMultiline("##text", text, { full_width, input_height });

        if (gui::widgets::button("Удалить##frames::notes-" + current_string_index,
                                 { full_width, buttons_height }).render())
        {
            submenu.remove_current_entry_animated();
        }
    }
    ImGui::PopFont();
    ImGui::PopItemWidth();
}

auto plugin::gui::windows::main::frames::notes::add_callback() -> void {
    nlohmann::json& notes = (*configuration)["internal"]["notes"];
    windows::notes::note_t new_note = {};
    
    notes.push_back(new_note);
    submenu.add_entry_animated(new_note.title, std::make_any<nlohmann::json&>(notes.back()));
}

auto plugin::gui::windows::main::frames::notes::render() -> void {
    popup.render();
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

plugin::gui::windows::main::frames::notes::notes(types::not_null<initializer*> child)
    : child(child),
      popup("frames::notes", child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

    submenu.set_frame_renderer(std::bind(&notes::frame_renderer, this, _1, _2));
    submenu.set_on_entry_destroyed_callback(std::bind(&notes::on_entry_destroyed, this, _1));
    submenu.set_add_callback(std::bind(&notes::add_callback, this));

    for (auto& note : (*configuration)["internal"]["notes"])
        submenu.add_entry(note["title"].get<std::string>(), std::make_any<nlohmann::json&>(note));
}
