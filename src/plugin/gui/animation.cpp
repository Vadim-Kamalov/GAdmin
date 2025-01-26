#include "plugin/gui/animation.h"

float
plugin::gui::animation::bring_to(float from, float to, std::chrono::steady_clock::time_point start_time,
                                 std::chrono::milliseconds duration) noexcept
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);
        return from + (count * (to - from) / 100);
    }

    return (timer > duration.count()) ? to : from;
}

ImVec4
plugin::gui::animation::bring_to(const ImVec4& from, const ImVec4& to, std::chrono::steady_clock::time_point start_time,
                                 std::chrono::milliseconds duration) noexcept
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);
        return {
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        };
    }

    return (timer > duration.count()) ? to : from;
}

ImVec4
plugin::gui::animation::get_contrast_color(const ImVec4& background, const ImVec4& a, const ImVec4& b) noexcept {
    return ((1 - (0.299 * background.x + 0.587 * background.y + 0.114 * background.z)) < 0.5) ? a : b;
}
