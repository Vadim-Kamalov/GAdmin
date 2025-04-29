#include "plugin/samp/core/server_settings.h"

void
plugin::samp::server_settings::set_name_tags_render_distance(float distance) const {
    name_tags_render_distance_offset.write(distance, *pointer);
}
    
void
plugin::samp::server_settings::set_name_tags_render_behind_wall(bool state) const {
    name_tags_render_behind_wall_offset.write(state, *pointer);
}
