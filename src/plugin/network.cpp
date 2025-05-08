#include "plugin/network.h"
#include "plugin/log.h"
#include <errhandlingapi.h>
#include <windows.h>
#include <wininet.h>
#include <fstream>

bool
plugin::network::download_file(const std::string_view& url, const std::filesystem::path& output,
                              std::stop_token stop_token, bool secured) noexcept
{
    HINTERNET internet = InternetOpen(NULL, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);
    
    if (!internet) {
        log::error("InternetOpen failed: {}", GetLastError());
        return false;
    }

    DWORD flags = INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE;
    
    if (secured)
        flags |= INTERNET_FLAG_SECURE;

    HINTERNET internet_url = InternetOpenUrl(internet, std::string(url).c_str(), NULL, 0, flags, 0);
    
    if (!internet_url) {
        log::error("InternetOpenUrl failed: {}", GetLastError());
        InternetCloseHandle(internet);
        return false;
    }

    std::ofstream output_file(output, std::ios::binary);
    
    if (!output_file) {
        log::error("failed to open output file in plugin::network::download_file: {}", output.string());
        InternetCloseHandle(internet_url);
        InternetCloseHandle(internet);
        return false;
    }

    char buffer[4096];
    DWORD bytes_read;

    while (InternetReadFile(internet_url, buffer, sizeof(buffer), &bytes_read) && bytes_read != 0) {
        if (stop_token.stop_requested()) {
            log::warn("download cancelled");
            output_file.close();
            InternetCloseHandle(internet_url);
            InternetCloseHandle(internet);
            return false;
        }

        output_file.write(buffer, bytes_read);
    }

    output_file.close();
    InternetCloseHandle(internet_url);
    InternetCloseHandle(internet);

    return true;
}

std::string
plugin::network::fetch_file_content(const std::string_view& url, std::stop_token stop_token, bool secured) noexcept {
    HINTERNET internet = InternetOpen(NULL, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);

    if (!internet) {
        log::error("InternetOpen failed: {}", GetLastError());
        return "";
    }

    DWORD flags = INTERNET_FLAG_RELOAD | INTERNET_FLAG_NO_CACHE_WRITE;

    if (secured)
        flags |= INTERNET_FLAG_SECURE;

    HINTERNET internet_url = InternetOpenUrl(internet, std::string(url).c_str(), NULL, 0, flags, 0);

    if (!internet_url) {
        log::error("InternetOpenUrl failed: {}", GetLastError());
        InternetCloseHandle(internet);
        return "";
    }

    std::string content;
    char buffer[4096];
    DWORD bytes_read;

    while (InternetReadFile(internet_url, buffer, sizeof(buffer), &bytes_read) && bytes_read != 0) {
        if (stop_token.stop_requested()) {
            log::warn("download cancelled");
            InternetCloseHandle(internet_url);
            InternetCloseHandle(internet);
            return "";
        }

        content.append(buffer, bytes_read);
    }

    InternetCloseHandle(internet_url);
    InternetCloseHandle(internet);

    return content;
}
