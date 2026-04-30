/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#ifndef GADMIN_PLUGIN_LOADER_H
#define GADMIN_PLUGIN_LOADER_H

#include "plugin/types/signatures.h"
#include "plugin/plugin.h"
#include "plugin/log.h"
#include <d3d9.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wreorder"
#include <kthook/kthook.hpp>
#pragma GCC diagnostic pop

namespace plugin {
namespace signatures {

using d3d9_present_t = types::signatures::stdcall_t<HRESULT, IDirect3DDevice9*,
                                                    const RECT*, const RECT*,
                                                    HWND, const RGNDATA*>;

using d3d9_reset_t = types::signatures::stdcall_t<HRESULT, IDirect3DDevice9*,
                                                  D3DPRESENT_PARAMETERS*>;

using wnd_proc_t = types::signatures::stdcall_t<LRESULT, HWND, UINT, WPARAM,
                                                LPARAM>;

using game_loop_t = types::signatures::cdecl_t<void>;

} // namespace signatures

/// Entry point of the plugin.
class loader final {
private:
    std::unique_ptr<plugin_initializer> core;
    plugin::log_handler log_handler;

    bool first_game_loop_call : 1 = true;
    bool initialized_imgui_render : 1 = false;

    kthook::kthook_simple<signatures::game_loop_t> game_loop_hook;
    kthook::kthook_simple<signatures::wnd_proc_t> wndproc_hook;
    kthook::kthook_signal<signatures::d3d9_present_t> d3d9_present_hook;
    kthook::kthook_signal<signatures::d3d9_reset_t> d3d9_reset_hook;

    static auto ensure_hook_installed(const std::string_view& name, bool result) -> bool;

    auto install_d3d9_hooks() -> void;
    auto initialize_imgui_render(IDirect3DDevice9* device) -> void;
    auto game_loop_hooked(const decltype(game_loop_hook)& hook) -> void;

    auto wndproc_hooked(const decltype(wndproc_hook)& hook, HWND hwnd,
                        UINT message, WPARAM wparam, LPARAM lparam) -> LRESULT;

    auto d3d9_present_hooked(const decltype(d3d9_present_hook)&,
                             IDirect3DDevice9* device, const RECT*,
                             const RECT*, HWND, const RGNDATA*)
        -> std::optional<HRESULT>;

    static auto d3d9_reset_hooked(const decltype(d3d9_reset_hook)&,
                           IDirect3DDevice9*, D3DPRESENT_PARAMETERS*)
        noexcept -> std::optional<HRESULT>;
public:
    explicit loader();
    ~loader() noexcept;
}; // class loader final

} // namespace loader

#endif // GADMIN_PLUGIN_LOADER_H
