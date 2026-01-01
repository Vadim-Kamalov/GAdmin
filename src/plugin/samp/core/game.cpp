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

#include "plugin/samp/core/game.h"

plugin::types::versioned_address_container<int, plugin::types::version_container_option::offsets>
plugin::samp::game::cursor_mode_offsets = { 0x55, 0x61, 0x61, 0x61 };

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::game::instance_container = { 0x21A10C, 0x26E96C, 0x26EBAC, 0x2ACA3C };
