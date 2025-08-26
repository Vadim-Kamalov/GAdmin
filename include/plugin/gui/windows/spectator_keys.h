#ifndef GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
#define GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/widgets/keycap.h"
#include "plugin/gui/gui.h"
#include "plugin/server/spectator.h"
#include "plugin/samp/events/synchronization.h"
#include "plugin/types/simple.h"
#include "plugin/types/not_null.h"
#include <imgui.h>
#include <vector>

namespace plugin::gui::windows {

class spectator_keys final : public window {
private:
    static constexpr float keycap_height = 35;

    template<samp::synchronization_key key>
    static constexpr auto make_keycap(const ImVec2& size = { keycap_height, keycap_height }) noexcept -> widgets::keycap;
    
    static auto get_keycaps(const samp::synchronization_type& type) noexcept -> std::vector<widgets::keycap>;
public:
    inline auto get_id() const -> types::zstring_t override;
    inline auto get_name() const -> types::zstring_t override;

    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;
    auto render() -> void override;

    explicit spectator_keys(types::not_null<gui_initializer*> child)
        : window(child, get_id()) {}
}; // class spectator_keys : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::spectator_keys::get_id() const -> types::zstring_t {
    return "windows::spectator_keys";
}

inline auto plugin::gui::windows::spectator_keys::get_name() const -> types::zstring_t {
    return "Клавиши в /sp";
}

template<plugin::samp::synchronization_key key>
constexpr auto plugin::gui::windows::spectator_keys::make_keycap(const ImVec2& size)
    noexcept -> widgets::keycap
{
    constexpr std::string_view name = samp::synchronization_key_names[std::to_underlying(key)];
    return widgets::keycap(name, size, server::spectator::get_key_state(key));
}

#endif // GADMIN_PLUGIN_GUI_SPECTATOR_KEYS_H
