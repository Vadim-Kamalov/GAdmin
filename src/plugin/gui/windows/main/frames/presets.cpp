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

#include "plugin/gui/windows/main/frames/presets.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/text_button.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/gui/style.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/types/color.h"
#include "plugin/cheats/wallhack.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include "common/common.h"
#include <misc/cpp/imgui_stdlib.h>
#include <algorithm>
#include <fstream>
#include <system_error>
#include <utility>

static constexpr std::uint8_t options_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../../../../../embed/main_frame_settings.mpk"
#else
#embed "../../../../../../embed/main_frame_settings.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t options_bytes[]

auto plugin::gui::windows::main::frames::presets::load_presets() -> void {
    preset_list = nlohmann::json::array();

    std::error_code error_code;

    if (!std::filesystem::exists(presets_file, error_code))
        return;

    std::ifstream file(presets_file);

    if (!file) {
        log::error("presets: failed to open \"{}\"", presets_file.string());
        return;
    }

    try {
        nlohmann::json parsed = nlohmann::json::parse(file);

        if (parsed.is_array())
            preset_list = std::move(parsed);
        else
            log::error("presets: \"{}\" is not a JSON array; ignored", presets_file.string());
    } catch (const std::exception& e) {
        log::error("presets: failed to parse \"{}\": {}", presets_file.string(), e.what());
    }
}

auto plugin::gui::windows::main::frames::presets::save_presets() const -> void {
    std::ofstream file(presets_file, std::ios::out | std::ios::trunc);

    if (!file) {
        log::error("presets: failed to write \"{}\"", presets_file.string());
        return;
    }

    file << preset_list.dump(4);
}

auto plugin::gui::windows::main::frames::presets::is_secret(const std::string& section, const std::string& item) -> bool {
    return section == "misc" && item == "auto_login";
}

auto plugin::gui::windows::main::frames::presets::snapshot_item(const std::string& section, const std::string& item) const
    -> nlohmann::json
{
    return (*configuration)[section][item];
}

auto plugin::gui::windows::main::frames::presets::capture_all() const -> nlohmann::json {
    nlohmann::json settings = nlohmann::json::object();

    for (const auto& [ section, meta_section ] : options.items())
        for (const auto& [ item, meta_item ] : meta_section.items()) {
            if (item.starts_with('_') || is_secret(section, item))
                continue;

            settings[section][item] = snapshot_item(section, item);
        }

    settings["hotkeys"] = capture_hotkeys();
    settings["player_checker"] = capture_player_checker();

    return settings;
}

auto plugin::gui::windows::main::frames::presets::capture_hotkeys() const -> nlohmann::json {
    nlohmann::json result = nlohmann::json::object();

    for (gui::hotkey& pooled : child->child->hotkey_handler->pool)
        if (pooled.can_render_in_settings())
            result[pooled.label] = pooled.bind.join();

    return result;
}

auto plugin::gui::windows::main::frames::presets::capture_player_checker() const -> nlohmann::json {
    nlohmann::json& windows = (*configuration)["windows"];

    if (windows.contains("player_checker") && windows["player_checker"].contains("players")
        && windows["player_checker"]["players"].is_array())
        return windows["player_checker"]["players"];

    return nlohmann::json::array();
}

auto plugin::gui::windows::main::frames::presets::apply_preset(const nlohmann::json& preset) const -> void {
    if (!preset.contains("settings"))
        return;

    const nlohmann::json& settings = preset["settings"];

    // merge_patch per section: keys absent from the preset (excluded items, passwords,
    // newer settings) stay untouched in the live config.
    for (types::zstring_t section : captured_sections)
        if (settings.contains(section))
            (*configuration)[section].merge_patch(settings.at(section));

    // Special blocks: the checker list and hotkeys live at their own paths, apply explicitly.
    if (settings.contains("player_checker"))
        (*configuration)["windows"]["player_checker"]["players"] = settings.at("player_checker");

    if (settings.contains("hotkeys") && settings.at("hotkeys").is_object()) {
        nlohmann::json& live_hotkeys = (*configuration)["internal"]["hotkeys"];

        for (const auto& [ label, packed ] : settings.at("hotkeys").items()) {
            live_hotkeys[label] = packed;

            // Update the live hotkey object so the bind applies at once, without a restart.
            if (gui::hotkey* pooled = find_pool_hotkey(label))
                pooled->bind = gui::key_bind(packed.get<std::uint32_t>());
        }
    }

    // merge_patch only rewrites the JSON; it does not run the side-effect handlers the
    // settings UI fires on toggle. Wallhack is the only setting whose live runtime state
    // (the `cheat_active` flag + server name-tag render) is more than its config value, so
    // reconcile it explicitly — otherwise the cheat keeps its pre-apply state against the
    // preset and its hotkey desyncs (a disabled-by-preset wallhack stays rendered and its
    // toggle gets blocked by the `use` gate). Mirror the settings toggle: switch the active
    // state only on /alogin, but always refresh the renderers for `custom_render` changes.
    if (settings.contains("cheats") && settings.at("cheats").contains("wallhack")) {
        if (server::user::is_on_alogin())
            cheats::wallhack::toggle((*configuration)["cheats"]["wallhack"]["use"].get<bool>());
        else
            cheats::wallhack::update();
    }

    configuration->save();
}

