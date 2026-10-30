cmake_minimum_required(VERSION 3.22.1)
project(neuro_dsp_native LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# High-Performance Compiler Optimization Flags for Real-Time DSP
if(MSVC)
    # Avoid /O2 in Debug builds to prevent conflict with MSVC /RTC1
    add_compile_options(
        $<$<CONFIG:Release>:/O2>
        $<$<CONFIG:Release>:/fp:fast>
        $<$<CONFIG:Profile>:/O2>
        /W4
    )
else()
    add_compile_options(
        -O3
        -ffast-math
        -fno-rtti
        -fno-exceptions
        -Wall
        -Wextra
        -fvisibility=hidden
        -fvisibility-inlines-hidden
    )

    # ARM64 SIMD (NEON) vectorization for Android
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
        add_compile_options(-march=armv8-a+simd)
    endif()
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

set(DSP_SOURCES
    src/biquad_filter.cpp
    src/phase_vocoder.cpp
    src/dsp_engine.cpp
    src/dsp_ffi_api.cpp
)

# Shared library for dynamic loading via Dart FFI and Android JNI
add_library(neuro_dsp_native SHARED
    ${DSP_SOURCES}
)

target_include_directories(neuro_dsp_native PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Link math library on POSIX/Android
if(UNIX AND NOT APPLE)
    target_link_libraries(neuro_dsp_native PRIVATE m)
endif()
