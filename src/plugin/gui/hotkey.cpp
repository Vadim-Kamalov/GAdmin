#include "plugin/gui/hotkey.h"
#include "plugin/gui/key_names.h"
#include "plugin/gui/style.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/hint.h"
#include "plugin/gui/widgets/text.h"
#include "plugin/gui/widgets/toggle_button.h"
#include "plugin/server/spectator.h"
#include "plugin/server/user.h"
#include "plugin/plugin.h"

auto plugin::gui::key_bind::to_string() const -> std::string {
    std::deque<std::string> output;

    if (modifiers.shift)
        output.push_back((modifiers.uses_right_hand_shift) ? "Right Shift" : "Shift");
    
    if (modifiers.control)
        output.push_back((modifiers.uses_right_hand_control) ? "Right Control" : "Control");
    
    if (modifiers.alt)
        output.push_back((modifiers.uses_right_hand_alt) ? "Right Alt" : "Alt");

    if (keys.first != 0)
        output.push_back(key_to_string(keys.first));

    if (keys.second != 0)
        output.push_back(key_to_string(keys.second));

    if (output.empty())
        return "Не назначено";

    std::string result = "";

    for (std::size_t i = 0; i < output.size(); i++) {
        if (i > 0)
            result.append(" + ");

        result.append(output[i]);
    }

    return result;
}

auto plugin::gui::hotkey::truncate_text_in_button(const std::string_view& text) const -> std::string {
    std::string output(text);
    std::string ellipsis = " ...";

    ImVec2 size = ImGui::CalcTextSize(output.c_str());
    ImVec2 padding = ImGui::GetStyle().FramePadding;
    float available_width = button_size.x - padding.x * 2;

    if (available_width >= size.x)
        return output;

    while (available_width < size.x && !output.empty()) {
        output.pop_back();
        size = ImGui::CalcTextSize((output + ellipsis).c_str());
    }

    if (!output.empty())
        output.append(ellipsis);

    return output;
}

auto plugin::gui::hotkey::hint_condition() -> bool {
    if (ImGui::IsMouseReleased(ImGuiMouseButton_Right) && ImGui::IsItemHovered() &&
        !handler->changing_any_hotkey && !handler->changing_any_properties)
    {
        hint_active = handler->changing_any_properties = true;
    }

    return hint_active;
}

auto plugin::gui::hotkey::hint_renderer() -> void {
    if (!ImGui::IsWindowHovered() && (ImGui::IsMouseClicked(ImGuiMouseButton_Left) ||
        ImGui::IsMouseClicked(ImGuiMouseButton_Left) ||
        ImGui::IsMouseClicked(ImGuiMouseButton_Left)))
    {
        hint_active = handler->changing_any_properties = false;
    }
    
    auto& saved_hotkeys = (*configuration)["internal"]["hotkeys"];

    ImFont* bold_font = handler->child->fonts->bold;
    ImFont* regular_font = handler->child->fonts->regular;

    float window_width = std::max(ImGui::GetWindowWidth(), 200.0f);
    float item_full_width = window_width - ImGui::GetStyle().WindowPadding.x * 2;

    widgets::text(bold_font, fonts_size, 0, "{}", label);
    ImGui::BeginGroup();
    {
        widgets::text(bold_font, fonts_size, 0, "Клавиши:");
        ImGui::SameLine();
        widgets::text(regular_font, fonts_size, 0, "{}", bind.to_string());
    }
    ImGui::EndGroup();
    ImGui::PushFont(bold_font, fonts_size);
    {
        ImGui::SetCursorPosX((window_width - ImGui::CalcTextSize("Условия активации").x) / 2);
        ImGui::TextUnformatted("Условия активации");
    }
    ImGui::PopFont();
    ImGui::PushFont(regular_font, fonts_size);
    {
        for (std::uint8_t i = 0; i < hint_settings.size(); i++) {
            types::setter<bool> setter = types::setter<bool>::from_proxy(bind.conditions[i]);
            std::string button_label = hint_settings[i] + "##" + label;
        
            if (widgets::toggle_button(button_label, setter).render())
                saved_hotkeys[label] = bind.join(); 
        }
    }
    ImGui::PopFont();
    ImGui::SetCursorPosY(ImGui::GetCursorPosY() - ImGui::GetStyle().ItemSpacing.y + ImGui::GetStyle().WindowPadding.y);
    ImGui::PushFont(regular_font, fonts_size);
    {
        if (widgets::button("Сбросить##" + label, { item_full_width, 30 }).render()) {
            saved_hotkeys[label] = 0;
            bind = {};
        }
    }
    ImGui::PopFont();
}

