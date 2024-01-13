/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023-2024 The Contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SDPX-License-Identifier: GPL-3.0-only
 */

global _sampAddChatMessage = sampAddChatMessage
global fn sampAddChatMessage(text, color) {
    _sampAddChatMessage(u8::decode(text), color)
}

global _sampSendChat = sampSendChat
global fn sampSendChat(message) {
    _sampSendChat(u8::decode(message))
}

global _sampSendDialogResponse = sampSendDialogResponse
global fn sampSendDialogResponse(id, button, listItem, input) {
    _sampSendDialogResponse(id, button, listItem, (input) ? u8::decode(input) : "")
}

global fn setClipboardText(text) {
    imgui.SetClipboardText(text)
}
