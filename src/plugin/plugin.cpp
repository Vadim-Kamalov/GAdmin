#include "plugin/plugin.h"
#include "plugin/gui/notify.h"
#include "plugin/samp/core/net_game.h"
#include "plugin/samp/samp.h"
#include "plugin/server/admins.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include <cstring>
#include <errhandlingapi.h>
#include <imgui.h>
#include <format>
#include <minwindef.h>
#include <windows.h>
#include <psapi.h>

using namespace std::chrono_literals;

void
plugin::plugin_initializer::on_log_message(const log::type& type, const std::string_view& message) {
    std::lock_guard<std::mutex> lock(log_mutex);
    log_file_stream << message << std::endl;

    if (type == log::type::fatal)
        unload();
}

bool
plugin::plugin_initializer::on_event(const samp::event_type& type, std::uint8_t id, samp::bit_stream* stream) {
    if (!server::admins::on_event(type, id, stream))
        return false;
    
    if (gui && !gui->on_event(type, id, stream))
        return false;
    
    stream->reset_read_pointer();

    if (!server::user::on_event(type, id, stream))
        return false;

    stream->reset_read_pointer();

    if (!server::spectator::on_event(type, id, stream))
        return false;

    stream->reset_read_pointer();

    return true;
}

bool
plugin::plugin_initializer::can_initialize_render() const {
    return gui->can_initialize_render();
}

void
plugin::plugin_initializer::on_render_initialize() {
    log::info("render initialized");
    gui->on_initialize();
}

void
plugin::plugin_initializer::on_frame() {
    gui->render();
}

bool
plugin::plugin_initializer::on_message(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (gui && !gui->on_event(message, wparam, lparam))
        return false;
    
    return true;
}

void
plugin::plugin_initializer::on_samp_initialize() {
    using namespace plugin::gui;

    log::info("samp::net_game::instance() != nullptr: SA:MP {} initialized", samp::get_version());

    if (strcmp(samp::net_game::get_host_address(), SERVER_HOST_ADDRESS) != 0) {
        log::fatal("plugin works only on \"sa.gambit-rp.ru:7777\" server");
        return;
    }

    if (!gui) {
        log::fatal("failed to initialize gui->on_samp_initialize(): gui == nullptr");
        return;
    }

    gui->on_samp_initialize();

    notify::send(notification("GAdmin v" PROJECT_VERSION " успешно запущен!",
                              "Плагин инициализирован и готов для использования.",
                              ICON_INFO));
}

void
plugin::plugin_initializer::main_loop() {
    static bool samp_initialized = false;
    
    event_handler->initialize();
    configuration->save(5min);
    
    server::user::main_loop();
    server::spectator::main_loop();

    if (samp::get_base() && samp::net_game::instance() && !samp_initialized) {
        on_samp_initialize();
        samp_initialized = true;
    }
}

void
plugin::plugin_initializer::initialize_logging() {
    using namespace std::placeholders;

    std::filesystem::path log_file = std::filesystem::current_path() / "gadmin.log";

    std::ofstream(log_file, std::ios::trunc).close();
    log_file_stream.open(log_file, std::ios::app);
    log::set_handler(std::bind(&plugin_initializer::on_log_message, this, _1, _2));
}

void
plugin::plugin_initializer::initialize_event_handler() {
    using namespace std::placeholders;
    
    event_handler = std::make_unique<samp::event_handler>();
    event_handler->attach(std::bind(&plugin_initializer::on_event, this, _1, _2, _3));

    log::info("plugin::samp::event_handler initialized");
}

void
plugin::plugin_initializer::create_and_initialize_files() {
    try {
        std::filesystem::path current_path = std::filesystem::current_path();
        
        std::filesystem::create_directories(current_path / "gadmin" / "resources");
        std::filesystem::create_directory(current_path / "gadmin" / "configuration");
        
        configuration = std::make_unique<configuration_initializer>(current_path / "gadmin" / "configuration" / "main.mpk");
    } catch (const std::exception& e) {
        log::fatal("failed to create and initialize files: {}", e.what());
    }
}

long __stdcall
plugin::plugin_initializer::on_unhandled_exception(EXCEPTION_POINTERS* exception_info) noexcept {
    DWORD code_exception = exception_info->ExceptionRecord->ExceptionCode;
    PVOID address_exception = exception_info->ExceptionRecord->ExceptionAddress;

    std::string module_name = "unknown module";
    std::uintptr_t module_offset = 0;
    {
        MEMORY_BASIC_INFORMATION mbi;
        if (VirtualQuery(address_exception, &mbi, sizeof(mbi))) {
            char name[MAX_PATH];
            if (GetModuleFileNameA(reinterpret_cast<HMODULE>(mbi.AllocationBase), name, sizeof(name))) {
                module_name = name;
                module_offset = reinterpret_cast<std::uintptr_t>(mbi.AllocationBase);
            }
        }
    }

    log::error("unhandled exception (code: 0x{:08X}) occured at 0x{:08X} (in {} + 0x{:X})",
               code_exception,
               reinterpret_cast<std::uintptr_t>(address_exception),
               module_name,
               reinterpret_cast<std::uintptr_t>(address_exception) - module_offset);
    
    log::error("registers:");
    {
        CONTEXT* context = exception_info->ContextRecord;
        log::error("| eax: 0x{:08X} ebx: 0x{:08X} ecx: 0x{:08X}", context->Eax, context->Ebx, context->Ecx);
        log::error("| edx: 0x{:08X} esi: 0x{:08X} edi: 0x{:08X}", context->Edx, context->Esi, context->Edi);
        log::error("| esp: 0x{:08X} ebp: 0x{:08X} eip: 0x{:08X}", context->Esp, context->Ebp, context->Eip);
        log::error("| eflags: 0x{:08X}", context->EFlags);
    }
    log::error("loaded modules:");

    MODULEINFO module_info;
    HMODULE modules[1024];
    DWORD needed;

    if (EnumProcessModules(GetCurrentProcess(), modules, sizeof(modules), &needed)) {
        for (unsigned int i = 0; i < (needed / sizeof(HMODULE)); i++) {
            char name[MAX_PATH];
            if (GetModuleInformation(GetCurrentProcess(), modules[i], &module_info, sizeof(MODULEINFO))) {
                GetModuleFileNameEx(GetCurrentProcess(), modules[i], name, sizeof(name));
                log::error("| base: 0x{:08X} size: 0x{:08X} entrypoint: 0x{:08X} name: {}",
                           reinterpret_cast<std::uintptr_t>(module_info.lpBaseOfDll),
                           module_info.SizeOfImage,
                           reinterpret_cast<unsigned long>(module_info.EntryPoint),
                           name);
            }
        }
    }

    log::error("plugin and process are terminated (FATAL)");

    return EXCEPTION_EXECUTE_HANDLER;
}

plugin::plugin_initializer::plugin_initializer() {
    initialize_logging();

    log::info("GAdmin v" PROJECT_VERSION " loaded. Copyright (C) 2023-2025 The Contributors");
    log::info("samp.dll base address: 0x{:X}", samp::get_base());

    create_and_initialize_files();
    initialize_event_handler();
    
    SetUnhandledExceptionFilter(on_unhandled_exception);

    gui = std::make_unique<gui_initializer>();
}

plugin::plugin_initializer::~plugin_initializer() noexcept {
    log::info("plugin terminated");

    event_handler.reset(nullptr);
    configuration.reset(nullptr);
    gui.reset(nullptr);

    if (log_file_stream.is_open())
        log_file_stream.close();
}
