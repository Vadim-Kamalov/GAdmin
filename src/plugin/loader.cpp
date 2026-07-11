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

#include "plugin/loader.h"
#include "plugin/game/game.h"
#include "plugin/samp/samp.h"
#include "plugin/samp/core/net_game.h"
#include <common/common.h>
#include <backends/imgui_impl_dx9.h>
#include <backends/imgui_impl_win32.h>
#include <imgui.h>

// This will run `plugin::loader::loader()` and so the rest of the plugin.
static plugin::loader _;

plugin::types::versioned_address_container<std::uintptr_t>
plugin::loader::wndproc_address = { 0x5DB40, 0x60EE0, 0x61650, 0x610C9 };

extern IMGUI_IMPL_API auto ImGui_ImplWin32_WndProcHandler(HWND hwnd, UINT msg, WPARAM wparam,
                                                          LPARAM lparam) -> LRESULT;

extern "C" IMAGE_DOS_HEADER __ImageBase;

auto plugin::loader::ensure_hook_installed(const std::string_view& name, bool result) -> bool {
    if (result) {
        log::info("installed \"{}\" hook", name);
        return true;
    }

    log::fatal("failed to install \"{}\" hook", name);

    return false;
}

auto plugin::loader::install_d3d9_hooks() -> void {
    using namespace std::placeholders;

    void** v_table = *reinterpret_cast<void***>(game::get_device());

    d3d9_present_hook.set_dest(v_table[17]);
    d3d9_present_hook.before.connect(std::bind(&loader::d3d9_present_hooked, this, _1, _2, _3, _4, _5, _6));
    
    if (!ensure_hook_installed("loader::d3d9_present_hook", d3d9_present_hook.install()))
        return;

    d3d9_reset_hook.set_dest(v_table[16]);
    d3d9_reset_hook.before.connect(&d3d9_reset_hooked);
    ensure_hook_installed("loader::d3d9_reset_hook", d3d9_reset_hook.install());
}

auto plugin::loader::try_install_wndproc_hook() -> void {
    using namespace std::placeholders;

    if (installed_wndproc_hook || samp::get_base() == 0 || samp::net_game::instance_container->read() == 0)
        return;

    wndproc_hook.set_dest(**wndproc_address);
    wndproc_hook.set_cb(std::bind(&loader::wndproc_hooked, this, _1, _2, _3, _4, _5));
    ensure_hook_installed("loader::wndproc_hook", wndproc_hook.install());

    installed_wndproc_hook = true;
}

auto plugin::loader::initialize_imgui_render(IDirect3DDevice9* device) -> void {
    ImGui_ImplWin32_EnableDpiAwareness();
    ImGui::CreateContext();
    
    ImGuiStyle& style = ImGui::GetStyle();
    float main_scale = ImGui_ImplWin32_GetDpiScaleForMonitor(MonitorFromPoint({ 0, 0 }, MONITOR_DEFAULTTOPRIMARY));

    style.ScaleAllSizes(main_scale);
    style.FontScaleDpi = main_scale;

    ImGui::GetIO().ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange;

    ImGui_ImplWin32_Init(plugin::game::get_window());
    ImGui_ImplDX9_Init(device);
        
    core->on_render_initialize();

    log::info("initialized ImGui render");
}

auto plugin::loader::game_loop_hooked(const decltype(game_loop_hook)& hook) -> void {
    if (core == nullptr) {
        hook.call_trampoline();
        return;
    }

    core->main_loop();
    try_install_wndproc_hook();

    if (first_game_loop_call) {
        install_d3d9_hooks();
        first_game_loop_call = false;
    }

    hook.call_trampoline();
}

auto plugin::loader::wndproc_hooked(const decltype(wndproc_hook)& hook, HWND hwnd,
                                    UINT message, WPARAM wparam, LPARAM lparam) -> int
{
    if (ImGui_ImplWin32_WndProcHandler(hwnd, message, wparam, lparam)
        || !core->on_message(message, wparam, lparam))
    {
        return true;
    }

    return hook.call_trampoline(hwnd, message, wparam, lparam);
}

auto plugin::loader::d3d9_present_hooked(const decltype(d3d9_present_hook)&, IDirect3DDevice9* device,
                                         const RECT*, const RECT*, HWND, const RGNDATA*)
    -> std::optional<HRESULT>
{
    if (core == nullptr || !core->can_initialize_render())
        return {};

    if (!initialized_imgui_render) {
        initialize_imgui_render(device);
        initialized_imgui_render = true;
    }

    ImGui_ImplDX9_NewFrame();
    ImGui_ImplWin32_NewFrame();

    // `ImGui::GetIO().DisplaySize` is updated every call to `ImGui_ImplWin32_NewFrame`. This sets the value
    // to the current display size, which we do not want, because issues may arise when a user, for example,
    // Alt+Tabs, causing all windows to later move to the top-left corner as the window size becomes much
    // smaller than before. This is primarily a GTA: SA issue, not an ImGui, SA:MP, or plugin problem.
    static auto [ size_x, size_y ] = game::get_screen_resolution();
    ImGui::GetIO().DisplaySize = { size_x, size_y };

    ImGui::NewFrame();
    {
        core->on_frame();
    }
    ImGui::EndFrame();
    ImGui::Render();
    ImGui_ImplDX9_RenderDrawData(ImGui::GetDrawData());

    return {};
}

auto plugin::loader::d3d9_reset_hooked(const decltype(d3d9_reset_hook)&, IDirect3DDevice9*,
                                       D3DPRESENT_PARAMETERS*)
    noexcept -> std::optional<HRESULT>
{
    ImGui_ImplDX9_InvalidateDeviceObjects();
    return {};
}

plugin::loader::loader() {
    using namespace std::placeholders;

    DisableThreadLibraryCalls(reinterpret_cast<HMODULE>(&__ImageBase));

    log_handler.load_file(common::get_game_path() / "gadmin.log");
    log::info("plugin::log_handler initialized");
   
    if (!plugin_initializer::is_connected_to_valid_server()) {
        log::fatal("plugin works only on \"sa.gambit-rp.ru:7777\" server");
        return;
    }

    log::set_unload_callback([this] { core.reset(nullptr); });

    game_loop_hook.set_dest(0x53D030);
    game_loop_hook.set_cb(std::bind(&loader::game_loop_hooked, this, _1));
    ensure_hook_installed("loader::game_loop_hook", game_loop_hook.install());

    core = std::make_unique<plugin_initializer>();
}

plugin::loader::~loader() noexcept {
    ImGui_ImplDX9_Shutdown();
    ImGui_ImplWin32_Shutdown();
    ImGui::DestroyContext();
    log::info("plugin unloaded");
}
