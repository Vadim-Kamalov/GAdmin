#ifndef GADMIN_PLUGIN_GAME_H
#define GADMIN_PLUGIN_GAME_H

#include <windef.h>

namespace plugin::game {

static constexpr HWND
get_window() noexcept {
    return **reinterpret_cast<HWND**>(0xC17054);
}

static constexpr DWORD
get_device() noexcept {
    return *reinterpret_cast<DWORD*>(0xC97C28);
}

} // namespace plugin::game

#endif // GADMIN_PLUGIN_GAME_H
