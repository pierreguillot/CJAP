# CJAP 

The CJAP (CMake JUCE Audio Plug-In) repository contains a collection of CMake tools (scripts and functions) to facilitate the development of audio plug-ins with the JUCE framework. The tools are split into several categories for generating compiler warnings, debugging, testing, codesigning, packaging and formatting. All the features can be included using the main file jap.cmake and enabled, disabled and configured using the options and variables defined at the top of the corresponding CMake files.

```cmake
# Xcode Code Sign options (will initialize default variables for codesigning)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Developer ID Application" CACHE STRING "The Apple code sign identity")
set(CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "FFFFFFFFFF" CACHE STRING "The Apple development team identifier")

# JUCE options (will initialize default variables for packaging)
set_directory_properties(PROPERTIES JUCE_COMPANY_COPYRIGHT "Copyright 2024 Ircam. All rights reserved")
set_directory_properties(PROPERTIES JUCE_COMPANY_NAME "Ircam")
set_directory_properties(PROPERTIES JUCE_COMPANY_WEBSITE "https://www.ircam.fr/")

# Main CJAP options for testing
set(CJAP_TEST_FAST_ENABLED ON)
set(CJAP_TEST_PLUGINVAL_SKIP_GUI_TESTS ON)
set(CJAP_TEST_ARA_SDK_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ARA_SDK" CACHE PATH "The path where the ARA SDK is located")
set(CJAP_TEST_AAXVALIDATOR_URL_APPLE_arm64 "https://myserver.fr/aax-developer-tools-mac-arm64.tar.gz" CACHE PATH "The URL of the AAX validator for Apple arm64")
set(CJAP_TEST_AAXVALIDATOR_URL_APPLE_x86_64 "https://myserver.fr/aax-developer-tools-mac-x86_64.tar.gz" CACHE PATH "The URL of the AAX validator for Apple x86_64")

# Main CJAP options for codesigning
set(CJAP_CODESIGN_ENABLED ON)
set(CJAP_CODESIGN_WINDOWS_KEYFILE "${CMAKE_CURRENT_SOURCE_DIR}/Code-Signing-Certificate.p12" CACHE PATH "The Windows (.p12) certificate file")
set(CJAP_CODESIGN_WINDOWS_CERTFILE "${CMAKE_CURRENT_SOURCE_DIR}/Code-Signing-Certificate.pfx" CACHE PATH "The Windows (.pfx) certificate file")
set(CJAP_CODESIGN_WINDOWS_KEYPASSWORD "MyCodeSigningPassword" CACHE STRING "The password of the Windows(.p12) certificate file")
set(CJAP_CODESIGN_PACE_EMAIL "john.doe@ircam.fr" CACHE STRING "The PACE developer email")
set(CJAP_CODESIGN_PACE_WCGUID "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF" CACHE STRING "The PACE GUID")
set(CJAP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER "MyInstallerProfile" CACHE STRING "The Apple keychain profile for installer")

# Main CJAP options for packaging
set(CJAP_PACKAGE_COMPANY_LOGO_BMP_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Resource/Ircam.bmp" CACHE PATH "The path to the company logo bmp file")
set(CJAP_PACKAGE_COMPANY_LOGO_PNG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Resource/Ircam.png" CACHE PATH "The path to the company logo bmp file")
set(CJAP_PACKAGE_INSTALL_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Resource/Install.txt" CACHE PATH "The path to the install text file")
set(CJAP_PACKAGE_CREDITS_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Resource/Credits.txt" CACHE PATH "The path to the credits text file")
set(CJAP_PACKAGE_CHANGELOG_FILE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Resource/ChangeLog.txt" CACHE PATH "The path to the change log text file")
set(CJAP_PACKAGE_WINDOWS_APPID "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF" CACHE STRING "The PACE GUID")
set(CJAP_PACKAGE_INSTALL_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}" CACHE STRING "The directory where the installation program will be created")

# Main CJAP options for formatting
set(CJAP_FORMAT_ENABLED ON)
file(GLOB_RECURSE CJAP_FORMAT_FILES ${CMAKE_CURRENT_SOURCE_DIR}/Source/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/Source/*.h)

# Add JUCE
add_subdirectory(JUCE)

# Add CJAP
include(CJAP/jap.cmake)

# Add a new plug-in
juce_add_plugin(MyPluging
...
)

# Enable the CJAP features for the plug-in
target_enable_cjap(MyPluging)
```

JAP is developed by Pierre Guillot at [IRCAM IMR department](https://www.ircam.fr/). 
