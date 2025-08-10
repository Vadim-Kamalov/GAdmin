#include "plugin/gui/windows/notes.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/game/game.h"
#include "plugin/plugin.h"
#include <ranges>

auto plugin::gui::windows::notes::get_note_information(const note_t& note) const -> note_information_t {
    float title_width = bold_font->CalcTextSizeA(note.title_size, FLT_MAX, 0.0f, note.title.c_str()).x
        + text_border_size * 2;

    float text_width = regular_font->CalcTextSizeA(note.text_size, FLT_MAX, 0.0f, note.text.c_str()).x
        + text_border_size * 2;

    note_information_t information = { title_width };

    if (information.width < text_width)
        information.width = text_width;

    information.width += ImGui::GetStyle().WindowPadding.x * 2;
    information.title_aligner = widgets::aligner(note.align_mode, title_width);
    information.align_mode = note.align_mode;

    return information;
}

auto plugin::gui::windows::notes::render_note(const note_t& note, const std::string& id) const -> void {
    if (!note.visible)
        return;

    note_information_t note_information = get_note_information(note);
    auto flags = ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoBackground;
    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImGui::SetNextWindowSize({ note_information.width, 0.0f });
    ImGui::SetNextWindowPos({ size_x / 2.0f, size_y / 2.0f }, ImGuiCond_FirstUseEver, { 0.5f, 0.5f });
    ImGui::Begin(id.c_str(), nullptr, flags);
    {
        note_information.title_aligner.align_next_item();
        widgets::text(bold_font, note.title_size, text_border_size, "{}", note.title);
        
        std::stringstream stream(note.text);
        
        for (std::string line; std::getline(stream, line);) {
            float line_width = regular_font->CalcTextSizeA(note.text_size, FLT_MAX, 0.0f, line.c_str()).x
                + text_border_size * 2;
        
            widgets::aligner(note_information.align_mode, line_width).align_next_item();
            widgets::text(regular_font, note.text_size, text_border_size, "{}", line);
        }
    }
    ImGui::End();
}

auto plugin::gui::windows::notes::render() -> void {
    auto& notes = (*configuration)["internal"]["notes"];

    for (const auto& [ index, note ] : notes | std::views::enumerate)
        render_note(note, "note-id:" + std::to_string(index));
}

auto plugin::gui::windows::notes::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<notes>(child);
}
