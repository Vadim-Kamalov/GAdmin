#ifndef GADMIN_PLUGIN_CHEATS_AIRBREAK_H
#define GADMIN_PLUGIN_CHEATS_AIRBREAK_H

#include "plugin/cheats/base.h"
#include "plugin/types/simple.h"
#include <numbers>

namespace plugin::cheats {

class airbreak : public basic_cheat {
private:
    gui::hotkey hotkey;
    types::vector_3d coords;
    bool cheat_active = false;

    void hotkey_callback(gui::hotkey& hotkey);
    float get_heading_from_xy(float x, float y) const;

    static constexpr float deg_to_rad(float deg) noexcept;
public:
    void on_alogin_new_state(bool state) override;
    void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) override;
    void main_loop() override;

    explicit airbreak();
}; // class airbreak : public basic_cheat

} // namespace plugin::cheats

constexpr float
plugin::cheats::airbreak::deg_to_rad(float deg) noexcept {
    return deg * (std::numbers::pi / 180.0f);
}

#endif // GADMIN_PLUGIN_CHEATS_AIRBREAK_H
