# GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2026 The Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0-only

!include      "LogicLib.nsh"
!include      "StrFunc.nsh"
!addplugindir "../build/plugins"

${using:strfunc} strloc

!macro SET_INSTALL_DIRECTORY
    readregstr $0 HKCU "Software\SAMP" "gta_sa_exe"
    ${if} $0 != ""
        strcpy $1 "$0"
        ${strloc} $2 $1 "\gta_sa.exe" 0
        ${if} $2 != ""
            strcpy $2 $1 $2
            strcpy $INSTDIR "$2"
            detailprint "Located the path to the game from the registry."
        ${else}
            strcpy $INSTDIR "$0"
        ${endif}
    ${endif}
!macroend

!macro FETCH_TOTAL_DOWNLOAD_SIZE SECTION_ID
    var /global asset_count 
    var /global asset_index
    var /global asset_name
    var /global asset_size
    var /global total_size

    gettempfilename $8
    inetc::get "https://api.github.com/repos/Vadim-Kamalov/GAdmin/releases/latest" "$8" /end
    pop $0

    ${if} $0 != "OK"
        detailprint "Failed to fetch GitHub release info: $0"
        return
    ${endif}

    nsjson::set /file "$8"
    pop $0

    ${if} $0 != "OK"
        detailprint "Failed to parse JSON response."
        delete $8
        return
    ${endif}
    
    nsjson::get /count "assets" /end
    pop $asset_count
    intop $asset_count $asset_count - 1
    strcpy $total_size 0

    ${for} $asset_index 0 $asset_count
        nsjson::get "assets" /index $asset_index "name" /end
        pop $asset_name
        ${if} $asset_name == "gadmin.dll"
        ${orif} $asset_name == "gadmin-loader.asi"
            nsjson::get "assets" /index $asset_index "size" /end
            pop $asset_size
            intop $asset_size $asset_size / 1024
            intop $total_size $total_size + $asset_size
        ${endif}
    ${next}

    delete $8
    detailprint "Fetched the total download size for the files."
    sectionsetsize ${SECTION_ID} $total_size
!macroend

!macro OPTIONAL_COMPONENT_SECTION SECTION_NAME COMPONENT_URL
    section /o "${SECTION_NAME}"
        gettempfilename $8
        inetc::get "${COMPONENT_URL}" "$8" /end
        pop $0

        ${if} $0 == "OK"
            execwait "$8"
            delete $8
            detailprint "Component ${SECTION_NAME} has been installed."
        ${else}
            detailprint "Failed to download ${SECTION_NAME} component."
        ${endif}
    sectionend
!macroend
