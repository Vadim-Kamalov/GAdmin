#ifndef GADMIN_PLUGIN_NETWORK_H
#define GADMIN_PLUGIN_NETWORK_H

#include <stop_token>
#include <string_view>
#include <filesystem>

namespace plugin {

class network {
public:
    static bool download_file(const std::string_view& url, const std::filesystem::path& output,
                              std::stop_token stop_token, bool secured = true) noexcept;
    
    static std::string fetch_file_content(const std::string_view& url, std::stop_token stop_token,
                                          bool secured = true) noexcept;
}; // class network

} // namespace plugin

#endif // GADMIN_PLUGIN_NETWORK_H
