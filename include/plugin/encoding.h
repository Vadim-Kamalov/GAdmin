#ifndef GADMIN_PLUGIN_ENCODING_H
#define GADMIN_PLUGIN_ENCODING_H

#include <string>
#include <windows.h>

namespace plugin::encoding {

std::string to_utf8(const std::string& text);

} // namespace plugin::encoding

#endif // GADMIN_PLUGIN_ENCODING_H
