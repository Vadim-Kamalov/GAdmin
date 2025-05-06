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

class key_bind {
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
    struct modifiers_t : raw_modifiers {
        using joined_t = std::uint8_t;
        
        constexpr joined_t join() const;

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

    std::string to_string() const;
    
    constexpr joined_t join() const;
    constexpr bool empty() const;
    constexpr bool operator==(const key_bind& other) const;

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
}; // class key_bind

class hotkey {
private:
    static constexpr ImVec2 button_size = { 100, 30 };
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

    std::string truncate_text_in_button(const std::string_view& text) const;
    
    void hint_renderer();
    bool hint_condition();
public:
    using callback_t = std::function<void(hotkey&)>;
public: 
    std::string label = "";
    key_bind bind;
    callback_t callback = [](hotkey&) {};

    void render();
    
    inline hotkey& with_callback(callback_t new_callback);
    inline hotkey& with_handler(hotkey_handler* new_handler);

    explicit hotkey(const std::string_view& label, const key_bind& bind);

    hotkey() = default;
}; // class hotkey

class hotkey_handler {
private:
    bool check_modifiers(const key_bind::modifiers_t& modifiers) const;
    bool check_conditions(const types::options<bind_condition>& conditions) const;
    void write_current_modifiers();
    void write_current_keys(unsigned int message, WPARAM wparam);
public:
    types::not_null<gui_initializer*> child;
    std::deque<hotkey> pool;
    
    key_bind current_keys;
    bool changing_any_properties = false;
    bool changing_any_hotkey = false;

    bool is_bind_defined(const key_bind& bind) const;
    bool is_hotkey_active(const hotkey& hotkey_to_find) const;

    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam);
    void main_loop();
    void add(hotkey& hotkey);

    explicit hotkey_handler(types::not_null<gui_initializer*> child)
        : child(child) {}
}; // class hotkey_handler

} // namespace gui
} // namespace plugin

template<>
struct std::formatter<plugin::gui::key_bind> : std::formatter<std::string_view> {
    auto format(const plugin::gui::key_bind& bind, std::format_context& ctx) const {
        return std::formatter<std::string_view>::format(bind.to_string(), ctx);
    }
}; // struct std::formatter<plugin::gui::key_bind> : std::formatter<std::string_view>

constexpr plugin::gui::key_bind::modifiers_t::joined_t
plugin::gui::key_bind::modifiers_t::join() const {
    return (alt << 7) | (uses_right_hand_alt << 6) |
           (control << 5) | (uses_right_hand_control << 4) |
           (shift << 3) | (uses_right_hand_shift << 2);
}

constexpr plugin::gui::key_bind::joined_t
plugin::gui::key_bind::join() const {
    return (static_cast<joined_t>(conditions.flags) << 24) |
           (static_cast<joined_t>(modifiers.join()) << 16) |
           (static_cast<joined_t>(keys.first) << 8) |
           (static_cast<joined_t>(keys.second));
}

constexpr bool
plugin::gui::key_bind::operator==(const key_bind& other) const {
    return modifiers.join() == other.modifiers.join() && keys == other.keys;
}

constexpr bool
plugin::gui::key_bind::empty() const {
    return keys.first == 0 && keys.second == 0;
}

inline plugin::gui::hotkey&
plugin::gui::hotkey::with_callback(callback_t new_callback) {
    callback = new_callback;
    return *this;
}

inline plugin::gui::hotkey&
plugin::gui::hotkey::with_handler(hotkey_handler* new_handler) {
    handler = new_handler;
    return *this;
}

#endif // GADMIN_PLUGIN_GUI_HOTKEY_H
