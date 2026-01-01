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

#include "plugin/gui/windows/main/frames/binder.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/plugin.h"
#include <algorithm>
#include <misc/cpp/imgui_stdlib.h>

auto plugin::gui::windows::main::frames::binder::get_binds() -> nlohmann::json& {
    return (*configuration)["internal"]["binds"];
}

auto plugin::gui::windows::main::frames::binder::generate_uuid() -> std::string {
    UUID uuid;
    RPC_CSTR uuid_str;
    std::string uuid_out;

    if (UuidCreate(&uuid) != RPC_S_OK)
        log::error("binder::generate_uuid(): failed to create UUID; error code: {}", GetLastError());

    if (UuidToStringA(&uuid, &uuid_str) != RPC_S_OK)
        log::error("binder::generate_uuid(): failed to convert UUID to RPC_CSTR; error code: {}", GetLastError());

    uuid_out = reinterpret_cast<char*>(uuid_str);
    RpcStringFreeA(&uuid_str);

    return uuid_out;
}

auto plugin::gui::windows::main::frames::binder::hotkey_callback(hotkey& hotkey) -> void {
    nlohmann::json& binds = get_binds();

    auto bind = std::find_if(binds.begin(), binds.end(), [hotkey](nlohmann::json& bind) {
        return bind["uuid"] == hotkey.label;
    });

    if (bind == binds.end())
        return;

    server::binder::evaluate(bind.value()["text"].get<std::string>());
}

auto plugin::gui::windows::main::frames::binder::add_hotkey(const std::string_view& uuid) const -> void {
    static std::deque<hotkey> hotkeys;
    hotkeys.push_back(hotkey(uuid, {}).with_callback(hotkey_callback).without_rendering_in_settings());
    child->child->hotkey_handler->add(hotkeys.back());
}

auto plugin::gui::windows::main::frames::binder::render_editable_title(std::string& label, std::string& value) const -> void {
    ImU32 color = ImGui::GetColorU32(ImGuiCol_WindowBg);

    ImGui::PushStyleColor(ImGuiCol_FrameBg, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, color);
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 });
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0);
    ImGui::PushFont(bold_font, title_font_size);
    {
        if (ImGui::InputText("##title", &value))
            label = value;
    }
    ImGui::PopFont();
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(3);

    gui::widgets::hint::render_as_guide("Нажмите на название, чтобы его изменить");
}

auto plugin::gui::windows::main::frames::binder::render_hotkey(const std::string_view& uuid, float width) const -> void {
    std::deque<hotkey>& hotkeys = child->child->hotkey_handler->pool;
    auto found_hotkey = std::find_if(hotkeys.begin(), hotkeys.end(), [uuid](hotkey& it) {
        return uuid == it.label;
    });

    if (found_hotkey == hotkeys.end())
        return;

    found_hotkey->render({ width, ImGui::GetFrameHeight() });
}

auto plugin::gui::windows::main::frames::binder::on_entry_destroyed(std::size_t index) const -> void {
    nlohmann::json& internal_binds = get_binds();
    nlohmann::json& internal_hotkeys = (*configuration)["internal"]["hotkeys"];
    std::string uuid = internal_binds[index]["uuid"];

    internal_binds.erase(index);
    internal_hotkeys.erase(uuid);
}

