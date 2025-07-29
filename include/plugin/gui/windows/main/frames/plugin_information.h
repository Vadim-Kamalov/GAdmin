#ifndef GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLUGIN_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLUGIN_INFORMATION_H

#include "plugin/gui/windows/main/initializer.h"
#include "plugin/gui/windows/main/base/frame.h"
#include "plugin/misc/features/nickname_colors.h"
#include "plugin/types/not_null.h"
#include "plugin/types/simple.h"

namespace plugin::gui::windows::main::frames {

class plugin_information final : public basic_frame {
private:
    static constexpr std::uint8_t nickname_count_per_group = 4;
    static constexpr float nickname_group_spacing_x = 12;
    
    static constexpr types::zstring_t header_text = "GAdmin v" PROJECT_VERSION;
    static constexpr types::zstring_t footer_text = "Copyright (C) " PROJECT_COPYRIGHT_YEARS " The Contributors";

    static constexpr float header_font_size = 24;
    static constexpr float nickname_font_size = 18;
    static constexpr float footer_font_size = 16;

    struct nicknames_information_t final {
        using entry_t = misc::features::nickname_colors::entry_t;

        struct group_t final {
            float offset_from_start_x = 0;
            std::deque<entry_t> entries;
        }; // struct group_t

        float total_width = 0;
        std::deque<group_t> grops;
    }; // struct nicknames_information_t final

    types::not_null<initializer*> child;

    auto get_nicknames_information() const -> nicknames_information_t;
    auto render_centered_text(types::not_null<ImFont*> font, float font_size, types::zstring_t text) const -> void;
public:
    auto render() -> void override;

    explicit plugin_information(types::not_null<initializer*> child)
        : child(child) {}
}; // class plugin_information final

} // namespace plugin::gui::windows::main::frames

#endif // GADMIN_PLUGIN_GUI_WINDOWS_MAIN_FRAMES_PLUGIN_INFORMATION_H
