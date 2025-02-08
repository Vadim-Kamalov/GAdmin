#ifndef GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
#define GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/widgets/keycap.h"
#include "plugin/server/spectator.h"
#include "plugin/samp/core/synchronization.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"
#include <imgui.h>
#include <vector>

namespace plugin::gui::windows {

class spectator_keys : public window {
private:
    utils::not_null<gui_initializer*> child;

    static constexpr float keycap_height = 35;

    template<samp::synchronization_key key>
    static constexpr widgets::keycap make_keycap(const ImVec2& size = { keycap_height, keycap_height }) noexcept;
    
    static std::vector<widgets::keycap> get_keycaps(const samp::synchronization_type& type) noexcept;
public:
    constexpr utils::zstring_t get_id() const override;

    void render() override;

    static window_ptr_t create(utils::not_null<gui_initializer*> child);
    explicit spectator_keys(utils::not_null<gui_initializer*> child);
}; // class spectator_keys : public window

} // namespace plugin::gui::windows

constexpr plugin::utils::zstring_t
plugin::gui::windows::spectator_keys::get_id() const {
    return "windows::spectator_keys";
}

template<plugin::samp::synchronization_key key>
constexpr plugin::gui::widgets::keycap
plugin::gui::windows::spectator_keys::make_keycap(const ImVec2& size) noexcept {
    const constexpr std::string_view name = samp::synchronization_key_names[std::to_underlying(key)];
    return widgets::keycap(name, size, server::spectator::get_key_state(key));
}

#endif // GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
