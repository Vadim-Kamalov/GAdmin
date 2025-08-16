#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP

#include "plugin/gui/widgets/search.h"
#include "plugin/gui/windows/main/widgets/popup.h"
#include "plugin/types/not_null.h"
#include "plugin/server/binder.h"
#include <deque>

namespace plugin::gui::windows::main::widgets {

class binder_variables_popup final {
private:
    static constexpr float title_font_size = 24;
    static constexpr float common_font_size = 18;
    static constexpr ImVec2 scrollable_area_size = { 600, 400 };

    std::string parameter = "";
    std::string* inserter = nullptr;

    std::string id;
    types::not_null<initializer*> child;
    gui::widgets::search search;
    widgets::popup popup;

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_filtered_binder_variables() const -> std::deque<server::binder::variable_t>;
    auto render_variable(const server::binder::variable_t& variable) -> void;
    auto popup_renderer() -> void;
public:
    inline auto render() -> void;
    inline auto open() -> void;
    inline auto set_inserter(std::string* new_inserter) -> void;

    explicit binder_variables_popup(const std::string_view& id, types::not_null<initializer*> child);
}; // class binder_variables_popup final

} // namespace plugin::gui::windows::main::widgets

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::render() -> void {
    popup.render(child);
}

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::open() -> void {
    popup.open();
}

inline auto plugin::gui::windows::main::widgets::binder_variables_popup::set_inserter(std::string* new_inserter)
    -> void
{
    inserter = new_inserter;
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_WIDGETS_BINDER_VARIABLES_POPUP
