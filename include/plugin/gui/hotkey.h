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

#ifndef GADMIN_PLUGIN_GUI_HOTKEY_H
#define GADMIN_PLUGIN_GUI_HOTKEY_H

#include "plugin/types/not_null.h"
#include "plugin/types/options.h"
#include <chrono>
#include <cstdint>
#include <deque>
#include <format>
#include <string>
#include <minwindef.h>
#include <windows.h>
#include <vector>
#include <functional>
#include <imgui.h>

namespace plugin {

class gui_initializer;

namespace gui {

class hotkey_handler;

/// Conditions for hotkey binding activation.
enum class bind_condition : std::uint8_t {
    always = 1 << 0,            ///< Always active.
    on_alogin = 1 << 1,         ///< Active only during `/alogin`.
    not_on_alogin = 1 << 2,     ///< Active only outside `/alogin`.
    in_spectator = 1 << 3,      ///< Active only in spectator mode.
    not_in_spectator = 1 << 4,  ///< Active only outside spectator mode.
    cursor_active = 1 << 5,     ///< Active only when cursor is active.
    cursor_not_active = 1 << 6, ///< Active only when cursor is inactive.
    never = 1 << 7              ///< Never active.
}; // enum class bind_condition : std::uint8_t

/// Represents key binding configuration.
class key_bind final {
public:
    /// Combined representation of key bind as 32-bit value.
    using joined_t = std::uint32_t;

    /// Pair of primary and secondary keys.
    using keys_t = std::pair<std::uint8_t, std::uint8_t>;
    
    /// Conditions (up to eight) for the bind activation.
    types::options<bind_condition> conditions = bind_condition::always;

    /// Modifiers for the current key bind. `internal_first_key_down` and
    /// `internal_second_key_down` are internal and should not be used anywhere
    /// (except in the hotkey handler, which utilizes these fields), including `key_bind::join`.
    ///
    /// Fields starting with `uses_right_hand_` indicate that the
    /// next field (key) is using the right-hand variation of it.
    ///
    /// Both left and right-hand variations of the modifiers are prohibited.
    struct raw_modifiers {
        std::uint8_t internal_first_key_down : 1;  ///< Internal data.
        std::uint8_t internal_second_key_down : 1; ///< Internal data.
        std::uint8_t uses_right_hand_shift : 1;    ///< Whether shift key is right-handed.
        std::uint8_t shift : 1;                    ///< Uses shift key.
        std::uint8_t uses_right_hand_control : 1;  ///< Whether control key is right-handed.
        std::uint8_t control : 1;                  ///< Uses control key.
        std::uint8_t uses_right_hand_alt : 1;      ///< Whether alt key is right-handed.
        std::uint8_t alt : 1;                      ///< Uses alt key.
    }; // struct raw_modifiers

    /// Wrapper for the `raw_modifiers` bit-field with
    /// the packing/unpacking method and constructor.
    struct modifiers_t final : raw_modifiers {
        /// Combined representation of modifiers as 8-bit value.
        using joined_t = std::uint8_t;
        
        /// Pack modifiers into single byte.
        ///
        /// @return Packed modifiers as single byte.
        constexpr auto join() const -> joined_t;

        /// Construct from raw modifers.
        ///
        /// @param modifiers[in] Raw modifiers.
        constexpr modifiers_t(const raw_modifiers& modifiers)
            : raw_modifiers(modifiers) {}

        /// Construct from combined representation of modidifers.
        ///
        /// @param modifiers[in] Combined modifiers representation.
        constexpr modifiers_t(joined_t modifiers) : raw_modifiers({
            .uses_right_hand_shift = static_cast<std::uint8_t>((modifiers >> 2) & 1),
            .shift = static_cast<std::uint8_t>((modifiers >> 3) & 1),
            .uses_right_hand_control = static_cast<std::uint8_t>((modifiers >> 4) & 1),
            .control = static_cast<std::uint8_t>((modifiers >> 5) & 1),
            .uses_right_hand_alt = static_cast<std::uint8_t>((modifiers >> 6) & 1),
            .alt = static_cast<std::uint8_t>((modifiers >> 7) & 1)
        }) {}

        /// Default constructor.
        constexpr modifiers_t()
            : raw_modifiers({ 0, 0, 0, 0, 0, 0, 0, 0 }) {}
    } modifiers; ///< Represents modifiers for the current bind.
   
