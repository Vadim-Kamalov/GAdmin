target_include_directories(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/
    ${kthook_SOURCE_DIR}/include/
    ${ctre_SOURCE_DIR}/include/
    ${imgui_markdown_SOURCE_DIR}/
)

target_sources(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    ${imgui_SOURCE_DIR}/imgui_demo.cpp
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_win32.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_dx9.cpp
)

set(LIBRARIES_LINKAGE d3d9 d3dx9 kthook gdi32 dwmapi common dbghelp nlohmann_json::nlohmann_json ctre::ctre)
