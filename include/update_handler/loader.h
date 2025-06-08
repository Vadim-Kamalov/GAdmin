#ifndef GADMIN_UDPATE_HANDLER_LOADER_H
#define GADMIN_UDPATE_HANDLER_LOADER_H

#include <filesystem>
#include <optional>
#include <nlohmann/json.hpp>

namespace update_handler {

struct file_information_t final {
    static constexpr const char* resource_file_names[2] = {
        "OriginalFilename",
        "FileVersion"
    }; // static constexpr const char* resource_file_names[2]

    std::filesystem::path path;
    std::string original_filename = "";
    std::string file_version = "";
}; // struct file_information_t

struct release_information_t final {
    std::string date_created;
    std::string old_tag_name;
    std::string tag_name;
    std::string name;
    std::string body;
    std::size_t file_size;
    std::size_t download_count;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(release_information_t, date_created, tag_name,
                                   old_tag_name, name, body, file_size, download_count);
}; // struct release_information_t final

class loader final {
private:
    static constexpr const char* release_information_url =
        "https://api.github.com/repos/" UPDATE_HANDLER_REPOSITORY "/releases/latest";
    
    auto check_updates(const file_information_t& plugin) const -> void;
    auto update_plugin(const file_information_t& plugin, const std::string_view& download_url) const -> bool;
    auto save_release_information(const release_information_t& information) const -> void;
    auto try_get_file_information(const std::filesystem::path& path) const -> std::optional<file_information_t>;
public:
    explicit loader();
}; // class loader final

} // namespace update_handler

static inline update_handler::loader loader;

#endif // GADMIN_UDPATE_HANDLER_LOADER_H
