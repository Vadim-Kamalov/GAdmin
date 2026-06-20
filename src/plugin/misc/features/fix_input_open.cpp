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
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/misc/features/fix_input_open.h"
#include "plugin/game/game.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/utils.h"
#include "plugin/plugin.h"

auto plugin::misc::features::fix_input_open::on_event(unsigned int message,
                                                      WPARAM wparam, LPARAM)
    -> bool
{
    static bool skip_first_wm_char = false;

    if (game::is_menu_opened() || !(*configuration)["misc"]["fix_input_open"])
        return true;

    if (message == WM_KEYDOWN && wparam == 'T' && !samp::utils::is_inputs_active()) {
        samp::input::open();
        skip_first_wm_char = true;
        return false;
    }

    /// Fixes the issue of sending WM_CHAR to the SA:MP input handler when
    /// the input is open (see above) with just one flag and one check.
    ///
    /// Can be done in a different way, but this way is just too simple.
    if (skip_first_wm_char && message == WM_CHAR) {
        skip_first_wm_char = false;
        return false;
    }

    return true;
}
