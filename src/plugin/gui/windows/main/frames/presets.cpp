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
#include "plugin/gui/windows/main/base/custom_setting.h"
#include "plugin/gui/windows/main/custom_settings/message_recolorer.h"
#include "plugin/gui/windows/main/custom_settings/report.h"
#include "plugin/gui/windows/main/custom_settings/short_commands.h"
#include "plugin/gui/windows/main/custom_settings/spectator_actions.h"
#include "plugin/gui/windows/main/custom_settings/spectator_information.h"
#include "plugin/gui/style.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include "plugin/types/color.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include "common/common.h"
#include <misc/cpp/imgui_stdlib.h>
#include <algorithm>
#include <array>
#include <fstream>
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

    if (!std::filesystem::exists(presets_file))
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

auto plugin::gui::windows::main::frames::presets::refresh_values(nlohmann::json& preset) const -> void {
    if (!preset.contains("settings"))
        return;

    for (auto& [ section, items ] : preset["settings"].items()) {
        // Спец-блоки (хоткеи, чекер) живут не как одноимённые секции конфига — обновляем их отдельно.
        if (section == "hotkeys" || section == "player_checker")
            continue;

        nlohmann::json& live_section = (*configuration)[section];

        for (auto& [ item, value ] : items.items())
            if (live_section.contains(item))
                value = live_section[item];
    }

    if (preset["settings"].contains("hotkeys"))
        preset["settings"]["hotkeys"] = capture_hotkeys();

    if (preset["settings"].contains("player_checker"))
        preset["settings"]["player_checker"] = capture_player_checker();
}

