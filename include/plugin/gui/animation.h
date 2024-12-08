#ifndef GADMIN_PLUGIN_GUI_ANIMATION_H
#define GADMIN_PLUGIN_GUI_ANIMATION_H

#include <imgui.h>
#include <unordered_map>
#include <chrono>

namespace plugin::gui {

template<typename T>
class Animation {
private:
    std::unordered_map<ImGuiID, T*> items;
public:
    constexpr T* operator[](ImGuiID id) const { return items.at(id); }
    constexpr T* operator[](const char* id) const { return items.at(ImGui::GetID(id)); }
    constexpr void register_once(const char* id, T item) noexcept { register_once(ImGui::GetID(id), item); }
    constexpr void register_once(ImGuiID id, T item) noexcept {
        if (items.find(id) == items.end())
            items.emplace(id, &item);
    }
}; // class Animation

namespace animation {

float bring_to(float from, float to, std::chrono::steady_clock::time_point start_time, std::chrono::milliseconds duration) noexcept;
ImVec4 bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time, std::chrono::milliseconds duration) noexcept;

constexpr bool
time_available(std::chrono::steady_clock::time_point time) noexcept {
    return time != std::chrono::steady_clock::time_point {};
}

} // namespace animation
} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_ANIMATION_H