auto plugin::gui::windows::main::frames::presets::get_active_index() const -> int {
    return (*configuration)["internal"].value("active_preset", -1);
}

auto plugin::gui::windows::main::frames::presets::set_active_index(int index) const -> void {
    (*configuration)["internal"]["active_preset"] = index;
    configuration->save();
}

auto plugin::gui::windows::main::frames::presets::preset_matches_live(const nlohmann::json& preset) const -> bool {
    if (!preset.contains("settings") || preset["settings"].empty())
        return false;

    for (const auto& [ section, items ] : preset["settings"].items()) {
        // Hotkeys and the checker list are excluded from the comparison (matching them is
        // harder and does not affect the applied/modified marker).
        if (section == "hotkeys" || section == "player_checker")
            continue;

        nlohmann::json& live_section = (*configuration)[section];

        for (const auto& [ item, value ] : items.items())
            if (!live_section.contains(item) || live_section[item] != value)
                return false;
    }

    return true;
}

auto plugin::gui::windows::main::frames::presets::render_status_banner(const nlohmann::json& preset, std::size_t index) const
    -> void
{
    bool active = static_cast<int>(index) == get_active_index();
    bool matches = active && preset_matches_live(preset);

    style::accent_colors_t& accents = style::get_current_accent_colors();

    ImU32 color;
    types::zstring_t glyph;
    types::zstring_t text;

    if (active && matches) {
        color = *accents.green;
        glyph = ICON_CHECK;
        text  = "Применён";
    } else if (active) {
        color = *accents.yellow;
        glyph = ICON_FLAG;
        text  = "Применён, но настройки изменены вручную";
    } else {
        color = ImGui::GetColorU32(ImGuiCol_TextDisabled);
        glyph = ICON_CIRCLE;
        text  = "Не применён";
    }

    // Draw the icon with the `icon` font (regular lacks its glyphs — would show "?"), text with regular.
    ImVec2 pos = ImGui::GetCursorScreenPos();
    float line_height = ImGui::GetTextLineHeight();
    ImVec2 glyph_size = icon_font->CalcTextSizeA(common_font_size, FLT_MAX, 0.0f, glyph);

    ImGui::GetWindowDrawList()->AddText(icon_font, common_font_size,
                                        { pos.x, pos.y + (line_height - glyph_size.y) / 2.0f }, color, glyph);

    ImGui::Dummy({ glyph_size.x + ImGui::GetStyle().ItemSpacing.x, line_height });
    ImGui::SameLine();
    ImGui::TextColored(ImGui::ColorConvertU32ToFloat4(color), "%s", text);
}

auto plugin::gui::windows::main::frames::presets::ensure_preset_ids() -> void {
    int max_id = 0;

    for (auto& preset : preset_list)
        if (preset.contains("id") && preset["id"].is_number_integer())
            max_id = std::max(max_id, preset["id"].get<int>());

    bool changed = false;

    for (auto& preset : preset_list)
        if (!preset.contains("id") || !preset["id"].is_number_integer()) {
            preset["id"] = ++max_id;
            changed = true;
        }

    next_id = max_id + 1;

    if (changed)
        save_presets();
}

auto plugin::gui::windows::main::frames::presets::preset_hotkey_label(int id) -> std::string {
    return "##preset:" + std::to_string(id);
}

