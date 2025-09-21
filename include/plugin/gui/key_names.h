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

#ifndef GADMIN_PLUGIN_GUI_KEY_NAMES_H
#define GADMIN_PLUGIN_GUI_KEY_NAMES_H

#include <unordered_map>
#include <string>
#include <cstdint>

namespace plugin::gui {

/// Key names associated by their virtual key code.
static const std::unordered_map<std::uint8_t, std::string> key_names = {
    { 0x01, "LM" },
    { 0x02, "RMB" },
    { 0x03, "Cancel" },
    { 0x04, "MMB" },
    { 0x08, "Backspace" },
    { 0x09, "Tab" },
    { 0x0C, "Clear" },
    { 0x0D, "Enter" },
    { 0x10, "Shift" },
    { 0x11, "Ctrl" },
    { 0x12, "Alt" },
    { 0x13, "Pause" },
    { 0x14, "Caps Lock" },
    { 0x1B, "Escape" },
    { 0x20, "Space" },
    { 0x21, "Page Up" },
    { 0x22, "Page Down" },
    { 0x23, "End" },
    { 0x24, "Home" },
    { 0x25, "Arrow Left" },
    { 0x26, "Arrow Up" },
    { 0x27, "Arrow Right" },
    { 0x28, "Arrow Down" },
    { 0x29, "Select" },
    { 0x2A, "Print" },
    { 0x2B, "Execute" },
    { 0x2C, "Print Screen" },
    { 0x2D, "Insert" },
    { 0x2E, "Delete" },
    { 0x2F, "Help" },
    { 0x30, "0" },
    { 0x31, "1" },
    { 0x32, "2" },
    { 0x33, "3" },
    { 0x34, "4" },
    { 0x35, "5" },
    { 0x36, "6" },
    { 0x37, "7" },
    { 0x38, "8" },
    { 0x39, "9" },
    { 0x41, "A" },
    { 0x42, "B" },
    { 0x43, "C" },
    { 0x44, "D" },
    { 0x45, "E" },
    { 0x46, "F" },
    { 0x47, "G" },
    { 0x48, "H" },
    { 0x49, "I" },
    { 0x4A, "J" },
    { 0x4B, "K" },
    { 0x4C, "L" },
    { 0x4D, "M" },
    { 0x4E, "N" },
    { 0x4F, "O" },
    { 0x50, "P" },
    { 0x51, "Q" },
    { 0x52, "R" },
    { 0x53, "S" },
    { 0x54, "T" },
    { 0x55, "U" },
    { 0x56, "V" },
    { 0x57, "W" },
    { 0x58, "X" },
    { 0x59, "Y" },
    { 0x5A, "Z" },
    { 0x60, "Num 0" },
    { 0x61, "Num 1" },
    { 0x62, "Num 2" },
    { 0x63, "Num 3" },
    { 0x64, "Num 4" },
    { 0x65, "Num 5" },
    { 0x66, "Num 6" },
    { 0x67, "Num 7" },
    { 0x68, "Num 8" },
    { 0x69, "Num 9" },
    { 0x6A, "Multiply" },
    { 0x6B, "Add" },
    { 0x6C, "Separator" },
    { 0x6D, "Subtract" },
    { 0x6E, "Decimal" },
    { 0x6F, "Divide" },
    { 0x70, "F1" },
    { 0x71, "F2" },
    { 0x72, "F3" },
    { 0x73, "F4" },
    { 0x74, "F5" },
    { 0x75, "F6" },
    { 0x76, "F7" },
    { 0x77, "F8" },
    { 0x78, "F9" },
    { 0x79, "F10" },
    { 0x7A, "F11" },
    { 0x7B, "F12" },
    { 0x7C, "F13" },
    { 0x7D, "F14" },
    { 0x7E, "F15" },
    { 0x7F, "F16" },
    { 0x80, "F17" },
    { 0x81, "F18" },
    { 0x82, "F19" },
    { 0x83, "F20" },
    { 0x84, "F21" },
    { 0x85, "F22" },
    { 0x86, "F23" },
    { 0x87, "F24" },
    { 0x90, "Num Lock" },
    { 0x91, "Scroll Lock" },
    { 0xA0, "Left Shift" },
    { 0xA1, "Right Shift" },
    { 0xA2, "Left Ctrl" },
    { 0xA3, "Right Ctrl" },
    { 0xA4, "Left Alt" },
    { 0xA5, "Right Alt" },
    { 0xA6, "Browser Back" },
    { 0xA7, "Browser Forward" },
    { 0xA8, "Browser Refresh" },
    { 0xA9, "Browser Stop" },
    { 0xAA, "Browser Search" },
    { 0xAB, "Browser Favorites" },
    { 0xAC, "Browser Home" },
    { 0xAD, "Volume Mute" },
    { 0xAE, "Volume Down" },
    { 0xAF, "Volume Up" },
    { 0xB0, "Next Track" },
    { 0xB1, "Previous Track" },
    { 0xB2, "Stop Media" },
    { 0xB3, "Play/Pause Media" },
    { 0xB4, "Start Mail" },
    { 0xB5, "Select Media" },
    { 0xB6, "Start Application 1" },
    { 0xB7, "Start Application 2" },
    { 0xBA, "Semicolon" },
    { 0xBB, "Plus" },
    { 0xBC, "Comma" },
    { 0xBD, "Minus" },
    { 0xBE, "Period" },
    { 0xBF, "Slash" },
    { 0xC0, "Tilde" },
    { 0xDB, "Open Bracket" },
    { 0xDC, "Backslash" },
    { 0xDD, "Close Bracket" },
    { 0xDE, "Quote" }
}; // static const std::unordered_map<std::uint8_t, std::string> key_names

auto key_to_string(std::uint8_t key) noexcept -> std::string;

} // namespace plugin::gui

#endif // GADMIN_PLUGIN_GUI_KEY_NAMES_H
