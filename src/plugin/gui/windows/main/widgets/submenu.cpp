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

#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/animation.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/gui.h"
#include "plugin/string_utils.h"
#include "plugin/common_utils.h"
#include <ranges>

auto plugin::gui::windows::main::widgets::submenu::get_next_available_entry_index() const -> std::size_t {
    return std::max<std::size_t>(0, std::min(current_entry_index - 1, entries.size() - 2));
}

auto plugin::gui::windows::main::widgets::submenu::render_entry(std::size_t index, entry_t& entry, const ImVec2& size) -> void {
    if (animation::is_time_available(entry.animation_time)) {
        entry.alpha = animation::bring_to(entry.alpha, (entry.hiding) ? 0.00f : 1.00f,
                                          entry.animation_time, entry_animation_duration);
    
        if (entry.hiding && entry.alpha == 0) {
            if (on_entry_destroy_callback.has_value())
                (*on_entry_destroy_callback)(current_entry_index);

            entries.erase(entries.begin() + current_entry_index);
            
            return;
        }
    }

    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, entry.alpha * ImGui::GetStyle().Alpha);
    {
        if (gui::widgets::button(entry.label + "##submenu::" + std::to_string(index), size).render()
            && index != future_entry_index)
        {
            future_entry_index = index;
            time_clicked = std::chrono::steady_clock::now();
        }
    }
    ImGui::PopStyleVar();
}

auto plugin::gui::windows::main::widgets::submenu::get_total_entries() const -> std::size_t {
    return entries.size();
}

auto plugin::gui::windows::main::widgets::submenu::get_current_entry_index() const -> std::size_t {
    return current_entry_index;
}

auto plugin::gui::windows::main::widgets::submenu::add_entry(const std::string_view& label, const std::any& payload) -> void {
    entries.emplace_back(std::string(label), std::move(payload));
}

auto plugin::gui::windows::main::widgets::submenu::add_entry_animated(const std::string_view& label, const std::any& payload) -> void {
    auto now = std::chrono::steady_clock::now();

    future_entry_index = entries.size();
    time_clicked = now;

    if (entries.empty())
        time_clicked -= fade_in_duration;

    entries.push_back({
        .label = std::string(label),
        .payload = std::move(payload),
        .animation_time = now,
        .alpha = 0.00,
        .hiding = false
    });
}

auto plugin::gui::windows::main::widgets::submenu::remove_current_entry_animated() -> void {
    auto now = std::chrono::steady_clock::now();
    entry_t& entry = entries[current_entry_index];

    future_entry_index = get_next_available_entry_index();
    time_clicked = now;

    entry.animation_time = now;
    entry.hiding = true;
}

auto plugin::gui::windows::main::widgets::submenu::set_on_entry_destroyed_callback(on_entry_destroy_callback_t new_callback) -> void {
    on_entry_destroy_callback = std::move(new_callback);
}

auto plugin::gui::windows::main::widgets::submenu::set_add_callback(add_callback_t new_callback) -> void {
    add_callback = std::move(new_callback);
}

auto plugin::gui::windows::main::widgets::submenu::set_frame_renderer(frame_renderer_t new_frame_renderer) -> void {
    frame_renderer = std::move(new_frame_renderer);
}

auto plugin::gui::windows::main::widgets::submenu::render_menu(types::not_null<initializer*> child) -> void {
    float child_width = (child_width_percent * child->window_size.x) / 100.0f;

    ImGui::BeginChild(label.c_str(), { child_width, 0 }, ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
    {
        gui::widgets::text(child->child->fonts->bold, title_font_size, 0, "{}",
                           string_utils::truncate_until_hashtag(label));

        ImVec2 region_size = ImGui::GetContentRegionAvail();
        ImVec2 button_size = { region_size.x, (switch_button_percent * child->window_size.y) / 100.0f };
        float child_height = region_size.y;

        if (add_callback.has_value())
            child_height -= button_size.y + ImGui::GetStyle().ItemSpacing.y;

        ImGui::SetCursorPosX(0);
        ImGui::BeginChild("scrollable_area", { child_width, child_height },
                          ImGuiChildFlags_AlwaysUseWindowPadding, child->window_flags);
        {
            ImGui::SetScrollX(0);

            for (const auto& [ index, entry ] : entries | std::views::enumerate)
                render_entry(index, entry, button_size);
        }
        ImGui::EndChild();

        if (add_callback.has_value() && gui::widgets::button("Добавить##add:" + label, button_size).render())
            (*add_callback)();
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::main::widgets::submenu::render_current_frame(types::not_null<initializer*> child) -> void {
    auto now = std::chrono::steady_clock::now();
    ImGuiWindowFlags flags = child->window_flags | ImGuiWindowFlags_NoBackground;

    if (now - time_clicked <= fade_in_out_duration) {
        bool change_animation_duration = (now - time_clicked >= fade_in_duration);
        std::chrono::milliseconds animation_duration = fade_in_duration;

        if (change_animation_duration) {
            current_entry_index = future_entry_index;
            animation_duration = fade_out_duration;
        }

        flags |= ImGuiWindowFlags_NoNav;
        frame_alpha = animation::bring_to(frame_alpha, static_cast<float>(change_animation_duration),
                                          time_clicked, animation_duration);
    }

    ImGui::PushStyleVar(ImGuiStyleVar_Alpha, frame_alpha * ImGui::GetStyle().Alpha);
    ImGui::BeginChild((label + "::current_frame").c_str(), { 0, 0 }, ImGuiChildFlags_None, flags);
    {
        if (current_entry_index >= entries.size()) {
            ImGui::PushFont(child->child->fonts->bold, empty_placeholder_font_size);
            {
                ImVec2 text_size = ImGui::CalcTextSize(selected_empty_placeholder);
                ImVec2 region_size = ImGui::GetWindowSize();
                ImGui::SetCursorPos({ (region_size.x - text_size.x) / 2.0f, (region_size.y - text_size.y) / 2.0f });
                ImGui::TextDisabled("%s", selected_empty_placeholder);
            }
            ImGui::PopFont();
        } else {
            entry_t& entry = entries[current_entry_index];
            frame_renderer(entry.label, entry.payload);
        }
    }
    ImGui::EndChild();
    ImGui::PopStyleVar();
}

plugin::gui::windows::main::widgets::submenu::submenu(const std::string_view& label)
    : label(std::move(label))
{
    static constexpr auto empty_placeholders = std::to_array<types::zstring_t>({
        "В тишине слышна мелодия души.",
        "Покой - источник вдохновения и сил.",
        "Звёзды хранят тайны бесконечности.",
        "Сердце, свободное от тревог, открыто миру.",
        "Вдали от шума находишь гармонию.",
        "Моменты тишины дарят ясность ума.",
        "В бескрайности неба скрыта свобода.",
        "Тихий вечер наполняет сердце светом.",
        "В покое рождаются новые мечты.",
        "Спокойствие - путь к внутренней гармонии.",
        "В тишине ночи мысли обретают ясность.",
        "Свобода от забот дарит лёгкость бытия.",
        "В просторах вселенной находишь себя.",
        "Тишина - пространство для новых идей.",
        "Вдали от суеты находишь вдохновение.",
        "Покой души - источник творчества.",
        "В тишине слышны отголоски сердца.",
        "Свободное сердце открыто для счастья.",
        "В бескрайности неба скрыты ответы.",
        "Тихий вечер дарит умиротворение и свет."
    }); // static constexpr auto empty_placeholders = std::to_array<types::zstring_t>({ ... })

    selected_empty_placeholder = *common_utils::select_randomly(empty_placeholders.begin(), empty_placeholders.end());
}
