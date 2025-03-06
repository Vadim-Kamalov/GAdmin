#include "plugin/samp/player.h"

bool
plugin::samp::player::is_available() const {
    return valid && handle.has_value();
}

plugin::samp::player::operator bool() const {
    return is_available();
}

plugin::samp::player::player(id_t id) {
    
}
