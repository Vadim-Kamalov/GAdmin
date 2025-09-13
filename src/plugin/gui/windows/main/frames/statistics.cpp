#include "plugin/gui/windows/main/frames/statistics.h"
#include "plugin/gui/widgets/button.h"
#include "plugin/gui/widgets/text.h"

const std::vector<plugin::gui::windows::main::frames::statistics::plot_info_t>
plugin::gui::windows::main::frames::statistics::plots = {
    { "Время онлайн", plot_key_t::total_time, plot_type_t::time },
    { "Время на /alogin", plot_key_t::time_on_alogin, plot_type_t::time },
    { "Ответы", plot_key_t::answer },
    { "Сообщений /a", plot_key_t::a_chat_message },
    { "Блокировки", plot_key_t::ban },
    { "Выданные PK", plot_key_t::pk },
    { "Выданные CK", plot_key_t::ck },
    { "Варны", plot_key_t::warn },
    { "Отключений /kick", plot_key_t::kick },
    { "Блокировки чата", plot_key_t::mute },
}; // plugin::gui::windows::main::frames::statistics::plots

auto plugin::gui::windows::main::frames::statistics::date_to_ymd(const misc::statistics_t::date_t& date)
    -> std::chrono::year_month_day
{
    return std::chrono::year(2000 + date.year) / std::chrono::month(date.month) / std::chrono::day(date.day);
}

auto plugin::gui::windows::main::frames::statistics::is_hour_range_in_peak(const misc::statistics_t::range_t& range)
    -> bool
{
    std::time_t time = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm now_tm = *std::localtime(&time);
    std::tm gmt_tm = *std::gmtime(&time);

    int timezone_offset = std::difftime(std::mktime(&now_tm), std::mktime(&gmt_tm)) / 3600;
    std::uint8_t gmt_hour = (range.first - timezone_offset + 24) % 24;

    return gmt_hour >= gmt_peak_hours.first && gmt_hour <= gmt_peak_hours.second;
}

auto plugin::gui::windows::main::frames::statistics::is_in_current_week(const misc::statistics_t::date_t& date)
    -> bool
{
    using namespace std::chrono;

    auto now_time_t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm local_tm = *std::localtime(&now_time_t);
    
    year_month_day current_ymd = year(local_tm.tm_year + 1900) / month(local_tm.tm_mon + 1) / day(local_tm.tm_mday);
    year_month_day date_ymd = date_to_ymd(date); 

    sys_days now = current_ymd;
    auto monday = now - (weekday(now) - Monday);
    auto sunday = monday + days(6);
    auto date_days = sys_days(date_ymd);

    return date_days >= monday && date_days <= sunday;
}

auto plugin::gui::windows::main::frames::statistics::render_day_plot(const plot_info_t& plot_info) -> void {
    std::vector<widgets::plot::value_t> values(hours_in_day);
    
    for (const auto& value : misc::statistics.get_today_entry().entries[std::to_underlying(plot_info.key)])
        values[value.range.first] = value.value;

    day_plot.set_values(values);
    day_plot.set_value_formatter([&plot_info](auto value) {
        if (plot_info.type == plot_type_t::time)
            return std::format("{:02}", value / 60);

        return std::to_string(value);
    });

    ImGui::PushFont(bold_font, title_font_size);
    {
        ImGui::SameLine(ImGui::GetWindowWidth() - ImGui::CalcTextSize(day_plot_title).x);
        ImGui::TextUnformatted(day_plot_title);
    }
    ImGui::PopFont();
    ImGui::PushFont(bold_font, day_plot_font_size);
    {
        ImVec2 region_avail = ImGui::GetContentRegionAvail();
        day_plot.render({ region_avail.x, region_avail.y / 2.0f });
    }
    ImGui::PopFont();
}

auto plugin::gui::windows::main::frames::statistics::render_week_plot(const plot_info_t& plot_info) -> void {
    write_week_plot_values(plot_info);
    week_plot.set_value_formatter([&plot_info](auto value) {
        if (plot_info.type == plot_type_t::time)
            return std::format("{:02}:{:02}", value / 3600, (value % 3600) / 60);

        return std::to_string(value);
    });

    ImGui::BeginGroup();
    {
        ImGui::PushFont(bold_font, title_font_size);
        {
            ImGui::SetCursorPosX(ImGui::GetWindowWidth() - ImGui::CalcTextSize(week_plot_title).x);
            ImGui::TextUnformatted(week_plot_title);
        }
        ImGui::PopFont();
        ImGui::PushFont(bold_font, week_plot_font_size);
        {
            week_plot.render(ImGui::GetContentRegionAvail());
        }
        ImGui::PopFont();
    }
    ImGui::EndGroup();
}

