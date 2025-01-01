#include "plugin/samp/utils.h"
#include "plugin/samp/core/input.h"
#include "plugin/samp/core/dialog.h"
#include <imgui.h>

bool
plugin::samp::utils::is_inputs_active() noexcept {
    return input::is_active() || dialog::is_active() || ImGui::GetIO().WantTextInput;
}
