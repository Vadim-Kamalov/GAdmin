#ifndef GADMIN_PLUGIN_CONFIGURATION_H
#define GADMIN_PLUGIN_CONFIGURATION_H

#include <filesystem>
#include <chrono>
#include <nlohmann/json.hpp>

namespace plugin {

class configuration_initializer {
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

    explicit configuration_initializer(const std::filesystem::path& configuration_file);
    ~configuration_initializer() noexcept;
private:
    inline static nlohmann::json json = R"json(
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

            "additions": {
                "hide_spectator_text_draws": true,
                "hide_spectator_menu": true,
                "command_requester": {
                    "use": true,
                    "notify_by_window": true
                }
            },

            "internal": {
                "guide_hints": [],
                "hotkeys": {}
            }
        }
    )json"_json;
}; // class configuration_initializer

} // namespace plugin

#endif // GADMIN_PLUGIN_CONFIGURATION_H
