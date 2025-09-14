#ifndef GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGIN_H
#define GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGIN_H

#include "plugin/misc/base/feature.h"

namespace plugin::misc::features {

class auto_alogin final : public feature {
private:
    bool done = false;
public:
    auto on_event(const samp::event_info& event) -> bool override;
}; // class auto_alogin final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_AUTO_ALOGIN_H
