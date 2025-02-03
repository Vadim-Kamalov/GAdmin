if (NOT ${CMAKE_C_COMPILER_ID} STREQUAL "GNU" OR NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    message(FATAL_ERROR "The C or C++ compiler is not GCC. Please set the C and C++ compilers to GCC.")
endif()

set(CMAKE_CXX_FLAGS_DEBUG   "-g -O0")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

target_compile_options(${PROJECT_NAME} PRIVATE -ffunction-sections -fdata-sections -fmerge-all-constants)
target_link_options(${PROJECT_NAME} PRIVATE -Wl,--gc-sections -ffast-math -static -fno-stack-protector -Wl,--no-insert-timestamp)
target_link_options(${PROJECT_NAME} PRIVATE -Wl,--disable-runtime-pseudo-reloc -Wl,--large-address-aware)
   
if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_link_options(${PROJECT_NAME} PRIVATE -Wl,--strip-all -Wl,--exclude-all-symbols)
endif()

target_compile_options(${PROJECT_NAME} PRIVATE -fno-rtti) # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=110572
target_link_options(${PROJECT_NAME} PRIVATE -static-libgcc -static-libstdc++ -lstdc++exp)
