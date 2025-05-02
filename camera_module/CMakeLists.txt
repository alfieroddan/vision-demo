cmake_minimum_required(VERSION 3.10)
project(camera_module)

# Set C++ standard to 11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Allow user to specify FlyCapture2 root path manually
set(FLYCAPTURE2_ROOT "" CACHE PATH "Path to FlyCapture2 SDK root directory")

# If the user hasn't specified the path, try to set a default one
if(NOT FLYCAPTURE2_ROOT)
    if(WIN32)
        set(FLYCAPTURE2_ROOT "C:/Program Files/Point Grey Research/FlyCapture2" CACHE PATH "Path to FlyCapture2 SDK root directory")
    elseif(UNIX)
        # Typical path for Linux (update as needed)
        set(FLYCAPTURE2_ROOT "/usr/local/FlyCapture2" CACHE PATH "Path to FlyCapture2 SDK root directory")
    endif()
endif()

# Debugging: Print the FLYCAPTURE2_ROOT path
message(STATUS "FLYCAPTURE2_ROOT is set to: ${FLYCAPTURE2_ROOT}")

# Ensure the FlyCapture2 SDK root directory exists
if(NOT EXISTS "${FLYCAPTURE2_ROOT}")
    message(FATAL_ERROR "FlyCapture2 SDK not found at specified location: ${FLYCAPTURE2_ROOT}")
endif()

# Platform-specific settings
if(WIN32)
    set(FLYCAPTURE2_INCLUDE_DIR "${FLYCAPTURE2_ROOT}/include")
    set(FLYCAPTURE2_LIBRARY_DIR "${FLYCAPTURE2_ROOT}/lib64")  # Corrected path to lib64
elseif(UNIX)
    set(FLYCAPTURE2_INCLUDE_DIR "${FLYCAPTURE2_ROOT}/include")
    set(FLYCAPTURE2_LIBRARY_DIR "${FLYCAPTURE2_ROOT}/lib")
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Debugging: Print the include and library directory paths
message(STATUS "FLYCAPTURE2_INCLUDE_DIR is: ${FLYCAPTURE2_INCLUDE_DIR}")
message(STATUS "FLYCAPTURE2_LIBRARY_DIR is: ${FLYCAPTURE2_LIBRARY_DIR}")

# Ensure that the library directory exists
if(NOT EXISTS "${FLYCAPTURE2_LIBRARY_DIR}")
    message(FATAL_ERROR "Library directory does not exist: ${FLYCAPTURE2_LIBRARY_DIR}")
endif()

# Debug: List files in the library directory
file(GLOB FLYCAPTURE2_LIBRARIES LIST_DIRECTORIES false RELATIVE "${FLYCAPTURE2_LIBRARY_DIR}" "*.so*")
message(STATUS "Found libraries in ${FLYCAPTURE2_LIBRARY_DIR}: ${FLYCAPTURE2_LIBRARIES}")

# Try to find the FlyCapture2 library in UNIX systems
if(UNIX)
    # Look for different possible library names (e.g., flycapture, flycapture2, etc.)
    find_library(FLYCAPTURE2_LIBRARY
        NAMES flycapture2 flycapture flycapture2_v100  # Adjust to the appropriate version name if needed
        PATHS "${FLYCAPTURE2_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
elseif(WIN32)
    # Windows-specific library finding (example, adjust for your exact version)
    find_library(FLYCAPTURE2_LIBRARY
        NAMES FlyCapture2_v100  # Adjust to the appropriate version name if needed
        PATHS "${FLYCAPTURE2_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

# Check if the library was found
if(NOT FLYCAPTURE2_LIBRARY)
    message(FATAL_ERROR "FlyCapture2 library not found in ${FLYCAPTURE2_LIBRARY_DIR}")
else()
    message(STATUS "Found FlyCapture2 library: ${FLYCAPTURE2_LIBRARY}")
endif()

# Source files for the project
add_executable(Main
    main.cpp
    stdafx.cpp
)

# Include directories
target_include_directories(Main PRIVATE "${FLYCAPTURE2_INCLUDE_DIR}")

# Link directories and libraries
target_link_directories(Main PRIVATE "${FLYCAPTURE2_LIBRARY_DIR}")
target_link_libraries(Main PRIVATE "${FLYCAPTURE2_LIBRARY}")
