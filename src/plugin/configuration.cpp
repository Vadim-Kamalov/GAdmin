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

#include "plugin/configuration.h"
#include "plugin/types/simple.h"
#include "plugin/log.h"
#include <fstream>

static constexpr std::uint8_t configuration_bytes[] = {

#ifdef USE_EMBEDDED_MESSAGE_PACK
#embed "../../embed/configuration.mpk"
#else
#embed "../../embed/configuration.json"
#endif // USE_EMBEDDED_MESSAGE_PACK

}; // static constexpr std::uint8_t configuration_bytes[]

auto plugin::configuration_initializer::write(const std::filesystem::path& path, const nlohmann::json& json) const -> void {
    if (std::ofstream file = std::ofstream(path, std::ios::out | std::ios::binary)) {
        std::vector<std::uint8_t> bytes = nlohmann::json::to_msgpack(json);
        file.write(reinterpret_cast<types::zstring_t>(bytes.data()), bytes.size());
        return;
    }
    
    log::fatal("failed to write JSON to \"{}\"", path.string());
}

auto plugin::configuration_initializer::get(const std::filesystem::path& path) const -> nlohmann::json {
    std::ifstream file(path, std::ios::binary | std::ios::ate);
    std::ifstream::pos_type pos = file.tellg();

    if (!file) {
        log::fatal("failed to get plugin configuration from \"{}\"", path.string());
        return nullptr;
    }
    
    std::vector<char> bytes(pos);

    file.seekg(0, std::ios::beg);
    file.read(&bytes[0], pos);

    auto file_json = nlohmann::json::from_msgpack(bytes);

    if (file_json.is_null()) {
        log::error("plugin configuration is corrupted in \"{}\"; default configuration is written", path.string());
        write(path, main_json);
        return nullptr;
    }

    return file_json;
}

auto plugin::configuration_initializer::operator[](const std::string_view& key) const -> nlohmann::json::reference {
    return main_json[key];
}

auto plugin::configuration_initializer::save() const -> void {
    write(configuration_file, main_json);
}

auto plugin::configuration_initializer::save(std::chrono::milliseconds after) const -> void {
    auto now = std::chrono::steady_clock::now();
    if (std::chrono::duration_cast<std::chrono::milliseconds>(now - last_time_saved) >= after) {
        last_time_saved = now;
        save();
    }
}

plugin::configuration_initializer::configuration_initializer(const std::filesystem::path& configuration_file)
    : last_time_saved(std::chrono::steady_clock::now()),
      configuration_file(configuration_file)
{
#ifdef USE_EMBEDDED_MESSAGE_PACK
    main_json = nlohmann::json::from_msgpack(configuration_bytes);
#else
    main_json = nlohmann::json::parse(configuration_bytes);
#endif

    if (!std::filesystem::exists(configuration_file)) {
        save();
    } else if (nlohmann::json configuration = get(configuration_file); !configuration.is_null()) {
        main_json.merge_patch(configuration);
    }
    
    log::info("plugin::configuration_initializer initialized");
}

plugin::configuration_initializer::~configuration_initializer() noexcept {
    save();
}