auto plugin::gui::hotkey::render() -> void {
    auto now = std::chrono::steady_clock::now();
    auto saved_hotkeys = (*configuration)["internal"]["hotkeys"];

    widgets::button button(bind.to_string(), label, button_size);

    if (changing && !handler->changing_any_hotkey) {
        changing = false;
        button.label = bind.to_string();
    }

    if (changing && handler->changing_any_hotkey) {
        if (new_bind.join() > handler->current_keys.join() && !new_bind.empty()) {
            bind = new_bind;
            saved_hotkeys[label] = bind.join();
            handler->changing_any_hotkey = changing = false;
            new_bind = {};
        } else {
            already_registered = handler->is_bind_defined(handler->current_keys);
            if (handler->current_keys.empty()) {
                if (now - tick_time >= 500ms) {
                    tick_state ^= true;
                    tick_time = now;
                }

                button.label = (tick_state) ? "" : "Ожидание";
            } else {
                button.label = handler->current_keys.to_string();
                if (!already_registered)
                    new_bind = handler->current_keys;
            }
        }
    }

    if (!changing && already_registered)
        already_registered = false;

    button.label = truncate_text_in_button(button.label);

    if (button.render() && !handler->changing_any_hotkey) {
        handler->changing_any_hotkey = changing = true;
        tick_time = now;
    }

    widgets::hint(label, ImGui::GetColorU32(ImGuiCol_ChildBg))
        .with_condition(std::bind(&hotkey::hint_condition, this))
        .with_renderer(std::bind(&hotkey::hint_renderer, this))
        .render();

    widgets::hint("Эти клавиши уже используются другим биндом.\nПодсказка: чтобы отменить смену клавиш - нажмите ESC.##" + label, style::accent_colors.red)
        .with_condition([this] { return already_registered; })
        .render();
}

plugin::gui::hotkey::hotkey(const std::string_view& label, const key_bind& default_bind) : label(std::move(label)) {
    auto& saved_binds = (*configuration)["internal"]["hotkeys"];

    for (const auto& [ key, value ] : saved_binds.items()) {
        if (key != label)
            continue;

        bind = key_bind(value.get<std::uint32_t>());
    
        return;
    }

    bind = default_bind;
    saved_binds[label] = default_bind.join();
}

auto plugin::gui::hotkey_handler::check_modifiers(const key_bind::modifiers_t& modifiers) const -> bool {
    if (modifiers.shift && !ImGui::IsKeyDown((modifiers.uses_right_hand_shift) ? ImGuiKey_RightShift : ImGuiKey_LeftShift))
        return false;

    if (modifiers.control && !ImGui::IsKeyDown((modifiers.uses_right_hand_control) ? ImGuiKey_RightCtrl : ImGuiKey_LeftCtrl))
        return false;

    if (modifiers.alt && !ImGui::IsKeyDown((modifiers.uses_right_hand_alt) ? ImGuiKey_RightAlt : ImGuiKey_LeftAlt))
        return false;

    return true;
}

auto plugin::gui::hotkey_handler::check_conditions(const types::options<bind_condition>& conditions) const -> bool {
    if (conditions.has_value(bind_condition::never))
        return false;
    
    if (conditions.has_value(bind_condition::always))
        return true;
    
    bool on_alogin = server::user::is_on_alogin();
    bool in_spectator = server::spectator::is_active();
    bool cursor_active = GetCursor() != nullptr;

#define FINISH_CASE(CONDITION) if (CONDITION) return false; break
    for (const auto& condition : conditions) {
        switch (condition) {
            case bind_condition::in_spectator: FINISH_CASE(!in_spectator);
            case bind_condition::not_in_spectator: FINISH_CASE(in_spectator);
            case bind_condition::on_alogin: FINISH_CASE(!on_alogin);
            case bind_condition::not_on_alogin: FINISH_CASE(on_alogin);
            case bind_condition::cursor_active: FINISH_CASE(!cursor_active);
            case bind_condition::cursor_not_active: FINISH_CASE(cursor_active);
            default: std::unreachable();
        }
    }
#undef FINISH_CASE

    return true;
}

auto plugin::gui::hotkey_handler::write_current_modifiers() -> void {
    current_keys.modifiers.shift = ImGui::IsKeyDown(ImGuiMod_Shift);
    current_keys.modifiers.alt = ImGui::IsKeyDown(ImGuiMod_Alt);
    current_keys.modifiers.control = ImGui::IsKeyDown(ImGuiMod_Ctrl);
    current_keys.modifiers.uses_right_hand_shift = ImGui::IsKeyDown(ImGuiKey_RightShift);
    current_keys.modifiers.uses_right_hand_alt = ImGui::IsKeyDown(ImGuiKey_RightAlt);
    current_keys.modifiers.uses_right_hand_control = ImGui::IsKeyDown(ImGuiKey_RightCtrl);
}

