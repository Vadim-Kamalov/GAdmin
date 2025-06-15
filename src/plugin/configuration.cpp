#include "plugin/configuration.h"
#include "plugin/types/simple.h"
#include "plugin/log.h"
#include <fstream>

static constexpr plugin::types::zstring_t main_json_content = R"json(
{
    "user": {
        "nickname": "Администратор",
        "level": 0
    },

    "windows": {
        "admins": {
            "use": true,
            "show_title": true,
            "show_count": false,
            "show_id": true,
            "show_level": true,
            "show_scrollbar_on": 10,
            "sort_by": "level",
            "align": "left"
        },

        "notify": {
            "use": true,
            "max_count": 5,
            "align": "right"
        },
                
        "spectator_information": {
            "use": true,
            "row_order": [
                "Игрок",
                "Пинг",
                "Платформа",
                "Время слежки",
                "ID аккаунта",
                "Дата регистрации",
                "Наличные/банк",
                "Здоровье/броня",
                "Фракция",
                "Должность",
                "Машина(-ы)",
                "Стадия",
                "VIP статус",
                "Предупреждения",
                "Модульный мир",
                "Тек./макс. скорость",
                "Выстрелы/попадания",
                "Машина",
                "Двигатель/двери"
            ]
        },

        "spectator_actions": {
            "use": true,
            "show_corner_buttons": true,
            "buttons": [
                { "use": true, "name": "*Вы тут?*", "action": "/ans ${{ SPECTATOR_ID }} Вы тут? Ответ в /b или /pm ${{ USER_ID }}" },
                { "use": true, "name": "AHEAL", "action": "/aheal ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "ANS", "action": "^/ans ${{ SPECTATOR_ID }} " },
                { "use": true, "name": "STATS", "action": 3 },
                { "use": true, "name": "AFRISK", "action": 5 },
                { "use": true, "name": "PAME", "action": "/pame ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "WARN", "action": "^/warn ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "SLAP", "action": "/slap ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "SWITCH", "action": 1 },
                { "use": true, "name": "GETBUYCAR", "action": "^/getbuycar " },
                { "use": true, "name": "BAN", "action": "^/ban ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "KICK", "action": "^/kick ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "BMUTE", "action": "^/bmute ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "EXIT", "action": 6 },
                { "use": true, "name": "ASPAWN", "action": "/aspawn ${{ SPECTATOR_ID }}" },
                { "use": true, "name": "PK", "action": "/pk ${{ SPECTATOR_ID }}" }
            ]
        },

        "kill_list": {
            "use": true,
            "show_time": true,
            "clist_color": true,
            "align": "left",
            "max_count": 5
        },

        "far_chat": {
            "use": true,
            "duplicates_delay_ms": 1200,
            "max_count": 5,
            "show_time": true,
            "clist_color": true,
            "align": "left"
        },

        "players_nearby": {
            "use": true,
            "max_count": 10,
            "show_distance": true,
            "show_title": true,
            "clist_color": true,
            "align": "left",
            "sort_by": "distance"
        },

        "report": {
            "use": true,
            "notify": true,
            "sound_notify": true,
            "insert_buttons": [
                { "name": "Приятной игры!", "insert": "Приятной игры!" },
                { "name": "Передал", "insert": "Передал." },
                { "name": "Нет тех.причины", "insert": "Нет технической причины." },
                { "name": "Пишите на форум", "insert": "Пишите жалобу на форум, туда со всеми доказательствами." },
                { "name": "Слежу", "insert": "Слежу за игроком." },
                { "name": "Следите за новостями", "insert": "Следите за новостями." }
            ]
        },

        "interaction_area": {
            "use": true,
            "radius": 300
        },

        "spectator_keys": { "use": true },
        "vehicle_selection": { "use": true }
    },

    "cheats": {
        "airbreak": {
            "use": true,
            "speed": 1.0
        },

        "wallhack": {
            "use": true,
            "custom_render": true,
            "font_size": 18
        },

        "tracers": {
            "use": true,
            "only_from_spectator": false,
            "seconds_to_hide": 15,
            "limit": 15
        },
                
        "clickwarp": { "use": true }
    },

    "misc": {
        "hide_spectator_text_draws": true,
        "hide_spectator_menu": true,
        "hide_addresses": true,
        "nickname_colors": true,
        "auto_aa_command": true,
        "display_id_in_chat": true,

        "auto_login": {
            "use": true,
            "account_password": "",
            "alogin_password": ""
        },

        "command_requester": {
            "use": true,
            "notify_by_window": true,
            "sound_notify": true
        },

        "mentions": {
            "use": true,
            "sound_notify": true,
            "color": "FFB6864A"
        },

        "report_one_color": {
            "use": true,
            "color": "FF00FFFF"
        },

        "death_notify_in_chat": {
            "use": true,
            "color": "FFAFAFAF"
        },

        "short_commands": {
            "use": true,
            "commands": {
                "vr": "vrepair {}",
                "as": "aspawn {}",
                "ah": "aheal {}",
                "af": "afrisk {}",
                "uf": "unfreeze {}",
                "g": "goto {}",
                "gh": "gethere {}",
                "gc": "getcar {}",
                "gbc": "getbuycar {}",
                "pt": "ptop {}",
                "jb": "ans {} Пишите жалобу на форум, туда со всем доказательствами",
                "asl": "ans {} Слежу за игроком",
                "ar": "kick {} AFK on ROAD",
                "ak": "kick {} AFK without ESC",
                "ap": "kick {} AFK public place"
            }
        },
        
        "fish_eye": {
            "use": true,
            "fov": 101
        }
    },

    "internal": {
        "guide_hints": [],
        "hotkeys": {}
    }
}
)json"; // static constexpr plugin::types::zstring_t main_json_content

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
    main_json = nlohmann::json::parse(main_json_content);
    
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
