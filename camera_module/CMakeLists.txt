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

if(WIN32)
    # On Windows: manual paths (you can keep this or adapt as needed)
    set(GSTREAMER_ROOT "" CACHE PATH "Path to GStreamer root directory")
    if(NOT GSTREAMER_ROOT)
        file(TO_CMAKE_PATH "$ENV{ProgramFiles}/gstreamer/1.0/msvc_x86_64" GSTREAMER_ROOT)
    endif()

    set(GSTREAMER_INCLUDE_DIRS
        "${GSTREAMER_ROOT}/include/gstreamer-1.0"
        "${GSTREAMER_ROOT}/include"
        "${GSTREAMER_ROOT}/include/glib-2.0"
        "${GSTREAMER_ROOT}/lib/glib-2.0/include"
    )
    set(GSTREAMER_LIBRARY_DIRS "${GSTREAMER_ROOT}/lib")
    set(GSTREAMER_LIBS
        gstreamer-1.0
        gstapp-1.0
        gstbase-1.0
        gobject-2.0
        glib-2.0
    )
endif()

# ===================== Executable Setup =====================
add_executable(Main
    main.cpp
    stdafx.cpp
)

# FlyCapture2 includes and libs
target_include_directories(Main PRIVATE "${FLYCAPTURE2_INCLUDE_DIR}")
target_link_directories(Main PRIVATE "${FLYCAPTURE2_LIBRARY_DIR}")

# Link FlyCapture2 lib
target_link_libraries(Main PRIVATE "${FLYCAPTURE2_LIBRARY}")

# ===================== Unix pkg-config for GStreamer and GLib =====================
if(UNIX)
    find_package(PkgConfig REQUIRED)

    # Find GLib
    pkg_check_modules(GLIB REQUIRED glib-2.0)
    message(STATUS "GLIB_INCLUDE_DIRS: ${GLIB_INCLUDE_DIRS}")

    # Find GStreamer core, app, and base libs
    pkg_check_modules(GSTREAMER REQUIRED gstreamer-1.0)
    pkg_check_modules(GSTREAMER_APP REQUIRED gstreamer-app-1.0)
    pkg_check_modules(GSTREAMER_BASE REQUIRED gstreamer-base-1.0)

    message(STATUS "GSTREAMER_INCLUDE_DIRS: ${GSTREAMER_INCLUDE_DIRS}")
    message(STATUS "GSTREAMER_APP_INCLUDE_DIRS: ${GSTREAMER_APP_INCLUDE_DIRS}")
    message(STATUS "GSTREAMER_BASE_INCLUDE_DIRS: ${GSTREAMER_BASE_INCLUDE_DIRS}")

    # Combine include dirs
    set(ALL_GSTREAMER_INCLUDE_DIRS
        ${GSTREAMER_INCLUDE_DIRS}
        ${GSTREAMER_APP_INCLUDE_DIRS}
        ${GSTREAMER_BASE_INCLUDE_DIRS}
        ${GLIB_INCLUDE_DIRS}
    )

    # Combine libs
    set(ALL_GSTREAMER_LIBS
        ${GSTREAMER_LIBRARIES}
        ${GSTREAMER_APP_LIBRARIES}
        ${GSTREAMER_BASE_LIBRARIES}
        ${GLIB_LIBRARIES}
    )

    target_include_directories(Main PRIVATE ${ALL_GSTREAMER_INCLUDE_DIRS})
    target_link_libraries(Main PRIVATE ${ALL_GSTREAMER_LIBS})
endif()

# ===================== Windows manual GStreamer includes/libs =====================
if(WIN32)
    target_include_directories(Main PRIVATE ${GSTREAMER_INCLUDE_DIRS})
    target_link_directories(Main PRIVATE ${GSTREAMER_LIBRARY_DIRS})
    target_link_libraries(Main PRIVATE ${GSTREAMER_LIBS})
endif()