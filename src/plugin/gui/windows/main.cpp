#include "plugin/gui/windows/main.h"
#include "plugin/game/game.h"
#include "plugin/gui/widgets/frame_switcher.h"
#include "plugin/gui/widgets/menu_selector.h"
#include "plugin/log.h"
#include <imgui_internal.h>
#include <imgui.h>
#include <windows.h>

constexpr const char*
plugin::gui::windows::Main::get_id() const {
    return "windows::Main";
}

void
plugin::gui::windows::Main::render_menu() {
    ImGui::SetCursorPos({ 0, 0 });
    ImGui::PushStyleVar(ImGuiStyleVar_ChildBorderSize, 0);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 10, 10 });
    ImGui::BeginChild("windows::Main::menu", { menu_width, ImGui::GetWindowHeight() }, true);
    {
        ImGui::SetCursorPos({ 0, 0 });
        ImGui::BeginGroup();
        {
            widgets::menu_selector(this);
        }
        ImGui::EndGroup();
        ImGui::SetCursorPos({ menu_min_width + ImGui::GetStyle().ItemSpacing.x, ImGui::GetStyle().WindowPadding.y });
        ImGui::BeginGroup();
        {
            ImFont *left = (*child->fonts->bold)[24], *right = (*child->fonts->light)[18];
                
            float left_width = left->CalcTextSizeA(left->FontSize, FLT_MAX, 0, "GAdmin").x,
                  right_width = right->CalcTextSizeA(right->FontSize, FLT_MAX, 0, "v" PROJECT_VERSION).x;

            ImGui::SetCursorPosX((menu_max_width - left_width - right_width - 5) / 2 + ImGui::GetStyle().WindowPadding.x);
            ImGui::BeginGroup();
            {
                child->fonts->bold->text(24, "GAdmin");
                ImGui::SameLine(0, 5);
                ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 4);
                child->fonts->light->text(18, "v" PROJECT_VERSION);
            }
            ImGui::EndGroup();
            ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, { 5, 5 });
            ImGui::SetCursorPos({ 0, menu_min_width + ImGui::GetStyle().ItemSpacing.x });
            ImGui::BeginGroup();
            {
                widgets::frame_switcher<SelectedFrame::Home>(this);
                widgets::frame_switcher<SelectedFrame::Settings>(this);
                widgets::frame_switcher<SelectedFrame::KeyBinds>(this);
                widgets::frame_switcher<SelectedFrame::PlayerChecker>(this);
                widgets::frame_switcher<SelectedFrame::WindowsCustomization>(this);
                widgets::frame_switcher<SelectedFrame::Logs>(this);
                widgets::frame_switcher<SelectedFrame::ServerInformation>(this);
                widgets::frame_switcher<SelectedFrame::Binder>(this);
                widgets::frame_switcher<SelectedFrame::Notes>(this);
                widgets::frame_switcher<SelectedFrame::Statistics>(this);
                widgets::frame_switcher<SelectedFrame::PluginInformation>(this);
            }
            ImGui::EndGroup();
            ImGui::PopStyleVar();
        }
        ImGui::EndGroup();
    }
    ImGui::EndChild();
    ImGui::PopStyleVar(2);

    ImVec2 rect_min = ImGui::GetItemRectMin(), rect_max = ImGui::GetItemRectMax();
    {
        ImDrawList* draw_list = ImGui::GetWindowDrawList();
        float child_rounding = ImGui::GetStyle().ChildRounding;
        float child_border_size = ImGui::GetStyle().ChildBorderSize;

        draw_list->AddRectFilled({ rect_max.x - child_rounding, rect_min.y }, rect_max,
                                 ImGui::GetColorU32(ImGui::GetStyle().Colors[ImGuiCol_ChildBg]));
    }
}

void
plugin::gui::windows::Main::render() {
    auto [size_x, size_y] = game::get_screen_resolution();
    auto flags = ImGuiWindowFlags_NoTitleBar;

    ImGui::SetNextWindowPos({ size_x / 2, size_y / 2 }, ImGuiCond_FirstUseEver, { 0.5, 0.5 });
    ImGui::SetNextWindowSize({ 700, 455 }, ImGuiCond_FirstUseEver);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, { 0, 0 });
    ImGui::Begin(get_id(), nullptr, flags);
    {
        ImGui::SetCursorPosX(menu_min_width + ImGui::GetStyle().ItemSpacing.x);
        ImGui::BeginGroup();
        {
            child->fonts->light->push(18);
            {
                ImGui::Text("menu_opened = %i", menu_opened);
            }
            child->fonts->pop();
        }
        ImGui::EndGroup();
        render_menu();
    }
    ImGui::End();
    ImGui::PopStyleVar();
}

bool
plugin::gui::windows::Main::on_event(unsigned int message, WPARAM wparam, LPARAM lparam) {
    if (message == WM_KEYUP && wparam == 0x5A /* VK_Z */) {
        child->switch_cursor();
        return false;
    }

    return true;
}

plugin::gui::windows::Main::Main(utils::not_null<GraphicalUserInterface*> child) : child(child) {
    log::info("window \"{}\" initialized", get_id());
}

plugin::gui::WindowRef
plugin::gui::windows::main(utils::not_null<GraphicalUserInterface*> child) noexcept {
    return std::make_unique<Main>(child);
}