#ifndef GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H
#define GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H

#include "plugin/misc/base/feature.h"

namespace plugin::misc::features {

class fish_eye : public feature {
public:
    void main_loop() override;
}; // class fish_eye : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H
