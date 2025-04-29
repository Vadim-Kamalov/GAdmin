#ifndef GADMIN_PLUGIN_CHEATS_WALLHACK_H
#define GADMIN_PLUGIN_CHEATS_WALLHACK_H

#include "plugin/cheats/base.h"

namespace plugin::cheats {

class wallhack : public basic_cheat {
private:
    gui::hotkey hotkey;
    bool cheat_active = false;

    void set_wallhack_state(bool state);
    void hotkey_callback(gui::hotkey& hotkey);
public:
    void register_hotkeys(types::not_null<gui::hotkey_handler*> handler) override;
    void render(types::not_null<gui_initializer*> child) override;
    void on_alogin_new_state(bool state) override;

    explicit wallhack();
private:
    static constexpr float render_distance = 0x7D0;
}; // class wallhack : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_WALLHACK_H
