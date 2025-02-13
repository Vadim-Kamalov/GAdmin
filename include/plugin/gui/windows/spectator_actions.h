#ifndef GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
#define GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows {

class spectator_actions : public window {
private:
    types::not_null<gui_initializer*> child;
public:
    struct button {
        bool use;
        std::string name;
        std::variant<std::string, int> action;
    }; // struct button
public:
    constexpr types::zstring_t get_id() const override;

    void render() override;

    static window_ptr_t create(types::not_null<gui_initializer*> child) noexcept;
    explicit spectator_actions(types::not_null<gui_initializer*> child);
}; // class spectator_actions : public window

void to_json(nlohmann::json& json, const spectator_actions::button& button);
void from_json(const nlohmann::json& json, spectator_actions::button& button);

} // namespace plugin::gui::windows

constexpr plugin::types::zstring_t
plugin::gui::windows::spectator_actions::get_id() const {
    return "windows::spectator_actions";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_ACTIONS_H
