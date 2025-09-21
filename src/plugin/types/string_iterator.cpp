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

#include "plugin/types/string_iterator.h"

auto plugin::types::string_iterator::current() const
    -> std::optional<unsigned char>
{
    if (index >= input.length())
        return {};

    return input[index];
}

auto plugin::types::string_iterator::consume()
    -> unsigned char
{
    return input[index++];
}

auto plugin::types::string_iterator::remaining()
    -> std::string
{
    return input.substr(index);
}
