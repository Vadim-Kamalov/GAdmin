#ifndef GADMIN_PLUGIN_MISC_H
#define GADMIN_PLUGIN_MISC_H

#include "plugin/misc/base/feature.h"
#include <deque>

namespace plugin::misc {

class initializer {
private:
    std::deque<feature_ptr_t> features;
public:
    bool on_event(const samp::event_info& event);

    explicit initializer();
}; // class initializer

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_H
