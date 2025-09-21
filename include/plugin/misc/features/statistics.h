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

#ifndef GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H
#define GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H

#include "plugin/misc/base/feature.h"
#include "plugin/samp/events/server_message.h"
#include <nlohmann/json.hpp>
#include <filesystem>
#include <utility>
#include <chrono>
#include <vector>
#include <fstream>

namespace plugin::misc {

/// Represents user statistics separated by days and specific ranges (usually hourly ranges).
/// Data is stored internally in a file with the following specification:
///
///     File Format:
///
///         - The file consists of a sequence of date entries.
///         
///         - Each date entry starts with an `OPCODE_DATE` byte, followed by 3 bytes representing
///           the `date_t` structure.
///         
///         - After the date, a sequence of entries follows. Each entry starts with an `OPCODE_ENTRY`
///           byte. The `OPCODE_ENTRY` byte is structured as `0bXXXXXX1`, where `XXXXXX` represents the
///           index of the `entry_type`.
///         
///         - After the `OPCODE_ENTRY` byte, a single byte indicates the count of `value_t` structures
///           that follow.
///         
///         - Each `value_t` structure consists of 4 bytes: 2 bytes for the `range_t` (first and second)
///           and 2 bytes for the `value`.
///
///     Example:
///
///         [OPCODE_DATE][YY][MM][DD][OPCODE_ENTRY][COUNT][VALUE_1][VALUE_2]...[VALUE_N]
/// 
/// Data is handled by the `features::statistics_updater`.
class statistics_t final {
public:
    /// Represents a date: year, month and day.
    struct date_t final {
        std::uint8_t year;  ///< Years since 2000: `[0; 255]`.
        std::uint8_t month; ///< Months since January: `[1; 12]`.
        std::uint8_t day;   ///< Day of the month: `[1; 31]`.

        /// Check the equality of two dates.
        ///
        /// @param other[in] Date to compare with.
        /// @paturn          True if the dates are equal.
        auto operator==(const date_t& other) const -> bool;
        
        /// Get current local date from the system.
        /// 
        /// @return Current local date.
        static auto today() noexcept -> date_t;
    }; // struct date_t final

    /// Represents a `[first; second]` range with `sizeof(std::uint8_t)` limit for each value.
    struct range_t final {
        std::uint8_t first;  ///< First value in the range.
        std::uint8_t second; ///< Second value in the range.
    
        /// Check the equality of two ranges.
        ///
        /// @param other[in] Range to compare with.
        /// @return          True if the ranges are equal.
        auto operator==(const range_t& other) const -> bool;

        /// Get current local hour range: `[current_hour; (current_hour + 1) % 24]`
        ///
        /// @return Current hour range.
        static auto current_hours() noexcept -> range_t;
    }; // struct range_t final

    /// Represents value in the statistics with a range.
    struct value_t final {
        range_t range;       ///< Range of the value (e.g., hours when value is set).
        std::uint16_t value; ///< Actual value.
    }; // struct value_t final

    /// Represents types of entries in the statistics.
    ///
    /// Note: Only `(<7 bits max value> - 1 (entry_type::count)) = 127` entries can
    /// be used. The last bit is reserved to indicate the `OPCODE_ENTRY` in the file.
    enum class entry_type : std::uint8_t {
        time_on_alogin, ///< User's time on /alogin while menu is not active.
        total_time,     ///< User's total time in the game while menu is not active.
        a_chat_message, ///< User's total messages sent in the `/a` chat.
        answer,         ///< User's total answers sent via `/ans` command.
        ban,            ///< User's issued bans (`/ban`).
        pk,             ///< User's issued PKs (`/pk`).
        ck,             ///< User's issued CKs (`/ck`).
        warn,           ///< User's issued warns (`/warn`).
        kick,           ///< User's issued disconnections (`/kick`).
        mute,           ///< User's issued mutes (`/mute`).
        count,          ///< Total count of the entries in this enumeration. Must always be the last entry.
        none = count    ///< None entry type: same as `entry_type::count` and must not be used in statistics.
    }; // enum class entry_type : std::uint8_t
   
    /// Represents an entry in the statistics associated with `entry_type`.
    using entry_t = std::vector<value_t>; ///< Represents entry in the statistics associated with `entry_type`.
    
