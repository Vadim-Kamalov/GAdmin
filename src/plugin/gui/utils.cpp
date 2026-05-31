#include "plugin/gui/utils.h"
#include "plugin/gui/icon.h"
#include "plugin/gui/notify.h"
#include <imgui_internal.h>

auto plugin::gui::utils::allow_copy_row(const std::string& text) noexcept -> void {
    ImGuiTable* table = ImGui::GetCurrentContext()->CurrentTable;

    // If we don't jump to the last column it will fail to calculate the rect size
    // Just in case we didn't render enough columns
    ImGui::TableSetColumnIndex(table->Columns.size() - 1);

    ImRect row_rect = { table->WorkRect.Min.x, table->RowPosY1, table->WorkRect.Max.x, table->RowPosY2 };
    row_rect.ClipWith(table->BgClipRect);

    if (!ImGui::IsMouseHoveringRect(row_rect.Min, row_rect.Max, false) || !ImGui::IsWindowHovered() || ImGui::IsAnyItemHovered())
        return;

    table->RowBgColor[1] = ImGui::GetColorU32(ImGuiCol_Border);

    if (!ImGui::IsMouseReleased(ImGuiMouseButton_Left))
        return;

    ImGui::SetClipboardText(text.c_str());
    gui::notify::send(gui::notification("Текст скопирован", "Информация из строки таблицы успешно скопирована!", ICON_COPY));
}
