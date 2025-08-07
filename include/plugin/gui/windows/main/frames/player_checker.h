#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H

#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>
#include <deque>

namespace plugin::gui::windows::main::frames {

class player_checker final : public basic_frame {
private:
    static constexpr float bottom_button_height = 30;
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr std::uint16_t id_none = 0xFFFF;
    static constexpr types::zstring_t description_hint = "Заметка об игроке";

    struct player_online_t final {
        std::string nickname;
        std::uint16_t id;
    }; // struct player_online_t final

    struct added_player_t final {
        std::string nickname;
        std::string description;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(added_player_t, nickname, description);
    }; // struct added_player_t final

    types::not_null<initializer*> child;
    gui::widgets::search search = gui::widgets::search("frames::player_checker::search");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;
    
    std::string description_text = "";
    std::uint16_t selected_id = id_none;
    std::size_t selected_player_index = 0;

    auto get_filtered_player_list() const -> std::deque<player_online_t>;
    static auto get_added_players_json() -> nlohmann::json&;
    auto render_description_hint(const ImVec2& input_size) const -> void;
    auto render_left_group(float width) -> void;
    auto render_right_group(float width) -> void;
public:
    auto render() -> void override;

    explicit player_checker(types::not_null<initializer*> child);
}; // class player_checker final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLAYER_CHECKER_H
