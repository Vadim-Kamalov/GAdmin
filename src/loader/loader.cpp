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

#include "loader/loader.h"
#include <fstream>
#include <functional>
#include <libloaderapi.h>
#include <nlohmann/json.hpp>
#include <common/network.h>
#include <filesystem>
#include <minwindef.h>
#include <processthreadsapi.h>
#include <shellapi.h>
#include <windows.h>
#include <winver.h>
#include <ranges>

extern "C" IMAGE_DOS_HEADER __ImageBase;

auto loader_t::load_plugin(const file_information_t& plugin) -> void {
    plugin_handle = LoadLibraryA(plugin.path.string().c_str());
}

auto loader_t::check_updates(const file_information_t& plugin) -> void {
    std::string raw_release_information = common::network::send_get_request(release_information_url);

    if (raw_release_information.empty()) {
        load_plugin(plugin);
        return;
    }

    nlohmann::json release_information = nlohmann::json::parse(raw_release_information);
    std::string tag_name = release_information["tag_name"];
    
    if (tag_name.substr(1) == plugin.file_version) {
        load_plugin(plugin);
        return;
    }

    for (const auto& asset : release_information["assets"]) {
        if (asset["name"] != plugin.original_filename)
            continue;

        std::wstring wide_tag_name = std::wstring(tag_name.begin(), tag_name.end());
        std::wstring message_text = L"Доступна новая версия GAdmin: " + wide_tag_name + L". Желаете установить сейчас?";

        if (MessageBoxW(nullptr, message_text.c_str(), L"Доступно обновление", MB_YESNO | MB_ICONQUESTION) == IDYES) {
            std::string browser_download_url = asset["browser_download_url"];
            
            if (!update_plugin(plugin, browser_download_url)) {
                static constexpr const wchar_t* message_text =
                    L"Что-то пошло не так при установке обновления. "
                     "Попробуйте установить версию самостоятельно.";

                load_plugin(plugin);
                MessageBoxW(nullptr, message_text, L"Ошибка!", MB_ICONERROR);

                return;
            }

            std::string date_created = release_information["created_at"];
            std::replace(date_created.begin(), date_created.end(), 'T', ' ');
            date_created.pop_back();

            save_release_information(release_information_t {
                .date_created = date_created,
                .old_tag_name = std::format("v{}", plugin.file_version),
                .tag_name = release_information["tag_name"],
                .name = release_information["name"],
                .body = release_information["body"],
                .file_size = asset["size"],
                .download_count = asset["download_count"]
            });
        }

        load_plugin(plugin);

        return;
    }
    
    load_plugin(plugin);
}

auto loader_t::update_plugin(const file_information_t& plugin, const std::string_view& download_url) const
    -> bool
{
    try {
        std::string filename = plugin.path.filename().string();
        std::filesystem::path temp_file_path = std::filesystem::temp_directory_path() / filename;

        if (!common::network::download_file(download_url, temp_file_path))
            return false;
        
        MessageBoxW(nullptr, L"Обновление успешно загружено!", L"Обновление загружено", MB_ICONINFORMATION);

        std::filesystem::rename(temp_file_path, plugin.path);

        return true;
    } catch (const std::exception& e) {
        return false;
    }
}

auto loader_t::save_release_information(const release_information_t& information) const -> void {
    std::filesystem::path current_path = std::filesystem::current_path();

    try {
        std::filesystem::create_directory(current_path / "gadmin");
    } catch (...) {
        return;
    }
    
    std::filesystem::path path = std::filesystem::current_path() / "gadmin" / "release_information.mpk";
    std::ofstream file = std::ofstream(path, std::ios::out | std::ios::binary);

    if (!file)
        return;

    nlohmann::json output = information;
    std::vector<std::uint8_t> bytes = nlohmann::json::to_msgpack(output);
    file.write(reinterpret_cast<const char*>(bytes.data()), bytes.size());
}

auto loader_t::try_get_file_information(const std::filesystem::path& path) const
    -> std::optional<file_information_t>
{
    std::string filename = path.string().c_str();
    DWORD dummy, size = GetFileVersionInfoSizeA(filename.c_str(), &dummy);

    if (size == 0)
        return {};

    std::vector<BYTE> data(size);

    if (!GetFileVersionInfoA(filename.c_str(), 0, size, data.data()))
        return {};

    std::array<std::string, 2> result;

    for (const auto& [ index, information_name ] : file_information_t::resource_file_names
         | std::views::enumerate)
    {
        LPVOID version_info;
        std::size_t length = 0;
        std::string query_path = std::format("\\StringFileInfo\\040904b0\\{}", information_name);
    
        if (!VerQueryValueA(data.data(), query_path.c_str(), &version_info, &length))
            return {};

        result[index] = std::string(static_cast<LPCSTR>(version_info));
    }

    return file_information_t { path, result[0], result[1] };
}

loader_t::loader_t() {
    DisableThreadLibraryCalls(reinterpret_cast<HMODULE>(&__ImageBase));
    for (const auto& entry : std::filesystem::directory_iterator(std::filesystem::current_path())) {
        if (!entry.is_regular_file())
            continue;

        auto file_information = try_get_file_information(entry);

        if (!file_information.has_value() || file_information->original_filename != ORIGINAL_FILENAME_TO_SEARCH)
            continue;

        thread = std::jthread(std::bind_front(&loader_t::check_updates, this, *file_information));
    
        return;
    }
}

loader_t::~loader_t() noexcept {
    if (plugin_handle == nullptr)
        return;

    FreeLibrary(plugin_handle);
}
