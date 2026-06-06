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

#include "common/common.h"
#include <libloaderapi.h>
#include <mutex>

auto common::get_game_path() noexcept -> std::filesystem::path {
    static std::filesystem::path game_path;
    static std::once_flag flag;

    std::call_once(flag, [] {
        char buffer[MAX_PATH];

        GetModuleFileNameA(nullptr, buffer, MAX_PATH);

        std::filesystem::path module_path(buffer);
        game_path = module_path.parent_path();
    });

    return game_path;
}
