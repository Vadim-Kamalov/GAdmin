#ifndef GADMIN_PLUGIN_GUI_FONTS_H
#define GADMIN_PLUGIN_GUI_FONTS_H

#include "plugin/gui/icon.h"
#include "plugin/types/simple.h"
#include <imgui.h>
#include <memory>
#include <thread>
#include <vector>
#include <unordered_map>

#define CREATE_FONT(NAME, FILENAME, GLYPHS, ...)                                                    \
    class NAME final : public basic_font {                                                          \
    private:                                                                                        \
        std::unordered_map<float, ImFont*> fonts;                                                   \
    public:                                                                                         \
        static constexpr types::zstring_t filename = FILENAME;                                      \
                                                                                                    \
        inline auto get_filename() const -> types::zstring_t override { return filename; }          \
        inline auto get_sizes() const -> std::vector<float> override { return { __VA_ARGS__ }; }    \
        auto get_fonts() const -> std::unordered_map<float, ImFont*> override { return fonts; }     \
                                                                                                    \
        explicit NAME() : fonts(create(GLYPHS)) {}                                                  \
    }

#define CREATE_SIMPLE_FONT(NAME, FILENAME, ...) \
    CREATE_FONT(NAME, FILENAME, ImGui::GetIO().Fonts->GetGlyphRangesCyrillic(), __VA_ARGS__)

#define CREATE_RANGED_FONT(NAME, FILENAME, RANGE_MIN, RANGE_MAX, ...)               \
    static constexpr const ImWchar ranges_##NAME[] = { RANGE_MIN, RANGE_MAX, 0 };   \
    CREATE_FONT(NAME, FILENAME, ranges_##NAME, __VA_ARGS__)

namespace plugin::gui {

class basic_font {
protected:
    std::unordered_map<float, ImFont*> create(const ImWchar* glyphs) const;
public:
    virtual ~basic_font() = default;
    virtual inline auto get_filename() const -> types::zstring_t = 0;
    virtual inline auto get_sizes() const -> std::vector<float> = 0;
    virtual auto get_fonts() const -> std::unordered_map<float, ImFont*> = 0;

    auto push(std::size_t size) const -> void;
    auto operator[](std::size_t size) const -> ImFont*;
    auto text(std::size_t size, types::zstring_t text) const -> void;
}; // class basic_font

namespace fonts {

CREATE_SIMPLE_FONT(light, "notosans-light.ttf", 18, 24);
CREATE_SIMPLE_FONT(regular, "notosans-regular.ttf", 10, 12, 15, 16, 18, 24);
CREATE_SIMPLE_FONT(bold, "notosans-bold.ttf", 10, 14, 15, 16, 18, 20, 24);
CREATE_RANGED_FONT(icon, "coolicons.ttf", ICON_MIN, ICON_MAX, 24);

} // namespace fonts

using font_ptr_t = std::unique_ptr<basic_font>;

class fonts_initializer final {
private:
    bool fonts_available = false;
    std::jthread downloader_thread;
public:
    font_ptr_t light;
    font_ptr_t regular;
    font_ptr_t bold;
    font_ptr_t icon;

    inline auto is_available() const -> bool;
    auto initialize() -> void;

    explicit fonts_initializer();
    ~fonts_initializer() noexcept;
}; // class fonts_initializer final

} // namespace plugin::gui

inline auto plugin::gui::fonts_initializer::is_available() const -> bool {
    return fonts_available;
}

#endif // GADMIN_PLUGIN_GUI_FONTS_H
