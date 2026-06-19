/// GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
/// Copyright (C) 2023-2026 The Contributors.
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

#include "plugin/gui/style.h"
#include "plugin/plugin.h"

const std::vector<ImGuiCol> plugin::gui::style::used_colors = {
    ImGuiCol_Text,
    ImGuiCol_TextDisabled,
    ImGuiCol_WindowBg,
    ImGuiCol_ChildBg,
    ImGuiCol_PopupBg,
    ImGuiCol_Border,
    ImGuiCol_BorderShadow,
    ImGuiCol_FrameBg,
    ImGuiCol_FrameBgHovered,
    ImGuiCol_FrameBgActive,
    ImGuiCol_ScrollbarBg,
    ImGuiCol_ScrollbarGrab,
    ImGuiCol_ScrollbarGrabHovered,
    ImGuiCol_ScrollbarGrabActive,
    ImGuiCol_Button,
    ImGuiCol_ButtonHovered,
    ImGuiCol_ButtonActive,
    ImGuiCol_Header,
    ImGuiCol_HeaderHovered,
    ImGuiCol_HeaderActive,
    ImGuiCol_Separator,
    ImGuiCol_SeparatorHovered,
    ImGuiCol_SeparatorActive,
    ImGuiCol_TextSelectedBg,
    ImGuiCol_Tab,
    ImGuiCol_TabHovered,
    ImGuiCol_TabActive,
    ImGuiCol_SliderGrab,
    ImGuiCol_SliderGrabActive,
    ImGuiCol_TableBorderLight,
    ImGuiCol_TableBorderStrong,
    ImGuiCol_TableHeaderBg,
    ImGuiCol_TableRowBg,
    ImGuiCol_TableRowBgAlt,
    ImGuiCol_ResizeGrip,
    ImGuiCol_ResizeGripActive,
    ImGuiCol_ResizeGripHovered,
}; // const std::vector<ImGuiCol> plugin::gui::style::used_colors

const std::vector<std::string> plugin::gui::style::colors_placeholders = {
    "Текст",                                        ///< ImGuiCol_Text
    "Не активный текст",                            ///< ImGuiCol_TextDisabled
    "Фон окна",                                     ///< ImGuiCol_WindowBg
    "Фон наследованного окна",                      ///< ImGuiCol_ChildBg
    "Фон всплывающего окна",                        ///< ImGuiCol_PopupBg
    "Обводка",                                      ///< ImGuiCol_Border
    "Тень обводки",                                 ///< ImGuiCol_BorderShadow
    "Фон элемента",                                 ///< ImGuiCol_FrameBg
    "Фон элемента (при наведении)",                 ///< ImGuiCol_FrameBgHovered
    "Фон элемента (активный)",                      ///< ImGuiCol_FrameBgActive
    "Фон полосы прокрутки",                         ///< ImGuiCol_ScrollbarBg
    "Ползунок полосы прокрутки",                    ///< ImGuiCol_ScrollbarGrab
    "Ползунок полосы прокрутки (при наведении)",    ///< ImGuiCol_ScrollbarGrabHovered
    "Ползунок полосы прокрутки (активный)",         ///< ImGuiCol_ScrollbarGrabActive
    "Фон кнопки",                                   ///< ImGuiCol_Button
    "Фон кнопки (при наведении)",                   ///< ImGuiCol_ButtonHovered
    "Фон кнопки (активный)",                        ///< ImGuiCol_ButtonActive
    "Фон заголовка",                                ///< ImGuiCol_Header
    "Фон заголовка (при наведении)",                ///< ImGuiCol_HeaderHovered
    "Фон заголовка (активный)",                     ///< ImGuiCol_HeaderActive
    "Разделитель",                                  ///< ImGuiCol_Separator
    "Разделитель (при наведении)",                  ///< ImGuiCol_SeparatorHovered
    "Разделитель (активный)",                       ///< ImGuiCol_SeparatorActive
    "Фон выделенного текста",                       ///< ImGuiCol_TextSelectedBg
    "Фон вкладки",                                  ///< ImGuiCol_Tab
    "Фон вкладки (при наведении)",                  ///< ImGuiCol_TabHovered
    "Фон вкладки (активный)",                       ///< ImGuiCol_TabActive
    "Ползунок слайдера",                            ///< ImGuiCol_SliderGrab
    "Ползунок слайдера (активный)",                 ///< ImGuiCol_SliderGrabActive
    "Светлая граница таблицы",                      ///< ImGuiCol_TableBorderLight
    "Тёмная граница таблицы",                       ///< ImGuiCol_TableBorderStrong
    "Фон заголовка таблицы",                        ///< ImGuiCol_TableHeaderBg
    "Фон строки таблицы",                           ///< ImGuiCol_TableRowBg
    "Альтернативный фон строки таблицы",            ///< ImGuiCol_TableRowBgAlt
    "Маркер изменения размера",                     ///< ImGuiCol_ResizeGrip
    "Маркер изменения размера (активный)",          ///< ImGuiCol_ResizeGripActive
    "Маркер изменения размера (при наведении)"      ///< ImGuiCol_ResizeGripHovered
}; // const std::vector<std::string> plugin::gui::style::colors_placeholders

