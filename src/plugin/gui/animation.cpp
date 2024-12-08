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
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100.0f);
        return {
            from.x + (count * (to.x - from.x) / 100.0f),
            from.y + (count * (to.y - from.y) / 100.0f),
            from.z + (count * (to.z - from.z) / 100.0f),
            from.w + (count * (to.w - from.w) / 100.0f)
        };
    }

    return (timer > duration.count()) ? to : from;
}
