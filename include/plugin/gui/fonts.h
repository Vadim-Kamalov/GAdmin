#ifndef GADMIN_PLUGIN_GUI_FONTS_H
#define GADMIN_PLUGIN_GUI_FONTS_H

#include <imgui.h>
#include <memory>
#include <thread>
#include <vector>
#include <unordered_map>

#define CREATE_FONT(name, filename, ...)                                                            \
    class name : public Font {                                                                      \
    private:                                                                                        \
        std::unordered_map<float, ImFont*> fonts;                                                   \
    public:                                                                                         \
        constexpr const char* get_filename() const override { return filename; }                    \
        constexpr std::vector<float> get_sizes() const override { return { __VA_ARGS__ }; }         \
        std::unordered_map<float, ImFont*> get_fonts() const override { return fonts; }             \
        explicit name() : fonts(create()) {}                                                        \
    }

namespace plugin::gui {
namespace fonts {
namespace files {

static constexpr const char* light = "notosans-light.ttf";
static constexpr const char* regular = "notosans-regular.ttf";
static constexpr const char* bold = "notosans-bold.ttf";

} // namespace files

class Font {
protected:
    std::unordered_map<float, ImFont*> create() const;
public:
    virtual ~Font() = default;
    virtual constexpr const char* get_filename() const = 0;
    virtual constexpr std::vector<float> get_sizes() const = 0;
    virtual std::unordered_map<float, ImFont*> get_fonts() const = 0;

    void push(std::size_t size) const { ImGui::PushFont((*this)[size]); }
    ImFont* operator[](float size) const { return get_fonts().at(size); }
}; // class Font

CREATE_FONT(Light, files::light, 10);
CREATE_FONT(Regular, files::regular, 10);
CREATE_FONT(Bold, files::bold, 18);

} // namespace fonts

class Fonts {
private:
    bool fonts_available = false;
    std::jthread downloader_thread;
public:
    std::unique_ptr<fonts::Font> light, regular, bold;
    
    constexpr bool available() const { return fonts_available; };
    
    void pop();
    void make();

    explicit Fonts();
    ~Fonts();
}; // class Fonts

} // namespace plugin::gui

#undef CREATE_FONT
#endif // GADMIN_PLUGIN_GUI_FONTS_H