auto plugin::gui::hotkey_handler::write_current_keys(unsigned int message, WPARAM wparam) -> void {
    auto& [ first_key, second_key ] = current_keys.keys;
   
    if (wparam == VK_CONTROL || wparam == VK_MENU || wparam == VK_SHIFT || wparam == VK_OEM_3)
        return;

    switch (message) {
        case WM_SYSKEYDOWN:
        case WM_KEYDOWN: {
            if (first_key == 0 && wparam != second_key)
                first_key = wparam;
            else if (second_key == 0 && wparam != first_key)
                second_key = wparam;

            break;
        }

        case WM_SYSKEYUP:
        case WM_KEYUP: {
            if (wparam == first_key)
                first_key = 0;
            else if (wparam == second_key)
                second_key = 0;

            break;
        }
    }
}

auto plugin::gui::hotkey_handler::is_bind_defined(const key_bind& bind) const -> bool {
    if (bind.empty())
        return false;

    return std::find_if(pool.begin(), pool.end(), [bind](const hotkey& hotkey) {
        return hotkey.bind == bind;
    }) != pool.end();
}

auto plugin::gui::hotkey_handler::is_hotkey_active(const hotkey& hotkey_to_find) const -> bool {
    if (auto it = std::find_if(pool.begin(), pool.end(), [hotkey_to_find](const hotkey& hotkey_in_pool) {
        return hotkey_to_find.label == hotkey_in_pool.label;
    }); it != pool.end())
        return it->bind.modifiers.internal_first_key_down && it->bind.modifiers.internal_second_key_down;

    return false;
}

auto plugin::gui::hotkey_handler::main_loop() -> void {
    if (ImGui::GetCurrentContext() == nullptr)
        return;

    write_current_modifiers();
}

auto plugin::gui::hotkey_handler::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) -> bool {
    if (wparam == 0)
        return true;

    if (message == WM_KEYDOWN && wparam == VK_ESCAPE && changing_any_hotkey) {
        changing_any_hotkey = false;
        return false;
    }

    write_current_keys(message, wparam);
    
    if (changing_any_hotkey)
        return true;

    for (auto& hotkey : pool) {
        auto& bind = hotkey.bind;

        if (bind.empty())
            continue;

        bool modifiers_down = check_modifiers(bind.modifiers);
        auto& [ first_key, second_key ] = hotkey.bind.keys;
        
        switch (message) {
            case WM_SYSKEYDOWN:
            case WM_KEYDOWN: {
                if (modifiers_down && check_conditions(bind.conditions)) {
                    if (bind.modifiers.internal_first_key_down && bind.modifiers.internal_second_key_down)
                        return true;

                    if ((first_key == 0 && second_key != 0 && wparam == second_key) ||
                        (second_key == 0 && first_key != 0 && wparam == first_key))
                    {
                        bind.modifiers.internal_first_key_down = bind.modifiers.internal_second_key_down = true;
                        hotkey.callback(hotkey);
                        return false;
                    }

                    if (bind.modifiers.internal_first_key_down &&
                        !bind.modifiers.internal_second_key_down &&
                        wparam == second_key)
                    {
                        bind.modifiers.internal_second_key_down = true;
                        hotkey.callback(hotkey);
                        return false;
                    } else if (!bind.modifiers.internal_first_key_down &&
                               bind.modifiers.internal_second_key_down &&
                               wparam == first_key)
                    {
                        bind.modifiers.internal_first_key_down = true;
                        hotkey.callback(hotkey);
                        return false;
                    }
                }

                if (wparam == first_key)
                    bind.modifiers.internal_first_key_down = true;
                else if (wparam == second_key)
                    bind.modifiers.internal_second_key_down = true;

                break;
            }

            case WM_SYSKEYUP:
            case WM_KEYUP: {
                if (wparam == first_key)
                    bind.modifiers.internal_first_key_down = false;
                else if (wparam == second_key)
                    bind.modifiers.internal_second_key_down = false;
                
                break;
            }
        }
    }

    return true;
}

auto plugin::gui::hotkey_handler::add(hotkey& hotkey) -> void {
    log::info("hotkey \"{}\" initialized: key_bind = 0x{:08X}", hotkey.label, hotkey.bind.join());
    pool.push_back(hotkey.with_handler(this));
}
