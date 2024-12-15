#ifndef GADMIN_PLUGIN_GAME_CURSOR_H
#define GADMIN_PLUGIN_GAME_CURSOR_H

namespace plugin {
namespace signatures {

using clear_mouse_history_t = void(__cdecl*)();
using update_pads_t = void(__cdecl*)();

} // namespace signatures

namespace game::cursor {

void set_status(bool status) noexcept;

} // namespace game::cursor
} // namespace plugin

#endif // GADMIN_PLUGIN_GAME_CURSOR_H
