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

#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PRESETS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PRESETS_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/frames/settings.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/gui/hotkey.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <chrono>
#include <filesystem>
#include <optional>
#include <string>
#include <vector>

namespace plugin::gui::windows::main::frames {

/// Represents the settings presets frame in the main window.
///
/// Allows the user to save the current script settings as a named preset, choose in a
/// detailed editor which settings are part of the preset (and edit their values without
/// touching the live configuration), apply a preset, rename, refresh or delete it. Presets
/// are stored in a separate human-readable JSON file so they can be shared between users.
/// Secrets (account/alogin passwords) and the internal UI state are never captured.
class presets final : public basic_frame {
private:
    using item_type = settings::item_type;

    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float buttons_height = 30;

    /// Hotkey badge (drawn over a preset entry in the side list) geometry.
    static constexpr float badge_font_size = 14;
    static constexpr float badge_padding_x = 6.0f;
    static constexpr float badge_padding_y = 2.0f;
    static constexpr float badge_right_margin = 6.0f;
    static constexpr float badge_text_gap = 8.0f; ///< Gap reserved between the name and the badge.

    /// Configuration sections a preset may capture.
    static constexpr types::zstring_t captured_sections[] = {
        "windows", "cheats", "misc", "spectator_mode"
    }; // static constexpr types::zstring_t captured_sections[]

    types::not_null<initializer*> child;

    /// Owning settings frame, reused to render the per-option editing widgets so the
    /// rendering logic is not duplicated.
    types::not_null<settings*> owner;

    widgets::submenu submenu = widgets::submenu("Пресеты##frames::presets");
    gui::widgets::search editor_search = gui::widgets::search("presets::editor_search");

    /// Shared popup used to edit the detailed options of a subsection (mirrors the popup
    /// of the regular settings frame, so the preset editor feels like the settings screen).
    widgets::popup popup = widgets::popup("frames::presets::editor_popup");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    ImFont* icon_font = nullptr;

    std::filesystem::path presets_file;
    nlohmann::json preset_list = nlohmann::json::array();

    /// Next stable preset id to assign. Ids are used to bind hotkeys to presets
    /// independently of their order or name.
    int next_id = 1;

    /// Settings tree metadata (parsed from `main_frame_settings.json`).
    nlohmann::ordered_json options;

    /// Whether an editor change is waiting to be written to disk (flushed when no widget
    /// is being actively edited, to avoid writing the file on every dragged frame).
    bool pending_save = false;

    /// State of the player-checker editor section (the player list lives in the preset).
    std::string pc_nickname_input;
    std::string pc_description_input;
    std::size_t pc_selected_index = 0;

    /// Per-preset hotkey editor objects: the real hotkey widget (with its key capture and
    /// activation-conditions popup) bound to the preset's hotkeys storage instead of the
    /// live binds. Rebuilt when the selected preset changes.
    std::vector<gui::hotkey> hotkey_editors;
    int hotkey_editors_preset_id = -1;

    auto load_presets() -> void;
    auto save_presets() const -> void;

    /// Whether the given configuration item must never enter a preset (passwords).
    static auto is_secret(const std::string& section, const std::string& item) -> bool;

    /// Snapshot a single configuration item from the live configuration.
    auto snapshot_item(const std::string& section, const std::string& item) const -> nlohmann::json;

    /// Capture every editable (non-secret) item of all captured sections.
    auto capture_all() const -> nlohmann::json;

    /// Snapshot the live hotkeys (those shown in the hotkeys frame) as a
    /// `{ label: packed_bind }` object, and the live player-checker list, respectively.
    auto capture_hotkeys() const -> nlohmann::json;
    auto capture_player_checker() const -> nlohmann::json;

    /// Apply the preset to the live configuration (only the included items).
    auto apply_preset(const nlohmann::json& preset) const -> void;

    /// Index of the last applied (active) preset, or -1 if none. Persisted in the config.
    auto get_active_index() const -> int;
    auto set_active_index(int index) const -> void;

    /// Whether every included item of the preset currently equals the live configuration.
    auto preset_matches_live(const nlohmann::json& preset) const -> bool;

    /// Ensure every preset has a unique stable id; assign to those missing one.
    auto ensure_preset_ids() -> void;

    /// Hotkey label (and config key) for the preset with the given id.
    static auto preset_hotkey_label(int id) -> std::string;

    /// Register a global hotkey that applies the preset with the given id.
    auto register_preset_hotkey(int id) -> void;

    /// Find the pooled hotkey with the given label (so its bind can be rendered/edited).
    auto find_pool_hotkey(const std::string& label) const -> gui::hotkey*;

    /// Textual representation of the preset entry's apply hotkey, or std::nullopt if the
    /// entry has no assigned key bind (used to draw / reserve space for its badge).
    auto entry_hotkey_text(std::size_t index) -> std::optional<std::string>;

    /// Apply the preset with the given id (called by its hotkey).
    auto apply_preset_by_id(int id) -> void;

    /// Render the "applied / not applied / modified" status banner for a preset.
    auto render_status_banner(const nlohmann::json& preset, std::size_t index) const -> void;

    auto render_editable_name(std::string& frame_label, std::string& value) -> void;

    /// Snapshot a single item's live value into the preset (used to fill in values that the
    /// preset does not have yet, e.g. an older preset or a setting added in a later version).
    auto include_item(const std::string& section, const std::string& item, nlohmann::json& settings) const -> void;

    auto render_editor(nlohmann::json& preset, float bottom_reserve) -> void;
    auto render_section_editor(const std::string& section, nlohmann::ordered_json& meta_section,
                               nlohmann::json& settings) -> void;

    /// Render the hotkeys / player-checker editor sections inline (editing the
    /// data stored in the preset, independently of the live configuration).
    auto render_hotkeys_section(nlohmann::json& settings, int preset_id) -> void;
    auto render_player_checker_section(nlohmann::json& settings) -> void;
    auto render_player_checker_body(nlohmann::json& players) -> void;

    /// (Re)build the per-preset hotkey editor objects when the selected preset changes,
    /// binding each to the preset's hotkeys storage.
    auto ensure_hotkey_editors(nlohmann::json& hotkeys, int preset_id) -> void;

    /// Open the shared popup to edit the detailed options of a subsection, exactly like the
    /// regular settings frame does (but editing the preset's snapshot instead of the live config).
    auto open_subsection_popup(const std::string& section, const std::string& item, const std::string& name,
                               nlohmann::ordered_json& meta_item, nlohmann::json& settings) -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
    auto add_callback() -> void;
    auto on_entry_destroyed(std::size_t index) -> void;
public:
    auto render() -> void override;

    /// Construct the frame.
    ///
    /// @param child[in] Valid pointer to the main window.
    /// @param owner[in] Owning settings frame, reused for the option-editing widgets.
    presets(types::not_null<initializer*> child, types::not_null<settings*> owner);
}; // class presets final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PRESETS_H
