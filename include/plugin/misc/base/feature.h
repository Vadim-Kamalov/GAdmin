#ifndef GADMIN_PLUGIN_MISC_BASE_FEATURE_H
#define GADMIN_PLUGIN_MISC_BASE_FEATURE_H

#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::misc {
    
class feature {
public:
    virtual ~feature() = default;
    virtual bool on_event(const samp::event_info& event);
    virtual void main_loop();
}; // class feature

using feature_ptr_t = std::unique_ptr<feature>;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_BASE_FEATURE_H
