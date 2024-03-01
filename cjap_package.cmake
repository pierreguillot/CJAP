# - CMake JUCE Audio Plug-in Packaging
#
# This file contains functions for packaging the plug-ins. 
# ToDo: Add support for autoprogram and autodesktop for standalone with Windows ISS
# ToDo: Add support user directory for standalone on Linux
# ToDo: Add support user directory on macOS

include(${CMAKE_CURRENT_LIST_DIR}/cjap_codesign.cmake)

# Option for enabling the the debugging.
option(CJAP_PACKAGE_ENABLED "Enable the plug-in packaging" ON)

get_directory_property(CJAP_PACKAGE_JUCE_COMPANY_NAME DIRECTORY ${CMAKE_SOURCE_DIR} JUCE_COMPANY_NAME)
get_directory_property(CJAP_PACKAGE_JUCE_COMPANY_WEBSITE DIRECTORY ${CMAKE_SOURCE_DIR} JUCE_COMPANY_WEBSITE)

# Variable to configure the packaging.
set(CJAP_PACKAGE_PROJECT_NAME "${CMAKE_PROJECT_NAME}" CACHE STRING "The name of the package")
set(CJAP_PACKAGE_PROJECT_VERSION "${CMAKE_PROJECT_VERSION}" CACHE STRING "The version of the package")
set(CJAP_PACKAGE_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/install" CACHE PATH "The directory where the installation program will be created")
set(CJAP_PACKAGE_COMPANY_NAME "${CJAP_PACKAGE_JUCE_COMPANY_NAME}" CACHE PATH "The name of the company")
set(CJAP_PACKAGE_COMPANY_WEBSITE "${CJAP_PACKAGE_JUCE_COMPANY_WEBSITE}" CACHE PATH "The website of the company")
set(CJAP_PACKAGE_COMPANY_LOGO_BMP_PATH "" CACHE PATH "The path to the company logo bmp file")
set(CJAP_PACKAGE_COMPANY_LOGO_PNG_PATH "" CACHE PATH "The path to the company logo png file")
set(CJAP_PACKAGE_INSTALL_FILE_PATH "" CACHE PATH "The path to the install text file")
set(CJAP_PACKAGE_LICENSE_FILE_PATH "" CACHE PATH "The path to the license text file")
set(CJAP_PACKAGE_CREDITS_FILE_PATH "" CACHE PATH "The path to the credits text file")
set(CJAP_PACKAGE_CHANGELOG_FILE_PATH "" CACHE PATH "The path to the change log text file")
set(CJAP_PACKAGE_WINDOWS_APP_ID "${CJAP_CODESIGN_PACE_WCGUID}" CACHE PATH "The Windows application ID (FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFFF)")

# Internal
set(CJAP_PACKAGE_BUILD_PATH "${CMAKE_CURRENT_BINARY_DIR}/Package")

if(CJAP_PACKAGE_PROJECT_NAME STREQUAL "")
  message(WARNING "CJAP_PACKAGE_PROJECT_NAME is undefined")
  set(CJAP_PACKAGE_ENABLED OFF)
endif()

if(CJAP_PACKAGE_PROJECT_VERSION STREQUAL "")
  message(WARNING "CJAP_PACKAGE_PROJECT_VERSION is undefined")
  set(CJAP_PACKAGE_ENABLED OFF)
endif()

if(CJAP_PACKAGE_COMPANY_NAME STREQUAL "")
  message(WARNING "CJAP_PACKAGE_COMPANY_NAME is undefined")
  set(CJAP_PACKAGE_ENABLED OFF)
endif()

if(CJAP_PACKAGE_COMPANY_WEBSITE STREQUAL "")
  message(WARNING "CJAP_PACKAGE_COMPANY_WEBSITE is undefined")
  set(CJAP_PACKAGE_ENABLED OFF)
endif()

if(WIN32)
  if(CJAP_PACKAGE_WINDOWS_APP_ID STREQUAL "")
    message(WARNING "CJAP_PACKAGE_WINDOWS_APP_ID is undefined")
    set(CJAP_PACKAGE_ENABLED OFF)
  endif()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/cjap_package_linux.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_package_windows.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cjap_package_apple.cmake)

# - Enables the packaging for the target on all plateforms
function(target_enable_cjap_package target)
  if(CJAP_PACKAGE_ENABLED)
    add_dependencies(${CJAP_PACKAGE_PROJECT_NAME}_Package ${target}_All)
    target_enable_linux_cjap_package(${target})
    target_enable_windows_cjap_package(${target})
    target_enable_apple_cjap_package(${target})
  endif()
endfunction(target_enable_cjap_package)

