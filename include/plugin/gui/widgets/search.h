#ifndef GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
#define GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H

#include <format>
#include <string>

namespace plugin::gui::widgets {

class search {
private:
    std::string id = "";
    std::string buffer = "";
public:
    void render(float width = 0, const std::string_view& placeholder = "");
    void clear();

    bool contains(std::string text) const;
    bool empty() const;

    template<typename... Args>
    bool contains(std::format_string<Args...> fmt, Args&&... args) const;

    explicit search(const std::string_view& id)
        : id(std::move(id)) {}
}; // class search

} // namespace plugin::gui::widgets

template<typename... Args>
bool
plugin::gui::widgets::search::contains(std::format_string<Args...> fmt, Args&&... args) const {
    return contains(std::format(fmt, std::forward<Args>(args)...));
}


#endif // GADMIN_PLUGIN_GUI_WIDGETS_SEARCH_H
