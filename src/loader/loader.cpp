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
#include <common/common.h>
#include <filesystem>
#include <minwindef.h>
#include <processthreadsapi.h>
#include <shellapi.h>
#include <windows.h>
#include <winver.h>
#include <errno.h>
#include <ranges>

extern "C" IMAGE_DOS_HEADER __ImageBase;

auto loader_t::load_plugin(const file_information_t& plugin) -> void {
    log::info("loading the plugin {}", plugin.path);
    log::info("passing the log stream to the plugin");
    log_handler.close_file();

    std::wstring path = plugin.path.wstring();
    plugin_handle = LoadLibraryW(path.c_str());
}

auto loader_t::check_updates(const file_information_t& plugin) -> void {
    std::string raw_release_information = common::network::send_get_request(release_information_url);

    if (raw_release_information.empty())
        return;

    nlohmann::json release_information = nlohmann::json::parse(raw_release_information);
    std::string tag_name = release_information["tag_name"];
    
    if (tag_name.substr(1) == plugin.file_version)
        return;

    for (const auto& asset : release_information["assets"]) {
        if (asset["name"] != plugin.original_filename)
            continue;

        std::ofstream update_file(common::get_game_path() / "gadmin" / "available_update.mpk",
                                  std::ios::out | std::ios::binary);

        if (!update_file)
            return;

        std::string date_created = release_information["created_at"];
        std::replace(date_created.begin(), date_created.end(), 'T', ' ');
        date_created.pop_back();

        std::vector<std::uint8_t> bytes = nlohmann::json::to_msgpack(
            nlohmann::json(release_information_t {
                .url = asset["browser_download_url"],
                .date_created = date_created,
                .old_tag_name = std::format("v{}", plugin.file_version),
                .tag_name = tag_name,
                .name = release_information["name"],
                .body = release_information["body"],
                .file_size = asset["size"],
                .download_count = asset["download_count"]
            })
        );

        update_file.write(reinterpret_cast<const char*>(bytes.data()), bytes.size());

        return;
    }
}

auto loader_t::update_plugin(const file_information_t& plugin, const std::string_view download_url) const
    -> bool
{
    try {
        std::string filename = plugin.path.filename().string();
        std::filesystem::path temp_file_path = std::filesystem::temp_directory_path() / filename;

        if (!common::network::download_file(download_url, temp_file_path)) {
            log::error("failed to common::network::download_file [with download_url = \"{}\", temp_file_path = \"{}\"]",
                       download_url, temp_file_path);
            return false;
        }
        
        MessageBoxW(nullptr, L"Обновление успешно установлено!", L"Обновление установлено", MB_ICONINFORMATION);
        std::filesystem::rename(temp_file_path, plugin.path);

        return true;
    } catch (const std::exception& e) {
        log::error("exception occured during loader_t::update_plugin: {}", e.what());
        return false;
    }
}

auto loader_t::try_get_file_information(const std::filesystem::path& path) const
    -> std::optional<file_information_t>
{
    std::wstring filename = path.wstring();
    DWORD dummy, size = GetFileVersionInfoSizeW(filename.c_str(), &dummy);

    if (size == 0)
        return {};

    std::vector<BYTE> data(size);

    if (!GetFileVersionInfoW(filename.c_str(), 0, size, data.data()))
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

// TODO: MessagePack file parsing is duplicated in several places. Extract this into a function in `common`.
auto loader_t::loader_t::try_get_available_update(const std::filesystem::path& path) const
    -> std::optional<release_information_t>
{
    std::ifstream file(path, std::ios::binary | std::ios::ate);

    if (!file) {
        log::error("failed to open {}. Reason: {}", path, std::strerror(errno));
        return {};
    }

    std::ifstream::pos_type pos = file.tellg();
    std::vector<char> bytes(pos);

    file.seekg(0, std::ios::beg);
    file.read(bytes.data(), pos);

    try {
        return nlohmann::json::from_msgpack(bytes);
    } catch (const std::exception& e) {
        log::error("file with the update information is corrupted ({}). deleting...", e.what());
        file.close();

        std::error_code ec;
        std::filesystem::remove(path, ec);
    }

    return {};
}

auto loader_t::loader_t::suggest_update_to_user(const file_information_t& plugin,
                                                const std::filesystem::path& update_file_path)
    -> void
{
    auto update_information = try_get_available_update(update_file_path);

    if (!update_information.has_value()) {
        load_plugin(plugin);
        return;
    }

    if (is_release_information_outdated(plugin, *update_information)) {
        std::error_code ec;

        log::info("update information is outdated. deleting...");
        std::filesystem::remove(update_file_path, ec);
        load_plugin(plugin);

        return;
    }

    log::info("found an update. suggesting it to user...");

    std::wstring wide_tag_name = std::wstring(update_information->tag_name.begin(), update_information->tag_name.end());
    std::wstring message_text = L"Доступна новая версия GAdmin: " + wide_tag_name + L". Желаете установить сейчас?";

    if (MessageBoxW(nullptr, message_text.c_str(), L"Доступно обновление", MB_YESNO | MB_ICONQUESTION) != IDYES) {
        std::error_code ec;
        std::filesystem::remove(update_file_path, ec);
        load_plugin(plugin);
        return;
    }

    if (!update_plugin(plugin, update_information->url)) {
        static constexpr const wchar_t* message_text =
            L"Что-то пошло не так при установке обновления. "
             "Попробуйте установить версию самостоятельно.";

        load_plugin(plugin);
        MessageBoxW(nullptr, message_text, L"Ошибка!", MB_ICONERROR);

        return;
    }

    log::info("succesfuly updated the plugin");

    try {
        std::filesystem::rename(update_file_path, update_file_path.parent_path() / "release_information.mpk");
    } catch (const std::exception& e) {
        log::warn("exception occured during std::filesystem::rename: {}", e.what());
    }

    load_plugin(plugin);
}

auto loader_t::is_release_information_outdated(const file_information_t& plugin,
                                               const release_information_t& information)
    noexcept -> bool
{
    std::string tag_name_with_prefix = "v" + plugin.file_version;
    return tag_name_with_prefix == information.tag_name;
}

loader_t::loader_t() {
    DisableThreadLibraryCalls(reinterpret_cast<HMODULE>(&__ImageBase));

    std::filesystem::path game_path = common::get_game_path();

    try {
        std::filesystem::create_directory(game_path / "gadmin");
    } catch (const std::exception& e) {
        log::fatal_without_unload("exception occured during std::filesystem::create_directory: {}", e.what());
        return;
    }

    log_handler.set_prefix("loader");
    log_handler.load_file(game_path / "gadmin.c.log", true);
    log::info("loader_t::log_handler initialized");

    for (const auto& entry : std::filesystem::directory_iterator(game_path)) {
        if (!entry.is_regular_file())
            continue;

        auto file_information = try_get_file_information(entry);

        if (!file_information.has_value() || file_information->original_filename != ORIGINAL_FILENAME_TO_SEARCH)
            continue;

        std::filesystem::path update_file_path = game_path / "gadmin" / "available_update.mpk";
        std::error_code ec;

        if (std::filesystem::exists(update_file_path, ec)) {
            suggest_update_to_user(*file_information, update_file_path);
            return;
        }

        log::info("file {} not exists. checking updates in a new thread...", update_file_path);
        load_plugin(*file_information);

        thread = std::jthread(std::bind_front(&loader_t::check_updates, this, *file_information));

        return;
    }

    log::fatal_without_unload("failed to locate the plugin");
}

loader_t::~loader_t() noexcept {
    if (plugin_handle == nullptr)
        return;

    FreeLibrary(plugin_handle);
}
