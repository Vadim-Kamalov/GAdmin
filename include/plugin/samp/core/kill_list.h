#ifndef GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H
#define GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H

#include "plugin/types/address.h"

namespace plugin::samp {

class kill_list final {
private:
    static inline types::offset<bool> enabled_offset = 0x0;
    static types::versioned_address_container<std::uintptr_t> instance_container;
public:
    static auto hide_window() noexcept -> void;
}; // class kill_list final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_KILL_LIST_H
