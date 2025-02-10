#ifndef GADMIN_PLUGIN_GUI_FONTS_H
#define GADMIN_PLUGIN_GUI_FONTS_H

#include "plugin/gui/icon.h"
#include "plugin/utils.h"
#include <imgui.h>
#include <memory>
#include <thread>
#include <vector>
#include <unordered_map>

#define CREATE_FONT(NAME, FILENAME, GLYPHS, ...)                                                    \
    class NAME : public basic_font {                                                                \
    private:                                                                                        \
        std::unordered_map<float, ImFont*> fonts;                                                   \
    public:                                                                                         \
        static constexpr utils::zstring_t filename = FILENAME;                                      \
                                                                                                    \
        constexpr utils::zstring_t get_filename() const override { return filename; }               \
        constexpr std::vector<float> get_sizes() const override { return { __VA_ARGS__ }; }         \
        std::unordered_map<float, ImFont*> get_fonts() const override { return fonts; }             \
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
    virtual constexpr utils::zstring_t get_filename() const = 0;
    virtual constexpr std::vector<float> get_sizes() const = 0;
    virtual std::unordered_map<float, ImFont*> get_fonts() const = 0;

    void push(std::size_t size) const;
    ImFont* operator[](std::size_t size) const;
    void text(std::size_t size, utils::zstring_t text) const;
}; // class basic_font

namespace fonts {

CREATE_SIMPLE_FONT(light, "notosans-light.ttf", 18, 24);
CREATE_SIMPLE_FONT(regular, "notosans-regular.ttf", 10, 12, 15, 16, 18, 24);
CREATE_SIMPLE_FONT(bold, "notosans-bold.ttf", 15, 16, 18, 20, 24);
CREATE_RANGED_FONT(icon, "icon.ttf", ICON_MIN, ICON_MAX, 24);

} // namespace fonts

using font = std::unique_ptr<basic_font>;

class fonts_initializer {
private:
    bool fonts_available = false;
    std::jthread downloader_thread;
public:
    font light, regular, bold, icon;

    constexpr bool available() const { return fonts_available; };
    void initialize();

    explicit fonts_initializer();
    ~fonts_initializer() noexcept;
}; // class fonts_initializer

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_FONTS_H
