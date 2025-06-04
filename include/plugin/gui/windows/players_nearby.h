#ifndef GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H
#define GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H

#include "nlohmann/detail/macro_scope.hpp"
#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/color.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <deque>

namespace plugin::gui::windows {

class players_nearby final : public window {
public:
    enum class sort_option_t { disabled, length, distance, id };
private:
    struct entry final {
        float width = 0;
        float distance = 0;
        std::string text = "";
        std::uint16_t id = 0;
        types::color color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
    }; // struct entry final

    struct information_t final {
        ImVec2 content_size;
        std::deque<entry> entries;
    }; // struct information_t final

    ImFont *entry_font, *title_font;

    auto get_window_information() const -> information_t;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;

    explicit players_nearby(types::not_null<gui_initializer*> child)
        : window(child),
          entry_font((*child->fonts->regular)[16]),
          title_font((*child->fonts->bold)[18]) {}
private:
    static constexpr std::size_t text_border_size = 1;
    static constexpr types::zstring_t title = "Игроки в зоне стрима";
}; // class players_nearby final : public window

NLOHMANN_JSON_SERIALIZE_ENUM(players_nearby::sort_option_t, {
    { players_nearby::sort_option_t::disabled, "disabled" },
    { players_nearby::sort_option_t::length, "length" },
    { players_nearby::sort_option_t::distance, "distance"},
    { players_nearby::sort_option_t::id, "id" }
})

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::players_nearby::get_id() const -> types::zstring_t {
    return "windows::players_nearby";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_PLAYERS_NEARBY_H
