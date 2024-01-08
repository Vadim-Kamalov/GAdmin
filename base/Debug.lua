---
--- This file is compiled from the source code of the GAdmin project using the Lua dialect - Clue:
---
---     https://github.com/ClueLang/Clue/
---
--- The repository (as well as the source code) is licensed under the standard GNU General Public License version 3.
---
--- GAdmin Repository: https://github.com/Vadim-Kamalov/GAdmin/
--- GAdmin Contributors: https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTING.md
--- Build-Target: Debug (with environment variable __GADMIN_DEBUG__)
---
--- ************************************************************************
---
--- GAdmin - Script simplifying the work of administrators on the Gambit-RP
--- Copyright (C) 2023-2024 The Contributors.
---
--- This program is free software: you can redistribute it and/or modify
--- it under the terms of the GNU General Public License as published by
--- the Free Software Foundation, either version 3 of the License, or
--- (at your option) any later version.
---
--- This program is distributed in the hope that it will be useful,
--- but WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--- GNU General Public License for more details.
---
--- You should have received a copy of the GNU General Public License
--- along with this program.  If not, see <https://www.gnu.org/licenses/>.
---
--- SDPX-License-Identifier: GPL-3.0-only
---

script_name         "GAdmin"
script_authors      "https://github.com/Vadim-Kamalov/GAdmin/blob/main/CONTRIBUTORS"
script_url          "https://github.com/Vadim-Kamalov/GAdmin/"
script_properties   "work-in-pause"

local import, modules
do
    function import(name)
        if modules[name] == nil then
            sampfuncsLog("{FF0000}__GADMIN_DEBUG__: {FFFFFF} attempting to import non-existent module: " .. name)
        else
            return modules[name]()
        end
    end
end

---! BEGIN_AUTO_GENERATED_CONTENT

--STATICS

modules = {§}

---! END_AUTO_GENERATED_CONTENT

import("EncodingCompatibility")
import("Main")

for name, _ in pairs(modules) do
    if string.find(name, "^events%.") or string.find(name, "^imgui%.windows%.") then
        import(name)
    end
end