auto plugin::gui::windows::main::frames::presets::register_preset_hotkey(int id) -> void {
    gui::hotkey preset_hotkey(preset_hotkey_label(id), gui::key_bind());

    preset_hotkey.without_rendering_in_settings();
    preset_hotkey.with_callback([this, id](gui::hotkey&) { apply_preset_by_id(id); });

    child->child->hotkey_handler->add(preset_hotkey);
}

auto plugin::gui::windows::main::frames::presets::find_pool_hotkey(const std::string& label) const -> gui::hotkey* {
    for (gui::hotkey& pooled : child->child->hotkey_handler->pool)
        if (pooled.label == label)
            return &pooled;

    return nullptr;
}

auto plugin::gui::windows::main::frames::presets::entry_hotkey_text(std::size_t index)
    -> std::optional<std::string>
{
    if (index >= preset_list.size())
        return std::nullopt;

    gui::hotkey* preset_hotkey = find_pool_hotkey(preset_hotkey_label(preset_list[index].value("id", -1)));

    if (!preset_hotkey || preset_hotkey->bind.empty())
        return std::nullopt;

    return preset_hotkey->bind.to_string();
}

auto plugin::gui::windows::main::frames::presets::apply_preset_by_id(int id) -> void {
    for (std::size_t index = 0; index < preset_list.size(); index++)
        if (preset_list[index].value("id", -1) == id) {
            apply_preset(preset_list[index]);
            set_active_index(static_cast<int>(index));

            std::string name = preset_list[index].value("name", std::string("Пресет"));
            gui::notify::send(gui::notification("Пресет применён", "«" + name + "» — настройки применены.", ICON_CHECK));

            return;
        }
}

auto plugin::gui::windows::main::frames::presets::render_editable_name(std::string& frame_label, std::string& value)
    -> void
{
    ImU32 color = ImGui::GetColorU32(ImGuiCol_WindowBg);

    ImGui::PushStyleColor(ImGuiCol_FrameBg, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgActive, color);
    ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, color);
    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 });
    ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0);
    ImGui::PushFont(bold_font, title_font_size);
    {
        if (ImGui::InputText("##preset_name", &value)) {
            frame_label = value;
            pending_save = true;
        }
    }
    ImGui::PopFont();
    ImGui::PopStyleVar(2);
    ImGui::PopStyleColor(3);

    gui::widgets::hint::render_as_guide("Нажмите на имя, чтобы переименовать пресет");
}

auto plugin::gui::windows::main::frames::presets::open_subsection_popup(const std::string& section,
                                                                        const std::string& item,
                                                                        const std::string& name,
                                                                        nlohmann::ordered_json& meta_item,
                                                                        nlohmann::json& settings) -> void
{
    // Capture pointers to stable nodes: meta_item lives in `options` (a class member) and the
    // value branch lives in the current preset (not reallocated while the popup is open).
    nlohmann::json* value = &settings[section][item];
    nlohmann::ordered_json* meta = &meta_item;
    std::string subsection_key = item;
    std::string title = name;

    popup.set_renderer([this, value, meta, subsection_key, title] {
        // Read the preset name live from the current entry, so a rename is reflected at once.
        std::size_t current = submenu.get_current_entry_index();
        std::string preset_name = current < preset_list.size()
            ? preset_list[current].value("name", std::string("пресет")) : std::string("пресет");

        ImGui::PushStyleColor(ImGuiCol_Text, ImGui::GetColorU32(ImGuiCol_TextDisabled));
        gui::widgets::text(regular_font, common_font_size, 0,
                           "Настройка относится к пресету «{}»", preset_name);
        ImGui::PopStyleColor();

        gui::widgets::text(bold_font, title_font_size, 0, "{}", title);

        ImGui::PushFont(regular_font, common_font_size);
        {
            // `use` is toggled from the list row, so the popup shows only the options. Reuse the
            // settings frame's widget renderer (live = false: a preset edit has no side effects).
            for (auto& [ key, meta_option ] : meta->items()) {
                if (key.starts_with('_') || !value->contains(key))
                    continue;

                nlohmann::json& option_value = (*value)[key];
                std::string before = option_value.dump();

                owner->render_option_widget("##opt:" + subsection_key + ":" + key,
                                            subsection_key + "." + key, meta_option, option_value, false);

                if (option_value.dump() != before)
                    pending_save = true;
            }
        }
        ImGui::PopFont();
    });

    popup.open();
}

