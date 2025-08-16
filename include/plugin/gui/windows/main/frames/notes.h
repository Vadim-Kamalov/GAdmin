#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/gui/windows/main/widgets/binder_variables_popup.h"
#include "plugin/gui/windows/main/widgets/submenu.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

namespace plugin::gui::windows::main::frames {

class notes final : public basic_frame {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr float buttons_height = 30;

    types::not_null<initializer*> child;
    widgets::binder_variables_popup popup;
    widgets::submenu submenu = widgets::submenu("Заметки##frames::notes");

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto render_align_setting(nlohmann::json& value) const -> void;
    auto render_editable_title(std::string& frame_label, std::string& value) const -> void;
    auto render_font_setting(const std::string& label, double& value) const -> void;

    auto on_entry_destroyed(std::size_t index) -> void;
    auto frame_renderer(std::string& label, std::any& payload) -> void;
    auto add_callback() -> void;
public:
    auto render() -> void override;

    explicit notes(types::not_null<initializer*> child);
}; // class notes final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_NOTES_H
