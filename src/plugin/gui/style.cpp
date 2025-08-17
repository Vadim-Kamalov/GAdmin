#include "plugin/gui/style.h"
#include <imgui.h>

auto plugin::gui::style::apply() noexcept -> void {
    ImGuiStyle& style = ImGui::GetStyle();

    style.AntiAliasedLines = true;
    style.AntiAliasedFill = true;

    style.IndentSpacing = 0;
    style.ScrollbarSize = 10;
    style.GrabMinSize = 10;
    style.WindowBorderSize = 1;
    style.ChildBorderSize = 1;
    style.PopupBorderSize = 1;
    style.FrameBorderSize = 1;
    style.TabBorderSize = 1;
    style.WindowRounding = 8;
    style.ChildRounding = 8;
    style.PopupRounding = 8;
    style.FrameRounding = 8;
    style.ScrollbarRounding = 5;
    style.GrabRounding = 5;
    style.TabRounding = 5;

    style.WindowPadding = { 8, 8 };
    style.FramePadding = { 5, 5 };
    style.ItemSpacing = { 5, 5 };
    style.ItemInnerSpacing = { 0, 0 };
    style.TouchExtraPadding = { 0, 0 };
    style.ButtonTextAlign = { 0.5, 0.5 };
    style.SelectableTextAlign = { 0.5, 0.5 };
   
    ImVec4 surface[2] = { ImGui::ColorConvertU32ToFloat4(0xFF241717), ImGui::ColorConvertU32ToFloat4(0xFF2E1D1D) };
    ImVec4 none = { 0, 0, 0, 0 };
    ImVec4 text[2] = { ImGui::ColorConvertU32ToFloat4(0xFFDEC2BA), ImGui::ColorConvertU32ToFloat4(0xFF5A4745) };
    ImVec4 overlay[3] = { ImGui::ColorConvertU32ToFloat4(0xFF3F302F), ImGui::ColorConvertU32ToFloat4(0xFF4E3E3C),
                          ImGui::ColorConvertU32ToFloat4(0xFF372A2A) };

    style.Colors[ImGuiCol_Text] = text[0];
    style.Colors[ImGuiCol_TextDisabled] = text[1];
    style.Colors[ImGuiCol_WindowBg] = surface[0];
    style.Colors[ImGuiCol_ChildBg] = surface[1];
    style.Colors[ImGuiCol_PopupBg] = surface[0];
    style.Colors[ImGuiCol_Border] = overlay[2];
    style.Colors[ImGuiCol_BorderShadow] = none;
    style.Colors[ImGuiCol_FrameBg] = overlay[0];
    style.Colors[ImGuiCol_FrameBgHovered] = overlay[1];
    style.Colors[ImGuiCol_FrameBgActive] = overlay[2];
    style.Colors[ImGuiCol_ScrollbarBg] = surface[1];
    style.Colors[ImGuiCol_ScrollbarGrab] = overlay[0];
    style.Colors[ImGuiCol_ScrollbarGrabHovered] = overlay[1];
    style.Colors[ImGuiCol_ScrollbarGrabActive] = overlay[2];
    style.Colors[ImGuiCol_Button] = overlay[0];
    style.Colors[ImGuiCol_ButtonHovered] = overlay[1];
    style.Colors[ImGuiCol_ButtonActive] = overlay[2];
    style.Colors[ImGuiCol_Header] = overlay[0];
    style.Colors[ImGuiCol_HeaderHovered] = overlay[1];
    style.Colors[ImGuiCol_HeaderActive] = overlay[2];
    style.Colors[ImGuiCol_Separator] = overlay[0];
    style.Colors[ImGuiCol_SeparatorHovered] = overlay[0];
    style.Colors[ImGuiCol_SeparatorActive] = overlay[1];
    style.Colors[ImGuiCol_TextSelectedBg] = overlay[2];
    style.Colors[ImGuiCol_Tab] = overlay[0];
    style.Colors[ImGuiCol_TabHovered] = overlay[1];
    style.Colors[ImGuiCol_TabActive] = overlay[2];
    style.Colors[ImGuiCol_SliderGrab] = surface[1];
    style.Colors[ImGuiCol_SliderGrabActive] = surface[1];
    style.Colors[ImGuiCol_TableBorderLight] = overlay[2];
    style.Colors[ImGuiCol_TableBorderStrong] = overlay[2];
    style.Colors[ImGuiCol_TableHeaderBg] = surface[1];
    style.Colors[ImGuiCol_TableRowBg] = surface[0];
    style.Colors[ImGuiCol_TableRowBgAlt] = surface[0];
    style.Colors[ImGuiCol_ResizeGrip] = none;
    style.Colors[ImGuiCol_ResizeGripActive] = none;
    style.Colors[ImGuiCol_ResizeGripHovered] = none;
    style.Colors[ImGuiCol_ModalWindowDimBg] = { 0, 0, 0, 0.5 };
}
