#include "plugin/gui/windows/main/frames/home.h"
#include "plugin/gui/gui.h"
#include "plugin/gui/widgets/text.h"

auto plugin::gui::windows::main::frames::home::render() -> void {
    widgets::text(child->child->fonts->light, 18, 0, "Hello, world! This is home frame.");
}
