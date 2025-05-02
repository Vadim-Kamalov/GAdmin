#ifndef GADMIN_PLUGIN_TYPES_U8REGEX_H
#define GADMIN_PLUGIN_TYPES_U8REGEX_H

#include <ctre.hpp>
#include <unicode-db.hpp>

namespace plugin::types {

class u8regex {
public:
    template<typename regex_results>
    class results {
    private:
        regex_results matches;
    public:
        template<std::size_t index>
        std::string get_string() const {
            std::u8string string = matches.template get<index>().str();
            return std::string(string.begin(), string.end());
        }

        template<std::size_t index>
        auto& get() const {
            return matches.template get<index>();
        }

        explicit operator bool() const {
            return matches;
        }
    
        explicit results(const regex_results& matches)
            : matches(std::move(matches)) {}
    }; // class results
private:
    template<ctll::fixed_string pattern, typename ctre_function>
    static auto pass(const std::string_view& input, ctre_function function) noexcept;
public:
    template<ctll::fixed_string pattern>
    static inline auto search(const std::string_view& input) noexcept;
    
    template<ctll::fixed_string pattern>
    static inline auto match(const std::string_view& input) noexcept;
}; // class u8regex

} // namespace plugin::types

template<ctll::fixed_string pattern, typename ctre_function>
inline auto
plugin::types::u8regex::pass(const std::string_view& input, ctre_function function) noexcept {
    std::u8string to_search = std::u8string(input.begin(), input.end());
    ctre::regex_results regex_results = function(to_search);
    return results<decltype(regex_results)>(regex_results);
}

template<ctll::fixed_string pattern>
inline auto
plugin::types::u8regex::search(const std::string_view& input) noexcept {
    return pass<pattern>(input, ctre::search<pattern>);
}

template<ctll::fixed_string pattern>
auto
plugin::types::u8regex::match(const std::string_view& input) noexcept {
    return pass<pattern>(input, ctre::match<pattern>);
}

#endif // GADMIN_PLUGIN_TYPES_U8REGEX_H
