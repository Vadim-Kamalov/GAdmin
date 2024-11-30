#include "plugin/plugin.h"
#include "plugin/signatures.h"
#include "plugin/game/game.h"
#include <kthook/kthook.hpp>
#include <backends/imgui_impl_dx9.h>
#include <backends/imgui_impl_win32.h>
#include <imgui.h>

std::unique_ptr<plugin::Plugin> plugin_to_load;

kthook::kthook_simple<plugin::signatures::GameLoop> game_loop_hook;
static void game_loop_hooked(const decltype(game_loop_hook)& hook);

kthook::kthook_simple<plugin::signatures::WndProc> wndproc_hook;
static LRESULT wndproc_hooked(const decltype(wndproc_hook)& hook, HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam);

kthook::kthook_signal<plugin::signatures::D3D9Present> d3d9_present_hook;
static std::optional<HRESULT> d3d9_present_hooked(const decltype(d3d9_present_hook)&, IDirect3DDevice9* device,
                                                  const RECT*, const RECT*, HWND, const RGNDATA*);

kthook::kthook_signal<plugin::signatures::D3D9Reset> d3d9_reset_hook;
static std::optional<HRESULT> d3d9_reset_hooked(const decltype(d3d9_reset_hook)&, IDirect3DDevice9*, D3DPRESENT_PARAMETERS*);

extern IMGUI_IMPL_API LRESULT ImGui_ImplWin32_WndProcHandler(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam);

class Loader {
public:
    Loader() {
        plugin_to_load = std::make_unique<plugin::Plugin>();

        game_loop_hook.set_dest(0x53BEE0);
        game_loop_hook.set_cb(&game_loop_hooked);
        game_loop_hook.install();

        wndproc_hook.set_dest(0x747EB0);
        wndproc_hook.set_cb(&wndproc_hooked);
        wndproc_hook.install();
    }
} loader;

void
game_loop_hooked(const decltype(game_loop_hook)& hook) {
    static bool initialized = false;

    hook.get_trampoline()();
    plugin_to_load->main_loop();

    if (initialized)
        return;

    void** v_table = *reinterpret_cast<void***>(plugin::game::get_device());

    d3d9_present_hook.set_dest(v_table[17]);
    d3d9_present_hook.before.connect(&d3d9_present_hooked);
    d3d9_present_hook.install();

    d3d9_reset_hook.set_dest(v_table[16]);
    d3d9_reset_hook.before.connect(&d3d9_reset_hooked);
    d3d9_present_hook.install();

    initialized = true;
}

LRESULT
wndproc_hooked(const decltype(wndproc_hook)& hook, HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
    if (!plugin_to_load->on_message(message, wparam, lparam))
        return true;

    if (ImGui_ImplWin32_WndProcHandler(hwnd, message, wparam, lparam))
        return true;

    return hook.call_trampoline(hwnd, message, wparam, lparam);
}

std::optional<HRESULT>
d3d9_present_hooked(const decltype(d3d9_present_hook)&, IDirect3DDevice9* device, const RECT*, const RECT*, HWND, const RGNDATA*) {
    static bool imgui_initialized = false;

    if (!imgui_initialized) {
        ImGui::CreateContext();
        ImGui_ImplWin32_Init(plugin::game::get_window());
        ImGui_ImplDX9_Init(device);

        plugin_to_load->on_render_initialize();

        imgui_initialized = true;
    }

    ImGui_ImplDX9_NewFrame();
    ImGui_ImplWin32_NewFrame();
    ImGui::NewFrame();

    plugin_to_load->on_frame();
    
    ImGui::EndFrame();
    ImGui::Render();
    ImGui_ImplDX9_RenderDrawData(ImGui::GetDrawData());

    return {};
}

std::optional<HRESULT>
d3d9_reset_hooked(const decltype(d3d9_reset_hook)&, IDirect3DDevice9*, D3DPRESENT_PARAMETERS*) {
    ImGui_ImplDX9_InvalidateDeviceObjects();
    return {};
}
