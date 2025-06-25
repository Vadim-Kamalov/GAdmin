#ifndef GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H
#define GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H

#include "plugin/misc/base/feature.h"
#include "plugin/types/color.h"
#include <nlohmann/json.hpp>

namespace plugin::misc::features {

class information_render final : public feature {
private:
    struct feature_configuration final {
        bool use;
        float font_size;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(feature_configuration, use, font_size);
    }; // struct feature_configuration final

    struct text_object final {
        std::string text;
        types::color color;
        ImFont* font;
    }; // struct text_object final

    bool samp_initialized = false;

    auto render_cars_information(ImDrawList* draw_list, ImFont* bold_font,
                                 ImFont* regular_font, float font_size) const -> void;
public:
    auto on_samp_initialize() -> void override;
    auto render(types::not_null<gui_initializer*> child) -> void override;
}; // class information_render final : public feature

} // namespace plugin::misc::features

#endif // GADMIN_PLUGIN_MISC_FEATURES_INFORMATION_RENDER_H
