#include "plugin/filesystem.h"
#include <windows.h>

extern "C" IMAGE_DOS_HEADER __ImageBase;

std::filesystem::path
plugin::filesystem::get_path(const std::filesystem::path& name, const std::string_view& extension) noexcept {
    wchar_t filename[MAX_PATH];

	GetModuleFileNameW(reinterpret_cast<HMODULE>(&__ImageBase), filename, MAX_PATH);
    
    std::filesystem::path module_path(filename);
    std::filesystem::path new_name(name);
    std::filesystem::path path = std::filesystem::current_path();

    if (module_path.has_parent_path())
        path = module_path.parent_path();

    if (module_path.has_stem())
        new_name = module_path.stem();
    
    return path / (new_name.string() + std::string(extension));
}
