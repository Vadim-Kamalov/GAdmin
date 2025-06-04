#include "plugin/types/color.h"

auto plugin::types::to_json(nlohmann::json& json, const color& col) -> void {
    json = std::format("{:08X}", col.get());
}

auto plugin::types::from_json(const nlohmann::json& json, color& col) -> void {
    col = std::stoul(json.get<std::string>(), nullptr, 16);
}
