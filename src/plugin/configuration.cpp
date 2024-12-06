#include "plugin/configuration.h"
#include "plugin/log.h"
#include <fstream>

void plugin::Configuration::write(const std::filesystem::path& path, const nlohmann::json& json) {
    if (std::ofstream file = std::ofstream(path))
        file << std::setw(4) << json << std::endl;
    else
        log::fatal("failed to write JSON to \"{}\"", path.string());
}

nlohmann::json plugin::Configuration::get(const std::filesystem::path& path) {
    std::ifstream file(path);

    if (!file) {
        log::fatal("failed to get plugin configuration from \"{}\"", path.string());
        return nullptr;
    }

    nlohmann::json file_json;
    file >> file_json;

    if (file_json.is_null()) {
        log::error("plugin configuration is corrupted in \"{}\"; default configuration is written", path.string());
        write(path, json);
    }

    return file_json;
}

void plugin::Configuration::save() const {
    write(configuration_file, json);
}

void plugin::Configuration::save(std::chrono::milliseconds after) const {
    auto now = std::chrono::steady_clock::now();

    if (std::chrono::duration_cast<std::chrono::milliseconds>(now - last_time_saved) >= after) {
        last_time_saved = now;
        save();
    }
}

plugin::Configuration::Configuration(const std::filesystem::path& configuration_file)
    : last_time_saved(std::chrono::steady_clock::now()),
      configuration_file(configuration_file)
{
    if (!std::filesystem::exists(configuration_file))
        save();
    else if (nlohmann::json configuration = get(configuration_file); !configuration.is_null())
        json.merge_patch(configuration);
    
    log::info("configuration initialized");
}

plugin::Configuration::~Configuration() {
    save();
}
