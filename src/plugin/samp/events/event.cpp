#include "plugin/samp/events/event.h"
#include <utility>

bool
plugin::samp::event_info::operator==(const event_id& e_id) const {
    return std::to_underlying(e_id) == id;
}

bool
plugin::samp::event_info::operator==(const event_type& e_type) const {
    return e_type == type;
}
