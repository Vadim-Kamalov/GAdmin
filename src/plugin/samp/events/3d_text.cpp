#include "plugin/samp/events/3d_text.h"
#include "plugin/string_utils.h"

plugin::samp::event<plugin::samp::event_id::create_3d_text>::event(bit_stream* stream) {
    stream->read_into(id, color, pos, draw_distance, test_los,
                      attached_player_id, attached_vehicle_id);
        
    text = string_utils::to_utf8(stream->read_encoded(4096));
}
