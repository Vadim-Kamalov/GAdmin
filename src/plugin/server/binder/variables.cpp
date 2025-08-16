#include "plugin/server/binder.h"
#include "plugin/samp/core/user.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include "plugin/game/ped.h"
#include "plugin/log.h"

#define GET_NOT_AVAILABLE_LABEL_EX(PARAMS, DEFAULT) ((PARAMS.empty()) ? DEFAULT : PARAMS[0])
#define GET_NOT_AVAILABLE_LABEL(PARAMS) GET_NOT_AVAILABLE_LABEL_EX(PARAMS, "N/A")

#define VARIABLE_SPECTATOR_INFORMATION_EX(POSTFIX, NAME, VALUE)                                         \
    {                                                                                                   \
        .name = "SPECTATOR_" POSTFIX,                                                                   \
        .description = NAME " игрока за которым вы следите",                                            \
        .parameters_info = "текст для замены если игрок не найден",                                     \
        .callback = [](const auto& params) {                                                            \
            return (plugin::server::spectator::is_active()) ? VALUE : GET_NOT_AVAILABLE_LABEL(params);  \
        }                                                                                               \
    }

#define VARIABLE_SPECTATOR_INFORMATION_RAW(POSTFIX, NAME, ENTRY) \
    VARIABLE_SPECTATOR_INFORMATION_EX(POSTFIX, NAME, plugin::server::spectator::get_information().ENTRY)

#define VARIABLE_SPECTATOR_INFORMATION_STR(POSTFIX, NAME, ENTRY) \
    VARIABLE_SPECTATOR_INFORMATION_EX(POSTFIX, NAME, std::to_string(plugin::server::spectator::get_information().ENTRY))

#define VARIABLE_USER_INFORMATION_EX(POSTFIX, DESCRIPTION, VALUE) \
    { "USER_" POSTFIX, DESCRIPTION, "", [](const auto&) { return VALUE; } }

#define VARIABLE_USER_INFORMATION_RAW(POSTFIX, DESCRIPTION, VALUE) \
    VARIABLE_USER_INFORMATION_EX(POSTFIX, DESCRIPTION, VALUE)

#define VARIABLE_USER_INFORMATION_STR(POSTFIX, DESCRIPTION, VALUE) \
    VARIABLE_USER_INFORMATION_EX(POSTFIX, DESCRIPTION, std::to_string(VALUE))

#define VARIABLE_PLAYER_PED_INFORMATION_EX(POSTFIX, DESCRIPTION, METHOD) \
    { "USER_" POSTFIX, DESCRIPTION, "", [](const auto&) { return plugin::game::ped::get_player().METHOD(); }}

#define VARIABLE_PLAYER_PED_INFORMATION_STR(POSTFIX, DESCRIPTION, METHOD) \
    { "USER_" POSTFIX, DESCRIPTION, "", [](const auto&) { return std::to_string(plugin::game::ped::get_player().METHOD()); }}

#define VARIABLE_PLAYER_PED_INFORMATION_FORMAT(POSTFIX, DESCRIPTION, METHOD) \
    { "USER_" POSTFIX, DESCRIPTION, "", [](const auto&) { return std::format("{}", plugin::game::ped::get_player().METHOD()); }}

#define VARIABLE_BOOLEAN_TYPE(KEY, DESCRIPTION, VALUE)          \
    { KEY, DESCRIPTION " (+ ИЛИ -)", "", [](const auto&) {      \
        static std::string bool_to_string[2] = { "-", "+" };    \
        return bool_to_string[VALUE];                           \
    }}

static auto select_variable_callback(const std::vector<std::string>& params) noexcept -> std::string {
    using log = plugin::log;
    using binder = plugin::server::binder;

    if (params.empty() || binder::select_parameters.empty())
        return "";

    try {
        int index = std::stoull(params[0]) - 1;

        if (index >= binder::select_parameters.size())
            return "";

        return binder::select_parameters[index];
    } catch (const std::exception& e) {
        std::string string_params = "";

        for (std::size_t i = 0; i < params.size(); i++) {
            if (i > 0)
                string_params.append(", ");

            string_params.append(params[i]);
        }

        log::warn("select_variable_callback: e.what() = \"{}\" [with `params` = [{}]]", e.what(), string_params);
    }

    return "";
}

