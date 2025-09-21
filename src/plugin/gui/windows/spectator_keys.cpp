/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2025 The Contributors.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// SPDX-License-Identifier: GPL-3.0-only

#include "plugin/gui/windows/spectator_keys.h"
#include "plugin/game/game.h"
#include "plugin/server/spectator.h"
#include "plugin/plugin.h"

auto plugin::gui::windows::spectator_keys::get_keycaps(const samp::synchronization_type& type)
    noexcept -> std::vector<widgets::keycap>
{
    using namespace server;
    using namespace samp;

    float wide_keycap_offset = ImGui::GetStyle().ItemSpacing.x / 2;

    switch (spectator::platform) {
        case spectator::platform_t::desktop: {
            switch (type) {
                case synchronization_type::player:
                    return {
                        make_keycap<synchronization_key::lmb>(),
                        make_keycap<synchronization_key::w>(),
                        make_keycap<synchronization_key::rmb>(),
                        make_keycap<synchronization_key::shift>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::alt>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::f>(),
                        make_keycap<synchronization_key::a>(),
                        make_keycap<synchronization_key::s>(),
                        make_keycap<synchronization_key::d>(),
                        make_keycap<synchronization_key::space>({ 110, keycap_height }),
                        make_keycap<synchronization_key::c>()
                    };
                case synchronization_type::vehicle:
                case synchronization_type::passenger:
                    return {
                        make_keycap<synchronization_key::q>(),
                        make_keycap<synchronization_key::w>(),
                        make_keycap<synchronization_key::e>(),
                        make_keycap<synchronization_key::up>({ 50, keycap_height }),
                        make_keycap<synchronization_key::ctrl>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::alt>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::f>(),
                        make_keycap<synchronization_key::a>(),
                        make_keycap<synchronization_key::s>(),
                        make_keycap<synchronization_key::d>(),
                        make_keycap<synchronization_key::down>({ 50, keycap_height }),
                        make_keycap<synchronization_key::space>({ 110, keycap_height }),
                        make_keycap<synchronization_key::h>()
                    };
            }
        }

        case spectator::platform_t::mobile: {
            switch (type) {
                case synchronization_type::player:
                    return {
                        make_keycap<synchronization_key::hit>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::aim>({ 55 - wide_keycap_offset, keycap_height }),
                        make_keycap<synchronization_key::f>(),
                        make_keycap<synchronization_key::jump_run>({ 110, keycap_height }),
                        make_keycap<synchronization_key::alt>()
                    };
                case synchronization_type::vehicle:
                case synchronization_type::passenger:
                    return {
                        make_keycap<synchronization_key::forward>({ 90, keycap_height }),
                        make_keycap<synchronization_key::signal>({ 65, keycap_height }),
                        make_keycap<synchronization_key::two>(),
                        make_keycap<synchronization_key::backward>({ 90, keycap_height }),
                        make_keycap<synchronization_key::braking>({ 65, keycap_height }),
                        make_keycap<synchronization_key::f>()
                    };
            }
        }

        case spectator::platform_t::none:
            break;
    }

    return {};
}

auto plugin::gui::windows::spectator_keys::render() -> void {
    bool use = (*configuration)["windows"]["spectator_keys"];

    if (!use || !server::spectator::can_render())
        return;

    auto [ size_x, size_y ] = game::get_screen_resolution();

    ImGui::SetNextWindowPos({ size_x / 5.43909f, size_y / 1.28299f }, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize({ 0, 0 });
    ImGui::SetNextWindowBgAlpha(0);
    ImGui::PushStyleColor(ImGuiCol_FrameBg, *types::color(ImGui::GetColorU32(ImGuiCol_FrameBg), 160));
    ImGui::PushStyleColor(ImGuiCol_Border, 0);
    ImGui::Begin(get_id(), nullptr, ImGuiWindowFlags_NoTitleBar);
    {
        if (server::spectator::platform == server::spectator::platform_t::mobile) {
            server::spectator::joystick.render();
            ImGui::SameLine();
        }

        ImGui::BeginGroup();
        {
            std::vector<widgets::keycap> keycaps = get_keycaps(server::spectator::last_synchronization);
            std::size_t new_line_index = keycaps.size() / 2 + static_cast<int>(keycaps.size() % 2 != 0);

            for (const auto& [ index, keycap ] : keycaps | std::views::enumerate) {
                ImGui::PushFont(child->fonts->bold, 15);
                {
                    keycap.render();
                }
                ImGui::PopFont();

                if ((index + 1) % new_line_index != 0)
                    ImGui::SameLine();
            }
        }
        ImGui::EndGroup();
    }
    ImGui::End();
    ImGui::PopStyleColor(2);
}

auto plugin::gui::windows::spectator_keys::create(types::not_null<gui_initializer*> child) noexcept -> window_ptr_t {
    return std::make_unique<spectator_keys>(child);
}