auto plugin::gui::windows::main::frames::presets::render_section_editor(const std::string& section,
                                                                        nlohmann::ordered_json& meta_section,
                                                                        nlohmann::json& settings) -> void
{
    std::string section_name = meta_section["_name"];

    // While searching, skip sections with no match and force-expand the rest.
    if (!editor_search.empty()) {
        bool any_match = false;

        for (auto& [ item, meta_item ] : meta_section.items())
            if (!item.starts_with('_') && !is_secret(section, item)
                && editor_search.contains(meta_item["_name"].get<std::string>()))
            {
                any_match = true;
                break;
            }

        if (!any_match)
            return;

        ImGui::SetNextItemOpen(true, ImGuiCond_Always);
    }

    if (!ImGui::CollapsingHeader((section_name + "##presets_sec:" + section).c_str()))
        return;

    for (auto& [ item, meta_item ] : meta_section.items()) {
        if (item.starts_with('_') || is_secret(section, item))
            continue;

        item_type type = meta_item["_type"];
        std::string name = meta_item["_name"];

        if (!editor_search.contains(name))
            continue;

        std::string id = section + ":" + item;

        // A preset is a full settings snapshot. If a value is missing (old preset or a
        // setting added later), take the current one from the live config.
        if (!settings.contains(section) || !settings[section].contains(item)) {
            include_item(section, item, settings);
            pending_save = true;
        }

        nlohmann::json& value = settings[section][item];

        // Subsection: a `use` toggle + a clickable name opening the detail popup — just like in Settings.
        if (type == item_type::subsection) {
            if (value.contains("use") && value["use"].is_boolean()) {
                if (gui::widgets::toggle_button("##use:" + id, value["use"].get_ref<bool&>()).render())
                    pending_save = true;

                ImGui::SameLine();
            }

            if (gui::widgets::text_button(name + "##presets_sub:" + id).render())
                open_subsection_popup(section, item, name, meta_item, settings);

            continue;
        }

        // Boolean option: a value toggle + the name.
        if (type == item_type::boolean && value.is_boolean()) {
            if (gui::widgets::toggle_button("##val:" + id, value.get_ref<bool&>()).render())
                pending_save = true;

            ImGui::SameLine();
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            continue;
        }

        // No other types exist at the section top level, but show the name just in case.
        gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
    }
}

auto plugin::gui::windows::main::frames::presets::include_item(const std::string& section, const std::string& item,
                                                               nlohmann::json& settings) const -> void
{
    settings[section][item] = snapshot_item(section, item);
}

auto plugin::gui::windows::main::frames::presets::render_editor(nlohmann::json& preset, float bottom_reserve) -> void {
    if (!preset.contains("settings") || !preset["settings"].is_object())
        preset["settings"] = nlohmann::json::object();

    nlohmann::json& settings = preset["settings"];
    int preset_id = preset.value("id", -1);

    gui::widgets::text(bold_font, common_font_size, 0, "Настройки пресета");

    float full_width = ImGui::GetContentRegionAvail().x;

    editor_search.render(full_width, "Поиск функции по названию...");

    // Negative height: fill the remaining space minus the action-button footer below.
    ImGui::BeginChild("presets::editor", { 0, -bottom_reserve }, ImGuiChildFlags_Borders);
    {
        ImGui::PushFont(regular_font, common_font_size);
        {
            for (auto& [ section, meta_section ] : options.items())
                render_section_editor(section, meta_section, settings);

            render_hotkeys_section(settings, preset_id);
            render_player_checker_section(settings);
        }
        ImGui::PopFont();
    }
    ImGui::EndChild();
}

auto plugin::gui::windows::main::frames::presets::ensure_hotkey_editors(nlohmann::json& hotkeys, int preset_id) -> void {
    if (preset_id == hotkey_editors_preset_id)
        return;

    hotkey_editors.clear();
    gui::hotkey_handler* handler = child->child->hotkey_handler.get();

    for (gui::hotkey& pooled : handler->pool) {
        if (!pooled.can_render_in_settings())
            continue;

        gui::hotkey editor(pooled.label, gui::key_bind());

        editor.without_rendering_in_settings().with_handler(handler).bind_to_external(&hotkeys);
        hotkey_editors.push_back(std::move(editor));
    }

    hotkey_editors_preset_id = preset_id;
}

