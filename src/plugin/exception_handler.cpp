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

#include "plugin/exception_handler.h"
#include "plugin/log.h"
#include <errhandlingapi.h>
#include <exception>
#include <psapi.h>
#include <psdk_inc/_dbg_common.h>

plugin::exception_handler::exception_info_t::exception_info_t(EXCEPTION_POINTERS* exception_pointers) noexcept
    : code(exception_pointers->ExceptionRecord->ExceptionCode),
      address(reinterpret_cast<std::uintptr_t>(exception_pointers->ExceptionRecord->ExceptionAddress))
{
    MEMORY_BASIC_INFORMATION mbi;

    if (!VirtualQuery(reinterpret_cast<void*>(address), &mbi, sizeof(mbi)))
        return;

    char name[MAX_PATH];

    if (!GetModuleFileNameA(reinterpret_cast<HMODULE>(mbi.AllocationBase), name, sizeof(name)))
        return;

    module_offset = reinterpret_cast<std::uintptr_t>(mbi.AllocationBase);
    module_name = name;
}

auto plugin::exception_handler::on_std_exception() noexcept -> void {
    try {
        if (std::exception_ptr eptr = std::current_exception()) {
            std::rethrow_exception(eptr);
        }
    } catch (const std::exception& e) {
        log::fatal_without_unload("plugin terminated by exception_handler::on_std_exception");
        log::fatal_without_unload("| reason (std::exception::what): {}", e.what());
    } catch (...) {
        log::fatal_without_unload("plugin terminated by exception_handler::on_std_exception");
        log::fatal_without_unload("| reason: unknown exception caught");
    }
}

auto plugin::exception_handler::log_registers(EXCEPTION_POINTERS* exception_pointers) noexcept -> void {
    CONTEXT* context = exception_pointers->ContextRecord;

    log::fatal_without_unload("| registers:");
    log::fatal_without_unload("| > eax: 0x{:08X} ebx: 0x{:08X} ecx: 0x{:08X}", context->Eax, context->Ebx, context->Ecx);
    log::fatal_without_unload("| > edx: 0x{:08X} esi: 0x{:08X} edi: 0x{:08X}", context->Edx, context->Esi, context->Edi);
    log::fatal_without_unload("| > esp: 0x{:08X} ebp: 0x{:08X} eip: 0x{:08X}", context->Esp, context->Ebp, context->Eip);
    log::fatal_without_unload("| > eflags: 0x{:08X}", context->EFlags);
}

auto plugin::exception_handler::create_stack_frame(EXCEPTION_POINTERS* exception_pointers) noexcept -> STACKFRAME64 {
    STACKFRAME64 stack_frame;

    stack_frame.AddrPC.Offset = exception_pointers->ContextRecord->Eip;
    stack_frame.AddrPC.Mode = AddrModeFlat;
    stack_frame.AddrFrame.Offset = exception_pointers->ContextRecord->Ebp;
    stack_frame.AddrFrame.Mode = AddrModeFlat;
    stack_frame.AddrStack.Offset = exception_pointers->ContextRecord->Esp;
    stack_frame.AddrStack.Mode = AddrModeFlat;

    return stack_frame;
}

auto plugin::exception_handler::log_call_stack(HANDLE process, EXCEPTION_POINTERS* exception_pointers) noexcept -> void {
    auto stack_frame = create_stack_frame(exception_pointers);

    log::fatal_without_unload("| call stack:");

    for (unsigned int frame = 0; ; frame++) {
        if (!StackWalk64(IMAGE_FILE_MACHINE_I386, process, GetCurrentThread(), &stack_frame, exception_pointers->ContextRecord,
                         nullptr, SymFunctionTableAccess64, SymGetModuleBase64, nullptr) || stack_frame.AddrPC.Offset == 0)
        {
            break;
        }

        DWORD64 address = stack_frame.AddrPC.Offset;
        std::string output = std::format("| > 0x{:08X}", static_cast<std::uintptr_t>(address));

        MODULEINFO module_info;
        HMODULE module_handle = nullptr;

        if (!GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                                reinterpret_cast<LPCSTR>(address), &module_handle))
        {
            log::fatal_without_unload("{}", output);
            continue;
        }

        char module_name[MAX_PATH];

        GetModuleInformation(process, module_handle, &module_info, sizeof(module_info));
        GetModuleFileNameA(module_handle, module_name, sizeof(module_name));

        log::fatal_without_unload("{} ({} + 0x{:X})", output, module_name,
                                  address - reinterpret_cast<std::uintptr_t>(module_info.lpBaseOfDll));
    }

    SymCleanup(process);
}

auto plugin::exception_handler::log_loaded_modules(HANDLE process) noexcept -> void {
    HMODULE modules[1024];
    DWORD needed;

    log::fatal_without_unload("| loaded modules:");

    if (!EnumProcessModules(process, modules, sizeof(modules), &needed))
        return;

    for (unsigned int i = 1; i < (needed / sizeof(HMODULE)); i++) {
        char name[MAX_PATH];
        MODULEINFO module_info;

        if (!GetModuleInformation(process, modules[i], &module_info, sizeof(MODULEINFO)))
            continue;

        GetModuleFileNameEx(process, modules[i], name, sizeof(name));
        log::fatal_without_unload("| > base: 0x{:08X} size: 0x{:08X} entrypoint: 0x{:08X} name: {}",
                                  reinterpret_cast<std::uintptr_t>(module_info.lpBaseOfDll),
                                  module_info.SizeOfImage,
                                  reinterpret_cast<unsigned long>(module_info.EntryPoint),
                                  name);
    }
}

auto __stdcall plugin::exception_handler::on_win32_exception(EXCEPTION_POINTERS* exception_pointers)
    noexcept -> long
{
    HANDLE process = GetCurrentProcess();
    exception_info_t exception(exception_pointers);

    log::fatal_without_unload("plugin terminated by exception_handler::on_win32_exception");
    log::fatal_without_unload("| module name: {}", exception.module_name);
    log::fatal_without_unload("| address: 0x{:08X} ({} + 0x{:X})", exception.address, exception.module_name,
                                                                   exception.module_offset);
    log::fatal_without_unload("| code: 0x{:08X}", exception.code);

    log_registers(exception_pointers);
    log_call_stack(process, exception_pointers);
    log_loaded_modules(process);

    return EXCEPTION_EXECUTE_HANDLER;
}

auto plugin::exception_handler::initialize() -> void {
    log::info("plugin::exception_handler initialized");
    std::set_terminate(on_std_exception);
    SetUnhandledExceptionFilter(on_win32_exception);
}