    /// Represents two virtual keys.
    keys_t keys;

    /// Convert key bind to string representation.
    ///
    /// @return String representation of key bind.
    auto to_string() const -> std::string;

    /// Pack key bind into single 32-bit value.
    ///
    /// @return Packed key bind as 32-bit value.
    constexpr auto join() const -> joined_t;

    /// Check if key bind is empty.
    ///
    /// @return True if no keys are set.
    constexpr auto empty() const -> bool;

    /// Compare with another key bind.
    ///
    /// @param other[in] Key bind to compare with.
    /// @return          True if key binds are equal.
    constexpr auto operator==(const key_bind& other) const -> bool;

    /// Construct from packed 32-bit value.
    ///
    /// @param bind[in] Packed key bind value.
    constexpr explicit key_bind(joined_t bind)
        : conditions(static_cast<bind_condition>(bind >> 24)),
          modifiers(static_cast<modifiers_t::joined_t>((bind >> 16) & 0xFF)),
          keys({ static_cast<std::uint8_t>((bind >> 8) & 0xFF),
                 static_cast<std::uint8_t>(bind & 0xFF) }) {} 

    /// Construct from key pair.
    ///
    /// @param keys[in] Key pair to use.
    constexpr key_bind(const keys_t& keys)
        : keys(keys) {}

    /// Construct from key pair and raw modifiers.
    ///
    /// @param keys[in]      Key pair to use.
    /// @param modifiers[in] Raw modifiers to use.
    constexpr explicit key_bind(const keys_t& keys, const raw_modifiers& modifiers)
        : keys(keys), modifiers(modifiers) {}

    /// Construct from key pair and conditions.
    ///
    /// @param keys[in]       Key pair to use.
    /// @param conditions[in] Activation conditions.
    constexpr explicit key_bind(const keys_t& keys, const types::options<bind_condition>& conditions)
        : keys(keys), conditions(conditions) {}

    /// Construct from key pair, modifiers, and conditions.
    ///
    /// @param keys[in] Key pair to use.
    /// @param modifiers[in] Raw modifiers to use.
    /// @param conditions[in] Activation conditions.
    constexpr explicit key_bind(const keys_t& keys, const raw_modifiers& modifiers,
                                const types::options<bind_condition>& conditions)
        : keys(keys), conditions(conditions), modifiers(modifiers) {}

    /// Default constructor.
    constexpr key_bind() = default;
}; // class key_bind final

/// Represents configurable hotkey in the GUI which can be saved and loaded.
class hotkey final {
private:
    static constexpr float fonts_size = 18;
    static inline const std::vector<std::string> hint_settings = {
        "Всегда", "На /alogin", "Вне /alogin", "В режиме наблюдения",
        "Вне режима наблюдения", "При включенном курсоре",
        "При выключенном курсоре", "Никогда"
    }; // static inline const std::vector<std::string> hint_settings

    bool changing = false;
    bool tick_state = false;
    bool hint_active = false;
    bool already_registered = false;
    bool rendering_in_settings = true;

    std::chrono::steady_clock::time_point tick_time;
    
    hotkey_handler* handler;
    key_bind new_bind;

    auto truncate_text_in_button(float button_width, const std::string_view& text) const -> std::string;
    auto hint_renderer() -> void;
    auto hint_condition() -> bool;
public:
    /// Callback function type that called each hotkey activation.
    using callback_t = std::function<void(hotkey&)>;

    /// Default button size.
    static constexpr ImVec2 default_button_size = { 100, 30 };

    std::string label = "";               ///< Hotkey's label.
    key_bind bind;                        ///< Hotkey's key bind.
    callback_t callback = [](hotkey&) {}; ///< Hotkey's callback that called each activation.

    /// Check if hotkey is intended to be rendered in the settings frame of the main window.
    ///
    /// @return True if can render in the settings frame.
    inline auto can_render_in_settings() const -> bool;

    /// Render hotkey widget.
    ///
    /// @param size[in] Button size (default: `default_button_size`).
    auto render(const ImVec2& size = default_button_size) -> void;

    /// Construct hotkey with the specific callback passed.
    ///
    /// @param new_callback[in] New callback to set.
    /// @return                 Reference to this hotkey to allow chain-calls.
    inline auto with_callback(callback_t new_callback) -> hotkey&;

