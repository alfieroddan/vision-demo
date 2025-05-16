cmake_minimum_required(VERSION 3.10)
project(camera_module)

# Set C++ standard to 11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ===================== FlyCapture2 Setup =====================
set(FLYCAPTURE2_ROOT "" CACHE PATH "Path to FlyCapture2 SDK root directory")

if(NOT FLYCAPTURE2_ROOT)
    if(WIN32)
        file(TO_CMAKE_PATH "$ENV{ProgramFiles}/Point Grey Research/FlyCapture2" FLYCAPTURE2_ROOT)
    elseif(UNIX)
        set(FLYCAPTURE2_ROOT "/usr/local/FlyCapture2")
    endif()
endif()

message(STATUS "FLYCAPTURE2_ROOT: ${FLYCAPTURE2_ROOT}")

if(NOT EXISTS "${FLYCAPTURE2_ROOT}")
    message(FATAL_ERROR "FlyCapture2 SDK not found at: ${FLYCAPTURE2_ROOT}")
endif()

set(FLYCAPTURE2_INCLUDE_DIR "${FLYCAPTURE2_ROOT}/include")
if(WIN32)
    set(FLYCAPTURE2_LIBRARY_DIR "${FLYCAPTURE2_ROOT}/lib64")
else()
    set(FLYCAPTURE2_LIBRARY_DIR "${FLYCAPTURE2_ROOT}/lib")
endif()

message(STATUS "FLYCAPTURE2_INCLUDE_DIR: ${FLYCAPTURE2_INCLUDE_DIR}")
message(STATUS "FLYCAPTURE2_LIBRARY_DIR: ${FLYCAPTURE2_LIBRARY_DIR}")

if(NOT EXISTS "${FLYCAPTURE2_LIBRARY_DIR}")
    message(FATAL_ERROR "FlyCapture2 library directory not found: ${FLYCAPTURE2_LIBRARY_DIR}")
endif()

# Find FlyCapture2 library
if(WIN32)
    find_library(FLYCAPTURE2_LIBRARY
        NAMES FlyCapture2_v100
        PATHS "${FLYCAPTURE2_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
else()
    find_library(FLYCAPTURE2_LIBRARY
        NAMES flycapture2 flycapture flycapture2_v100
        PATHS "${FLYCAPTURE2_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
endif()

if(NOT FLYCAPTURE2_LIBRARY)
    message(FATAL_ERROR "FlyCapture2 library not found in ${FLYCAPTURE2_LIBRARY_DIR}")
endif()

message(STATUS "Found FlyCapture2 library: ${FLYCAPTURE2_LIBRARY}")

# ===================== GStreamer Setup =====================
set(GSTREAMER_ROOT "" CACHE PATH "Path to GStreamer root directory")

if(NOT GSTREAMER_ROOT)
    if(WIN32)
        file(TO_CMAKE_PATH "$ENV{ProgramFiles}/gstreamer/1.0/msvc_x86_64" GSTREAMER_ROOT)
    elseif(UNIX)
        set(GSTREAMER_ROOT "/usr")
    endif()
endif()

set(GSTREAMER_INCLUDE_DIRS
    "${GSTREAMER_ROOT}/include/gstreamer-1.0"
    "${GSTREAMER_ROOT}/include"
    "${GSTREAMER_ROOT}/include/glib-2.0"
    "${GSTREAMER_ROOT}/lib/glib-2.0/include"
)
set(GSTREAMER_LIBRARY_DIRS "${GSTREAMER_ROOT}/lib")

message(STATUS "GStreamer include dirs: ${GSTREAMER_INCLUDE_DIRS}")
message(STATUS "GStreamer library dirs: ${GSTREAMER_LIBRARY_DIRS}")

set(GSTREAMER_LIBS
    gstreamer-1.0
    gstapp-1.0
    gstbase-1.0
    gobject-2.0
    glib-2.0
)

# ===================== Executable Setup =====================
add_executable(Main
    main.cpp
    stdafx.cpp
)

# Include directories
target_include_directories(Main PRIVATE
    ${GSTREAMER_INCLUDE_DIRS}
    "${FLYCAPTURE2_INCLUDE_DIR}"
)

# Library directories
target_link_directories(Main PRIVATE
    ${GSTREAMER_LIBRARY_DIRS}
    "${FLYCAPTURE2_LIBRARY_DIR}"
)

# Link libraries
target_link_libraries(Main PRIVATE
    ${GSTREAMER_LIBS}
    "${FLYCAPTURE2_LIBRARY}"
)
