#ifndef GADMIN_PLUGIN_MISC_FEATURES_FIXES_H
#define GADMIN_PLUGIN_MISC_FEATURES_FIXES_H

#include "plugin/misc/base/feature.h"

namespace plugin::misc::features {

class fixes final : public feature {
public:
    auto on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool override;
}; // class fixes final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_FIXES_H
