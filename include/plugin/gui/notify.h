#ifndef GADMIN_PLUGIN_GUI_NOTIFY_H
#define GADMIN_PLUGIN_GUI_NOTIFY_H

#include "plugin/types/simple.h"
#include <imgui.h>
#include <chrono>
#include <list>
#include <optional>
#include <string>
#include <functional>
#include <utility>

using namespace std::chrono_literals;

namespace plugin::gui {

class notification final {
public:
    using icon_t = types::zstring_t;
    using button_callback_t = std::function<void(notification&)>;
    using condition_t = std::function<bool()>;

    struct button final {
        struct backend_t final {
            static inline std::chrono::milliseconds clicked_duration = 300ms;
            static inline std::chrono::milliseconds hovered_duration = 200ms;
            
            ImVec4 color;
            bool hovered_state_previous = false, hovered_state_current = false;
            std::chrono::steady_clock::time_point time[2], hovered_time, clicked_time;

            struct colors_t final {
                ImVec4 hovered = ImGui::GetStyle().Colors[ImGuiCol_Text];
                ImVec4 clicked = ImGui::GetStyle().Colors[ImGuiCol_FrameBgActive];
                ImVec4 text = ImGui::GetStyle().Colors[ImGuiCol_TextDisabled];
            } colors; // struct colors_t final
        }; // struct backend_t final
        
        std::string name;
        button_callback_t callback;
        std::optional<backend_t> backend;
    }; // struct button final

    struct backend_t final {
        static inline std::chrono::milliseconds open_close_duration = 200ms;
        static inline std::chrono::milliseconds drop_duration = 100ms;
        float cursor_pos_x;
    }; // struct backend_t final

    using buttons_t = std::pair<button, button>;
public:
    std::string title, description;
    std::optional<buttons_t> buttons;
    std::chrono::steady_clock::time_point time_sent;
    icon_t icon;

    std::chrono::milliseconds duration = 5s;
    condition_t condition = []{ return true; };

    std::optional<backend_t> backend;

    auto with_duration(std::chrono::milliseconds new_duration) -> notification&;
    auto with_buttons(const button& first, const button& second) -> notification&;
    auto with_condition(condition_t new_condition) -> notification&;
    auto remove() -> void;

    notification(const std::string_view& title, const std::string_view& description, icon_t icon)
        : title(std::move(title)),
          description(std::move(description)),
          icon(icon),
          time_sent(std::chrono::steady_clock::now()) {}
}; // class notification final

class notify final {
public:
    using callback_t = std::function<bool(notification&)>;
private:
    static inline std::list<notification> notifications;
    static inline callback_t on_send_callback = [](notification&) { return true; };
public:
    static auto get_notifications() noexcept -> std::list<notification>&;

    static auto has_notifications() noexcept -> bool;
    static auto notifications_count() noexcept -> std::size_t;
    
    static auto send(const notification& to_send) -> void;
    static auto set_callback(callback_t callback) noexcept -> void;
}; // class notify final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_NOTIFY_H
