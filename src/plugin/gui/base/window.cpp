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

#include "plugin/gui/base/window.h"
#include "plugin/log.h"

auto plugin::gui::window::on_event(unsigned int, WPARAM, LPARAM) -> bool {
    return true;
}

auto plugin::gui::window::on_event(const samp::event_info&) -> bool {
    return true;
}

auto plugin::gui::window::stop_render() noexcept -> void {
    log::error("cannot render \"{}\" window", get_id());
    rendering = false;
}

plugin::gui::window::window(types::not_null<gui_initializer*> child, types::zstring_t id) : child(child) {
    log::info("window \"{}\" initialized", id);
}
