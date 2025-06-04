#ifndef GADMIN_PLUGIN_SAMP_UTILS_H
#define GADMIN_PLUGIN_SAMP_UTILS_H

namespace plugin::samp {

class utils final {
public:
    static auto is_inputs_active() noexcept -> bool;
}; // class utils final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_UTILS_H
