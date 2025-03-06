#include "plugin/samp/core/chat.h"
#include "plugin/types/address.h"

plugin::types::versioned_address_container<plugin::signatures::add_message_t>
plugin::samp::chat::add_message_container = { 0x645A0, 0x679F0, 0x68170, 0x67BE0 };

plugin::types::versioned_address_container<std::uintptr_t>
plugin::samp::chat::instance_container = { 0x21A0E4, 0x26E8C8, 0x26EB80, 0x2ACA10 };
