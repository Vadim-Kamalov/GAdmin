#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SERVER_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SERVER_INFORMATION_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/gui/widgets/search.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows::main::frames {

class server_information final : public basic_frame {
public:
    enum class item_type : std::uint8_t {
        complex_table,
        map
    }; // enum class item_type : std::uint8_t
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;

    struct frame_payload_t final {
        item_type type;
        nlohmann::json& config;
    }; // struct frame_payload_t final

    nlohmann::json information;
    types::not_null<initializer*> child;
    widgets::submenu submenu = widgets::submenu("Таблицы##frames::server_information");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    static auto get_filtered_map(const gui::widgets::search& search, const nlohmann::json& config)
        -> std::vector<std::array<std::string, 2>>;

    auto handle_row_controls(const std::string& text_to_copy) const -> void;
    auto render_complex_table(const std::string& id, const nlohmann::json& config) const -> void;
    auto render_map(const std::string& id, const nlohmann::json& config) const -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
public:
    auto render() -> void override;

    explicit server_information(types::not_null<initializer*> child);
}; // class server_information final : public basic_frame

NLOHMANN_JSON_SERIALIZE_ENUM(server_information::item_type, {
    { server_information::item_type::complex_table, "complextable" },
    { server_information::item_type::map, "map" }
})

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_SERVER_INFORMATION_H