auto plugin::gui::style::apply_theme(ImGuiStyle& style, const theme_t& theme) noexcept -> void {
    static constexpr ImVec4 none_color = { 0.0f, 0.0f, 0.0f, 0.0f };
    interface_colors_t interface_colors = theme.interface_colors;

    ImVec4 surface[2] = { ImGui::ColorConvertU32ToFloat4(*interface_colors.surface[0]),
                          ImGui::ColorConvertU32ToFloat4(*interface_colors.surface[1]) };

    ImVec4 text[2] = { ImGui::ColorConvertU32ToFloat4(*interface_colors.text[0]),
                       ImGui::ColorConvertU32ToFloat4(*interface_colors.text[1]) };

    ImVec4 overlay[3] = { ImGui::ColorConvertU32ToFloat4(*interface_colors.overlay[0]),
                          ImGui::ColorConvertU32ToFloat4(*interface_colors.overlay[1]),
                          ImGui::ColorConvertU32ToFloat4(*interface_colors.overlay[2]) };

    current_theme = theme;

    set_color(style, ImGuiCol_Text, text[0]);
    set_color(style, ImGuiCol_TextDisabled, text[1]);
    set_color(style, ImGuiCol_WindowBg, surface[0]);
    set_color(style, ImGuiCol_ChildBg, surface[1]);
    set_color(style, ImGuiCol_PopupBg, surface[0]);
    set_color(style, ImGuiCol_Border, overlay[2]);
    set_color(style, ImGuiCol_BorderShadow, none_color);
    set_color(style, ImGuiCol_FrameBg, overlay[0]);
    set_color(style, ImGuiCol_FrameBgHovered, overlay[1]);
    set_color(style, ImGuiCol_FrameBgActive, overlay[2]);
    set_color(style, ImGuiCol_ScrollbarBg, surface[1]);
    set_color(style, ImGuiCol_ScrollbarGrab, overlay[0]);
    set_color(style, ImGuiCol_ScrollbarGrabHovered, overlay[1]);
    set_color(style, ImGuiCol_ScrollbarGrabActive, overlay[2]);
    set_color(style, ImGuiCol_Button, overlay[0]);
    set_color(style, ImGuiCol_ButtonHovered, overlay[1]);
    set_color(style, ImGuiCol_ButtonActive, overlay[2]);
    set_color(style, ImGuiCol_Header, overlay[0]);
    set_color(style, ImGuiCol_HeaderHovered, overlay[1]);
    set_color(style, ImGuiCol_HeaderActive, overlay[2]);
    set_color(style, ImGuiCol_Separator, overlay[0]);
    set_color(style, ImGuiCol_SeparatorHovered, overlay[0]);
    set_color(style, ImGuiCol_SeparatorActive, overlay[1]);
    set_color(style, ImGuiCol_TextSelectedBg, overlay[2]);
    set_color(style, ImGuiCol_Tab, overlay[0]);
    set_color(style, ImGuiCol_TabHovered, overlay[1]);
    set_color(style, ImGuiCol_TabActive, overlay[2]);
    set_color(style, ImGuiCol_SliderGrab, surface[1]);
    set_color(style, ImGuiCol_SliderGrabActive, surface[1]);
    set_color(style, ImGuiCol_TableBorderLight, overlay[2]);
    set_color(style, ImGuiCol_TableBorderStrong, overlay[2]);
    set_color(style, ImGuiCol_TableHeaderBg, surface[1]);
    set_color(style, ImGuiCol_TableRowBg, surface[0]);
    set_color(style, ImGuiCol_TableRowBgAlt, surface[0]);
    set_color(style, ImGuiCol_ResizeGrip, none_color);
    set_color(style, ImGuiCol_ResizeGripActive, none_color);
    set_color(style, ImGuiCol_ResizeGripHovered, none_color);
    set_color(style, ImGuiCol_ModalWindowDimBg, { 0, 0, 0, 0.5 });
}

auto plugin::gui::style::set_color(ImGuiStyle& style, ImGuiCol color_index, const ImVec4& color) noexcept -> void {
    style.Colors[color_index] = color;
    global_colors[color_index] = color;
}

auto plugin::gui::style::get_saved_theme() -> nlohmann::json& {
    return (*configuration)["internal"]["theme"];
}

auto plugin::gui::style::apply_theme(const theme_t& theme) -> void {
    apply_theme(ImGui::GetStyle(), theme);
}

auto plugin::gui::style::apply() -> void {
    ImGuiStyle& style = ImGui::GetStyle();

    style.AntiAliasedLines = true;
    style.AntiAliasedFill = true;

    style.IndentSpacing = 0.0f;
    style.ScrollbarSize = 10.0f;
    style.GrabMinSize = 10.0f;
    style.WindowBorderSize = 1.0f;
    style.ChildBorderSize = 1.0f;
    style.PopupBorderSize = 1.0f;
    style.FrameBorderSize = 1.0f;
    style.TabBorderSize = 1.0f;
    style.WindowRounding = 8.0f;
    style.ChildRounding = 8.0f;
    style.PopupRounding = 8.0f;
    style.FrameRounding = 8.0f;
    style.ScrollbarRounding = 5.0f;
    style.GrabRounding = 5.0f;
    style.TabRounding = 5.0f;

    style.WindowPadding = { 8.0f, 8.0f };
    style.FramePadding = { 5.0f, 5.0f };
    style.ItemSpacing = { 5.0f, 5.0f };
    style.ItemInnerSpacing = { 0.0f, 0.0f };
    style.TouchExtraPadding = { 0.0f, 0.0f };
    style.ButtonTextAlign = { 0.5f, 0.5f };
    style.SelectableTextAlign = { 0.5f, 0.5f };

    apply_theme(style, get_saved_theme());
}