auto plugin::gui::windows::main::frames::presets::render_hotkeys_section(nlohmann::json& settings, int preset_id)
    -> void
{
    if (!settings.contains("hotkeys") || !settings["hotkeys"].is_object()) {
        settings["hotkeys"] = capture_hotkeys();
        pending_save = true;
    }

    nlohmann::json& hotkeys = settings["hotkeys"];
    ensure_hotkey_editors(hotkeys, preset_id);

    // Refresh the storage pointer every frame: preset_list (a json array) may be reallocated
    // when a preset is added, which would leave the editors' cached pointer to
    // settings["hotkeys"] dangling (use-after-free).
    for (gui::hotkey& editor : hotkey_editors)
        editor.set_external_storage(&hotkeys);

    // While searching, show the section only if some hotkey label matches.
    if (!editor_search.empty()) {
        bool any_match = false;

        for (gui::hotkey& editor : hotkey_editors)
            if (editor_search.contains(editor.label)) {
                any_match = true;
                break;
            }

        if (!any_match)
            return;

        ImGui::SetNextItemOpen(true, ImGuiCond_Always);
    }

    if (!ImGui::CollapsingHeader("Горячие клавиши##presets_sec:hotkeys"))
        return;

    gui::widgets::hint::render_as_guide("ЛКМ — задать клавишу, ПКМ — условия активации (в слежке, на /alogin и т.д.).");

    // The hotkey widget writes the bind straight into the preset JSON via external storage.
    // Compare the dump before/after to mark the preset for saving on any change.
    std::string before = hotkeys.dump();

    for (gui::hotkey& editor : hotkey_editors) {
        if (!editor_search.contains(editor.label))
            continue;

        editor.render({ 160.0f, buttons_height });
        ImGui::SameLine();
        ImGui::AlignTextToFramePadding();

        // The label is clickable text (hover-highlighted, as on other tabs): a left click
        // opens the same activation-conditions popup as a right click on the key button.
        if (gui::widgets::text_button(editor.label).render())
            editor.open_conditions_popup();
    }

    if (hotkeys.dump() != before)
        pending_save = true;
}

auto plugin::gui::windows::main::frames::presets::render_player_checker_section(nlohmann::json& settings) -> void {
    if (!settings.contains("player_checker") || !settings["player_checker"].is_array()) {
        settings["player_checker"] = capture_player_checker();
        pending_save = true;
    }

    // The player list is a separate entity, not subject to the option filter.
    if (!editor_search.empty())
        return;

    if (!ImGui::CollapsingHeader("Чекер игроков##presets_sec:player_checker"))
        return;

    render_player_checker_body(settings["player_checker"]);
}

auto plugin::gui::windows::main::frames::presets::render_player_checker_body(nlohmann::json& players) -> void {
    ImGui::BeginChild("presets::pc_list", { 0, 120 }, ImGuiChildFlags_Borders);
    {
        for (std::size_t i = 0; i < players.size(); i++) {
            std::string nickname = players[i].value("nickname", std::string());

            if (ImGui::Selectable((nickname + "##presets_pc:" + std::to_string(i)).c_str(), pc_selected_index == i)) {
                pc_selected_index = i;
                pc_description_input = players[i].value("description", std::string());
            }
        }
    }
    ImGui::EndChild();

    float full_width = ImGui::GetContentRegionAvail().x;
    float add_button_width = 140.0f;

    ImGui::SetNextItemWidth(full_width - add_button_width - ImGui::GetStyle().ItemSpacing.x);
    ImGui::InputTextWithHint("##presets_pc_nick", "Никнейм игрока", &pc_nickname_input);
    ImGui::SameLine();

    if (gui::widgets::button("Добавить##presets_pc_add", { add_button_width, ImGui::GetFrameHeight() }).render()
        && !pc_nickname_input.empty())
    {
        players.push_back({ { "nickname", pc_nickname_input }, { "description", "" } });
        pc_selected_index = players.size() - 1;
        pc_nickname_input.clear();
        pc_description_input.clear();
        pending_save = true;
    }

    if (pc_selected_index < players.size()) {
        gui::widgets::text(regular_font, common_font_size, 0, "Заметка об игроке «{}»:",
                           players[pc_selected_index].value("nickname", std::string()));

        if (ImGui::InputTextMultiline("##presets_pc_desc", &pc_description_input, { full_width, 60 })) {
            players[pc_selected_index]["description"] = pc_description_input;
            pending_save = true;
        }

        if (gui::widgets::button("Удалить выбранного##presets_pc_del", { full_width, buttons_height }).render()) {
            players.erase(pc_selected_index);
            pc_selected_index = 0;
            pc_description_input.clear();
            pending_save = true;
        }
    }
}

