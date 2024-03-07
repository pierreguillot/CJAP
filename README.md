# CJAP 

The CJAP (CMake JUCE Audio Plug-In) repository contains a collection of CMake tools (scripts and functions) to facilitate the development of audio plug-ins with the JUCE framework. The tools are split into several sections for generating compiler warnings, debugging, testing, codesigning, packaging and formatting. All the features can be included using the main file cjap.cmake and enabled, disabled and configured using the options and variables defined at the top of the corresponding CMake files.

## Warnings
The warnings section enables most of Xcode's warnings. It can be used in addition to `juce::juce_recommended_warning_flags`.

The option `CJAP_WARNINGS_ENABLED` enables the section (default: ON). 

Other generators and compilers may be supported in the future.

## Debug
The debug section defines the program that will be used to run the plug-in in Xcode for each plug-in format. This can be used in addition to `JUCE_COPY_PLUGIN_AFTER_BUILD` to ensure the plug-in are well installed in the program search path. If this copy option is enabled, the VST3 debugging program is Cubase and the target is an ARA plug-in, the plug-in is automatically copied to ARA specific directory for Cubase.

The option `CJAP_DEBUG_ENABLED` enables the section (default: ON).  
Refer to `cjap_debug.cmake` for the variable to define the program to use for each plug-in format (defaul:t Reaper for VST3, Logic for AudioUnits and Pro Tools Developer for AAX).

Other generators may be supported in the future.

## Test
The test section generates automatic tests for the plug-in using ctest (the CMake test driver program). The section downloads and/or compiles the binaries, creates several scripts to generates tests with [pluginval](https://github.com/Tracktion/pluginval) by Traktion, auval command-line tool by Apple (AudioUnits only), VST3 Validator by Steinberg (VST3 only), AAX Validator by AVID (AAX only), ARA Test Host by Celemony (ARA only). 

The option `CJAP_TEST_ENABLED` enables the section (default: ON).  
The AAX validator requires to specify the URL to download the binaries.  
Refer to `cjap_test.cmake` for the variable to enable or disable specific tests and adapt the tests to your need.

AAX validator may be improved and support Windows in the future.

## Format
The format section generates two targets that respectively check and apply the formatting of the source code. The formatting is based on [clang-format](https://clang.llvm.org/docs/ClangFormat.html) that should be installed on yout system. The `.clang-format` file should be installed at the root of the files to format.

The option `CJAP_FORMAT_ENABLED` enables the section (default: OFF).  
The variable `CJAP_FORMAT_FILES` is used to define the files to format.  
Refer to `cjap_format.cmake` for further information.

The definition of the style may be improved in the future to support better location and presets. 

## Package
The packake section generates a target that create package installer for the plug-ins. The target is based on the native tools pkgbuild and productbuild for macOS, [Inno Setup](https://jrsoftware.org/isinfo.php) on Windows and only bash on Linux. 

The option `CJAP_PACKAGE_ENABLED` enables the section (default: ON).  
Refer to `cjap_package.cmake` for further information and to adapt the packaging to your need.  
The package target is included in the ALL targets.
The package can be code-signed and notarized automatically, please refer to the code-sign section.

## Codesign
The packake section control variable and generates a post command to code-sign the plug-ins. Code-signing is supported on macOS for all the plug-in formats and only for AAX on Windows. The AAX code-signing requires a PACE subcription. 

If the package section is enabled, a sign target is generated to code-sign (and notarize) the package on macOS and Windows. This target is included in the ALL targets.
When notarizing the package on macOS, the log file containing the info, warning and error is created at `${CMAKE_CURRENT_BINARY_DIR}/Package/info.log`.

The option `CJAP_CODESIGN_ENABLED` enables the section (default: OFF).  
Refer to `cjap_codesign.cmake` for further information and to adapt the code-signing to your need.  

## Example

```cmake
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
set(CJAP_CODESIGN_WINDOWS_KEYPASSWORD "MyCodeSigningPassword" CACHE STRING "The password of the Windows (.p12) certificate files")
set(CJAP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT "Developer ID Application" CACHE STRING "The Apple Developer ID Application certificate")
set(CJAP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT "Developer ID Installer" CACHE STRING "The Apple Developer ID Installer certificate")
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
include(CJAP/cjap.cmake)

# Add a new plug-in
juce_add_plugin(MyPluging
...
)

# Enable the CJAP features for the plug-in
target_enable_cjap(MyPluging)
```

# Credits

CJAP is developed by Pierre Guillot at [IRCAM IMR department](https://www.ircam.fr/). 
