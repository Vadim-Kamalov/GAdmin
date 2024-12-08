#ifndef GADMIN_PLUGIN_CONFIGURATION_H
#define GADMIN_PLUGIN_CONFIGURATION_H

#include <filesystem>
#include <chrono>
#include <nlohmann/json.hpp>

namespace plugin {

class Configuration {
private:
    std::filesystem::path configuration_file;
    mutable std::chrono::steady_clock::time_point last_time_saved;

    static void write(const std::filesystem::path& path, const nlohmann::json& json);
    static nlohmann::json get(const std::filesystem::path& path);
public:
    static constexpr nlohmann::json::reference operator[](const std::string_view& key) { return json[key]; }
    static constexpr nlohmann::json::reference operator[](std::size_t index) { return json[index]; }

    void save() const;
    void save(std::chrono::milliseconds after) const;

    explicit Configuration(const std::filesystem::path& configuration_file);
    ~Configuration();
private:
    inline static nlohmann::json json = R"(
        {
            "key": "value"
        }
    )"_json;
}; // class Configuration

} // namespace plugin

#endif // GADMIN_PLUGIN_CONFIGURATION_H
