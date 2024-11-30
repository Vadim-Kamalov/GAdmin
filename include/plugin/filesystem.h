#ifndef GADMIN_PLUGIN_FILESYSTEM_H
#define GADMIN_PLUGIN_FILESYSTEM_H

#include <filesystem>

namespace plugin::filesystem {

std::filesystem::path get_path(const std::filesystem::path& name, const std::string_view& extension) noexcept;

} // namespace plugin::filesystem

#endif // GADMIN_PLUGIN_FILESYSTEM_H
