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

#ifndef GADMIN_PLUGIN_EXCEPTION_HANDLER_H
#define GADMIN_PLUGIN_EXCEPTION_HANDLER_H

#include <cstdint>
#include <string>
#include <windows.h>
#include <dbghelp.h>

namespace plugin {

/// Handler responsible for catching and loging all exceptions from C++ and Win32.
class exception_handler final {
private:
    struct exception_info_t final {
        std::uintptr_t code = 0;
        std::uintptr_t address = 0;
        std::uintptr_t module_offset = 0;
        std::string module_name = "<unknown module>";

        explicit exception_info_t(EXCEPTION_POINTERS* exception_pointers) noexcept;
    }; // struct exception_info_t final

    static auto on_std_exception() noexcept -> void;
    static auto log_registers(EXCEPTION_POINTERS* exception_pointers) noexcept -> void;
    static auto create_stack_frame(EXCEPTION_POINTERS* exception_pointers) noexcept -> STACKFRAME64;
    static auto log_call_stack(HANDLE process, EXCEPTION_POINTERS* exception_pointers) noexcept -> void;
    static auto log_loaded_modules(HANDLE process) noexcept -> void;
    static auto __stdcall on_win32_exception(EXCEPTION_POINTERS* exception_pointers) noexcept -> long;
public:
    /// Initialize the handler.
    static auto initialize() -> void;
}; // class exception_handler final

} // namespace plugin

#endif // GADMIN_PLUGIN_EXCEPTION_HANDLER_H