auto plugin::gui::windows::main::frames::binder::frame_renderer(std::string& label, std::any& payload) -> void {
    nlohmann::json& bind = get_binds()[submenu.get_current_entry_index()];
    std::string uuid = std::any_cast<std::string>(payload);

    render_editable_title(label, bind["title"].get_ref<std::string&>());

    ImGui::PushFont(regular_font, common_font_size);
    {
        ImVec2 item_spacing = ImGui::GetStyle().ItemSpacing;
        float full_width = ImGui::GetContentRegionAvail().x;
        float half_width = (full_width - item_spacing.x) / 2.0f;
        std::string current_string_index = std::to_string(submenu.get_current_entry_index());

        gui::widgets::text(bold_font, common_font_size, 0, "Клавиши для активации");
        ImGui::SameLine(half_width + item_spacing.x);
        gui::widgets::text(bold_font, common_font_size, 0, "Команда для активации");
        
        render_hotkey(uuid, half_width);
        ImGui::SameLine(half_width + item_spacing.x);
        ImGui::SetNextItemWidth(half_width);
        ImGui::InputTextWithHint("##command", "Команда без /", &bind["command_name"].get_ref<std::string&>());

        if (gui::widgets::button("Вставить переменную##frames::binder", { full_width, buttons_height }).render())
            popup.open();

        gui::widgets::text(bold_font, common_font_size, 0, "Текст бинда");
        ImGui::SameLine();
        ImGui::PushStyleColor(ImGuiCol_Text, ImGui::GetColorU32(ImGuiCol_TextDisabled));
        {
            gui::widgets::text(regular_font, common_font_size, 0, "подсказка: символ ^ в начале строки вставит ее в поле ввода чата");
        }
        ImGui::PopStyleColor();

        std::string* bind_text = &bind["text"].get_ref<std::string&>();
        float input_height = ImGui::GetContentRegionAvail().y - buttons_height - ImGui::GetStyle().ItemSpacing.y;

        popup.set_inserter(bind_text);
        ImGui::InputTextMultiline("##text", bind_text, { full_width, input_height });

        if (gui::widgets::button("Удалить##frames::binder:" + current_string_index,
                    { full_width, buttons_height }).render())
        {
            submenu.remove_current_entry_animated();
        }
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::binder::add_callback() -> void {
    bind_t new_bind = { "##" + generate_uuid(), "Новый бинд" };

    add_hotkey(new_bind.uuid);
    get_binds().push_back(new_bind);

    submenu.add_entry_animated(new_bind.title, new_bind.uuid);
}

auto plugin::gui::windows::main::frames::binder::on_send_command(const samp::out_event<samp::event_id::send_command>& event) const
    -> bool
{
    std::size_t space_pos = event.command.find(' ');
    std::string lowercase_command = event.command.substr(1, space_pos - 1);
    nlohmann::json& binds = get_binds();

    std::transform(lowercase_command.begin(), lowercase_command.end(), lowercase_command.begin(), ::tolower);

    auto bind = std::find_if(binds.begin(), binds.end(), [lowercase_command](const nlohmann::json& json) {
        std::string lowercase_bind_command = json["command_name"];
        
        if (lowercase_bind_command.empty())
            return false;

        std::transform(lowercase_bind_command.begin(), lowercase_bind_command.end(),
                       lowercase_bind_command.begin(), ::tolower);

        return lowercase_command == lowercase_bind_command;
    });

    if (bind == binds.end())
        return true;

    if (space_pos != std::string::npos) {
        std::stringstream stream(event.command.substr(space_pos + 1));
        for (std::string param; std::getline(stream, param, ' ');)
            server::binder::select_parameters.push_back(param);
    }

    server::binder::evaluate(bind.value()["text"].get<std::string>());
    server::binder::select_parameters.clear();

    return false;
}

auto plugin::gui::windows::main::frames::binder::render() -> void {
    popup.render();
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

auto plugin::gui::windows::main::frames::binder::on_event(const samp::event_info& event) -> bool {
    if (event == samp::event_type::outgoing_rpc && event == samp::event_id::send_command)
        return on_send_command(event.create<samp::event_id::send_command, samp::event_type::outgoing_rpc>());

    return true;
}

plugin::gui::windows::main::frames::binder::binder(types::not_null<initializer*> child)
    : child(child),
      popup("frames::binder", child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

    submenu.set_on_entry_destroyed_callback(std::bind(&binder::on_entry_destroyed, this, _1));
    submenu.set_frame_renderer(std::bind(&binder::frame_renderer, this, _1, _2));
    submenu.set_add_callback(std::bind(&binder::add_callback, this));

    for (const auto& bind : get_binds()) {
        std::string uuid = bind["uuid"];
        std::string title = bind["title"];

        submenu.add_entry(title, uuid);
        add_hotkey(uuid);
    }
}
