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

#include "plugin/game/cursor.h"
#include "plugin/memory.h"
#include <windows.h>

auto plugin::game::cursor::set_state(bool state) noexcept -> void {
    if (state) {
        memory::set(0x53F417, 0x90, 5);
	    memory::copy(0x53F41F, { 0x33, 0xC0, 0x0F, 0x84 });
	    memory::write<std::uint8_t>(0x6194A0, 0xC3);
    } else {
        memory::copy(0x53F417, { 0xE8, 0xB4, 0x7A, 0x20, 0x00 });
	    memory::copy(0x53F41F, { 0x85, 0xC0, 0x0F, 0x8C });
	    memory::write<std::uint8_t>(0x6194A0, 0xE9);
    }

    memory::set(0xB73424, 0x0, 8);
	memory::set(0xB7342C, 0x0, 8);

    reinterpret_cast<signatures::clear_mouse_history_t>(0x541BD0)();
    reinterpret_cast<signatures::update_pads_t>(0x541DD0)();

    SetCursor(LoadCursor(nullptr, (state) ? IDC_ARROW : nullptr));
}
