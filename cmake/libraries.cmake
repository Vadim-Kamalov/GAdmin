include(FetchContent)

FetchContent_Declare(json   GIT_REPOSITORY https://github.com/nlohmann/json.git GIT_TAG 3cca3ad21012e289d34970e2e3060d255494c548)
FetchContent_Declare(imgui  GIT_REPOSITORY https://github.com/ocornut/imgui.git)
FetchContent_Declare(kthook GIT_REPOSITORY https://github.com/defaultzone/kthook.git)

FetchContent_Declare(ctre
    GIT_REPOSITORY https://github.com/hanickadot/compile-time-regular-expressions.git
    GIT_TAG aa31a2537e6563c1792e9bef0fe2be7122c4a8ee
)

FetchContent_MakeAvailable(json kthook imgui ctre)

target_include_directories(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/
    ${kthook_SOURCE_DIR}/include/
    ${ctre_SOURCE_DIR}/include/
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

set(LIBRARIES_LINKAGE d3d9 d3dx9 kthook gdi32 dwmapi wininet dbghelp nlohmann_json::nlohmann_json ctre::ctre)
