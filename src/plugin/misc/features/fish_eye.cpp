#include "plugin/misc/features/fish_eye.h"
#include "plugin/game/camera.h"
#include "plugin/game/ped.h"
#include "plugin/plugin.h"

void
plugin::misc::features::fish_eye::main_loop() {
    auto feature_configuration = (*configuration)["misc"]["fish_eye"];

    if (!feature_configuration["use"])
        return;

    game::ped player_ped = game::ped::get_player();
    
    float fov = (player_ped.is_targeting() && player_ped.get_current_weapon() == game::weapon::sniper_rifle)
        ? 70.0f
        : feature_configuration["fov"].get<float>();

    game::camera::lerp_fov(fov, fov, 1000.0f, true);
}
