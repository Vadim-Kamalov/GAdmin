#include "plugin/gui/animation.h"
#include "plugin/utils.h"

float
plugin::gui::animation::bring_to(float from, float to,
                                 std::chrono::steady_clock::time_point start_time,
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
plugin::gui::animation::bring_to(const ImVec4& from, const ImVec4& to,
                                 std::chrono::steady_clock::time_point start_time,
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

plugin::utils::color_abgr_t
plugin::gui::animation::bring_to(utils::color_abgr_t from, utils::color_abgr_t to,
                                 std::chrono::steady_clock::time_point start_time,
                                 std::chrono::milliseconds duration) noexcept
{
    auto now = std::chrono::steady_clock::now();
    auto timer = std::chrono::duration_cast<std::chrono::milliseconds>(now - start_time).count();

    if (timer >= 0 && timer <= duration.count()) {
        float count = static_cast<float>(timer) / (static_cast<float>(duration.count()) / 100);

        std::uint8_t from_a = (from >> 24) & 0xFF;
        std::uint8_t from_b = (from >> 16) & 0xFF;
        std::uint8_t from_g = (from >> 8) & 0xFF;
        std::uint8_t from_r = from & 0xFF;

        std::uint8_t to_a = (to >> 24) & 0xFF;
        std::uint8_t to_b = (to >> 16) & 0xFF;
        std::uint8_t to_g = (to >> 8) & 0xFF;
        std::uint8_t to_r = to & 0xFF;

        std::uint8_t a = static_cast<std::uint8_t>(from_a + (count * (to_a - from_a) / 100));
        std::uint8_t b = static_cast<std::uint8_t>(from_b + (count * (to_b - from_b) / 100));
        std::uint8_t g = static_cast<std::uint8_t>(from_g + (count * (to_g - from_g) / 100));
        std::uint8_t r = static_cast<std::uint8_t>(from_r + (count * (to_r - from_r) / 100));

        return (a << 24) | (b << 16) | (g << 8) | r;
    }

    return (timer > duration.count()) ? to : from;
}

ImVec4
plugin::gui::animation::get_contrast_color(const ImVec4& background, const ImVec4& a, const ImVec4& b) noexcept {
    return ((1 - (0.299 * background.x + 0.587 * background.y + 0.114 * background.z)) < 0.5) ? a : b;
}
