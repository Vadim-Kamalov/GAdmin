#ifndef GADMIN_PLUGIN_MISC_H
#define GADMIN_PLUGIN_MISC_H

#include "plugin/misc/base/feature.h"
#include <deque>

namespace plugin::misc {

class initializer final {
private:
    std::deque<feature_ptr_t> features;
public:
    auto on_event(const samp::event_info& event) -> bool;
    auto main_loop() -> void;

    explicit initializer();
}; // class initializer final

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_H
