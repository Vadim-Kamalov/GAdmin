#include "plugin/misc/features/fish_eye.h"
#include "plugin/server/spectator.h"
#include "plugin/game/camera.h"
#include "plugin/game/ped.h"
#include "plugin/samp/core/game.h"
#include "plugin/plugin.h"
#include <windows.h>

auto plugin::misc::features::fish_eye::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    if (message != WM_MOUSEWHEEL)
        return true;

    auto& spectator_camera_zoom_configuration = (*configuration)["spectator_mode"]["zoom_camera"];

    if (!spectator_camera_zoom_configuration["use"]
        || !server::spectator::is_active()
        || GetCursor() != nullptr
        || samp::game::cursor_mode_offsets->read(samp::game::instance_container->read() != 0))
    {
        return true;
    }

    std::int16_t wheel_delta = GET_WHEEL_DELTA_WPARAM(wparam);
    float step = spectator_camera_zoom_configuration["step"];
    float current_fov = game::camera::get_fov();

    if (wheel_delta > 0)
        spectator_fov = std::min<float>(current_fov + step, 130);
    else if (wheel_delta < 0)
        spectator_fov = std::max<float>(current_fov - step, 50);

    return true;
}

auto plugin::misc::features::fish_eye::main_loop() -> void {
    auto global_fov_configuration = (*configuration)["misc"]["fish_eye"];
    auto spectator_camera_zoom_configuration = (*configuration)["spectator_mode"]["zoom_camera"];
    
    bool change_spectator_camera_fov = spectator_camera_zoom_configuration["use"];
    bool change_global_fov = global_fov_configuration["use"];

    if (!change_global_fov && !change_spectator_camera_fov)
        return;

    float new_fov_value = 70.0f;

    if (change_global_fov) {
        game::ped player_ped = game::ped::get_player();
 
        if (!player_ped.is_targeting() || player_ped.get_current_weapon() == game::weapon::sniper_rifle) {
            new_fov_value = global_fov_configuration["fov"];
        }
    }

    if (change_spectator_camera_fov && server::spectator::is_active() && spectator_fov != 0.0f)
        new_fov_value = spectator_fov;

    game::camera::lerp_fov(new_fov_value, new_fov_value, 1000.0f, true);
}
