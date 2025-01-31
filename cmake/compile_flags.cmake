if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS_DEBUG   "-g -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3")

    target_compile_options(${PROJECT_NAME} PRIVATE -ffunction-sections -fdata-sections -fmerge-all-constants)
    target_link_options(${PROJECT_NAME} PRIVATE -Wl,--gc-sections -ffast-math -static -fno-stack-protector -Wl,--no-insert-timestamp)
    target_link_options(${PROJECT_NAME} PRIVATE -Wl,--disable-runtime-pseudo-reloc -Wl,--large-address-aware)
   
    if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_link_options(${PROJECT_NAME} PRIVATE -Wl,--strip-all -Wl,--exclude-all-symbols)
    endif()

    target_compile_options(${PROJECT_NAME} PRIVATE -fno-rtti) # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=110572
	
    if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        target_link_options(${PROJECT_NAME} PRIVATE -static-libgcc -static-libstdc++ -lstdc++exp)
    else()
        target_compile_options(${PROJECT_NAME} PRIVATE -flto=thin)
        target_link_options(${PROJECT_NAME} PRIVATE -Wl,--thinlto-cache-dir=lto_cache)
    endif()
endif()

# TODO: MSVC support?
