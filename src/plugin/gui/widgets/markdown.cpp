#include "plugin/gui/widgets/markdown.h"
#include <windows.h>

auto plugin::gui::widgets::markdown::link_callback(ImGui::MarkdownLinkCallbackData data) noexcept -> void {
    if (data.isImage)
        return;

    std::string url(data.link, data.linkLength);
    ShellExecuteA(nullptr, "open", url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
}

auto plugin::gui::widgets::markdown::render() const -> void {
    markdown_config.linkCallback = link_callback;
    markdown_config.headingFormats[0] = { font, 26, false };
    markdown_config.headingFormats[1] = { font, 22, false };
    markdown_config.headingFormats[2] = { font, 20, false };

    ImGui::Markdown(text.c_str(), text.length(), markdown_config);
}
