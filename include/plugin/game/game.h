#ifndef GADMIN_PLUGIN_GAME_H
#define GADMIN_PLUGIN_GAME_H

#include <utility>
#include <windef.h>

namespace plugin::game {

static inline HWND get_window() noexcept;
static inline DWORD get_device() noexcept;
static inline bool is_menu_opened() noexcept;
std::pair<float, float> get_screen_resolution() noexcept;

} // namespace plugin::game

inline HWND
plugin::game::get_window() noexcept {
    return **reinterpret_cast<HWND**>(0xC17054);
}

inline DWORD
plugin::game::get_device() noexcept {
    return *reinterpret_cast<DWORD*>(0xC97C28);
}

inline bool
plugin::game::is_menu_opened() noexcept {
    return *reinterpret_cast<bool*>(0xBA67A4);
}

#endif // GADMIN_PLUGIN_GAME_H
