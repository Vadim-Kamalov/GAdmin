#include "plugin/gui/gui.h"
#include "plugin/gui/windows/main.h"
#include "plugin/memory.h"
#include <windows.h>
#include <imgui.h>

bool
plugin::GraphicalUserInterface::on_event(const samp::EventType& type, std::uint8_t id, samp::BitStream* bit_stream) const {
    for (const auto& window : registered_windows) {
        bit_stream->reset_read_pointer();
        if (!window->on_event(type, id, bit_stream))
            return false;
    }

    return true;
}

bool
plugin::GraphicalUserInterface::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) const {
    for (const auto& window : registered_windows)
        if (!window->on_event(message, wparam, lparam))
            return false;

    return true;
}

void
plugin::GraphicalUserInterface::on_samp_initialize() const {
    for (const auto& window : registered_windows)
        window->on_samp_initialize();
}

void
plugin::GraphicalUserInterface::render() const {
    for (const auto& window : registered_windows)
        window->render();
}

void
plugin::GraphicalUserInterface::enable_cursor() {
	memory::set(0x53F417, 0x90, 5);
	memory::copy(0x53F41F, { 0x33, 0xC0, 0x0F, 0x84 });
	memory::write<byte>(0x6194A0, 0xC3);
	memory::set(0xB73424, 0x0, 8);
	memory::set(0xB7342C, 0x0, 8);
	
    SetCursor(LoadCursor(nullptr, IDC_ARROW));

    cursor_active = true;
}

void
plugin::GraphicalUserInterface::disable_cursor() {
	memory::copy(0x53F417, { 0xE8, 0xB4, 0x7A, 0x20, 0x00 });
	memory::copy(0x53F41F, { 0x85, 0xC0, 0x0F, 0x8C });
	memory::write<byte>(0x6194A0, 0xE9);
	memory::set(0xB73424, 0x0, 8);
	memory::set(0xB7342C, 0x0, 8);

	reinterpret_cast<void(__cdecl*)()>(0x541BD0)();
	reinterpret_cast<void(__cdecl*)()>(0x541DD0)();
	SetCursor(LoadCursor(nullptr, nullptr));

    cursor_active = false;
}

void
plugin::GraphicalUserInterface::switch_cursor() {
    if (cursor_active)
        disable_cursor();
    else
        enable_cursor();
}

plugin::GraphicalUserInterface::GraphicalUserInterface() {
    using namespace gui;

    registered_windows.push_back(windows::main(this));
}
