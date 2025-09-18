#include "plugin/misc/features/fixes.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/utils.h"
#include "plugin/plugin.h"

auto plugin::misc::features::fixes::on_event(unsigned int message, WPARAM wparam, LPARAM) -> bool {
    if ((*configuration)["misc"]["fix_chat_opening"]
        && message == WM_KEYDOWN
        && wparam == 'T'
        && !samp::utils::is_inputs_active())
    {
        samp::input::open();
        return false;
    }

    return true;
}
