/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
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

#ifndef GADMIN_LOADER_LOADER_H
#define GADMIN_LOADER_LOADER_H

#include <filesystem>
#include <minwindef.h>
#include <optional>
#include <nlohmann/json.hpp>
#include <thread>

/// File information extracted from version resources.
struct file_information_t final {
    /// Resource entries to extract from version information.
    static constexpr const char* resource_file_names[2] = {
        "OriginalFilename",  ///< Original filename resource name
        "FileVersion"        ///< File version resource name
    }; // static constexpr const char* resource_file_names[2]

    std::filesystem::path path;         ///< Path to the plugin file.
    std::string original_filename = ""; ///< Original filename extracted from version resources.
    std::string file_version = "";      ///< File version extracted from version resources.
}; // struct file_information_t final

/// Release information stored after successful update.
struct release_information_t final {
    std::string date_created;   ///< Date when release was created.
    std::string old_tag_name;   ///< Previous release tag name.
    std::string tag_name;       ///< Current release tag name.
    std::string name;           ///< Release title.
    std::string body;           ///< Release description/body content.
    std::size_t file_size;      ///< Size of the downloaded file in bytes.
    std::size_t download_count; ///< Total number of downloads for this release.

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(release_information_t, date_created, tag_name,
                                   old_tag_name, name, body, file_size, download_count);
}; // struct release_information_t final

/// Entry point for `gadmin-loader.asi` that:
///
///     1. Locates gadmin.dll using version resources;
///     2. Checks for available updates by comparing versions;
///     3. Prompts user to download updates if available;
///     4. Creates release information file after successful update;
///
/// If no updates are found, then it just loads the plugin.
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
    /// Construct the loader.
    explicit loader_t();

    /// Destroy the loader.
    ~loader_t() noexcept;
}; // class loader_t final

/// Global loader instance created at startup.
static inline loader_t loader;

#endif // GADMIN_LOADER_LOADER_H
