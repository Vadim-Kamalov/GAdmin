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

#ifndef GADMIN_PLUGIN_CONFIGURATION_H
#define GADMIN_PLUGIN_CONFIGURATION_H

#include <filesystem>
#include <chrono>
#include <nlohmann/json.hpp>

namespace plugin {

/// Handles plugin configuration file operations. Manages loading,
/// saving, and accessing JSON configuration data. Provides automatic
/// save functionality with configurable delay.
class configuration_initializer final {
private:
    std::filesystem::path configuration_file;
    
    static inline nlohmann::json main_json;
    mutable std::chrono::steady_clock::time_point last_time_saved;

    auto write(const std::filesystem::path& path, const nlohmann::json& json) const -> void;
    auto get(const std::filesystem::path& path) const -> nlohmann::json;
public:
    /// Access configuration value by key.
    ///
    /// @param key[in] Key to access in configuration.
    /// @return        Reference to JSON value associated with key.
    auto operator[](const std::string_view& key) const -> nlohmann::json::reference;

    /// Save configuration to file immediately.
    ///
    /// Writes current configuration state to disk.
    auto save() const -> void;

    /// Save configuration after specified delay.
    ///
    /// @param after[in] Time delay before saving.
    auto save(std::chrono::milliseconds after) const -> void;

    /// Construct configuration initializer. Loads
    /// configuration from specified file path.
    ///
    /// @param configuration_file[in] Path to configuration file.
    explicit configuration_initializer(const std::filesystem::path& configuration_file);
    
    /// Destroy configuration initializer. Ensures
    /// pending changes are saved before destruction.
    ~configuration_initializer() noexcept;
}; // class configuration_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_CONFIGURATION_H
