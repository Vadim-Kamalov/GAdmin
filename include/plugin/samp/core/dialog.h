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

#ifndef GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
#define GADMIN_PLUGIN_SAMP_CORE_DIALOG_H

#include "plugin/types/address.h"
#include <cstdint>

namespace plugin::samp {

/// Provides methods for managing SA:MP dialog window.
class dialog final {
private:
    static types::versioned_address_container<std::uintptr_t> instance_container;
    static inline types::offset<int> active_offset = 0x28; 
public:
    static constexpr std::uint16_t list_item_none = 0xFFFF; ///< None list item.
    static constexpr std::uint16_t invalid_id = 0xFFFF;     ///< Invalid dialog ID.
    static constexpr std::uint8_t send_response_id = 62;    ///< RPC ID for sending dialog responses.

    /// Buttons in the dialog.
    enum class button : std::uint8_t {
        left, ///< Left button in the dialog.
        right ///< Right button in the dialog.
    }; // enum class button : std::uint8_t

    /// Dialog styles.
    enum class style : std::uint8_t {
        message_box,     ///< Dialog with only the text inside of it.
        input,           ///< Dialog with the input inside of it.
        list,            ///< Dialog with the list of items inside of it.
        password,        ///< Same as `input` but the typed value is hidden.
        tab_list,        ///< Same as `list` but can be separated by the columns.
        tab_list_headers ///< Same as `tab_list` but with the titles for the columns.
    }; // enum class style : std::uint8_t

    /// Send response to the dialog with specific button.
    ///
    /// @param id[in]        Dialog ID.
    /// @param button[in]    Dialog button.
    /// @param list_item[in] Dialog list item. Can be set to `list_item_none`, if there's no need for this.
    /// @parma input[in]     Dialog text to set in the input. Can be set to empty string, if there's no need for this.
    static auto send_response(std::uint16_t id, const button& button, std::uint16_t list_item = list_item_none,
                              const std::string_view& input = "") noexcept -> void;

    /// Check if any dialog on the screen is active.
    ///
    /// @return True if any dialog on the screen is active.
    static auto is_active() noexcept -> bool;
}; // class dialog final

} // namespace plugin::samp

#endif // GADMIN_PLUGIN_SAMP_CORE_DIALOG_H
