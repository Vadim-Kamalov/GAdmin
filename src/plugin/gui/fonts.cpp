#include "plugin/gui/fonts.h"
#include "plugin/log.h"
#include "plugin/network.h"
#include <filesystem>

std::unordered_map<float, ImFont*>
plugin::gui::fonts::Font::create() const {
    std::unordered_map<float, ImFont*> fonts;

    std::filesystem::path path = std::filesystem::current_path() / "gadmin" / "resources" / get_filename();
    ImFontAtlas* font_atlas = ImGui::GetIO().Fonts;
    const ImWchar* glyphs = font_atlas->GetGlyphRangesCyrillic();

    for (const auto& size : get_sizes())
        fonts.emplace(size, font_atlas->AddFontFromFileTTF(path.string().c_str(), size, nullptr, glyphs));

    return fonts;
}

void
plugin::gui::Fonts::pop() {
    ImGui::PopFont();
}

void
plugin::gui::Fonts::make() {
    light = std::make_unique<fonts::Light>();
    regular = std::make_unique<fonts::Regular>();
    bold = std::make_unique<fonts::Bold>();
}

plugin::gui::Fonts::Fonts() {
    std::filesystem::path resources_directory = std::filesystem::current_path() / "gadmin" / "resources";
    std::vector<std::string> fonts = { fonts::files::light, fonts::files::regular, fonts::files::bold };

    try {
        for (auto it = fonts.begin(); it != fonts.end();) {
            if (std::filesystem::exists(resources_directory / *it)) {
                it = fonts.erase(it);
            } else {
                ++it;
            }
        }

        if (!fonts.empty()) {
            downloader_thread = std::jthread(([this, resources_directory, fonts](std::stop_token stop_token) {
                for (const auto& font : fonts) {
                    if (stop_token.stop_requested()) {
                        log::info("font download cancelled");
                        return;
                    }

                    std::string url = std::format(PROJECT_DATABASE "/resources/{}", font);
                    std::filesystem::path output = resources_directory / font;

                    if (!network::download_file(url, output, stop_token)) {
                        log::fatal("failed to download \"{}\" file when initializing resources", url);
                        return;
                    }
                }
    
                log::info("plugin::gui::Fonts::Fonts() initialized (after downloader_thread)");

                fonts_available = true;
            }));
            
            return;
        }
        
        fonts_available = true;
    } catch (const std::exception& e) {
        log::fatal("failed to initialize fonts: {}", e.what());
    }

    log::info("plugin::gui::Fonts::Fonts() initialized");
}

plugin::gui::Fonts::~Fonts() {
    if (downloader_thread.joinable()) {
        downloader_thread.request_stop();
        downloader_thread.join();
    }
}
