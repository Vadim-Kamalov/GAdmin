#include "plugin/game/cursor.h"
#include "plugin/memory.h"
#include <windows.h>

void
plugin::game::cursor::set_status(bool status) noexcept {
    if (status) {
        memory::set(0x53F417, 0x90, 5);
	    memory::copy(0x53F41F, { 0x33, 0xC0, 0x0F, 0x84 });
	    memory::write<std::uint8_t>(0x6194A0, 0xC3);
    } else {
        memory::copy(0x53F417, { 0xE8, 0xB4, 0x7A, 0x20, 0x00 });
	    memory::copy(0x53F41F, { 0x85, 0xC0, 0x0F, 0x8C });
	    memory::write<std::uint8_t>(0x6194A0, 0xE9);

        reinterpret_cast<signatures::clear_mouse_history_t>(0x541BD0)();
        reinterpret_cast<signatures::update_pads_t>(0x541DD0)();
    }

    SetCursor(LoadCursor(nullptr, (status) ? IDC_ARROW : nullptr));

    memory::set(0xB73424, 0x0, 8);
	memory::set(0xB7342C, 0x0, 8);
}
