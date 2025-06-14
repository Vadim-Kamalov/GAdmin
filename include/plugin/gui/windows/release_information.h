#ifndef GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <imgui_markdown.h>
#include <filesystem>
#include <chrono>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

class release_information final : public window {
private:
    static constexpr float bold_font_size = 24;
    static constexpr float regular_font_size = 18;

    static constexpr std::chrono::milliseconds animation_duration = 500ms;
    static inline ImGui::MarkdownConfig markdown_config;
    static std::filesystem::path file_path;

    struct parsed_information_t final {
        std::string date_created;
        std::string old_tag_name;
        std::string tag_name;
        std::string name;
        std::string body;
        std::size_t file_size;
        std::size_t download_count;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(parsed_information_t, date_created, tag_name,
                                       old_tag_name, name, body, file_size, download_count);
    }; // struct parsed_information_t final

    std::uint8_t window_alpha = 255, background_alpha = 128;
    std::chrono::steady_clock::time_point time;
    bool closing = false;

    ImFont *bold_font, *regular_font;
    std::optional<parsed_information_t> parsed_information;

    static auto markdown_link_callback(ImGui::MarkdownLinkCallbackData data) noexcept -> void;
    auto render_markdown(const std::string& markdown) const -> void;
    auto render_title() const -> void;
    auto close_window() -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;

    explicit release_information(types::not_null<gui_initializer*> child);
}; // class release_information final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::release_information::get_id() const -> types::zstring_t {
    return "windows::release_information";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_RELEASE_INFORMATION_H
