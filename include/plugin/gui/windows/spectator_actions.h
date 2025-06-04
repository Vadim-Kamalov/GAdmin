#ifndef GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows {

class spectator_actions final : public window {
public:
    struct button final {
        bool use;
        std::string name;
        std::variant<std::string, int> action;
    }; // struct button final
    
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;

    explicit spectator_actions(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class spectator_actions final : public window

auto to_json(nlohmann::json& json, const spectator_actions::button& button) -> void;
auto from_json(const nlohmann::json& json, spectator_actions::button& button) -> void;

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::spectator_actions::get_id() const -> types::zstring_t {
    return "windows::spectator_actions";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