auto plugin::gui::windows::main::frames::statistics::write_week_plot_values(const plot_info_t& plot_info) -> void {
    std::vector<widgets::plot::value_t> values(days_in_week);

    for (const auto& date_entry : misc::statistics.date_entries | std::views::reverse) {
        if (!is_in_current_week(date_entry.date))
            break;

        std::chrono::sys_days sys_days = date_to_ymd(date_entry.date);
        std::uint8_t weekday_index = std::chrono::weekday(sys_days).iso_encoding() - 1;
        std::uint32_t weekday_value = 0;

        for (const auto& value : date_entry.entries[std::to_underlying(plot_info.key)])
            weekday_value += value.value;

        values[weekday_index] = weekday_value;
    }

    week_plot.set_values(values);
}

auto plugin::gui::windows::main::frames::statistics::format_value(const plot_type_t& type, std::uint32_t value) const
    -> std::string
{
    if (type == plot_type_t::time)
        return std::format("{:02}:{:02}:{:02}", value / 3600, (value % 3600) / 60, value % 60);

    return std::to_string(value);
}

auto plugin::gui::windows::main::frames::statistics::get_time_periods(const plot_info_t& plot) const -> time_periods_t {
    auto today = misc::statistics_t::date_t::today();
    time_periods_t periods;

    for (const auto& date_entry : misc::statistics.date_entries) {
        for (const auto& value : date_entry.entries[std::to_underlying(plot.key)]) {
            periods.total += value.value;
            
            if (is_in_current_week(date_entry.date))
                periods.week += value.value;

            if (date_entry.date == today) {
                if (is_hour_range_in_peak(value.range))
                    periods.peak += value.value;

                periods.today += value.value;
            }
        }
    }

    return periods;
}

auto plugin::gui::windows::main::frames::statistics::frame_renderer(std::string& label, std::any& payload) -> void {
    plot_info_t plot_info = std::any_cast<plot_info_t>(payload);
    time_periods_t periods = get_time_periods(plot_info);

    gui::widgets::text(bold_font, title_font_size, 0, "{}", label);
    render_day_plot(plot_info);
    ImGui::BeginGroup();
    {
        ImGui::BeginGroup();
        {
            gui::widgets::text(bold_font, title_font_size, 0, "Общая статистика");
            gui::widgets::text(bold_font, common_font_size, 0, "Всего: ");
            ImGui::SameLine(0.0f, 0.0f);
            gui::widgets::text(regular_font, common_font_size, 0, "{}", format_value(plot_info.type, periods.total));
            gui::widgets::text(bold_font, common_font_size, 0, "Сегодня: ");
            ImGui::SameLine(0.0f, 0.0f);
            gui::widgets::text(regular_font, common_font_size, 0, "{}", format_value(plot_info.type, periods.today));
            gui::widgets::text(bold_font, common_font_size, 0, "Неделя: ");
            ImGui::SameLine(0.0f, 0.0f);
            gui::widgets::text(regular_font, common_font_size, 0, "{}", format_value(plot_info.type, periods.week));
            gui::widgets::text(bold_font, common_font_size, 0, "В пике (сегодня): ");
            ImGui::SameLine(0.0f, 0.0f);
            gui::widgets::text(regular_font, common_font_size, 0, "{}", format_value(plot_info.type, periods.peak));
        }
        ImGui::EndGroup();
        ImGui::SetCursorPosY(ImGui::GetWindowHeight() - clear_button_height);

        if (gui::widgets::button("Очистить##plot:" + label, { ImGui::GetItemRectSize().x, clear_button_height })
            .render())
        {
            for (auto& date_entry : misc::statistics.date_entries)
                date_entry.entries[std::to_underlying(plot_info.key)].clear();
        }
    }
    ImGui::EndGroup();
    ImGui::SameLine(0.0f, ImGui::GetStyle().WindowPadding.x);
    render_week_plot(plot_info);
}

auto plugin::gui::windows::main::frames::statistics::render() -> void {
    submenu.render_menu(child);
    ImGui::SameLine();
    submenu.render_current_frame(child);
}

plugin::gui::windows::main::frames::statistics::statistics(types::not_null<initializer*> child)
    : child(child),
      bold_font(child->child->fonts->bold),
      regular_font(child->child->fonts->regular)
{
    using namespace std::placeholders;

    week_plot.set_lines_descriptions({ "Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс" });
    day_plot.set_lines_descriptions({ "00", "01", "02", "03", "04", "05", "06", "07",
                                      "08", "09", "10", "11", "12", "13", "14", "15",
                                      "16", "17", "18", "19", "20", "21", "22", "23" });
    
    submenu.set_frame_renderer(std::bind(&statistics::frame_renderer, this, _1, _2));

    for (const auto& plot : plots)
        submenu.add_entry(plot.label, std::make_any<plot_info_t>(plot));
}
