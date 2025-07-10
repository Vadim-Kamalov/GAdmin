# GAdmin - Plugin simplifying the work of administrators on the Gambit-RP
# Copyright (C) 2023-2025 The Contributors.
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

if(USE_EMBEDDED_MESSAGE_PACK)
    file(GLOB JSON_FILES "${CMAKE_SOURCE_DIR}/embed/*.json")
    find_program(MPK_EXECUTABLE NAMES mpk)
    
    if(NOT MPK_EXECUTABLE)
        message(FATAL_ERROR "mpk command not found. Please ensure msgpack-cli is installed and mpk is in your PATH.")
    endif()

    foreach(FILE ${JSON_FILES})
        get_filename_component(FILE_NAME ${FILE} NAME_WE)
        set(OUTPUT_FILE "${CMAKE_SOURCE_DIR}/embed/${FILE_NAME}.mpk")

        add_custom_command(
            OUTPUT ${OUTPUT_FILE}
            COMMAND mpk ${FILE} -m > ${OUTPUT_FILE}
            DEPENDS ${FILE}
            COMMENT "Building MessagePack file ${OUTPUT_FILE}"
        )

        list(APPEND GENERATED_MPK_FILES ${OUTPUT_FILE})
    endforeach()

    target_compile_definitions(${PROJECT_NAME} PRIVATE USE_EMBEDDED_MESSAGE_PACK=1)
    add_custom_target(process_json_files DEPENDS ${GENERATED_MPK_FILES})
    add_dependencies(${PROJECT_NAME} process_json_files)
endif()
