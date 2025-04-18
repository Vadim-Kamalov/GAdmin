#ifndef GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H
#define GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H

#include "nlohmann/detail/macro_scope.hpp"
#include "plugin/gui/base/window.h"
#include "plugin/gui/hotkey.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/gui/gui.h"
#include "plugin/samp/events/server_message.h"
#include "plugin/samp/events/dialog.h"
#include <nlohmann/json.hpp>
#include <array>
#include <chrono>

namespace plugin::gui::windows {

class report : public window {
private:
    struct report_information_t {
        std::string nickname;
        std::string text;
        std::uint16_t id;
        std::chrono::steady_clock::time_point time_taken;
    }; // struct report_information_t

    struct action_button {
        widgets::button widget;
        std::function<void()> callback;
    }; // struct action_button
    
    struct insert_button {
        std::string name;
        std::string insert;
    }; // struct insert_button

    enum class dialog_option {
        spectate,
        answer,
        remove,
        block,
        return_to_administration,
        set_map_point
    }; // enum class dialog_option
    
    struct dialog_response {
        dialog_option option;
        std::optional<std::string> message;
        std::uint8_t block_time = 0;
    }; // struct dialog_response

    std::uint8_t window_alpha = 0;
    std::uint16_t dialog_id = 0;

    std::chrono::steady_clock::time_point time_hint_active;
    std::chrono::steady_clock::time_point time_switched_window;

    bool closing = false;
    bool active = false;
    bool focus = false;
    bool dialog_active = false;
    bool notification_active = false;

    std::optional<report_information_t> current_report;
    std::optional<dialog_response> current_response;

    types::not_null<gui_initializer*> child;
    std::string answer_input;

    ImFont* bold_font;
    ImFont* regular_font;

    hotkey switch_window_hotkey;

    std::array<action_button, 12> get_action_buttons();
    void send_chat_action_button() const;
    void block_action_button();

    bool on_show_dialog(const samp::event<samp::event_id::show_dialog>& dialog);
    bool on_server_message(const samp::event<samp::event_id::server_message>& message);
    bool on_new_report_message(const std::string& nickname, std::uint16_t id);
    bool on_report_canceled();

    void open_window();
    void open_window_with_dialog();
    void close_window();
    void switch_window();

    std::string get_time_active() const;

    bool can_send_response();
    void close_dialog();
    void send_response(const dialog_option& option);
    void send_input_response(const dialog_option& option);
    void close_report();
public:
    constexpr types::zstring_t get_id() const override;

    void render() override;
    bool on_event(const samp::event_info& event) override;

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit report(types::not_null<gui_initializer*> child);
private:
    static constexpr float answer_button_height = 30;
    static constexpr std::size_t max_buttons_per_line = 3;
    static constexpr std::size_t max_action_buttons_lines = 4;
    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static constexpr int block_time_options[4] = { 10, 30, 60, 90 };
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(insert_button, name, insert);
}; // class report : public window 

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::report::get_id() const {
    return "windows::report";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_REPORT_H
