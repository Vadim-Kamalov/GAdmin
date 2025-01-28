#ifndef GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H
#define GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H

#include "imgui.h"
#include "plugin/gui/base/window.h"
#include "plugin/gui/gui.h"
#include "plugin/utils.h"
#include <cstdint>

namespace plugin::gui::windows {

class spectator_information : public window {
private:
    class row {
    public:
        using color_updater_t = std::function<std::uint32_t()>;
        using custom_renderer_t = std::function<void(std::string_view, std::uint32_t)>;
    private:
        std::optional<color_updater_t> updater;
        std::optional<custom_renderer_t> custom_renderer;
    public:
        std::string value = "";
        std::string label = "";
        
        std::uint32_t color = ImGui::ColorConvertFloat4ToU32(ImGui::GetStyle().Colors[ImGuiCol_Text]);
        
        inline bool is_updater_available() const { return updater.has_value(); }
        inline void update_color() { color = (*updater)(); }

        inline bool is_custom_renderer_available() const { return custom_renderer.has_value(); }
        inline void use_custom_renderer() const { (*custom_renderer)(value, color); }

        explicit row(const std::string_view& label, const std::string_view& value, color_updater_t updater)
            : label(std::move(label)), value(std::move(value)), updater(updater) { color = updater(); }

        explicit row(const std::string_view& label, const std::string_view& value)
            : label(std::move(label)), value(value) {}

        explicit row(const std::string_view& label, const std::string_view& value, custom_renderer_t custom_renderer)
            : label(std::move(label)), value(std::move(value)), custom_renderer(custom_renderer) {}
    }; // class row
private:
    utils::not_null<gui_initializer*> child;
    
    void vehicles_custom_renderer(const std::string_view& value, std::uint32_t color) const;
    void vehicle_information_custom_renderer(const std::string_view&, std::uint32_t) const;

    void render_centered_text(const std::string_view& value, ImFont* font, const ImVec4& color = ImGui::GetStyle().Colors[ImGuiCol_Text]) const;
    std::string get_time_spectated() const;

    void nickname_custom_renderer(const std::string_view& value, std::uint32_t color) const;

    std::vector<row> get_rows() const;
public:
    static constexpr float min_wrap_width = 80;

    constexpr const char* get_id() const override { return "windows::spectator_information"; }
    void render() override;

    static window_ptr_t create(utils::not_null<gui_initializer*> child) noexcept;
    explicit spectator_information(utils::not_null<gui_initializer*> child);
}; // class spectator_information : public window

} // namespace plugin::gui::windows

#endif // GADMIN_PLUGIN_GUI_WINDOWS_SPECTATOR_INFORMATION_H
