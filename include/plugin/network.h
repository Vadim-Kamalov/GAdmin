#ifndef GADMIN_PLUGIN_NETWORK_H
#define GADMIN_PLUGIN_NETWORK_H

#include <stop_token>
#include <string_view>
#include <filesystem>

namespace plugin::network {

bool download_file(const std::string_view& url, const std::filesystem::path& output, std::stop_token stop_token, bool secured = true);

} // namespace plugin::network

#endif // GADMIN_PLUGIN_NETWORK_H
