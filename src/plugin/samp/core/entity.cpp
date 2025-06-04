#include "plugin/samp/core/entity.h"

plugin::types::versioned_address_container<plugin::signatures::get_model_index_t>
plugin::samp::entity::get_model_index_container = { 0x9A670, 0x9E920, 0x9F030, 0x9EE70 };

auto plugin::samp::entity::is_available() const -> bool {
    return handle.is_available() && game_handle.read(*handle) != 0;
}

auto plugin::samp::entity::get_model_index() const -> int {
    return get_model_index_container->invoke(*handle);
}

auto plugin::samp::entity::operator==(const entity& other) const -> bool {
    return *handle == *other.handle;
}
