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

#ifndef GADMIN_PLUGIN_TYPES_SIGNATURES_H
#define GADMIN_PLUGIN_TYPES_SIGNATURES_H

namespace plugin::types::signatures {

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"

/// Function pointer type alias for the `__thiscall` calling convention.
///
/// This type is necessary because GCC emits an error when the `__thiscall`
/// calling convention is used directly in code (`error: 'thiscall' attribute
/// is used for non-class method [-Werror=attributes]`). By wrapping the type
/// in a pragma that ignores `-Wattributes`, we avoid repeating the pragma
/// elsewhere in the codebase.
///
/// @tparam Ret  Return type of the function.
/// @tparam Args Argument types of the function.
template<typename Ret, typename... Args>
using thiscall_t = Ret(__thiscall*)(Args...);

/// Function pointer type alias for the `__stdcall` calling convention.
///
/// Unlike `thiscall_t`, the `__stdcall` calling convention can be used directly
/// in the codebase without triggering GCC warnings. However, this type is
/// retained to maintain consistency in codestyle.
///
/// @see         plugin::types::signatures::thiscall_t
/// @tparam Ret  Return type of the function.
/// @tparam Args Argument types of the function.
template<typename Ret, typename... Args>
using stdcall_t = Ret(__stdcall*)(Args...);

/// Function pointer type alias for the `__cdecl` calling convention.
///
/// Unlike `thiscall_t`, the `__cdecl` calling convention can be used directly
/// in the codebase without triggering GCC warnings. However, this type is
/// retained to maintain consistency in codestyle.
///
/// @see         plugin::types::signatures::thiscall_t
/// @tparam Ret  Return type of the function.
/// @tparam Args Argument types of the function.
template<typename Ret, typename... Args>
using cdecl_t = Ret(__cdecl*)(Args...);

#pragma GCC diagnostic pop

} // namespace plugin::types::signatures

#endif // GADMIN_PLUGIN_TYPES_SIGNATURES_H
