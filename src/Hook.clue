/**
 * GAdmin - Script simplifying the work of administrators on the Gambit-RP
 * Copyright (C) 2023 The Contributors.
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

@define JMP_HOOK        global fn
@define JMP_HOOK_NEW    global

ffi.cdef("
    int VirtualProtect(
        void*           lpAddress,
        unsigned long   dwSize,
        unsigned long   flNewProtect,
        unsigned long*  lpflOldProtect
    );
")

static __hooks__ = { hooks = {} }

method __hooks__::new(cast, callback, hookAddress, size = 5) {
    jit.off(callback, true)

    local newHook = { status = false }
    local detourAddress = tonumber(ffi.cast("intptr_t", ffi.cast("void*", ffi.cast(cast, callback))))
    local voidAddress = ffi.cast("void*", hookAddress)
    local oldProt = ffi.new("unsigned long[1]")
    local orgBytes = ffi.new("uint8_t[?]", size)
    
    ffi.copy(orgBytes, voidAddress, size)
    
    local hookBytes = ffi.new("uint8_t[?]", size, 0x90)
    hookBytes[0] = 0xE9
    ffi.cast("uint32_t*", hookBytes + 1)[0] = detourAddress - hookAddress - 5
    
    local fn setStatus(bool) {
        newHook.status = bool
        ffi.C.VirtualProtect(voidAddress, size, 0x40, oldProt)
        ffi.copy(voidAddress, (bool) ? hookBytes : orgBytes, size)
        ffi.C.VirtualProtect(voidAddress, size, oldProt[0], oldProt)
    }

    newHook.call   = ffi.cast(cast, hookAddress)
    newHook.status = false
    newHook.stop   = fn { setStatus(false) }
    newHook.start  = fn { setStatus(true) }
    
    newHook.start()
    table.insert(self.hooks, newHook)
    
    return setmetatable(newHook, {
        __call = fn(self, ...) {
            self.stop()
            local result = self.call(...)
            self.start()
            return result
        }
    })
}

method __hooks__::unref() {
    for _, hook in self.hooks {
        if hook.status {
            hook.stop()
        }
    }
}

return __hooks__
