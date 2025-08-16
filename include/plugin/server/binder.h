#ifndef GADMIN_PLUGIN_SERVER_BINDER_H
#define GADMIN_PLUGIN_SERVER_BINDER_H

#include <chrono>
#include <functional>
#include <list>
#include <string>
#include <deque>

namespace plugin::server {

class binder final {
public:
    using variable_replacement_t = std::function<std::string(const std::vector<std::string>&)>;
    
    struct variable_t final {
        std::string name;
        std::string description;
        std::string parameters_info;
        variable_replacement_t callback;
    }; // struct variable_t final
private:
    struct message final {
        std::string text;
        std::chrono::steady_clock::time_point time;
    }; // struct message final

    static inline std::list<message> messages;
    static auto process_variable_body(const std::string_view& input) -> std::string;
    static auto evaluate_single_line(const std::string_view& input) -> void;
public:
    static inline std::vector<std::string> select_parameters;
    static std::deque<variable_t> variables;

    static auto process(const std::string_view& input) -> std::string;
    static auto evaluate(const std::string_view& input) -> void;
    static auto main_loop() -> void;
}; // class binder final

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_BINDER_H
