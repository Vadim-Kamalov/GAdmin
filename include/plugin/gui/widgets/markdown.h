#ifndef GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H
#define GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H

#include <imgui.h>
#include <imgui_markdown.h>
#include <string>
#include "plugin/types/not_null.h"

namespace plugin::gui::widgets {

class markdown final {
private:
    static inline ImGui::MarkdownConfig markdown_config;
    
    std::string text;
    types::not_null<ImFont*> font;
    
    static auto link_callback(ImGui::MarkdownLinkCallbackData data) noexcept -> void; 
public:
    auto render() const -> void;

    explicit markdown(const std::string_view& text, types::not_null<ImFont*> font = ImGui::GetFont())
        : text(std::move(text)), font(font) {}
}; // class markdown final

} // namespace plugin::gui::widgets

#endif // GADMIN_PLUGIN_GUI_WIDGETS_MARKDOWN_H
