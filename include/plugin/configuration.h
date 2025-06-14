#ifndef GADMIN_PLUGIN_CONFIGURATION_H
#define GADMIN_PLUGIN_CONFIGURATION_H

#include <filesystem>
#include <chrono>
#include <nlohmann/json.hpp>

namespace plugin {

class configuration_initializer final {
private:
    std::filesystem::path configuration_file;
    
    static inline nlohmann::json main_json;
    mutable std::chrono::steady_clock::time_point last_time_saved;

    auto write(const std::filesystem::path& path, const nlohmann::json& json) const -> void;
    auto get(const std::filesystem::path& path) const -> nlohmann::json;
public:
    auto operator[](const std::string_view& key) const -> nlohmann::json::reference;

    auto save() const -> void;
    auto save(std::chrono::milliseconds after) const -> void;

    explicit configuration_initializer(const std::filesystem::path& configuration_file);
    ~configuration_initializer() noexcept;
}; // class configuration_initializer final

} // namespace plugin

#endif // GADMIN_PLUGIN_CONFIGURATION_H
