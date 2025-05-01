#ifndef GADMIN_PLUGIN_CHEATS_CLICKWARP_H
#define GADMIN_PLUGIN_CHEATS_CLICKWARP_H

#include "plugin/cheats/base.h"
#include "plugin/game/vehicle.h"
#include "plugin/types/simple.h"

namespace plugin::cheats {

class clickwarp : public basic_cheat {
private:
    struct teleport_information_t {
        types::vector_3d coordinates;
        game::vehicle vehicle_to_jump;
    }; // struct teleport_information_t

    bool selecting_place_to_warp = false;
    bool need_to_update_cursor = false;

    std::optional<teleport_information_t> teleport_information;

    void stop_selecting_place();
public:
    void on_alogin_new_state(bool state) override;
    bool on_event(unsigned int message, WPARAM wparam, LPARAM lparam) override;
    void render(types::not_null<gui_initializer*> child) override;
}; // class clickwarp : public basic_cheat

} // namespace plugin::cheats

#endif // GADMIN_PLUGIN_CHEATS_CLICKWARP_H
