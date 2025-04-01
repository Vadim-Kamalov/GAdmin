#ifndef GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/hotkey.h"
#include "plugin/samp/events/event.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include "plugin/samp/events/send_command.h" // IWYU pragma: keep
#include "plugin/samp/events/server_message.h"
#include "plugin/gui/gui.h"

namespace plugin::gui::windows {

class command_requester : public window {
private:
    struct command_t {
        enum class type_t : std::uint8_t {
            none,
            reason,
            answer
        }; // enum class type_t : std::uint8_t

        enum class param_t : std::uint8_t {
            id,
            number,
            number_optional,
            text
        }; // enum class param_t : std::uint8_t

        type_t type;
        std::string name;
        std::uint8_t level;
        std::vector<param_t> params;
    }; // struct command_t

    struct parsed_request_t {
        command_t command;
        std::optional<std::uint16_t> receiver_id;

        explicit parsed_request_t(const command_t& command, const std::optional<std::uint16_t>& receiver_id)
            : command(std::move(command)), receiver_id(std::move(receiver_id)) {}
    }; // struct parsed_request_t

    struct request_t {
        std::optional<std::uint16_t> receiver_id;
        std::string sender_nickname;
        std::uint16_t sender_id;
        std::string full_command;
        command_t command;
    }; // struct request_t

    static const std::vector<command_t> commands;
    types::not_null<gui_initializer*> child;

    std::chrono::steady_clock::time_point time_request_sent;
    std::optional<request_t> current_request;
    
    std::string last_command = "";
    std::string command_to_send = "";

    ImFont* regular_font;
    ImFont* bold_font;

    std::chrono::steady_clock::time_point time_to_send_command;
    hotkey approve_request_hotkey;

    std::optional<parsed_request_t> try_parse_request(const std::string_view& usage) const;
    bool try_handle_new_request(const std::string& text);
    bool try_handle_approved_request(const std::string& text, const types::color& color);

    void approve_request();

    bool on_send_command(const samp::out_event<samp::event_id::send_command>& event);
    bool on_server_message(const samp::event<samp::event_id::server_message>& event);
public:
    constexpr types::zstring_t get_id() const override;

    void render() override;
    bool on_event(const samp::event_info& event) override;

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit command_requester(types::not_null<gui_initializer*> child);
}; // class command_requester : public window 

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::command_requester::get_id() const {
    return "windows::command_requester";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_COMMAND_REQUESTER_H
