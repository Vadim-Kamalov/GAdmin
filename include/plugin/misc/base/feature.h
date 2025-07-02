#ifndef GADMIN_PLUGIN_MISC_BASE_FEATURE_H
#define GADMIN_PLUGIN_MISC_BASE_FEATURE_H

#include "plugin/gui/gui.h"
#include "plugin/samp/events/event.h"
#include <memory>

namespace plugin::misc {
    
class feature {
public:
    virtual ~feature() = default;
    virtual auto on_event(const samp::event_info& event) -> bool;
    virtual auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool;
    virtual auto on_alogin_new_state(bool state) -> void;
    virtual auto render(types::not_null<gui_initializer*> child) -> void;
    virtual auto on_samp_initialize() -> void;
    virtual auto main_loop() -> void;
}; // class feature

using feature_ptr_t = std::unique_ptr<feature>;

} // namespace plugin::misc

#endif // GADMIN_PLUGIN_MISC_BASE_FEATURE_H
