#include "plugin/types/color.h"

void
plugin::types::to_json(nlohmann::json& json, const color& col) {
    json = std::format("{:08X}", col.get());
}

void
plugin::types::from_json(const nlohmann::json& json, color& col) {
    col = std::stoul(json.get<std::string>(), nullptr, 16);
}
