include(FetchContent)

FetchContent_Declare(json   URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz)
FetchContent_Declare(imgui  GIT_REPOSITORY https://github.com/ocornut/imgui.git)
FetchContent_Declare(kthook GIT_REPOSITORY https://github.com/kin4stat/kthook.git)

FetchContent_Declare(ctre
    GIT_REPOSITORY https://github.com/hanickadot/compile-time-regular-expressions.git

    # fix for changes in comparison in old compilers, failing in bug introduced lately (branch: main)
    GIT_TAG aa31a2537e6563c1792e9bef0fe2be7122c4a8ee
)

FetchContent_Declare(imgui_markdown
    GIT_REPOSITORY https://github.com/enkisoftware/imgui_markdown.git

    # Added dynamic font support to MarkdownHeadingFormat (branch: dev)
    GIT_TAG 3914f24ddd3a6369308efd48dfcace3bc6096783
)

FetchContent_MakeAvailable(json kthook imgui ctre imgui_markdown)
