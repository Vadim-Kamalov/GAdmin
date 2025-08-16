#ifndef GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H
#define GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H

#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/aligner.h"
#include "plugin/types/not_null.h"
#include <nlohmann/json.hpp>

using namespace std::chrono_literals;

namespace plugin::gui::windows {

class notes final : public window {
public:
    struct note_t final {
        std::string title = "Заметка";
        std::string text = "";
        widgets::aligner::mode_t align_mode = widgets::aligner::mode_t::left;
        float text_size = 18.0f;
        float title_size = 20.0f;
        bool visible = true;

        NLOHMANN_DEFINE_TYPE_INTRUSIVE(note_t, title, text, align_mode, text_size,
                                       title_size, visible);
    }; // struct note_t final
private:
    static constexpr float text_border_size = 1;

    struct note_information_t final {
        float width = 0.0f;
        std::string processed_text;
        widgets::aligner title_aligner;
        widgets::aligner::mode_t align_mode;
    }; // struct note_information_t final

    ImFont* bold_font = nullptr;
    ImFont* regular_font = nullptr;

    auto get_note_information(const note_t& note) const -> note_information_t;
    auto render_note(const note_t& note, const std::string& id) const -> void;
public:
    inline auto get_id() const -> types::zstring_t override;
    static auto create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t;

    auto render() -> void override;

    explicit notes(types::not_null<gui_initializer*> child)
        : window(child, get_id()),
          bold_font(child->fonts->bold),
          regular_font(child->fonts->regular) {}
}; // class notes final : public window

} // namespace plugin::gui::windows

inline auto plugin::gui::windows::notes::get_id() const -> types::zstring_t {
    return "windows::notes";
}

#endif // GADMIN_PLUGIN_GUI_WINDOWS_NOTES_H
