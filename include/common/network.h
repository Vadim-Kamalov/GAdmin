#ifndef GADMIN_COMMON_NETWORK_H
#define GADMIN_COMMON_NETWORK_H

#include <functional>
#include <stop_token>
#include <string_view>
#include <filesystem>
#include <windows.h>
#include <wininet.h>

namespace common {

class internet_t final {
private:
    static constexpr DWORD internet_flags =
        INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE | INTERNET_FLAG_SECURE;
    
    bool valid = true;
    std::stop_token stop_token;
public:
    using read_file_callback_t = std::function<void(char buffer[4096], std::size_t bytes_read)>;

    HINTERNET handle;
    HINTERNET url;
    
    inline auto is_available() const -> bool;
    inline explicit operator bool() const;
    auto read_file(read_file_callback_t callback) const -> bool;

    template<typename... Args>
    static auto close_handlers(Args&&... handlers) noexcept -> void;

    explicit internet_t(const std::string_view& link, std::stop_token stop_token);
    ~internet_t() noexcept;
}; // class internet_t final

class network final {
private:
    static constexpr const char* headers = "User-Agent: GAdmin/1.0\r\n";
public:
    static auto download_file(const std::string_view& url, const std::filesystem::path& output,
                              std::stop_token stop_token = std::stop_token()) noexcept -> bool;
    
    static auto fetch_file_content(const std::string_view& url,
                                   std::stop_token stop_token = std::stop_token()) noexcept -> std::string;
    
    static auto send_get_request(const std::string_view& url,
                                 std::stop_token stop_token = std::stop_token()) noexcept -> std::string;
}; // class network final

} // namespace common

inline auto common::internet_t::is_available() const -> bool {
    return valid;
}

inline common::internet_t::operator bool() const {
    return is_available();
}

template<typename... Args>
auto common::internet_t::close_handlers(Args&&... handlers) noexcept -> void {
    (InternetCloseHandle(std::forward<Args>(handlers)), ...);
}

#endif // GADMIN_COMMON_NETWORK_H
