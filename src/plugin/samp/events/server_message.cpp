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

#include "plugin/samp/events/server_message.h"
#include "plugin/string_utils.h"

auto plugin::samp::event<plugin::samp::event_id::server_message>::is_continuation_start(const std::string& text)
    noexcept -> bool
{
    return text.starts_with("... ");
}

auto plugin::samp::event<plugin::samp::event_id::server_message>::is_continuation_end(const std::string& text)
    noexcept -> bool
{
    return text.ends_with(" ..") || text.ends_with(" ..."); 
}

auto plugin::samp::event<plugin::samp::event_id::server_message>::trim_ellipsis(const std::string& text)
    noexcept -> std::string
{
    std::string output = text;

    if (is_continuation_start(output))
        output.erase(0, output.find_first_not_of('.'));

    if (is_continuation_end(output))
        output.erase(output.find_last_not_of('.'));

    return output;
}

auto plugin::samp::event<plugin::samp::event_id::server_message>::set_continuous_text_callback(
    std::string& storage,
    on_unwrapped_text_callback_t callback) const -> void
{
    std::string clean_text = string_utils::remove_samp_colors(text);

    if (!storage.empty()) {
        if (is_continuation_end(clean_text) && is_continuation_start(clean_text)) {
            storage = trim_ellipsis(storage) + trim_ellipsis(clean_text);
            return;
        }

        if (is_continuation_start(clean_text)) {
            callback(trim_ellipsis(storage) + trim_ellipsis(clean_text), color);
            storage.clear();
            return;
        }

        callback(storage, color);
        storage.clear();
        callback(clean_text, color);

        return;
    } else if (is_continuation_end(clean_text)) {
        storage = clean_text;
        return;
    }

    callback(clean_text, color);
}

auto plugin::samp::event<plugin::samp::event_id::server_message>::write(const std::string_view& new_text,
                                                                        const types::color& new_color) const
    -> void
{
    stream->reset_bit_stream();
    stream->write(new_color.cast<types::color_type::rgba>());
    stream->write_string<std::uint32_t>(string_utils::to_cp1251(std::string(new_text)));
}
