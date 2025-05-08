#ifndef GADMIN_PLUGIN_COMMON_UTILS_H
#define GADMIN_PLUGIN_COMMON_UTILS_H

#include <random>
#include <iterator>

namespace plugin {

class common_utils {
public:
    template<typename iterator, typename random_generator>
    static iterator select_randomly(iterator start, iterator end, random_generator& g);

    template<typename iterator>
    static iterator select_randomly(iterator start, iterator end);
}; // class common_utils

} // namespace plugin

template<typename iterator, typename random_generator>
iterator
plugin::common_utils::select_randomly(iterator start, iterator end, random_generator& g) {
    std::uniform_int_distribution<> dis(0, std::distance(start, end) - 1);
    std::advance(start, dis(g));
    return start;
}

template<typename iterator>
iterator
plugin::common_utils::select_randomly(iterator start, iterator end) {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    return select_randomly(start, end, gen);
}

#endif // GADMIN_PLUGIN_COMMON_UTILS_H
