#include "plugin/samp/events/event.h"
#include <utility>

auto plugin::samp::event_info::operator==(const event_id& e_id) const -> bool {
    return std::to_underlying(e_id) == id;
}

auto plugin::samp::event_info::operator==(const event_type& e_type) const -> bool {
    return e_type == type;
}
