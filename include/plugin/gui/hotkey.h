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

enum class bind_condition : std::uint8_t {
    always = 1 << 0,
    on_alogin = 1 << 1,
    not_on_alogin = 1 << 2, 
    in_spectator = 1 << 3,
    not_in_spectator = 1 << 4,
    cursor_active = 1 << 5,
    cursor_not_active = 1 << 6,
    never = 1 << 7
}; // enum class bind_condition : std::uint8_t

class key_bind final {
public:
    using joined_t = std::uint32_t;
    using keys_t = std::pair<std::uint8_t, std::uint8_t>;
    
    /// Conditions (up to eight) for the bind usage.
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
        std::uint8_t internal_first_key_down : 1;
        std::uint8_t internal_second_key_down : 1;
        std::uint8_t uses_right_hand_shift : 1;
        std::uint8_t shift : 1;
        std::uint8_t uses_right_hand_control : 1;
        std::uint8_t control : 1;
        std::uint8_t uses_right_hand_alt : 1;
        std::uint8_t alt : 1;
    }; // struct raw_modifiers

    /// Wrapper for the `raw_modifiers` bit-field with
    /// the packing/unpacking method and constructor.
    struct modifiers_t final : raw_modifiers {
        using joined_t = std::uint8_t;
        
        constexpr auto join() const -> joined_t;

        constexpr modifiers_t(const raw_modifiers& modifiers)
            : raw_modifiers(modifiers) {}
        
        constexpr modifiers_t(joined_t modifiers) : raw_modifiers({
            .uses_right_hand_shift = static_cast<std::uint8_t>((modifiers >> 2) & 1),
            .shift = static_cast<std::uint8_t>((modifiers >> 3) & 1),
            .uses_right_hand_control = static_cast<std::uint8_t>((modifiers >> 4) & 1),
            .control = static_cast<std::uint8_t>((modifiers >> 5) & 1),
            .uses_right_hand_alt = static_cast<std::uint8_t>((modifiers >> 6) & 1),
            .alt = static_cast<std::uint8_t>((modifiers >> 7) & 1)
        }) {}

        constexpr modifiers_t()
            : raw_modifiers({ 0, 0, 0, 0, 0, 0, 0, 0 }) {}
    } modifiers; ///< Represents modifiers for the current bind.
   
    /// Represents two virtual keys.
    keys_t keys;

    auto to_string() const -> std::string;
    
    constexpr auto join() const -> joined_t;
    constexpr auto empty() const -> bool;
    constexpr auto operator==(const key_bind& other) const -> bool;

    constexpr explicit key_bind(joined_t bind)
        : conditions(static_cast<bind_condition>(bind >> 24)),
          modifiers(static_cast<modifiers_t::joined_t>((bind >> 16) & 0xFF)),
          keys({ static_cast<std::uint8_t>((bind >> 8) & 0xFF),
                 static_cast<std::uint8_t>(bind & 0xFF) }) {} 

    constexpr key_bind(const keys_t& keys)
        : keys(keys) {}

    constexpr explicit key_bind(const keys_t& keys, const raw_modifiers& modifiers)
        : keys(keys), modifiers(modifiers) {}
    
    constexpr explicit key_bind(const keys_t& keys, const types::options<bind_condition>& conditions)
        : keys(keys), conditions(conditions) {}
    
    constexpr explicit key_bind(const keys_t& keys, const raw_modifiers& modifiers,
                                const types::options<bind_condition>& conditions)
        : keys(keys), conditions(conditions), modifiers(modifiers) {}

    constexpr key_bind() = default;
}; // class key_bind final

class hotkey final {
private:
    static constexpr float fonts_size = 18;
    static inline const std::vector<std::string> hint_settings = {
        "Всегда", "На /alogin", "Вне /alogin", "В режиме наблюдения",
        "Вне режима наблюдения", "При включенном курсоре",
        "При выключенном курсоре", "Никогда"
    };

    bool changing = false;
    bool tick_state = false;
    bool hint_active = false;
    bool already_registered = false;

    std::chrono::steady_clock::time_point tick_time;
    
    hotkey_handler* handler;
    key_bind new_bind;

    auto truncate_text_in_button(float button_width, const std::string_view& text) const -> std::string;
    auto hint_renderer() -> void;
    auto hint_condition() -> bool;
public: 
    static constexpr ImVec2 default_button_size = { 100, 30 };
    
    using callback_t = std::function<void(hotkey&)>;
    
    std::string label = "";
    key_bind bind;
    callback_t callback = [](hotkey&) {};

    auto render(const ImVec2& size = default_button_size) -> void;
    
    inline auto with_callback(callback_t new_callback) -> hotkey&;
    inline auto with_handler(hotkey_handler* new_handler) -> hotkey&;

    explicit hotkey(const std::string_view& label, const key_bind& bind);

    hotkey() = default;
}; // class hotkey final

class hotkey_handler final {
private:
    auto check_modifiers(const key_bind::modifiers_t& modifiers) const -> bool;
    auto check_conditions(const types::options<bind_condition>& conditions) const -> bool;
    auto write_current_modifiers() -> void;
    auto write_current_keys(unsigned int message, WPARAM wparam) -> void;
public:
    types::not_null<gui_initializer*> child;
    std::deque<hotkey> pool;
    
    key_bind current_keys;
    bool changing_any_properties = false;
    bool changing_any_hotkey = false;

    auto is_bind_defined(const key_bind& bind) const -> bool;
    auto is_hotkey_active(const hotkey& hotkey_to_find) const -> bool;

    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;
    auto main_loop() -> void;
    auto add(hotkey& hotkey) -> void;

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

inline auto plugin::gui::hotkey::with_callback(callback_t new_callback) -> hotkey& {
    callback = new_callback;
    return *this;
}

inline auto plugin::gui::hotkey::with_handler(hotkey_handler* new_handler) -> hotkey& {
    handler = new_handler;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_HOTKEY_H
