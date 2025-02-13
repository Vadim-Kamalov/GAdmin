#include "plugin/gui/fonts.h"
#include "plugin/log.h"
#include "plugin/network.h"
#include <filesystem>

std::unordered_map<float, ImFont*>
plugin::gui::basic_font::create(const ImWchar* glyphs) const {
    std::unordered_map<float, ImFont*> fonts;

    std::filesystem::path path = std::filesystem::current_path() / "gadmin" / "resources" / get_filename();
    ImFontAtlas* font_atlas = ImGui::GetIO().Fonts;

    for (const auto& size : get_sizes())
        fonts.emplace(size, font_atlas->AddFontFromFileTTF(path.string().c_str(), size, nullptr, glyphs));

    return fonts;
}

void
plugin::gui::basic_font::push(std::size_t size) const {
    ImGui::PushFont((*this)[size]);
}

ImFont*
plugin::gui::basic_font::operator[](std::size_t size) const {
    return get_fonts().at(size);
}

void
plugin::gui::basic_font::text(std::size_t size, types::zstring_t text) const {
    push(size);
    ImGui::TextUnformatted(text);
    ImGui::PopFont();
}

void
plugin::gui::fonts_initializer::initialize() {
    light = std::make_unique<fonts::light>();
    regular = std::make_unique<fonts::regular>();
    bold = std::make_unique<fonts::bold>();
    icon = std::make_unique<fonts::icon>();
}

plugin::gui::fonts_initializer::fonts_initializer() {
    std::filesystem::path resources_directory = std::filesystem::current_path() / "gadmin" / "resources";
    std::vector<std::string> fonts = { fonts::light::filename, fonts::regular::filename,
                                       fonts::bold::filename, fonts::icon::filename };

    try {
        for (auto it = fonts.begin(); it != fonts.end();) {
            if (std::filesystem::exists(resources_directory / *it)) {
                it = fonts.erase(it);
            } else {
                it++;
            }
        }

        if (!fonts.empty()) {
            downloader_thread = std::jthread([this, resources_directory, fonts](std::stop_token stop_token) {
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
    
                log::info("plugin::gui::fonts_initializer initialized (after downloader_thread)");

                fonts_available = true;
            });
            
            return;
        }
        
        fonts_available = true;
    } catch (const std::exception& e) {
        log::fatal("failed to initialize fonts: {}", e.what());
    }

    log::info("plugin::gui::fonts_initializer initialized");
}

plugin::gui::fonts_initializer::~fonts_initializer() noexcept {
    if (downloader_thread.joinable()) {
        downloader_thread.request_stop();
        downloader_thread.join();
    }
}
