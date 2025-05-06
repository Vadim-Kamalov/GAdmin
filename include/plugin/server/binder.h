#ifndef GADMIN_PLUGIN_SERVER_BINDER_H
#define GADMIN_PLUGIN_SERVER_BINDER_H

#include <chrono>
#include <functional>
#include <list>
#include <string>

namespace plugin::server {

class binder {
private:
    struct message {
        std::string text;
        std::chrono::steady_clock::time_point time;
    }; // struct message
private:
    using variable_replacement_t = std::function<std::string(const std::vector<std::string>&)>;
    
    static std::unordered_map<std::string, variable_replacement_t> variables;
    static inline std::list<message> messages;

    static std::string process_variable_body(const std::string_view& input);
    static void evaluate_single_line(const std::string_view& input);
public:
    static std::string process(const std::string_view& input);
    static void evaluate(const std::string_view& input);
    static void main_loop();
}; // class binder

} // namespace plugin::server

#endif // GADMIN_PLUGIN_SERVER_BINDER_H
