#ifndef GADMIN_PLUGIN_SAMP_EVENTS_MENU_H
#define GADMIN_PLUGIN_SAMP_EVENTS_MENU_H

#include "plugin/samp/events/event.h"

namespace plugin::samp {

template<>
struct event<event_id::show_menu> {};

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_EVENTS_MENU_H
