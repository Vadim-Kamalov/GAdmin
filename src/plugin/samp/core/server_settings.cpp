#include "plugin/samp/core/server_settings.h"

auto plugin::samp::server_settings::set_name_tags_render_distance(float distance) const
    -> void
{
    name_tags_render_distance_offset.write(distance, *pointer);
}
    
auto plugin::samp::server_settings::set_name_tags_render_behind_wall(bool state) const
    -> void
{
    name_tags_render_behind_wall_offset.write(state, *pointer);
}