    /// Construct hotkey with the specific handler passed.
    ///
    /// @param hotkey_handler[in] New handler to set.
    /// @return                   Reference to this hotkey to allow chain-calls.
    inline auto with_handler(hotkey_handler* new_handler) -> hotkey&;

    /// Construct hotkey with the disabled rendering in the settins frame of the main window.
    ///
    /// @return Reference to this hotkey to allow chain-calls.
    inline auto without_rendering_in_settings() -> hotkey&;

    /// Construct hotkey with label and bind.
    ///
    /// @param label[in] Hotkey's label.
    /// @param bind[in]  Hotkey's key bind.
    explicit hotkey(const std::string_view& label, const key_bind& bind);

    /// Default constructor.
    hotkey() = default;
}; // class hotkey final

/// Hotkey initialization and management class.
class hotkey_handler final {
private:
    auto check_modifiers(const key_bind::modifiers_t& modifiers) const -> bool;
    auto check_conditions(const types::options<bind_condition>& conditions) const -> bool;
    auto write_current_modifiers() -> void;
    auto write_current_keys(unsigned int message, WPARAM wparam) -> void;
public:
    types::not_null<gui_initializer*> child; ///< Valid instance of the GUI initializer used to create handler.
    std::deque<hotkey> pool;                 ///< All created hotkeys.

    key_bind current_keys;                ///< Current active key bind.
    bool changing_any_properties = false; ///< Whether changing any hotkeys' properties.
    bool changing_any_hotkey = false;     ///< Whether changing any hotkeys' key bind.

    /// Check if bind is already used by one of the hotkey.
    ///
    /// @parma bind[in] Bind to check.
    /// @return         True if bind is already used by one of the hotkey.
    auto is_bind_defined(const key_bind& bind) const -> bool;

    /// Check if hotkey's key bind is down.
    ///
    /// @param hotkey_to_find[in] Hotkey to find.
    /// @return                   True if hotkey's key bind is down.
    auto is_hotkey_active(const hotkey& hotkey_to_find) const -> bool;

    /// Process window's message.
    ///
    /// @param message[in]            Message ID.
    /// @param wparam[in], lparam[in] Message parameters.
    /// @return                       Whether the message should continue processing.
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;

    /// Main loop.
    auto main_loop() -> void;

    /// Add hotkey to the handler to allow its activation.
    ///
    /// @param hotkey[out] Reference to the hotkey to add.
    auto add(hotkey& hotkey) -> void;

    /// Construct the hotkey handler.
    ///
    /// @param child[in] Valid instance of the GUI initializer.
    explicit hotkey_handler(types::not_null<gui_initializer*> child)
        : child(child) {}
}; // class hotkey_handler final

} // namespace gui
} // namespace plugin

template<>
struct std::formatter<plugin::gui::key_bind> : std::formatter<std::string_view> {
    auto format(const plugin::gui::key_bind& bind, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(bind.to_string(), ctx);
    }
}; // struct std::formatter<plugin::gui::key_bind> : std::formatter<std::string_view>

constexpr auto plugin::gui::key_bind::modifiers_t::join() const -> joined_t {
    return (alt << 7) | (uses_right_hand_alt << 6) |
           (control << 5) | (uses_right_hand_control << 4) |
           (shift << 3) | (uses_right_hand_shift << 2);
}

constexpr auto plugin::gui::key_bind::join() const -> joined_t {
    return (static_cast<joined_t>(conditions.flags) << 24) |
           (static_cast<joined_t>(modifiers.join()) << 16) |
           (static_cast<joined_t>(keys.first) << 8) |
           (static_cast<joined_t>(keys.second));
}

constexpr auto plugin::gui::key_bind::operator==(const key_bind& other) const -> bool {
    return modifiers.join() == other.modifiers.join() && keys == other.keys;
}

constexpr auto plugin::gui::key_bind::empty() const -> bool {
    return keys.first == 0 && keys.second == 0;
}

inline auto plugin::gui::hotkey::can_render_in_settings() const -> bool {
    return rendering_in_settings;
}

inline auto plugin::gui::hotkey::with_callback(callback_t new_callback) -> hotkey& {
    callback = new_callback;
    return *this;
}

inline auto plugin::gui::hotkey::with_handler(hotkey_handler* new_handler) -> hotkey& {
    handler = new_handler;
    return *this;
}

inline auto plugin::gui::hotkey::without_rendering_in_settings() -> hotkey& {
    rendering_in_settings = false;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_HOTKEY_H