auto plugin::gui::windows::main::frames::presets::frame_renderer(std::string& label, std::any&) -> void {
    std::size_t current = submenu.get_current_entry_index();
    nlohmann::json& preset = preset_list[current];
    std::string index = std::to_string(current);
    float full_width = ImGui::GetContentRegionAvail().x;

    ImGui::PushFont(regular_font, common_font_size);
    {
        render_editable_name(label, preset["name"].get_ref<std::string&>());
        render_status_banner(preset, current);

        // The single key that applies this whole preset.
        if (gui::hotkey* preset_hotkey = find_pool_hotkey(preset_hotkey_label(preset.value("id", -1)))) {
            gui::widgets::text(regular_font, common_font_size, 0, "Горячая клавиша применения:");
            preset_hotkey->render({ full_width, buttons_height });
            gui::widgets::hint::render_as_guide("ЛКМ — задать клавишу, ПКМ — условия активации");
        }

        // The bordered settings editor fills the middle, leaving room for the stacked action
        // footer below (three full-width buttons + the spacing between them).
        float spacing = ImGui::GetStyle().ItemSpacing.y;
        float footer_reserve = buttons_height * 3.0f + spacing * 3.0f;
        render_editor(preset, footer_reserve);

        // Action buttons stacked full-width: apply / write the current settings into the preset / delete.
        bool active_and_applied = static_cast<int>(current) == get_active_index() && preset_matches_live(preset);
        std::string apply_label = active_and_applied ? "Применить заново" : "Применить";
        ImVec2 button_size = { full_width, buttons_height };

        if (gui::widgets::button(apply_label + "##frames::presets-apply-" + index, button_size)
                .without_click_animation().render())
        {
            apply_preset(preset);
            set_active_index(static_cast<int>(current));
        }

        if (gui::widgets::button("Записать текущие настройки##frames::presets-write-" + index, button_size)
                .without_click_animation().render())
        {
            preset["settings"] = capture_all();
            save_presets();

            // The hotkey editors cache binds — force a rebuild so they pick up the new values.
            hotkey_editors_preset_id = -1;
        }

        if (gui::widgets::button("Удалить##frames::presets-delete-" + index, button_size)
                .without_click_animation().render())
            submenu.remove_current_entry_animated();
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::presets::add_callback() -> void {
    int id = next_id++;

    nlohmann::json preset = {
        { "id", id },
        { "name", "Новый пресет" },
        { "settings", capture_all() }
    };

    preset_list.push_back(std::move(preset));
    register_preset_hotkey(id);

    submenu.add_entry_animated(preset_list.back()["name"].get<std::string>(),
                               std::make_any<nlohmann::json&>(preset_list.back()));
    save_presets();
}

auto plugin::gui::windows::main::frames::presets::on_entry_destroyed(std::size_t index) -> void {
    int active = get_active_index();

    if (active == static_cast<int>(index))
        set_active_index(-1);
    else if (active > static_cast<int>(index))
        set_active_index(active - 1);

    // Free the deleted preset's hotkey: clear its bind in the pool and in the config.
    int id = preset_list[index].value("id", -1);

    if (id >= 0) {
        std::string label = preset_hotkey_label(id);

        if (gui::hotkey* pooled = find_pool_hotkey(label))
            pooled->bind = {};

        (*configuration)["internal"]["hotkeys"].erase(label);
    }

    preset_list.erase(index);
    save_presets();
}

auto plugin::gui::windows::main::frames::presets::render() -> void {
    // Layout: the preset-list sidebar on the left, the selected preset's detail on the right.
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
    popup.render(child);

    // Deferred write: save the file only once the user releases the slider/field, otherwise
    // dragging a slider would write the file every frame.
    if (pending_save && !ImGui::IsAnyItemActive()) {
        save_presets();
        pending_save = false;

        // Editing the active preset mirrors the live settings screen: push the change to the
        // live configuration at once, so there is no need to press "Apply" again.
        std::size_t current = submenu.get_current_entry_index();

        if (current < preset_list.size() && static_cast<int>(current) == get_active_index())
            apply_preset(preset_list[current]);
    }
}

plugin::gui::windows::main::frames::presets::presets(types::not_null<initializer*> child, types::not_null<settings*> owner)
    : child(child),
      owner(owner),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular),
      icon_font(child->child->fonts->icon)
{
#ifdef USE_EMBEDDED_MESSAGE_PACK
    options = nlohmann::ordered_json::from_msgpack(options_bytes);
#else
    options = nlohmann::ordered_json::parse(options_bytes);
#endif // USE_EMBEDDED_MESSAGE_PACK

    presets_file = common::get_game_path() / "gadmin" / "configuration" / "presets.json";
    load_presets();
    ensure_preset_ids();

    for (auto& preset : preset_list)
        register_preset_hotkey(preset["id"].get<int>());

    using namespace std::placeholders;

    submenu.set_frame_renderer(std::bind(&presets::frame_renderer, this, _1, _2));
    submenu.set_on_entry_destroyed_callback(std::bind(&presets::on_entry_destroyed, this, _1));
    submenu.set_add_callback(std::bind(&presets::add_callback, this));

    // Highlight the active preset by filling its list button: green — applied and matching
    // the current settings, yellow — applied but the settings were changed manually.
    submenu.set_entry_highlight([this](std::size_t index) -> types::color {
        if (static_cast<int>(index) != get_active_index() || index >= preset_list.size())
            return types::color();

        style::accent_colors_t& accents = style::get_current_accent_colors();
        std::uint32_t base = preset_matches_live(preset_list[index]) ? *accents.green : *accents.yellow;

        // Semi-transparent fill, but bright enough for the active preset to stand out.
        return types::color(types::color::abgr((base & 0x00FFFFFFu) | (0xAAu << 24)));
    });

    // Draw a badge with the assigned apply hotkey on the right of the preset button.
    submenu.set_entry_overlay([this](std::size_t index, const ImVec2& min, const ImVec2& max) {
        std::optional<std::string> text = entry_hotkey_text(index);

        if (!text)
            return;

        ImDrawList* draw_list = ImGui::GetWindowDrawList();

        ImGui::PushFont(regular_font, badge_font_size);
        {
            ImVec2 text_size = ImGui::CalcTextSize(text->c_str());
            ImVec2 badge_size = { text_size.x + badge_padding_x * 2.0f, text_size.y + badge_padding_y * 2.0f };

            ImVec2 badge_min = { max.x - badge_right_margin - badge_size.x,
                                 min.y + (max.y - min.y - badge_size.y) / 2.0f };
            ImVec2 badge_max = { badge_min.x + badge_size.x, badge_min.y + badge_size.y };

            float rounding = ImGui::GetStyle().FrameRounding;

            draw_list->AddRectFilled(badge_min, badge_max, ImGui::GetColorU32(ImGuiCol_FrameBg), rounding);
            draw_list->AddRect(badge_min, badge_max, ImGui::GetColorU32(ImGuiCol_FrameBgActive), rounding);
            draw_list->AddText({ badge_min.x + badge_padding_x, badge_min.y + badge_padding_y },
                               ImGui::GetColorU32(ImGuiCol_Text), text->c_str());
        }
        ImGui::PopFont();
    });

    // Reserve space on the right for the badge so the preset name does not run under it.
    submenu.set_entry_text_reserve([this](std::size_t index) -> float {
        std::optional<std::string> text = entry_hotkey_text(index);

        if (!text)
            return 0.0f;

        ImGui::PushFont(regular_font, badge_font_size);
        float text_width = ImGui::CalcTextSize(text->c_str()).x;
        ImGui::PopFont();

        return text_width + badge_padding_x * 2.0f + badge_right_margin + badge_text_gap;
    });

    for (auto& preset : preset_list)
        submenu.add_entry(preset["name"].get<std::string>(), std::make_any<nlohmann::json&>(preset));
}
