#ifndef GADMIN_LOADER_LOADER_H
#define GADMIN_LOADER_LOADER_H

#include <filesystem>
#include <minwindef.h>
#include <optional>
#include <nlohmann/json.hpp>
#include <thread>

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

class loader_t final {
private:
    std::jthread thread;
    HMODULE plugin_handle = nullptr;

    static constexpr const char* release_information_url =
        "https://api.github.com/repos/" UPDATE_REPOSITORY "/releases/latest";
    
    auto load_plugin(const file_information_t& plugin) -> void;
    auto check_updates(const file_information_t& plugin) -> void;
    auto update_plugin(const file_information_t& plugin, const std::string_view& download_url) const -> bool;
    auto save_release_information(const release_information_t& information) const -> void;
    auto try_get_file_information(const std::filesystem::path& path) const -> std::optional<file_information_t>;
public:
    explicit loader_t();
    ~loader_t() noexcept;
}; // class loader_t final

static inline loader_t loader;

#endif // GADMIN_LOADER_LOADER_H