    /// Represents all entries in the statistics.
    using entries_t = std::array<entry_t, std::to_underlying(entry_type::count)>;

    /// Represents a date associated with entries in the statistics.
    struct date_entry_t final {
        date_t date;       ///< Date when the entries are valid.
        entries_t entries; ///< Entries for this date.

        /// Increment value in the entries for a specific `entry_type` and range.
        ///
        /// @note If no entry is found, a new value is inserted with the passed
        ///       `range` and a value of 1.
        ///
        /// @param entry[in] Entry type to increment.
        /// @param range[in] Range of the value to increment.
        auto increment_value_at(const entry_type& entry, const range_t& range) -> void;
    }; // struct entry_t final
private:
    /// Represents all used opcodes in the file.
    enum file_opcode : std::uint8_t {
        /// Binary: `0b00000000`
        ///
        /// Indicates that the next 3 bytes represent a `date_t`
        /// structure. Must be followed by an `OPCODE_ENTRY`.
        OPCODE_DATE = 0x00,

        /// Binary: `0bXXXXXX1`, where `X` represents the index of `entry_type`.
        ///
        /// Not an opcode, but a specification for entries. Indicates the entry type and the number
        /// of `value_t` structures to parse. Format: `OPCODE_ENTRY <COUNT> (<VALUE> * COUNT)`.
        OPCODE_ENTRY = 0x01
    }; // enum file_opcode : std::uint8_t

    template<typename T>
    static auto read_value(std::ifstream& file, T& output) -> bool;
    
    template<typename T>
    static auto write_value(std::ofstream& file, const T& value) -> bool;

    static auto read_date(std::ifstream& file, date_t& output) -> bool;
    static auto read_value(std::ifstream& file, value_t& output) -> bool;
    static auto write_date(std::ofstream& file, const date_t& date) -> bool;
    static auto write_value(std::ofstream& file, const value_t& value) -> bool;
public:
    /// Represents statistics' data as a vector of date entries.
    std::vector<date_entry_t> date_entries;
    
    /// Parse data from the file at `path` and write it into `date_entries`.
    ///
    /// @note           When called, the `date_entries` vector is cleared.
    /// @param path[in] Path of the file to parse.
    auto read(const std::filesystem::path& path) -> void;

    /// Write date from the `date_entries` to the file at `path`.
    ///
    /// @param path[in] Path of the file to write.
    auto write(const std::filesystem::path& path) -> void;

    /// Get the date entry for `date_t::today()`.
    ///
    /// @note If no date entry is found, a new entry with `date_t::today()`
    ///       is inserted into `date_entries` and returned.
    ///
    /// @return Reference to the date entry.
    auto get_today_entry() -> date_entry_t&;
}; // struct statistics final

/// Current user's statistics. Handled by `features::statistics_updater.`.
///
/// @see plugin::misc::features::statistics_updater
/// @see plugin::misc::statistics_t
inline statistics_t statistics;

namespace features {

/// Represents the statistics' updater: read/writes initial values
/// and inserts/increments those by some of the user actions.
class statistics_updater final : public feature {
private:
    static std::filesystem::path file_path;
    std::chrono::steady_clock::time_point time_updated;

    auto try_increment_punishment(const std::string_view& punisment_text) const -> void;
    auto on_server_message(const samp::event<samp::event_id::server_message>& message) const -> bool;
public:
    auto on_event(const samp::event_info& event) -> bool override;
    auto main_loop() -> void override;

    explicit statistics_updater();
    ~statistics_updater() noexcept;
}; // class statistics_updater final : public feature

} // namespace features
} // namespace plugin::misc

template<typename T>
auto plugin::misc::statistics_t::read_value(std::ifstream& file, T& output) -> bool {
    return !!file.read(reinterpret_cast<char*>(&output), sizeof(T));
}
    
template<typename T>
auto plugin::misc::statistics_t::write_value(std::ofstream& file, const T& value) -> bool {
    return !!file.write(reinterpret_cast<const char*>(&value), sizeof(T));
}

#endif // GADMIN_PLUGIN_MISC_FEATURES_STATISTICS_H
