#ifndef GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/types/color.h"
#include "plugin/types/simple.h"
#include <deque>

namespace plugin::gui::windows {

class player_checker final : public window {
public:
    enum class align_t : std::uint8_t {
        left,
        center,
        right
    }; // enum class align_t : std::uint8_t
private:
    static constexpr float title_font_size = 20;
    static constexpr float common_font_size = 18;
    static constexpr float text_border_size = 1;
    static constexpr std::uint16_t id_none = 0xFFFF;
    static constexpr types::zstring_t title_text = "Чекер игроков";

    struct entry_t final {
        std::string nickname, description;
        types::color nickname_color;
        std::uint16_t id = id_none;
        widgets::aligner aligner;

        auto to_string() const -> std::string;
    }; // struct entry_t final

    struct window_information_t final {
        struct render_configuration_t final {
            bool render : 1 = false;
            bool show_title : 1 = false;
            bool show_offline : 1 = false;
        } render_configuration;

        widgets::aligner title_aligner;
        std::deque<entry_t> entries;
        float width = 0.0f;
    }; // struct window_information_t final
    
    struct status_notification_t final {
        struct configuration_t final {
            bool disconnected : 1 = false;
            bool notify : 1 = false;
            bool sound_notify : 1 = false;
        } configuration;

        std::string nickname;
        std::uint16_t id;
    }; // struct status_notification_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_render_safe_color(const types::color& color) const -> types::color;
    auto get_entry_width(const entry_t& entry, bool show_offline) const -> float;
    auto get_window_information() const -> window_information_t;
    auto send_status_notification(const status_notification_t& notification) const -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto on_event(const samp::event_info& event) -> bool override;
    auto render() -> void override;

    explicit player_checker(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class player_checker final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::player_checker::get_id() const -> types::zstring_t {
    return "windows::player_checker";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_PLAYER_CHECKER_H
