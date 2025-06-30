#ifndef GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H
#define GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H

#include "plugin/misc/base/feature.h"

namespace plugin::misc::features {

class fish_eye final : public feature {
private:
    float spectator_fov = 0;
public:
    auto on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool override;
    auto main_loop() -> void override;
}; // class fish_eye final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_FISH_EYE_H
