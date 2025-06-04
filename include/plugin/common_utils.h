#ifndef GADMIN_PLUGIN_COMMON_UTILS_H
#define GADMIN_PLUGIN_COMMON_UTILS_H

#include <random>
#include <iterator>

namespace plugin {

class common_utils final {
public:
    template<typename iterator, typename random_generator>
    static auto select_randomly(iterator start, iterator end, random_generator& g) -> iterator;

    template<typename iterator>
    static auto select_randomly(iterator start, iterator end) -> iterator;
}; // class common_utils final

} // namespace plugin

template<typename iterator, typename random_generator>
auto plugin::common_utils::select_randomly(iterator start, iterator end, random_generator& g) -> iterator {
    std::uniform_int_distribution<> dis(0, std::distance(start, end) - 1);
    std::advance(start, dis(g));
    return start;
}

template<typename iterator>
auto plugin::common_utils::select_randomly(iterator start, iterator end) -> iterator {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    return select_randomly(start, end, gen);
}

#endif // GADMIN_PLUGIN_COMMON_UTILS_H
