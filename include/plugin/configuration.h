#ifndef GADMIN_PLUGIN_CONFIGURATION_H
#define GADMIN_PLUGIN_CONFIGURATION_H

#include <filesystem>
#include <chrono>
#include <nlohmann/json.hpp>

namespace plugin {

class configuration_initializer {
private:
    std::filesystem::path configuration_file;
    
    static nlohmann::json main_json;
    mutable std::chrono::steady_clock::time_point last_time_saved;

    void write(const std::filesystem::path& path, const nlohmann::json& json) const;
    nlohmann::json get(const std::filesystem::path& path) const;
public:
    nlohmann::json::reference operator[](const std::string_view& key) const;

    void save() const;
    void save(std::chrono::milliseconds after) const;

    explicit configuration_initializer(const std::filesystem::path& configuration_file);
    ~configuration_initializer() noexcept;
}; // class configuration_initializer

} // namespace plugin

#endif // GADMIN_PLUGIN_CONFIGURATION_H
