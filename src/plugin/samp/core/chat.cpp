/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#include "plugin/samp/core/chat.h"
#include "plugin/types/address.h"

plugin::types::versioned_address_container<plugin::signatures::add_message_t>
plugin::samp::chat::add_message_container = { 0x645A0, 0x679F0, 0x68170, 0x67BE0 };

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::chat::instance_container = { 0x21A0E4, 0x26E8C8, 0x26EB80, 0x2ACA10 };