auto plugin::gui::windows::main::frames::presets::apply_preset(const nlohmann::json& preset) const -> void {
    if (!preset.contains("settings"))
        return;

    const nlohmann::json& settings = preset["settings"];

    // merge_patch посекционно: ключи, которых в пресете нет (исключённые элементы, пароли,
    // более новые настройки), остаются в живом конфиге нетронутыми.
    for (types::zstring_t section : captured_sections)
        if (settings.contains(section))
            (*configuration)[section].merge_patch(settings.at(section));

    // Спец-блоки: список чекера и хоткеи лежат по своим путям, применяем их явно.
    if (settings.contains("player_checker"))
        (*configuration)["windows"]["player_checker"]["players"] = settings.at("player_checker");

    if (settings.contains("hotkeys") && settings.at("hotkeys").is_object()) {
        nlohmann::json& live_hotkeys = (*configuration)["internal"]["hotkeys"];

        for (const auto& [ label, packed ] : settings.at("hotkeys").items()) {
            live_hotkeys[label] = packed;

            // Обновляем живой объект хоткея, чтобы бинд применился сразу, без перезапуска.
            if (gui::hotkey* pooled = find_pool_hotkey(label))
                pooled->bind = gui::key_bind(packed.get<std::uint32_t>());
        }
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
        // Хоткеи и список чекера не участвуют в сравнении (их сопоставление сложнее
        // и не влияет на маркер «применён/изменён»).
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

    // Иконку рисуем шрифтом `icon` (в regular её глифов нет — иначе «?»), текст — обычным.
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
    return "preset:" + std::to_string(id);
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

auto plugin::gui::windows::main::frames::presets::render_variant(const std::string& id, nlohmann::ordered_json& config,
                                                                 nlohmann::json& value) -> void
{
    if (!value.is_string())
        return;

    std::string& setter = value.get_ref<std::string&>();
    int current = 0;

    for (std::size_t index = 0; index < config.size(); index++)
        if (config[index][0] == setter) {
            current = static_cast<int>(index);
            break;
        }

    std::string format = config[current][1];

    ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);

    if (ImGui::SliderInt(id.c_str(), &current, 0, static_cast<int>(config.size()) - 1, format.c_str())) {
        setter = config[current][0].get<std::string>();
        pending_save = true;
    }
}

auto plugin::gui::windows::main::frames::presets::render_color(const std::string& id, nlohmann::json& value) -> void {
    types::color color = value.get<types::color>();
    ImVec4 vector_color = ImGui::ColorConvertU32ToFloat4(*color);

    ImGui::SetNextItemWidth(ImGui::GetContentRegionAvail().x);

    if (ImGui::ColorEdit3(id.c_str(), reinterpret_cast<float*>(&vector_color), ImGuiColorEditFlags_NoInputs)) {
        value = types::color(ImGui::ColorConvertFloat4ToU32(vector_color));
        pending_save = true;
    }
}

auto plugin::gui::windows::main::frames::presets::render_custom(const std::string& custom_id, nlohmann::json& value)
    -> void
{
    static auto custom_settings = std::to_array<custom_setting_ptr_t>({
        std::make_unique<custom_settings::report>(),
        std::make_unique<custom_settings::short_commands>(),
        std::make_unique<custom_settings::spectator_information>(),
        std::make_unique<custom_settings::spectator_actions>(),
        std::make_unique<custom_settings::message_recolorer>()
    }); // static auto custom_settings = std::to_array<custom_setting_ptr_t>({ ... })

    auto setting = std::find_if(custom_settings.begin(), custom_settings.end(),
        [&custom_id](const custom_setting_ptr_t& setting) { return setting->get_id() == custom_id; });

    if (setting == custom_settings.end()) {
        log::error("presets::render_custom: custom setting \"{}\" not found", custom_id);
        return;
    }

    // У custom-редакторов нет сигнала об изменении — сравниваем дамп до/после (значение небольшое).
    std::string before = value.dump();
    (*setting)->render(child->child, value);

    if (value.dump() != before)
        pending_save = true;
}

auto plugin::gui::windows::main::frames::presets::render_option(const std::string& id, const std::string& key,
                                                                const std::string& subsection_key,
                                                                nlohmann::ordered_json& meta_option, nlohmann::json& parent)
    -> void
{
    if (!parent.contains(key))
        return;

    item_type type = meta_option["_type"];
    std::string name = meta_option["_name"];
    std::string widget_id = "##opt:" + id;
    nlohmann::json& value = parent[key];
    float available = ImGui::GetContentRegionAvail().x;

    switch (type) {
        case item_type::boolean:
            if (value.is_boolean() && gui::widgets::toggle_button(widget_id, value.get_ref<bool&>()).render())
                pending_save = true;

            ImGui::SameLine();
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            break;

        case item_type::int_range: {
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);

            nlohmann::ordered_json& config = meta_option["_config"];
            int minimum = config[0].get<int>(), maximum = config[1].get<int>();
            int current = static_cast<int>(value.get<long long>());

            ImGui::SetNextItemWidth(available);

            if (ImGui::SliderInt(widget_id.c_str(), &current, minimum, maximum)) {
                value = static_cast<std::uint64_t>(current);
                pending_save = true;
            }

            break;
        }

        case item_type::float_range: {
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);

            nlohmann::ordered_json& config = meta_option["_config"];
            double minimum = config[0].get<double>(), maximum = config[1].get<double>();
            double current = value.get<double>();

            ImGui::SetNextItemWidth(available);

            if (ImGui::SliderScalar(widget_id.c_str(), ImGuiDataType_Double, &current, &minimum, &maximum, "%.3f")) {
                value = current;
                pending_save = true;
            }

            break;
        }

        case item_type::variant:
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            render_variant(widget_id, meta_option["_config"], value);
            break;

        case item_type::color:
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            render_color(widget_id, value);
            break;

        case item_type::input:
            if (auto* setter = value.get_ptr<std::string*>()) {
                gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
                ImGui::SetNextItemWidth(available);

                if (ImGui::InputText(widget_id.c_str(), setter))
                    pending_save = true;
            }

            break;

        case item_type::custom:
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            render_custom(subsection_key + "." + key, value);
            break;

        default:
            break;
    }
}

