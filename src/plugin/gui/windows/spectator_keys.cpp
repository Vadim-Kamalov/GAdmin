#include "plugin/gui/windows/spectator_keys.h"
#include "plugin/server/spectator.h"
#include "plugin/log.h"
#include "plugin/plugin.h"

std::vector<plugin::gui::widgets::keycap>
plugin::gui::windows::spectator_keys::get_keycaps(const samp::synchronization_type& type) noexcept {
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

void
plugin::gui::windows::spectator_keys::render() {
    auto window_configuration = (*configuration)["windows"]["spectator_keys"];

    if (!window_configuration["use"] || !server::spectator::is_active())
        return;

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
                child->fonts->bold->push(15);
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

plugin::gui::window_ptr_t
plugin::gui::windows::spectator_keys::create(utils::not_null<gui_initializer*> child) {
    return std::make_unique<spectator_keys>(child);
}

plugin::gui::windows::spectator_keys::spectator_keys(utils::not_null<gui_initializer*> child) : child(child) {
    log::info("window \"windows::spectator_keys\" initialized");
}
