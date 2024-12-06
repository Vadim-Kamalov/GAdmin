#ifndef GADMIN_PLUGIN_GAME_H
#define GADMIN_PLUGIN_GAME_H

#include <utility>
#include <windef.h>

namespace plugin::game {

static inline HWND
get_window() noexcept {
    return **reinterpret_cast<HWND**>(0xC17054);
}

static inline DWORD
get_device() noexcept {
    return *reinterpret_cast<DWORD*>(0xC97C28);
}

static inline bool
is_menu_opened() noexcept {
    return *reinterpret_cast<bool*>(0xBA67A4);
}

static std::pair<float, float>
get_screen_resolution() noexcept {
    auto x = *reinterpret_cast<int*>(0xC9C040);
    auto y = *reinterpret_cast<int*>(0xC9C044);
    return std::make_pair(static_cast<float>(x), static_cast<float>(y));
}

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_H