auto plugin::gui::windows::main::frames::presets::open_subsection_popup(const std::string& section,
                                                                        const std::string& item,
                                                                        const std::string& name,
                                                                        nlohmann::ordered_json& meta_item,
                                                                        nlohmann::json& settings) -> void
{
    // Захватываем указатели на стабильные узлы: meta_item живёт в `options` (член класса),
    // а ветка значения — в текущем пресете (не перевыделяется, пока попап открыт).
    nlohmann::json* value = &settings[section][item];
    nlohmann::ordered_json* meta = &meta_item;
    std::string subsection_key = item;
    std::string title = name;

    popup.set_renderer([this, value, meta, subsection_key, title] {
        // Имя пресета читаем «вживую» по текущей записи — переименование подхватится сразу.
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
            // `use` редактируется тумблером в строке списка, поэтому в попапе только опции.
            for (auto& [ key, meta_option ] : meta->items()) {
                if (key.starts_with('_'))
                    continue;

                render_option(subsection_key + ":" + key, key, subsection_key, meta_option, *value);
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

    // При активном поиске пропускаем разделы без совпадений и форсируем раскрытие остальных.
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

        // Пресет — полный снимок настроек. Если значения ещё нет (старый пресет или
        // настройка, добавленная позже), берём актуальное из живого конфига.
        if (!settings.contains(section) || !settings[section].contains(item)) {
            include_item(section, item, settings);
            pending_save = true;
        }

        nlohmann::json& value = settings[section][item];

        // Подсекция: тумблер `use` + кликабельное имя, открывающее детальный попап — ровно как в «Настройках».
        if (type == item_type::subsection) {
            if (value.contains("use") && value["use"].is_boolean()) {
                if (gui::widgets::toggle_button("##use:" + id, value["use"].get_ref<bool&>()).render())
                    pending_save = true;

                ImGui::SameLine();
            }

            ImGui::AlignTextToFramePadding();

            if (gui::widgets::text_button(name + "##presets_sub:" + id).render())
                open_subsection_popup(section, item, name, meta_item, settings);

            continue;
        }

        // Bool-функция: тумблер значения + имя.
        if (type == item_type::boolean && value.is_boolean()) {
            if (gui::widgets::toggle_button("##val:" + id, value.get_ref<bool&>()).render())
                pending_save = true;

            ImGui::SameLine();
            gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
            continue;
        }

        // На верхнем уровне секции иных типов нет, но на всякий случай покажем имя.
        ImGui::AlignTextToFramePadding();
        gui::widgets::text(regular_font, common_font_size, 0, "{}", name);
    }
}

auto plugin::gui::windows::main::frames::presets::include_item(const std::string& section, const std::string& item,
                                                               nlohmann::json& settings) const -> void
{
    settings[section][item] = snapshot_item(section, item);
}

auto plugin::gui::windows::main::frames::presets::render_editor(nlohmann::json& preset) -> void {
    if (!preset.contains("settings") || !preset["settings"].is_object())
        preset["settings"] = nlohmann::json::object();

    nlohmann::json& settings = preset["settings"];
    int preset_id = preset.value("id", -1);

    gui::widgets::text(bold_font, common_font_size, 0, "Настройки пресета");

    float full_width = ImGui::GetContentRegionAvail().x;

    editor_search.render(full_width, "Поиск функции по названию...");

    ImGui::BeginChild("presets::editor", { 0, 0 }, ImGuiChildFlags_Borders);
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

    // Каждый кадр освежаем указатель на хранилище: preset_list (json-массив) может
    // перевыделиться при добавлении пресета, и закэшированный в редакторах указатель
    // на settings["hotkeys"] стал бы висячим (use-after-free).
    for (gui::hotkey& editor : hotkey_editors)
        editor.set_external_storage(&hotkeys);

    // При активном поиске показываем секцию только если есть совпадения по меткам хоткеев.
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

    // Хоткей-виджет пишет бинд прямо в JSON пресета через внешнее хранилище. Сравниваем
    // дамп до/после, чтобы отметить пресет на сохранение при любом изменении.
    std::string before = hotkeys.dump();

    for (gui::hotkey& editor : hotkey_editors) {
        if (!editor_search.contains(editor.label))
            continue;

        editor.render({ 160.0f, buttons_height });
        ImGui::SameLine();
        ImGui::AlignTextToFramePadding();

        // Подпись — кликабельный текст (с подсветкой при наведении, как в других вкладках):
        // ЛКМ открывает тот же попап условий активации, что и ПКМ по кнопке клавиши.
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

    // Список игроков — отдельная сущность, под фильтр функций не подводим.
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

    if (gui::widgets::button("Добавить##presets_pc_add", { add_button_width, buttons_height }).render()
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
        ImGui::Separator();

        bool active_and_applied = static_cast<int>(current) == get_active_index() && preset_matches_live(preset);
        std::string apply_label = active_and_applied ? "Применить заново" : "Применить";

        if (gui::widgets::button(apply_label + "##frames::presets-" + index, { full_width, buttons_height }).render()) {
            apply_preset(preset);
            set_active_index(static_cast<int>(current));
        }

        if (gui::widgets::button("Обновить значения из текущих##frames::presets-" + index,
                                 { full_width, buttons_height }).render())
        {
            refresh_values(preset);
            save_presets();

            // Редакторы хоткеев кэшируют бинды — форсируем их перестройку, чтобы они
            // подхватили обновлённые из текущих значения.
            hotkey_editors_preset_id = -1;
        }

        if (gui::widgets::button("Удалить##frames::presets-" + index, { full_width, buttons_height }).render())
            submenu.remove_current_entry();

        if (gui::hotkey* preset_hotkey = find_pool_hotkey(preset_hotkey_label(preset.value("id", -1)))) {
            gui::widgets::text(regular_font, common_font_size, 0, "Горячая клавиша применения:");
            preset_hotkey->render({ full_width, buttons_height });
            gui::widgets::hint::render_as_guide("ЛКМ — задать клавишу, ПКМ — условия активации");
        }

        ImGui::Dummy({ 0, ImGui::GetStyle().ItemSpacing.y });

        render_editor(preset);
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

    // Освобождаем горячую клавишу удаляемого пресета: обнуляем бинд в пуле и в конфиге.
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
    // Раскладка: настройки слева, сайдбар со списком пресетов справа. Поскольку фрейм
    // по умолчанию занимает всё доступное место, при отрисовке слева задаём ему явную
    // ширину (всё минус ширина сайдбара и отступ).
    float frame_width = ImGui::GetContentRegionAvail().x
                        - submenu.get_menu_width(child) - ImGui::GetStyle().ItemSpacing.x;

    submenu.render_current_frame(child, frame_width);
    ImGui::SameLine();
    submenu.render_menu(child);
    popup.render(child);

    // Отложенная запись: пишем файл, только когда пользователь отпустил слайдер/поле,
    // иначе при перетаскивании ползунка файл писался бы каждый кадр.
    if (pending_save && !ImGui::IsAnyItemActive()) {
        save_presets();
        pending_save = false;
    }
}

plugin::gui::windows::main::frames::presets::presets(types::not_null<initializer*> child)
    : child(child),
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

    // Активный пресет подсвечиваем заливкой его кнопки в списке: зелёная — применён и
    // совпадает с текущими настройками, жёлтая — применён, но настройки изменены вручную.
    submenu.set_entry_highlight([this](std::size_t index) -> std::optional<std::uint32_t> {
        if (static_cast<int>(index) != get_active_index() || index >= preset_list.size())
            return std::nullopt;

        style::accent_colors_t& accents = style::get_current_accent_colors();
        std::uint32_t base = preset_matches_live(preset_list[index]) ? *accents.green : *accents.yellow;

        // Полупрозрачная заливка — но достаточно яркая, чтобы активный пресет выделялся.
        return (base & 0x00FFFFFFu) | (0xAAu << 24);
    });

    // На кнопке пресета справа рисуем бейдж с назначенной горячей клавишей применения.
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

    // Резервируем под бейдж место справа, чтобы название пресета не залезало под него.
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
