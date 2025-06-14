#ifndef GADMIN_PLUGIN_GUI_FONTS_H
#define GADMIN_PLUGIN_GUI_FONTS_H

#include "plugin/types/simple.h"
#include <filesystem>
#include <queue>
#include <thread>
#include <imgui.h>

namespace plugin::gui {

class fonts_initializer final {
private:
    static constexpr float default_font_size = 16.0f;
    static constexpr std::uint8_t icon_font_index = 3;
    static constexpr types::zstring_t filenames[4] = {
        "notosans-regular.ttf", ///< ImFont* regular;
        "notosans-bold.ttf",    ///< ImFont* bold;
        "notosans-light.ttf",   ///< ImFont* light;
        "coolicons.ttf"         ///< ImFont* icon;
    }; // static constexpr std::string_view filenames[4]
    
    struct missing_font final {
        std::filesystem::path path;
        types::zstring_t filename;
    }; // struct missing_font final
    
    std::queue<missing_font> missing_fonts;
    std::jthread network_thread;

    auto get_missing_fonts() const -> std::queue<missing_font>;
    auto download_missing_fonts() -> void;
public:
    ImFont* regular = nullptr;
    ImFont* bold = nullptr;
    ImFont* light = nullptr;
    ImFont* icon = nullptr;

    auto can_assign_fonts() const -> bool;
    auto assign_fonts() -> void;

    explicit fonts_initializer();
}; // class fonts_initializer final

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_FONTS_H
