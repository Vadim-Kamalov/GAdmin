#ifndef GADMIN_PLUGIN_SERVER_BINDER_H
#define GADMIN_PLUGIN_SERVER_BINDER_H

#include <chrono>
#include <functional>
#include <list>
#include <string>

namespace plugin::server {

class binder final {
private:
    struct message final {
        std::string text;
        std::chrono::steady_clock::time_point time;
    }; // struct message final
private:
    using variable_replacement_t = std::function<std::string(const std::vector<std::string>&)>;
    
    static std::unordered_map<std::string, variable_replacement_t> variables;
    static inline std::list<message> messages;

    static auto process_variable_body(const std::string_view& input) -> std::string;
    static auto evaluate_single_line(const std::string_view& input) -> void;
public:
    static auto process(const std::string_view& input) -> std::string;
    static auto evaluate(const std::string_view& input) -> void;
    static auto main_loop() -> void;
}; // class binder final

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_BINDER_H
