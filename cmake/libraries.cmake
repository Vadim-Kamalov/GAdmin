include(FetchContent)

FetchContent_Declare(json   URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz)
FetchContent_Declare(imgui  GIT_REPOSITORY https://github.com/ocornut/imgui.git)
FetchContent_Declare(kthook GIT_REPOSITORY https://github.com/kin4stat/kthook.git)
FetchContent_MakeAvailable(json kthook imgui)

target_include_directories(${PROJECT_NAME} PUBLIC ${imgui_SOURCE_DIR}/ ${kthook_SOURCE_DIR}/include/)
target_sources(${PROJECT_NAME} PUBLIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    ${imgui_SOURCE_DIR}/imgui_demo.cpp
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_win32.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_dx9.cpp
)

set(LIBRARIES_LINKAGE d3d9 d3dx9 gdi32 dwmapi kthook wininet  nlohmann_json::nlohmann_json)
