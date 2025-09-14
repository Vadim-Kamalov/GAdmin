#include "plugin/samp/core/kill_list.h"

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::kill_list::instance_container = { 0x21A0EC, 0x26E8D0, 0x26EB88, 0x26EB88 };

auto plugin::samp::kill_list::hide_window() noexcept -> void {
    enabled_offset.write(false, instance_container->read());
}
