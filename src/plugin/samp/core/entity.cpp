#include "plugin/samp/core/entity.h"
#include "plugin/samp/samp.h"

bool
plugin::samp::entity::is_available() const {
    return handle != 0 && *reinterpret_cast<std::uintptr_t*>(handle + 0x40) != 0;
}

int
plugin::samp::entity::get_model_index() const {
    static constexpr std::uintptr_t offsets[] = { 0x0, 0x0, 0x9A670, 0x9E920, 0x9F030, 0x9EE70 };
    return reinterpret_cast<signatures::get_model_index_t>(base(offsets))(handle);
}

bool
plugin::samp::entity::operator==(const entity& other) const {
    return handle == other.handle;
}
