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

!include "MUI2.nsh"
!include "utils.nsi"

name                  "GAdmin"
outfile               "gadmin-web-installer.exe"
unicode               true
requestexecutionlevel admin

!define FILES_TO_DOWNLOAD     "https://github.com/Vadim-Kamalov/GAdmin/releases/latest/download"
!define COMPONENTS_TO_INSTALL "https://github.com/defaultzone/nsis-components/raw/refs/heads/main/windows-components-installers"
!define MUI_ABORTWARNING

section "-Main Application Files" SECTION_MAIN
    detailprint "Downloading files from the latest release..."
    inetc::get "${FILES_TO_DOWNLOAD}/gadmin.dll" "$INSTDIR\gadmin.dll" /banner /end
    pop $0
    detailprint "gadmin.dll download result: $0"
    inetc::get "${FILES_TO_DOWNLOAD}/gadmin-loader.asi" "$INSTDIR\gadmin-loader.asi" /banner /end
    pop $0
    detailprint "gadmin-loader.asi download result: $0"
sectionend

!insertmacro OPTIONAL_COMPONENT_SECTION "DirectX Web Installer" "${COMPONENTS_TO_INSTALL}/dxwebsetup.exe"
!insertmacro OPTIONAL_COMPONENT_SECTION "Microsoft Visual C++ Redistributable x86 (2010)" "${COMPONENTS_TO_INSTALL}/vcredist_x86_2010.exe"
!insertmacro OPTIONAL_COMPONENT_SECTION "Microsoft Visual C++ Redistributable x86 (2013)" "${COMPONENTS_TO_INSTALL}/vcredist_x86_2013.exe"
!insertmacro OPTIONAL_COMPONENT_SECTION "Microsoft Visual C++ Redistributable x86 (2015)" "${COMPONENTS_TO_INSTALL}/vcredist_x86_2015.exe"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "../LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "English"

function .oninit
    !insertmacro MUI_LANGDLL_DISPLAY
    !insertmacro SET_INSTALL_DIRECTORY
    !insertmacro FETCH_TOTAL_DOWNLOAD_SIZE ${SECTION_MAIN}
functionend