std::deque<plugin::server::binder::variable_t> plugin::server::binder::variables = {
    { "SELECT", "Аргумент команды по индексу", "индекс начиная с 1", select_variable_callback },
    VARIABLE_BOOLEAN_TYPE("USER_ALOGIN_STATE", "Текущее состояние /alogin", server::user::is_on_alogin()),
    VARIABLE_USER_INFORMATION_STR("ID", "Ваш ID", samp::user::get_id()),
    VARIABLE_USER_INFORMATION_STR("PING", "Ваш пинг", samp::user::get_ping()),
    VARIABLE_USER_INFORMATION_RAW("NAME", "Ваш никнейм", samp::user::get_name()),
    VARIABLE_BOOLEAN_TYPE("USER_IS_IN_THE_AIR", "Проверка что вы в воздухе", game::ped::get_player().is_in_the_air()),
    VARIABLE_BOOLEAN_TYPE("USER_IS_TARGETING", "Проверка что вы целитесь", game::ped::get_player().is_targeting()),
    VARIABLE_BOOLEAN_TYPE("USER_IS_IN_VEHICLE", "Проверка что вы в машине", game::ped::get_player().get_vehicle().is_available()),
    VARIABLE_PLAYER_PED_INFORMATION_STR("SPEED", "Ваша скорость (метры в секунду)", get_speed),
    VARIABLE_PLAYER_PED_INFORMATION_FORMAT("CURRENT_WEAPON", "Ваше текущее оружие в руках", get_current_weapon),
    VARIABLE_PLAYER_PED_INFORMATION_STR("MODEL_INDEX", "Ваш ID скина", get_model_index),
    VARIABLE_PLAYER_PED_INFORMATION_FORMAT("POSITION", "Ваши координаты (X: < ... > | Y: < ... > | Z: < ... >)", get_position),
    VARIABLE_SPECTATOR_INFORMATION_EX("ID", "ID", std::to_string(server::spectator::id)),
    VARIABLE_SPECTATOR_INFORMATION_EX("PLATFORM", "Платформа", std::format("{}", server::spectator::platform)),
    VARIABLE_SPECTATOR_INFORMATION_EX("NICKNAME", "Никнейм", server::spectator::nickname),
    VARIABLE_SPECTATOR_INFORMATION_STR("ARMOR", "Броня", armor),
    VARIABLE_SPECTATOR_INFORMATION_STR("PING", "Пинг", ping),
    VARIABLE_SPECTATOR_INFORMATION_STR("HEALTH", "Здоровье", health),
    VARIABLE_SPECTATOR_INFORMATION_STR("ACCOUNT_ID", "ID аккаунта", account_id),
    VARIABLE_SPECTATOR_INFORMATION_RAW("WEAPON", "Оружие", weapon),
    VARIABLE_SPECTATOR_INFORMATION_RAW("MONEY_HAND", "Деньги на руках", money_hand),
    VARIABLE_SPECTATOR_INFORMATION_RAW("MONEY_BANK", "Деньги в банке", money_bank),
    VARIABLE_SPECTATOR_INFORMATION_RAW("FRACTION", "Фракция", fraction),
    VARIABLE_SPECTATOR_INFORMATION_RAW("RANK", "Ранг", rank),
    VARIABLE_SPECTATOR_INFORMATION_RAW("VEHICLE", "Машины", vehicle),
    VARIABLE_SPECTATOR_INFORMATION_RAW("HOUSE", "Дом", house),
    VARIABLE_SPECTATOR_INFORMATION_RAW("VIP", "VIP статус", vip),
    VARIABLE_SPECTATOR_INFORMATION_RAW("REGISTRATION_DATE", "Дата регистрации", registration_date),
    VARIABLE_SPECTATOR_INFORMATION_STR("WARNINGS", "Предупреждения", warnings),
    VARIABLE_SPECTATOR_INFORMATION_STR("STAGE", "Стадия", stage),
    VARIABLE_SPECTATOR_INFORMATION_STR("WORLD", "Виртуальный мир", world),
    VARIABLE_SPECTATOR_INFORMATION_STR("MOVE_SPEED_CURRENT", "Текущая скорость", move_speed_current),
    VARIABLE_SPECTATOR_INFORMATION_STR("MOVE_SPEED_MAX", "Максимальная скорость", move_speed_max),
    VARIABLE_SPECTATOR_INFORMATION_STR("TOTAL_SHOTS", "Выстрелы", total_shots),
    VARIABLE_SPECTATOR_INFORMATION_STR("HIT_SHOTS", "Попадания", hit_shots)
}; // std::map<std::string, plugin::server::binder::variable_t> plugin::server::binder::variables
